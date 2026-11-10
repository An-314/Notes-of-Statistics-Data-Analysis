#ifndef HW6_COMMON_H
#define HW6_COMMON_H

#include <Math/DistFunc.h>
#include <Math/QuantFuncMathCore.h>
#include <TCanvas.h>
#include <TF1.h>
#include <TH1D.h>
#include <TLegend.h>
#include <TLine.h>
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
#include <sstream>
#include <stdexcept>
#include <string>
#include <vector>

namespace hw6 {
struct Bin {
  double xmin, xmax;
  int n;
  std::array<double, 2> expected;
};

inline void initialize() {
  gROOT->SetBatch(true);
  gStyle->SetOptStat(0);
  gStyle->SetTitleFontSize(.048);
  TH1::AddDirectory(false);
}

inline void style(TH1 &histogram) {
  histogram.SetStats(false);
  histogram.SetLineWidth(2);
  histogram.GetXaxis()->SetTitleSize(.046);
  histogram.GetYaxis()->SetTitleSize(.046);
  histogram.GetXaxis()->SetLabelSize(.041);
  histogram.GetYaxis()->SetLabelSize(.041);
  histogram.GetYaxis()->SetTitleOffset(1.25);
}

inline void pad() {
  gPad->SetLeftMargin(.15);
  gPad->SetRightMargin(.045);
  gPad->SetBottomMargin(.14);
  gPad->SetTopMargin(.11);
}

struct Output {
  std::string dir;
  std::ofstream stats, meta;
  Output(const char *path, const char *exercise) : dir(path) {
    if (dir.empty()) throw std::runtime_error("Empty output directory");
    gSystem->mkdir(dir.c_str(), true);
    stats.open(dir + "/" + exercise + "-results.csv");
    meta.open(dir + "/" + exercise + "-run-info.txt");
    if (!stats || !meta) throw std::runtime_error("Cannot open output: " + dir);
    stats << std::setprecision(17);
    meta << std::setprecision(17) << "Exercise " << exercise
         << "\nROOT " << gROOT->GetVersion() << '\n';
  }
  void save(TCanvas &canvas, const char *name) const {
    const std::string file = dir + "/" + name + ".svg";
    canvas.SaveAs(file.c_str());
    if (gSystem->AccessPathName(file.c_str()))
      throw std::runtime_error("Missing figure: " + file);
  }
};

inline std::vector<Bin> loadData(const char *path) {
  std::ifstream input(path);
  if (!input) throw std::runtime_error(std::string("Cannot open data: ") + path);
  std::string line;
  std::getline(input, line);
  if (line != "xmin,xmax,n,theory1,theory2")
    throw std::runtime_error("Unexpected data CSV header");
  std::vector<Bin> bins;
  while (std::getline(input, line)) {
    if (line.empty()) continue;
    std::replace(line.begin(), line.end(), ',', ' ');
    std::istringstream row(line);
    Bin b{};
    if (!(row >> b.xmin >> b.xmax >> b.n >> b.expected[0] >> b.expected[1]))
      throw std::runtime_error("Invalid data row");
    if (b.n < 0 || b.expected[0] <= 0 || b.expected[1] <= 0 ||
        std::abs((b.xmax - b.xmin) - .5) > 1e-10 ||
        (!bins.empty() && std::abs(b.xmin - bins.back().xmax) > 1e-10))
      throw std::runtime_error("Invalid bin boundaries, counts, or expectations");
    bins.push_back(b);
  }
  if (bins.size() != 20 || bins.front().xmin != 0 || bins.back().xmax != 10)
    throw std::runtime_error("Expected 20 bins spanning [0,10]");
  return bins;
}

inline double pearson(const std::vector<double> &counts,
                      const std::vector<double> &expected) {
  if (counts.size() != expected.size())
    throw std::runtime_error("Count/expectation size mismatch");
  double q = 0;
  for (std::size_t i = 0; i < counts.size(); ++i) {
    const double delta = counts[i] - expected[i];
    q += delta * delta / expected[i];
  }
  return q;
}
} // namespace hw6

#endif
