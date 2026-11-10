#include "analysis.h"
#include <ROOT/RDataFrame.hxx>
#include <TRandom3.h>
#include <array>

void exercise3() {
    PrepareDirectories();
    // 单线程固定调用顺序，重现第1题的同一组数据。
    if (ROOT::IsImplicitMTEnabled()) ROOT::DisableImplicitMT();
    TRandom3 random(42);
    ROOT::RDataFrame source(10000);
    auto generated = source
        .Define("xy", [&random]() {
            return std::array<double, 2>{random.Gaus(0, 1),
                                         random.Gaus(0, 1)};
        })
        .Define("x", [](const std::array<double, 2>& xy) { return xy[0]; },
                {"xy"})
        .Define("y", [](const std::array<double, 2>& xy) { return xy[1]; },
                {"xy"});
    generated.Snapshot("events", "output/gaussian_rdf.root", {"x", "y"});
    // 从文件重新读取，统计时不会再次抽样。
    ROOT::RDataFrame input("events", "output/gaussian_rdf.root");
    auto data = input.Define("sum", "x+y").Define("xy_product", "x*y");
    auto count = data.Count();
    auto mean_x = data.Mean("x"), mean_y = data.Mean("y");
    auto std_x = data.StdDev("x"), std_y = data.StdDev("y");
    auto std_sum = data.StdDev("sum");
    auto mean_xy = data.Mean("xy_product");
    const auto n = count.GetValue();  // 预订全部结果后触发一次循环。
    if (n != 10000) throw std::runtime_error("Wrong RDF entry count");
    const double covariance = double(n) / (n - 1)
        * (mean_xy.GetValue() - mean_x.GetValue() * mean_y.GetValue());
    const double correlation = covariance
        / (std_x.GetValue() * std_y.GetValue());
    Summary result{n, mean_x.GetValue(), mean_y.GetValue(),
                   std_x.GetValue(), std_y.GetValue(),
                   std_sum.GetValue(), correlation};
    SaveSummary(result, "output/rdf-statistics.json");
    std::cout << "RDF statistics event loops = " << input.GetNRuns() << '\n';
    if (input.GetNRuns() != 1) throw std::runtime_error("Unexpected rerun");
}
