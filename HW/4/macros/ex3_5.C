#include "../include/HW4Common.h"

// Run from HW/4: root -l -b -q 'macros/ex3_5.C()'
void ex3_5(const char *output = "../pic/4") {
  using namespace hw4;
  initialize();
  Output files(output, "3-5");
  auto &stats = files.stats;
  auto save = [&](TCanvas &canvas, const char *name) {
    files.save(canvas, name);
  };

  // BEGIN 3.5
  const double sigma = .5;
  const std::array<double, 3> taus{{.05, 1, 5}};
  std::vector<TH1D *> exps;
  for (int j = 0; j < 3; ++j) {
    const double tau = taus[j];
    TRandom3 rng(seed + 5000 + j);
    auto h =
        new TH1D(Form("exg%d", j),
                 Form("tau = %.2g, sigma = 0.5;y;Events / bin", tau),
                 100, -2, 8 * tau + 1.5);
    Moments my;
    int negative = 0;
    for (int k = 0; k < 100000; ++k) {
      double t = rng.Exp(tau), x = rng.Gaus(0, sigma), y = t + x;
      h->Fill(y);
      my.add(y);
      if (y < 0)
        ++negative;
    }
    stats << "3.5-tau" << tau << ",100000," << my.mean() << ","
          << sqrt(my.variance()) << "," << negative / 100000.0 << ","
          << h->GetBinContent(0) + h->GetBinContent(101) << "\n";
    style(*h);
    h->SetLineColor(kBlue + 1);
    exps.push_back(h);
  }
  // END 3.5
  TCanvas c5("c5", "3.5", 1100, 1350);
  c5.Divide(1, 3);
  std::vector<TF1 *> exfuncs;
  for (int j = 0; j < 3; ++j) {
    c5.cd(j + 1);
    pad();
    auto h = exps[j];
    h->SetMinimum(0);
    h->Draw("HIST");
    auto f =
        new TF1(Form("exfunc%d", j),
                "[0]/(2*[1])*exp([2]*[2]/(2*[1]*[1])-x/"
                "[1])*TMath::Erfc(([2]*[2]/[1]-x)/(sqrt(2)*[2]))",
                -2, 8 * taus[j] + 1.5);
    f->SetParameters(100000 * h->GetBinWidth(1), taus[j], sigma);
    f->SetNpx(1000);
    f->SetLineColor(kRed + 1);
    f->Draw("SAME");
    exfuncs.push_back(f);
  }
  save(c5, "3-5-exgaussian");
  for (auto h : exps)
    delete h;
  for (auto f : exfuncs)
    delete f;
  std::cout << "Exercise 3.5 finished: " << files.dir << std::endl;
}
