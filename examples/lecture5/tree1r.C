#include <TFile.h>
#include <TTree.h>
#include <TH1F.h>
#include <TH2F.h>
#include <TCanvas.h>
#include <TStyle.h>
#include <stdexcept>

void tree1r() {
    TFile file("tree1.root");
    TTree* t1 = nullptr;
    file.GetObject("t1", t1);
    if (!t1) throw std::runtime_error("Cannot find t1");
    Float_t px, py, pz;
    t1->SetBranchAddress("px", &px);
    t1->SetBranchAddress("py", &py);
    t1->SetBranchAddress("pz", &pz);
    TH1F hpx("hpx", "px distribution;px;Entries", 80, -4, 4);
    TH2F hpxpy("hpxpy", "Event correlation;px;py", 50, -4, 4, 50, -4, 4);
    hpx.SetDirectory(nullptr);
    hpxpy.SetDirectory(nullptr);
    const Long64_t n = t1->GetEntries();
    for (Long64_t entry = 0; entry < n; ++entry) {
        t1->GetEntry(entry);
        hpx.Fill(px);
        hpxpy.Fill(px, py);
    }
    gStyle->SetOptStat(0);
    TCanvas canvas("canvas", "TTree analysis", 1200, 500);
    canvas.Divide(2, 1);
    canvas.cd(1); hpx.DrawCopy("HIST");
    canvas.cd(2); hpxpy.DrawCopy("COLZ");
    canvas.SaveAs("tree-distributions-cpp.png");
    t1->ResetBranchAddresses();
}
