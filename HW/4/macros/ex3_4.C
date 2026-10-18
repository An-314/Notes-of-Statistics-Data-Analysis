#include "../include/HW4Common.h"

// Run from HW/4: root -l -b -q 'macros/ex3_4.C()'
void ex3_4(const char *output = "../pic/4") {
  using namespace hw4;
  initialize();
  Output files(output, "3-4");
  auto &stats = files.stats;
  auto save = [&](TCanvas &canvas, const char *name) {
    files.save(canvas, name);
  };

  std::vector<TH1D *> clt;
  for (int n = 1; n <= 20; ++n) {
    TRandom3 rng(seed + 4000 + n);
    Moments mz;
    std::vector<double> zvals;
    auto h = new TH1D(Form("clt%d", n),
                      Form("n = %d;z;Events / bin", n), 80, -5, 5);
    // BEGIN 3.4
    for (int k = 0; k < 10000; ++k) {
      double y = 0;
      for (int j = 0; j < n; ++j)
        y += rng.Rndm();
      double z = (y - n / 2.0) / sqrt(n / 12.0);
      h->Fill(z);
      mz.add(z);
      zvals.push_back(z);
    }
    // END 3.4
    std::sort(zvals.begin(), zvals.end());
    double ks = 0;
    for (size_t i = 0; i < zvals.size(); ++i) {
      double F = .5 * std::erfc(-zvals[i] / sqrt(2.0));
      ks = std::max({ks, (i + 1) / 10000.0 - F, F - i / 10000.0});
    }
    stats << "3.4-n" << n << ",10000," << mz.mean() << ","
          << sqrt(mz.variance()) << "," << mz.excess() << "," << ks
          << "\n";
    style(*h);
    h->SetLineColor(kBlue + 1);
    h->SetMinimum(0);
    h->SetMaximum(std::max(550.0, h->GetMaximum() * 1.1));
    clt.push_back(h);
  }
  TF1 normal("normal", "10000*.125/sqrt(2*TMath::Pi())*exp(-x*x/2)",
             -5, 5);
  normal.SetLineColor(kRed + 1);
  for (int group = 0; group < 4; ++group) {
    int first = 6 * group, last = std::min(first + 6, 20),
        rows = (last - first + 1) / 2;
    TCanvas c(Form("cltCanvas%d", group), "3.4", 1200, 420 * rows);
    c.Divide(2, rows);
    for (int k = first; k < last; ++k) {
      c.cd(k - first + 1);
      pad();
      clt[k]->Draw("HIST");
      normal.Draw("SAME");
    }
    save(c, Form("3-4-clt-%d", group + 1));
  }
  for (auto h : clt)
    delete h;
  std::cout << "Exercise 3.4 finished: " << files.dir << std::endl;
}
