#!/usr/bin/env python3
"""用独立计算核对统计、树内容和拟合对象。"""
import json
import math
import statistics
from pathlib import Path
import ROOT

ROOT.gROOT.SetBatch(True)
base = Path(__file__).resolve().parent

def read_rows(name):
    file = ROOT.TFile.Open(str(base / "output" / name))
    assert file and not file.IsZombie(), name
    tree = file.Get("events")
    assert tree and tree.GetEntries() == 10000, name
    assert {b.GetName() for b in tree.GetListOfBranches()} == {"x", "y"}
    rows = [(float(e.x), float(e.y)) for e in tree]
    file.Close()
    return rows

rows = read_rows("gaussian.root")
rdf_rows = read_rows("gaussian_rdf.root")
assert rows == rdf_rows, "RDF generation must reproduce the stored pairs"
x, y = zip(*rows)
sums = [a + b for a, b in rows]
reference = {
    "n": len(rows), "mean_x": statistics.mean(x),
    "mean_y": statistics.mean(y), "std_x": statistics.stdev(x),
    "std_y": statistics.stdev(y), "std_sum": statistics.stdev(sums),
    "correlation": statistics.correlation(x, y),
}
for name in ("tree-statistics.json", "rdf-statistics.json"):
    measured = json.loads((base / "output" / name).read_text())
    for key, value in reference.items():
        assert math.isclose(measured[key], value, rel_tol=1e-12, abs_tol=1e-12), (name, key)
variance_sum = reference["std_sum"] ** 2
variance_identity = (reference["std_x"] ** 2 + reference["std_y"] ** 2
                     + 2 * reference["correlation"] * reference["std_x"] * reference["std_y"])
assert math.isclose(variance_sum, variance_identity, rel_tol=1e-12)
fit = json.loads((base / "output/fit-statistics.json").read_text())
assert fit["status"] == 0 and fit["covariance_status"] == 3
parameters = ["N", "mu_x", "sigma_x", "mu_y", "sigma_y", "rho"]
max_pull = max(abs(fit[p + "_pull"]) for p in parameters)
assert max_pull < 3, "Inspect parameter deviations from generation values"
file = ROOT.TFile.Open(str(base / "output/fit.root"))
hist, model, result = file.Get("hxy"), file.Get("gaussian2d"), file.Get("fit_result")
assert hist and model and result and result.IsValid()
assert hist.Integral(0, 51, 0, 51) == 10000
assert hist.Integral() == fit["in_range"]
xx, yy = .25, -.4
u, v = (xx - fit["mu_x"]) / fit["sigma_x"], (yy - fit["mu_y"]) / fit["sigma_y"]
rho = fit["rho"]
expected = (fit["N"] * fit["bin_area"]
            / (2 * math.pi * fit["sigma_x"] * fit["sigma_y"] * math.sqrt(1 - rho * rho))
            * math.exp(-(u*u + v*v - 2*rho*u*v) / (2*(1-rho*rho))))
assert math.isclose(model.Eval(xx, yy), expected, rel_tol=1e-12)
file.Close()
r = reference["correlation"]
z = math.atanh(r)
z_error = 1 / math.sqrt(len(rows) - 3)
verification = {
    "n": len(rows), "same_pairs": True, "statistics_tolerance": 1e-12,
    "variance_identity_error": abs(variance_sum - variance_identity),
    "correlation_z": z / z_error,
    "correlation_ci_low": math.tanh(z - 1.95996398454 * z_error),
    "correlation_ci_high": math.tanh(z + 1.95996398454 * z_error),
    "max_fit_pull": max_pull,
    "root_version": str(ROOT.gROOT.GetVersion()),
}
(base / "output/verification.json").write_text(json.dumps(verification, indent=2) + "\n")
print("PASS: 10000 stored pairs are identical in TTree and RDF outputs.")
print("PASS: all statistics agree with independent calculations to 1e-12.")
print("PASS: variance identity and persisted TF2/fit result are valid.")
print(f"PASS: fit status=0, covariance status=3; largest |pull|={max_pull:.3f}.")
print(f"Correlation 95% Fisher interval: [{verification['correlation_ci_low']:.6f}, "
      f"{verification['correlation_ci_high']:.6f}]")
