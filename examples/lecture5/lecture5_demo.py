"""Reproduce and cross-check the TTree/RDataFrame examples (ROOT 6.40)."""
from array import array
import json
from pathlib import Path
import numpy as np
import ROOT

ROOT.gROOT.SetBatch(True)
ROOT.gStyle.SetOptStat(0)

# The C++- and Python-generated files use identical RNG calls.  Float rounding
# of pz can differ because Python evaluates its arithmetic in double precision.
source = ROOT.RDataFrame("t1", "tree1.root").AsNumpy()
assert len(source["i"]) == 5000
np.testing.assert_array_equal(source["i"], np.arange(5000))
np.testing.assert_allclose(source["pz"], source["px"].astype(float) ** 2
                           + source["py"].astype(float) ** 2, rtol=1e-7)
assert np.all((source["random"] >= 0) & (source["random"] < 1))
writer_agreement = None
if Path("tree1-cpp.root").exists():
    cpp = ROOT.RDataFrame("t1", "tree1-cpp.root").AsNumpy()
    for col in ("px", "py", "random", "i"):
        np.testing.assert_array_equal(cpp[col], source[col])
    np.testing.assert_allclose(cpp["pz"], source["pz"], rtol=2e-7)
    writer_agreement = True

# Copy only selected branches; CopyTree also applies a row selection.
old = ROOT.TFile.Open("tree1.root")
tree = old.Get("t1")
tree.SetBranchStatus("*", 0)
tree.SetBranchStatus("p*", 1)
tree.SetBranchStatus("i", 1)
small_file = ROOT.TFile("small.root", "RECREATE")
small = tree.CloneTree()
small.Write()
small_file.Close()
copy_file = ROOT.TFile("positive.root", "RECREATE")
positive = tree.CopyTree("px>0")
positive_count = positive.GetEntries()
positive.Write()
copy_file.Close()
assert positive_count == int(np.count_nonzero(source["px"] > 0))

# The traditional event loop: CloneTree(0), add p, select, then Fill.
px, py, pz = (array("f", [0]) for _ in range(3))
i = array("i", [0])
for name, buf in (("px", px), ("py", py), ("pz", pz), ("i", i)):
    tree.SetBranchAddress(name, buf)
out = ROOT.TFile("manual.root", "RECREATE")
manual = tree.CloneTree(0)
p = array("f", [0])
manual.Branch("p", p, "p/F")
for entry in range(tree.GetEntries()):
    tree.GetEntry(entry)
    if px[0] < 0:
        continue
    p[0] = np.sqrt(px[0] ** 2 + py[0] ** 2 + pz[0] ** 2)
    manual.Fill()
manual.Write()
out.Close()
tree.ResetBranchAddresses()
old.Close()

# Book all lazy actions before accessing a result.  An explicitly lazy
# Snapshot can be part of the same event loop; default Snapshot is immediate.
df = ROOT.RDataFrame("t1", "tree1.root")
cut = df.Filter("px >= 0", "px>=0")
with_p = cut.Define("p", "sqrt(px*px + py*py + pz*pz)")
count = df.Count()
mean_px, std_px, mean_pz = df.Mean("px"), df.StdDev("px"), df.Mean("pz")
selected = cut.Count()
report = cut.Report()
h_rdf = df.Histo1D(("h_rdf", "Same data, same selection;px;Entries", 80, -4, 4), "px")
options = ROOT.RDF.RSnapshotOptions()
options.fLazy = True
snapshot = with_p.Snapshot("t1", "rdf.root", ["px", "py", "pz", "i", "p"], options)
runs_before = int(df.GetNRuns())
assert runs_before == 0
n_total = int(count.GetValue())
runs_after = int(df.GetNRuns())
assert runs_after == 1
n_selected = int(selected.GetValue())
report.Print()
assert n_selected == int(np.count_nonzero(source["px"] >= 0))
assert int(df.GetNRuns()) == 1
manual_columns = ROOT.RDataFrame("t1", "manual.root").AsNumpy()
rdf_columns = ROOT.RDataFrame("t1", "rdf.root").AsNumpy()
assert set(manual_columns) == set(rdf_columns) == {"px", "py", "pz", "i", "p"}
for col in manual_columns:
    np.testing.assert_allclose(manual_columns[col], rdf_columns[col], rtol=2e-7, atol=1e-7)

# Compare histogram bin contents, including underflow/overflow, to a reader loop.
f = ROOT.TFile.Open("tree1.root")
t = f.Get("t1")
h_loop = ROOT.TH1D("h_loop", "Same data, same selection;px;Entries", 80, -4, 4)
h_loop.SetDirectory(0)
for event in t:
    h_loop.Fill(event.px)
for bin_no in range(h_loop.GetNbinsX() + 2):
    assert h_loop.GetBinContent(bin_no) == h_rdf.GetValue().GetBinContent(bin_no)
c = ROOT.TCanvas("comparison", "TTree and RDataFrame", 1100, 520)
h_loop.SetLineColor(ROOT.kBlue + 1)
h_loop.SetLineWidth(3)
h_loop.Draw("HIST")
h_rdf.SetLineColor(ROOT.kRed + 1)
h_rdf.SetLineWidth(2)
h_rdf.SetLineStyle(2)
h_rdf.Draw("HIST SAME")
legend = ROOT.TLegend(0.58, 0.72, 0.88, 0.87)
legend.SetBorderSize(0)
legend.AddEntry(h_loop, "Explicit TTree event loop", "l")
legend.AddEntry(h_rdf.GetValue(), "RDataFrame (identical bins)", "l")
legend.Draw()
c.SaveAs("rdf-comparison.png")

# TChain concatenates compatible trees; an explicit list avoids accidentally
# including both original and reduced copies through an overly broad wildcard.
chain = ROOT.TChain("t1")
chain.Add("tree1.root")
chain.Add("small.root")
chain_entries = int(chain.GetEntries())
assert chain_entries == 10000
assert int(ROOT.RDataFrame(chain).Count().GetValue()) == chain_entries

# A generated framework can be compiled and used immediately.
t.MakeClass("AnaFrame")
ROOT.gROOT.ProcessLine('.L AnaFrame.C+')
# MakeClass's generated destructor deletes GetCurrentFile().  Allocate that
# input file on the heap and let the local generated analysis own it.
assert ROOT.gInterpreter.Declare('''
Long64_t runGeneratedFrame() {
    auto* generatedInput = TFile::Open("tree1.root");
    auto* generatedTree = generatedInput->Get<TTree>("t1");
    AnaFrame generatedAnalysis(generatedTree);
    generatedAnalysis.Loop();
    return generatedTree->GetEntries();
}
''')
assert int(ROOT.runGeneratedFrame()) == n_total

# Fixed-capacity C arrays and std::vector both represent variable multiplicity.
variable_file = ROOT.TFile("variable.root", "RECREATE")
variable = ROOT.TTree("tracks", "Variable-size arrays and vector")
ntrack = array("i", [0])
track_px = array("f", [0] * 50)
pv = array("d", [0, 0, 0])
vpx = ROOT.std.vector("float")()
variable.Branch("ntrack", ntrack, "ntrack/I")
variable.Branch("px", track_px, "px[ntrack]/F")
variable.Branch("pv", pv, "pv[3]/D")
variable.Branch("vpx", vpx)
rng = ROOT.TRandom3(42)
expected_lengths = []
for entry in range(100):
    ntrack[0] = int(rng.Integer(15))
    assert 0 <= ntrack[0] <= len(track_px)
    vpx.clear()
    expected_lengths.append(ntrack[0])
    for j in range(ntrack[0]):
        track_px[j] = rng.Gaus()
        vpx.push_back(track_px[j])
    variable.Fill()
variable.Write()
variable_file.Close()
check_variable = ROOT.TFile.Open("variable.root")
for entry, event in enumerate(check_variable.Get("tracks")):
    assert event.ntrack == expected_lengths[entry]
    assert len(event.vpx) == event.ntrack
    for j in range(event.ntrack):
        assert event.px[j] == event.vpx[j]
check_variable.Close()

# An entry-aligned friend stores a new observable without rewriting old columns.
friend_file = ROOT.TFile("friend.root", "RECREATE")
friend_tree = ROOT.TTree("t1f", "an entry-aligned friend")
new_v = array("f", [0])
friend_tree.Branch("new_v", new_v, "new_v/F")
for entry in range(n_total):
    new_v[0] = 2 * float(source["px"][entry])
    friend_tree.Fill()
friend_tree.Write()
friend_file.Close()
t.AddFriend("t1f", "friend.root")
friend_good = t.Draw("t1f.new_v - 2*px", "", "goff")
residual = np.array([t.GetV1()[j] for j in range(friend_good)])
assert friend_good == n_total
assert np.max(np.abs(residual)) == 0
f.Close()

results = {
    "root_version": ROOT.gROOT.GetVersion(),
    "seed": 42,
    "entries": n_total,
    "mean_px": float(mean_px.GetValue()),
    "sample_std_px": float(std_px.GetValue()),
    "mean_pz": float(mean_pz.GetValue()),
    "selected_px_nonnegative": n_selected,
    "selection_efficiency": n_selected / n_total,
    "copytree_px_positive": int(positive_count),
    "rdf_runs_before_result": runs_before,
    "rdf_runs_after_all_results": runs_after,
    "manual_rdf_columns_agree": True,
    "manual_rdf_histograms_identical": True,
    "cpp_python_writers_agree_with_float_tolerance": writer_agreement,
    "chain_entries": chain_entries,
    "makeclass_generated_compiled_and_looped": True,
    "variable_array_vector_entries_checked": 100,
    "friend_entries_checked": int(friend_good),
    "friend_max_abs_residual": float(np.max(np.abs(residual))),
}
# The Gaussian mean/stddev and chi-square(2) mean fluctuate in a finite sample.
assert abs(results["mean_px"]) < 4 / np.sqrt(n_total)
assert abs(results["sample_std_px"] - 1) < 4 / np.sqrt(2 * (n_total - 1))
assert abs(results["mean_pz"] - 2) < 4 * 2 / np.sqrt(n_total)
assert abs(results["selection_efficiency"] - 0.5) < 4 * np.sqrt(0.25 / n_total)
Path("results.json").write_text(json.dumps(results, indent=2) + "\n")
print(json.dumps(results, indent=2))
