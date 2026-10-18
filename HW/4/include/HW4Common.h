#ifndef HW4_COMMON_H
#define HW4_COMMON_H

#include <TCanvas.h>
#include <TF1.h>
#include <TGraph.h>
#include <TH1D.h>
#include <TH2D.h>
#include <TLegend.h>
#include <TMath.h>
#include <TPad.h>
#include <TROOT.h>
#include <TRandom3.h>
#include <TStyle.h>
#include <TSystem.h>
#include <algorithm>
#include <array>
#include <cmath>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <numeric>
#include <stdexcept>
#include <string>
#include <vector>

namespace hw4 {
constexpr unsigned seed = 20261014;
constexpr double pi = 3.14159265358979323846;
struct Moments {
  long n = 0;
  double s1 = 0, s2 = 0, s3 = 0, s4 = 0;
  void add(double x) {
    ++n;
    s1 += x;
    s2 += x * x;
    s3 += x * x * x;
    s4 += x * x * x * x;
  }
  double mean() const { return s1 / n; }
  double variance() const { return (s2 - s1 * s1 / n) / (n - 1); }
  double excess() const {
    double m = mean(), v = s2 / n - m * m;
    return (s4 / n - 4 * m * s3 / n + 6 * m * m * s2 / n -
            3 * m * m * m * m) /
               (v * v) -
           3;
  }
};
inline void style(TH1 &h) {
  h.SetStats(false);
  h.SetLineWidth(2);
  h.GetXaxis()->SetTitleSize(.045);
  h.GetYaxis()->SetTitleSize(.045);
  h.GetXaxis()->SetLabelSize(.04);
  h.GetYaxis()->SetLabelSize(.04);
  h.GetYaxis()->SetTitleOffset(1.1);
}
inline void pad() {
  gPad->SetLeftMargin(.13);
  gPad->SetRightMargin(.07);
  gPad->SetBottomMargin(.13);
}
inline double quantile(std::vector<double> x, double p) {
  std::sort(x.begin(), x.end());
  double a = p * (x.size() - 1);
  size_t i = static_cast<size_t>(a);
  double t = a - i;
  return (1 - t) * x[i] + t * x[std::min(i + 1, x.size() - 1)];
}
} // namespace hw4

namespace hw4 {
inline void initialize() {
  gStyle->SetOptStat(0);
  gStyle->SetTitleFontSize(.05);
  TH1::AddDirectory(false);
}

// Each exercise owns its output files, so running one does not
// replace the statistics of another exercise.
struct Output {
  std::string dir;
  std::ofstream stats, meta;
  Output(const char *path, const char *exercise) : dir(path) {
    if (dir.empty())
      throw std::runtime_error("Empty output directory");
    gSystem->mkdir(dir.c_str(), true);
    stats.open(dir + "/" + exercise + "-results.csv");
    meta.open(dir + "/" + exercise + "-run-info.txt");
    if (!stats || !meta)
      throw std::runtime_error("Cannot write output directory: " +
                               dir);
    stats << std::setprecision(12);
    stats << "case,N,mean,sd,auxiliary1,auxiliary2\n";
    meta << "Exercise " << exercise << "\nROOT "
         << gROOT->GetVersion() << "\nBase seed " << seed << "\n";
  }
  void save(TCanvas &canvas, const char *name) const {
    const std::string path = dir + "/" + name + ".svg";
    canvas.SaveAs(path.c_str());
    if (gSystem->AccessPathName(path.c_str()))
      throw std::runtime_error("Missing figure: " + path);
  }
};
} // namespace hw4

#endif // HW4_COMMON_H
