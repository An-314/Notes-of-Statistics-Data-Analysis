#include "../include/HW4Common.h"

// Run from HW/4: root -l -b -q 'macros/ex3_3.C()'
void ex3_3(const char *output = "../pic/4") {
  using namespace hw4;
  initialize();
  Output files(output, "3-3");
  auto &stats = files.stats;
  auto save = [&](TCanvas &canvas, const char *name) {
    files.save(canvas, name);
  };

  // BEGIN 3.3
  TRandom3 rng3(seed + 3000);
  const double xmax = 1;
  TH1D inv("inv", "Inverse CDF;x;Events / bin", 50, 0, xmax);
  TH1D rej("rej", "Rejection sampling;x;Events / bin", 50, 0, xmax);
  Moments mi, mr;
  for (int k = 0; k < 10000; ++k) {
    double x = xmax * sqrt(rng3.Rndm());
    inv.Fill(x);
    mi.add(x);
  }
  int accepted = 0, trials = 0;
  while (accepted < 10000) {
    ++trials;
    double x = xmax * rng3.Rndm(), u = (2 / xmax) * rng3.Rndm();
    if (u < 2 * x / (xmax * xmax)) {
      rej.Fill(x);
      mr.add(x);
      ++accepted;
    }
  }
  // END 3.3
  stats << "3.3-inverse,10000," << mi.mean() << ","
        << sqrt(mi.variance()) << ",0,0\n";
  stats << "3.3-rejection,10000," << mr.mean() << ","
        << sqrt(mr.variance()) << "," << trials << ","
        << 10000.0 / trials << "\n";
  TCanvas c3("c3", "3.3", 1200, 600);
  c3.Divide(2, 1);
  TF1 triangle("triangle", "400*x", 0, 1);
  triangle.SetLineColor(kRed + 1);
  c3.cd(1);
  pad();
  style(inv);
  inv.SetMinimum(0);
  inv.SetLineColor(kBlue + 1);
  inv.Draw("HIST");
  triangle.Draw("SAME");
  c3.cd(2);
  pad();
  style(rej);
  rej.SetMinimum(0);
  rej.SetLineColor(kBlue + 1);
  rej.Draw("HIST");
  triangle.Draw("SAME");
  save(c3, "3-3-triangular");
  std::cout << "Exercise 3.3 finished: " << files.dir << std::endl;
}
