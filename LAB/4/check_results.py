#!/usr/bin/env python3
"""独立读回 ROOT 数据，核对竞争抽样、径迹、统计及直方图。"""
import json
import math
import re
import statistics
from pathlib import Path

import ROOT

ROOT.gROOT.SetBatch(True)
BASE = Path(__file__).resolve().parent
OUTPUT = BASE / "output"
summary = json.loads((OUTPUT / "statistics.json").read_text())
source = ROOT.TFile.Open(str(OUTPUT / "transport.root"))
assert source and not source.IsZombie(), "Cannot open transport.root"
tree = source.Get("particles")
assert tree, "Cannot find particles tree"
n = int(tree.GetEntries())
assert n == summary["n"] == 200000
assert summary["seed"] == 42
assert summary["lambda_scatter"] == 2 and summary["lambda_annihilation"] == 5
assert math.isclose(summary["lambda_step"], 10 / 7, rel_tol=1e-14)

samples = {name: [] for name in
           ("total", "scatter", "last", "nscatter", "displacement",
            "raw_scatter", "raw_annihilation")}
track_rows = {}
angle_limit = math.pi / 6
max_path_error = max_position_error = 0.0

for row in tree:
    event = int(row.event)
    assert event == len(samples["total"]), "Entry identity is inconsistent"
    ns = int(row.nscatter)
    scatter = list(map(float, row.scatter_steps))
    candidates_s = list(map(float, row.candidate_scatter))
    candidates_a = list(map(float, row.candidate_annihilation))
    total, last = float(row.total), float(row.last)
    x, y = float(row.x), float(row.y)
    theta0 = float(row.theta0)
    displacement = float(row.displacement)
    assert len(scatter) == ns >= 0
    assert len(candidates_s) == len(candidates_a) == ns + 1
    assert all(math.isfinite(v) and v > 0 for v in candidates_s + candidates_a)
    assert -angle_limit <= theta0 <= angle_limit
    for step, cs, ca in zip(scatter, candidates_s[:-1], candidates_a[:-1]):
        assert step == cs < ca, "A recorded scattering step did not win"
    assert last == candidates_a[-1] <= candidates_s[-1]
    expected_total = math.fsum(scatter + [last])
    path_error = abs(total - expected_total)
    max_path_error = max(max_path_error, path_error)
    assert math.isclose(total, expected_total, rel_tol=2e-12, abs_tol=2e-12)
    assert math.isclose(displacement, math.hypot(x, y), rel_tol=2e-12, abs_tol=2e-12)
    assert displacement <= total + 2e-12 * max(1.0, total)

    samples["total"].append(total)
    samples["last"].append(last)
    samples["nscatter"].append(ns)
    samples["displacement"].append(displacement)
    samples["scatter"].extend(scatter)
    samples["raw_scatter"].extend(candidates_s)
    samples["raw_annihilation"].extend(candidates_a)

    path_x, path_y = list(map(float, row.path_x)), list(map(float, row.path_y))
    turns = list(map(float, row.turns))
    if event < 100:
        assert len(path_x) == len(path_y) == ns + 2
        assert len(turns) == ns
        assert path_x[0] == path_y[0] == 0
        assert all(-angle_limit <= a <= angle_limit for a in turns)
        theta = theta0
        for j, step in enumerate(scatter + [last]):
            expected_x = path_x[j] + step * math.cos(theta)
            expected_y = path_y[j] + step * math.sin(theta)
            err = max(abs(path_x[j + 1] - expected_x), abs(path_y[j + 1] - expected_y))
            max_position_error = max(max_position_error, err)
            assert math.isclose(path_x[j + 1], expected_x, rel_tol=2e-12, abs_tol=2e-12)
            assert math.isclose(path_y[j + 1], expected_y, rel_tol=2e-12, abs_tol=2e-12)
            if j < ns:
                theta += turns[j]
        assert path_x[-1] == x and path_y[-1] == y
        track_rows[event] = (path_x, path_y, ns)
    else:
        assert not path_x and not path_y and not turns


def independent_stats(values):
    count = len(values)
    std = statistics.stdev(values)
    return {"n": count, "mean": statistics.fmean(values),
            "sample_std": std, "se": std / math.sqrt(count)}


computed = {name: independent_stats(values) for name, values in samples.items()}
for name, values in computed.items():
    for key, value in values.items():
        assert math.isclose(value, summary[name][key], rel_tol=5e-11, abs_tol=2e-12), (name, key)
assert computed["scatter"]["n"] == sum(samples["nscatter"])
assert computed["raw_scatter"]["n"] == computed["scatter"]["n"] + n
assert computed["raw_annihilation"]["n"] == computed["raw_scatter"]["n"]
identity = (computed["last"]["mean"]
            + computed["nscatter"]["mean"] * computed["scatter"]["mean"])
pooled_error = abs(computed["total"]["mean"] - identity)
assert math.isclose(computed["total"]["mean"], identity, rel_tol=2e-12, abs_tol=2e-12)

histogram_checks = {}
for name in ("total", "scatter", "last", "nscatter"):
    hist = source.Get("h_" + name)
    assert hist and hist.InheritsFrom("TH1"), name
    nbins = hist.GetNbinsX()
    low, high = hist.GetXaxis().GetXmin(), hist.GetXaxis().GetXmax()
    width = (high - low) / nbins
    expected = [0] * (nbins + 2)
    for value in samples[name]:
        ibin = 0 if value < low else nbins + 1 if value >= high else 1 + int((value - low) / width)
        expected[ibin] += 1
    actual = [hist.GetBinContent(i) for i in range(nbins + 2)]
    assert expected == actual, f"{name}: histogram bins disagree with saved tree"
    assert int(hist.GetEntries()) == len(samples[name]) == sum(expected)
    if name != "nscatter":
        info = summary["histograms"][name]
        assert info["underflow"] == expected[0]
        assert info["overflow"] == expected[-1]
        assert info["bin_count"] == nbins
        assert math.isclose(info["xmax"], high)
    histogram_checks[name] = {"entries": len(samples[name]), "bins": nbins,
                              "underflow": expected[0], "overflow": expected[-1]}

names = {key.GetName() for key in source.GetListOfKeys()}
track_names = {name for name in names if re.fullmatch(r"track_\d{3}", name)}
assert track_names == {f"track_{i:03d}" for i in range(100)}
for i in range(100):
    graph = source.Get(f"track_{i:03d}")
    xs, ys, _ = track_rows[i]
    assert graph and graph.InheritsFrom("TGraph") and graph.GetN() == len(xs)
    for j, (x, y) in enumerate(zip(xs, ys)):
        assert graph.GetPointX(j) == x and graph.GetPointY(j) == y
single_id = int(summary["single_event"])
assert single_id == next(i for i in range(100) if track_rows[i][2] >= 3)
xs, ys, ns = track_rows[single_id]
single = source.Get("single_track")
assert single and single.InheritsFrom("TGraph")
assert single.GetN() == len(xs) == summary["single_points"]
assert ns == summary["single_nscatter"] >= 3
for j, (x, y) in enumerate(zip(xs, ys)):
    assert single.GetPointX(j) == x and single.GetPointY(j) == y


def ks_exponential(values, mean, fixed_sample=True):
    """独立用经验CDF计算与指定指数分布的Kolmogorov距离。"""
    count = len(values)
    distance = 0.0
    for i, value in enumerate(sorted(values), 1):
        cdf = -math.expm1(-value / mean)
        distance = max(distance, i / count - cdf, cdf - (i - 1) / count)
    result = {"ks_distance": distance}
    if fixed_sample:
        bound = math.sqrt(math.log(2 / 1e-6) / (2 * count))
        assert distance <= bound, "Inspect an unexpectedly large CDF discrepancy"
        result["dkw_bound_alpha_1e_minus6"] = bound
    # 原始候选的总抽样数由湮灭停止时刻决定；这里只报告CDF距离，
    # 不把固定样本量的DKW界套到依赖候选数值的停止样本上。
    return result


theory = {}
for name, reference in {"total": 5.0, "scatter": 10 / 7, "last": 10 / 7,
                        "nscatter": 2.5, "raw_scatter": 2.0,
                        "raw_annihilation": 5.0}.items():
    stats = computed[name]
    pull = (stats["mean"] - reference) / stats["se"]
    # 宽阈值只用于发现明显错误；固定样本的一致性仍应连同标准误差解释。
    assert abs(pull) < 5, (name, "inspect mean beyond five standard errors", pull)
    theory[name] = {"reference_mean": reference, "sample_mean": stats["mean"],
                    "mean_standard_error": stats["se"], "pull": pull}
    if name != "nscatter":
        theory[name].update(ks_exponential(samples[name], reference,
                                             fixed_sample=name in {"total", "scatter", "last"}))

verification = {
    "root_version": str(ROOT.gROOT.GetVersion()),
    "particle_count": n,
    "scattering_step_count": computed["scatter"]["n"],
    "candidate_pair_count": computed["raw_scatter"]["n"],
    "track_graph_count": len(track_names),
    "single_event": single_id,
    "single_nscatter": ns,
    "single_points": len(xs),
    "max_path_identity_error": max_path_error,
    "max_track_coordinate_error": max_position_error,
    "pooled_path_identity_error": pooled_error,
    "candidate_competition_checked": True,
    "all_statistics_match": True,
    "all_histograms_match": True,
    "all_track_graphs_match": True,
    "all_scattering_angles_within_30_degrees": True,
    "all_displacements_no_larger_than_paths": True,
    "histograms": histogram_checks,
    "independent_statistics": computed,
    "theory": theory,
}
source.Close()
(OUTPUT / "verification.json").write_text(json.dumps(verification, indent=2) + "\n")
print(f"PASS: {n} particles and {computed['raw_scatter']['n']} candidate pairs read back.")
print("PASS: every minimum, winner, path sum and displacement is consistent.")
print("PASS: means/standard errors and all histogram bins agree with independent calculations.")
print("PASS: 100 stored TGraphs and the selected single track match saved coordinates and turns.")
for name in ("total", "scatter", "last", "nscatter"):
    result = theory[name]
    print(f"{name}: mean={result['sample_mean']:.9f}, SE={result['mean_standard_error']:.9f}, "
          f"pull={result['pull']:.3f}")
