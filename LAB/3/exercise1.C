#include "analysis.h"
#include <TCanvas.h>
#include <TFile.h>
#include <TH1D.h>
#include <TRandom3.h>
#include <TTree.h>
#include <TTreeReader.h>
#include <TTreeReaderValue.h>

void exercise1() {
    PrepareDirectories();
    constexpr int n = 10000;
    TRandom3 random(42);
    {
        TFile file("output/gaussian.root", "RECREATE");
        if (file.IsZombie()) throw std::runtime_error("Cannot create file");
        TTree tree("events", "Independent standard normal variables");
        double x, y;
        tree.Branch("x", &x, "x/D");
        tree.Branch("y", &y, "y/D");
        for (int i = 0; i < n; ++i) {
            x = random.Gaus(0, 1);
            y = random.Gaus(0, 1);
            tree.Fill();
        }
        tree.Write();
    }
    // 重新打开文件，统计实际读回的数据。
    TFile file("output/gaussian.root", "READ");
    if (file.IsZombie()) throw std::runtime_error("Cannot read file");
    TTreeReader reader("events", &file);
    TTreeReaderValue<double> x(reader, "x"), y(reader, "y");
    TH1D hx("hx", "x;x;Entries", 80, -5, 5);
    TH1D hs("hs", "x+y;x+y;Entries", 80, -8, 8);
    Moments moments;
    while (reader.Next()) {
        moments.Add(*x, *y);
        hx.Fill(*x); hs.Fill(*x + *y);
    }
    const Summary result = moments.Result();
    if (result.n != n) throw std::runtime_error("Wrong entry count");
    SaveSummary(result, "output/tree-statistics.json");
    TCanvas canvas("samples", "", 1400, 600);
    canvas.Divide(2, 1);
    canvas.cd(1); hx.Draw("HIST");
    canvas.cd(2); hs.Draw("HIST");
    canvas.SaveAs("pic/distributions.png");
    canvas.SaveAs("output/distributions.pdf");
}
