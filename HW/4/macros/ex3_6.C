#include "../include/HW4Common.h"

// Run from HW/4: root -l -b -q 'macros/ex3_6.C()'
void ex3_6(const char *output = "../pic/4") {
  using namespace hw4;
  initialize();
  Output files(output, "3-6");
  auto &stats = files.stats;
  auto &meta = files.meta;
  auto save = [&](TCanvas &canvas, const char *name) {
    files.save(canvas, name);
  };

  // BEGIN 3.6
  TRandom3 rng6(seed + 6000);
  auto cauchy = [&]() { return tan(pi * (rng6.Rndm() - .5)); };
  TH1D hx(
      "hx",
      "Cauchy random numbers;x or sample mean;Probability density",
      100, -10, 10);
  TH1D hm("hm", "", 100, -10, 10);
  std::vector<double> xv, mv;
  for (int k = 0; k < 10000; ++k) {
    double x = cauchy();
    hx.Fill(x);
    xv.push_back(x);
  }
  for (int rep = 0; rep < 10000; ++rep) {
    double sum = 0;
    for (int j = 0; j < 10; ++j)
      sum += cauchy();
    double mean = sum / 10;
    hm.Fill(mean);
    mv.push_back(mean);
  }
  // END 3.6
  const std::array<std::pair<TH1D *, std::vector<double> *>, 2>
      samples{{{&hx, &xv}, {&hm, &mv}}};
  for (const auto &pair : samples) {
    double outside =
        pair.first->GetBinContent(0) + pair.first->GetBinContent(101);
    stats << (pair.first == &hx ? "3.6-x" : "3.6-mean")
          << ",10000,NA,NA," << quantile(*pair.second, .5) << ","
          << quantile(*pair.second, .75) - quantile(*pair.second, .25)
          << "\n";
    meta << pair.first->GetName() << " out-of-range count " << outside
         << " / 10000\n";
    pair.first->Scale(1 / (10000 * pair.first->GetBinWidth(1)));
    style(*pair.first);
  }
  hx.SetLineColor(kBlue + 1);
  hm.SetLineColor(kGreen + 2);
  hx.SetMinimum(0);
  hx.SetMaximum(.38);
  TCanvas c6("c6", "3.6", 1100, 650);
  pad();
  hx.Draw("HIST");
  hm.Draw("HIST SAME");
  TF1 fc("fc", "1/(TMath::Pi()*(1+x*x))", -10, 10);
  fc.SetLineColor(kRed + 1);
  fc.SetLineWidth(2);
  fc.Draw("SAME");
  TLegend legend(.62, .68, .9, .89);
  legend.SetBorderSize(0);
  legend.AddEntry(&hx, "Original x", "l");
  legend.AddEntry(&hm, "Mean of n = 10", "l");
  legend.AddEntry(&fc, "Cauchy density", "l");
  legend.Draw();
  save(c6, "3-6-cauchy");
  std::cout << "Exercise 3.6 finished: " << files.dir << std::endl;
}
