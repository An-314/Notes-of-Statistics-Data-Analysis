import ROOT


def tree1r():
    ROOT.gROOT.SetBatch(True)
    ROOT.gStyle.SetOptStat(0)
    file = ROOT.TFile.Open("tree1.root")
    t1 = file.Get("t1")
    hpx = ROOT.TH1F("hpx", "px distribution;px;Entries", 80, -4, 4)
    hpxpy = ROOT.TH2F("hpxpy", "Event correlation;px;py", 50, -4, 4, 50, -4, 4)
    hpx.SetDirectory(0)
    hpxpy.SetDirectory(0)
    for entry in t1:
        hpx.Fill(entry.px)
        hpxpy.Fill(entry.px, entry.py)
    canvas = ROOT.TCanvas("canvas", "TTree analysis", 1200, 500)
    canvas.Divide(2, 1)
    canvas.cd(1)
    ROOT.gPad.SetLeftMargin(0.12)
    hpx.SetLineColor(ROOT.kBlue + 1)
    hpx.SetLineWidth(2)
    hpx.Draw("HIST")
    canvas.cd(2)
    ROOT.gPad.SetRightMargin(0.14)
    hpxpy.Draw("COLZ")
    canvas.SaveAs("tree-distributions.png")
    file.Close()


if __name__ == "__main__":
    tree1r()
