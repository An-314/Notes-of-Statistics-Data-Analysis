#include "../include/HW6Common.h"

// Run from HW/6: root -l -b -q 'macros/ex4_4.C()'
void ex4_4(const char *output = "../pic/6", long long toys = 2000000,
           const char *dataPath = "data/ex4_4.csv") {
  using namespace hw6;
  if (toys <= 1) throw std::runtime_error("At least two pseudoexperiments required");
  initialize();
  const auto bins = loadData(dataPath);
  const int nBins = static_cast<int>(bins.size());
  const std::array<unsigned, 2> seeds{{20261101U, 20261102U}};
  std::vector<double> counts;
  std::array<std::vector<double>, 2> expected;
  for (const auto &bin : bins) {
    counts.push_back(bin.n);
    for (int model = 0; model < 2; ++model)
      expected[model].push_back(bin.expected[model]);
  }
  Output files(output, "4-4");
  files.stats << "model,total_expected,Q_obs,p_chi2,toys,seed,tail,p_mc,mc_se,mean_Q,var_Q,variance_exact,underflow,overflow\n";
  files.meta << "Input CSV: " << dataPath << "\nBins " << nBins
             << "\nObserved total " << std::accumulate(counts.begin(), counts.end(), 0.)
             << "\nIndependent Poisson bin counts; total NOT fixed.\n"
             << "No rescaling, fitted parameters, or discarded zero-count bins.\n"
             << "Density range [0,120], bin width 0.5; normalization uses all toys.\n"
             << "Tail counts include toys outside plotted range.\n";

  TH1D data("data", "Exercise 4.4;x;Events / 0.5", nBins, 0, 10);
  TH1D theory1("theory1", "", nBins, 0, 10), theory2("theory2", "", nBins, 0, 10);
  std::array<TH1D *, 2> predictions{{&theory1, &theory2}};
  std::array<double, 2> observed{};
  // BEGIN 4.4a
  for (int i = 0; i < nBins; ++i) {
    data.SetBinContent(i + 1, counts[i]);
    data.SetBinError(i + 1, std::sqrt(counts[i]));
    for (int model = 0; model < 2; ++model)
      predictions[model]->SetBinContent(i + 1, expected[model][i]);
  }
  for (int model = 0; model < 2; ++model)
    observed[model] = pearson(counts, expected[model]);
  // END 4.4a
  style(data); style(theory1); style(theory2);
  data.SetMarkerStyle(20); data.SetMarkerSize(.9); data.SetLineColor(kBlack);
  data.SetMinimum(0); data.SetMaximum(10.5);
  theory1.SetLineColor(kBlue + 1); theory2.SetLineColor(kRed + 1);
  TCanvas cData("cData", "Observed data and fixed theory expectations", 1100, 650);
  pad();
  data.Draw("E1P"); theory1.Draw("HIST SAME"); theory2.Draw("HIST SAME");
  data.Draw("E1P SAME");
  TLegend dataLegend(.60, .68, .93, .87);
  dataLegend.SetBorderSize(0); dataLegend.SetFillStyle(0); dataLegend.SetTextSize(.034);
  dataLegend.AddEntry(&data, "Data (#sqrt{n} errors)", "lep");
  dataLegend.AddEntry(&theory1, "theory1", "l");
  dataLegend.AddEntry(&theory2, "theory2", "l");
  dataLegend.Draw();
  files.save(cData, "4-4-data-theory");

  TCanvas cToys("cToys", "Calibrated Pearson statistic", 1400, 600);
  cToys.Divide(2, 1);
  std::vector<TH1D *> histograms;
  std::vector<TF1 *> approximations;
  std::vector<TLine *> cutLines;
  std::vector<TLegend *> legends;
  for (int model = 0; model < 2; ++model) {
    const std::string name = "theory" + std::to_string(model + 1);
    const auto &nu = expected[model];
    const double qObserved = observed[model];
    const double totalExpected = std::accumulate(nu.begin(), nu.end(), 0.0);
    const double pApprox = ROOT::Math::chisquared_cdf_c(qObserved, nBins);
    double varianceExact = 0;
    for (double mean : nu) varianceExact += 2 + 1 / mean;
    TRandom3 rng(seeds[model]);
    auto *hist = new TH1D(("q_" + name).c_str(),
                         (name + ";Q;Probability density").c_str(), 240, 0, 120);
    histograms.push_back(hist);
    long long tail = 0;
    long double sumQ = 0, sumQ2 = 0;
    std::vector<double> simulated(nBins);
    // BEGIN 4.4b
    for (long long experiment = 0; experiment < toys; ++experiment) {
      for (int i = 0; i < nBins; ++i)
        simulated[i] = rng.PoissonD(nu[i]);
      const double q = pearson(simulated, nu);
      hist->Fill(q);
      if (q >= qObserved - 1e-12) ++tail;
      sumQ += q;
      sumQ2 += q * q;
    }
    const double pMC = static_cast<double>(tail) / toys;
    const double mcSE = std::sqrt(pMC * (1 - pMC) / toys);
    // END 4.4b
    const double meanQ = static_cast<double>(sumQ / toys);
    const double varianceQ = static_cast<double>((sumQ2 - sumQ * sumQ / toys) / (toys - 1));
    const auto underflow = static_cast<long long>(hist->GetBinContent(0));
    const auto overflow = static_cast<long long>(hist->GetBinContent(hist->GetNbinsX() + 1));
    hist->Scale(1.0 / (toys * hist->GetBinWidth(1)));
    style(*hist); hist->SetLineColor(kBlue + 1); hist->SetMinimum(0);
    auto *approx = new TF1(("chi2_" + name).c_str(),
        [nBins](double *x, double *) { return ROOT::Math::chisquared_pdf(x[0], nBins); },
        0, 120, 0);
    approximations.push_back(approx);
    approx->SetNpx(1000); approx->SetLineColor(kGray + 2); approx->SetLineStyle(2);
    hist->SetMaximum(1.18 * std::max(hist->GetMaximum(), approx->GetMaximum()));
    cToys.cd(model + 1); pad();
    hist->Draw("HIST"); approx->Draw("SAME");
    auto *cut = new TLine(qObserved, 0, qObserved, .93 * hist->GetMaximum());
    cutLines.push_back(cut);
    cut->SetLineColor(kRed + 1); cut->SetLineWidth(2); cut->SetLineStyle(3); cut->Draw();
    auto *legend = new TLegend(.45, .67, .94, .88);
    legends.push_back(legend);
    legend->SetBorderSize(0); legend->SetFillStyle(0); legend->SetTextSize(.034);
    legend->AddEntry(hist, "Independent Poisson toys", "l");
    legend->AddEntry(approx, "#chi^{2}_{20} approximation", "l");
    std::ostringstream label;
    label << "Observed Q = " << std::fixed << std::setprecision(3) << qObserved;
    legend->AddEntry(cut, label.str().c_str(), "l"); legend->Draw();

    files.stats << name << ',' << totalExpected << ',' << qObserved << ',' << pApprox << ','
                << toys << ',' << seeds[model] << ',' << tail << ',' << pMC << ',' << mcSE << ','
                << meanQ << ',' << varianceQ << ',' << varianceExact << ','
                << underflow << ',' << overflow << '\n';
    files.meta << name << ": seed=" << seeds[model] << ", toys=" << toys
               << ", tail=" << tail << ", mean Q=" << meanQ << ", expected mean=" << nBins
               << ", variance Q=" << varianceQ << ", exact variance=" << varianceExact
               << ", underflow=" << underflow << ", overflow=" << overflow << '\n';
    std::cout << std::setprecision(12) << name << ": Q=" << qObserved
              << ", pMC=" << pMC << " +- " << mcSE << ", pChi2=" << pApprox
              << ", mean=" << meanQ << ", variance=" << varianceQ << '\n';
  }
  files.save(cToys, "4-4-pearson-toys");
  cToys.Clear();
  for (auto *object : legends) delete object;
  for (auto *object : cutLines) delete object;
  for (auto *object : approximations) delete object;
  for (auto *object : histograms) delete object;
}
