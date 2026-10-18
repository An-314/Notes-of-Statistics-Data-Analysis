#include "../include/HW4Common.h"

// Run from HW/4: root -l -b -q 'macros/ex3_1.C()'
void ex3_1(const char *output = "../pic/4") {
  using namespace hw4;
  initialize();
  Output files(output, "3-1");
  auto &stats = files.stats;
  auto save = [&](TCanvas &canvas, const char *name) {
    files.save(canvas, name);
  };

  // BEGIN 3.1
  TRandom3 rng1(seed + 1000);
  TH1D h1("h1", "Uniform random numbers;u;Events / bin", 100, 0, 1);
  Moments m1;
  for (int k = 0; k < 10000; ++k) {
    double u = 1 - rng1.Rndm();
    h1.Fill(u);
    m1.add(u);
  }
  // END 3.1
  style(h1);
  h1.SetLineColor(kBlue + 1);
  h1.SetMinimum(0);
  TCanvas c1("c1", "3.1", 1100, 650);
  pad();
  h1.Draw("HIST");
  TF1 flat("flat", "100", 0, 1);
  flat.SetLineColor(kRed + 1);
  flat.Draw("SAME");
  save(c1, "3-1-uniform");
  stats << "3.1,10000," << m1.mean() << "," << sqrt(m1.variance())
        << "," << h1.GetBinContent(0) << "," << h1.GetBinContent(101)
        << "\n";
  std::cout << "Exercise 3.1 finished: " << files.dir << std::endl;
}
