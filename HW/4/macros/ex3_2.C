#include "../include/HW4Common.h"

// Run from HW/4: root -l -b -q 'macros/ex3_2.C()'
void ex3_2(const char *output = "../pic/4") {
  using namespace hw4;
  initialize();
  Output files(output, "3-2");
  auto &stats = files.stats;
  auto save = [&](TCanvas &canvas, const char *name) {
    files.save(canvas, name);
  };

  // BEGIN 3.2
  TH1D bins("bins", "", 5, 0, 1);
  TH1D h3("h3", "100 repeated experiments;n_{3};Experiments", 101,
          -.5, 100.5);
  TH2D h23("h23", "Bin-count correlation;n_{2};n_{3}", 41, -.5, 40.5,
           41, -.5, 40.5);
  std::array<std::array<int, 5>, 100> counts{};
  for (int rep = 0; rep < 100; ++rep) {
    TRandom3 rng(
        seed + 2000 +
        rep); // A distinct, nonzero seed for each experiment.
    bins.Reset();
    for (int k = 0; k < 100; ++k)
      bins.Fill(1 - rng.Rndm());
    for (int j = 0; j < 5; ++j)
      counts[rep][j] = static_cast<int>(bins.GetBinContent(j + 1));
    h3.Fill(counts[rep][2]);
    h23.Fill(counts[rep][1], counts[rep][2]);
  }
  // END 3.2
  Moments m2, m3;
  double s23 = 0;
  for (const auto &a : counts) {
    m2.add(a[1]);
    m3.add(a[2]);
    s23 += a[1] * a[2];
  }
  double cov = (s23 - m2.s1 * m3.s1 / 100) / 99;
  double corr = cov / sqrt(m2.variance() * m3.variance());
  stats << "3.2,100," << m3.mean() << "," << sqrt(m3.variance())
        << "," << cov << "," << corr << "\n";
  TCanvas c2("c2", "3.2", 1200, 600);
  c2.Divide(2, 1);
  c2.cd(1);
  pad();
  style(h3);
  h3.SetLineColor(kBlue + 1);
  h3.GetXaxis()->SetRangeUser(-.5, 40.5);
  h3.Draw("HIST");
  std::array<double, 41> xs{}, ys{};
  for (int k = 0; k <= 40; ++k) {
    xs[k] = k;
    ys[k] =
        100 * TMath::Binomial(100, k) * pow(.2, k) * pow(.8, 100 - k);
  }
  TGraph binom(41, xs.data(), ys.data());
  binom.SetLineColor(kRed + 1);
  binom.SetLineWidth(2);
  binom.Draw("L SAME");
  c2.cd(2);
  pad();
  gPad->SetRightMargin(.15);
  style(h23);
  h23.Draw("COLZ");
  TF1 conditional("conditional", "(100-x)/4", 0, 40);
  conditional.SetLineColor(kRed + 1);
  conditional.Draw("SAME");
  save(c2, "3-2-multinomial");
  std::cout << "Exercise 3.2 finished: " << files.dir << std::endl;
}
