#include "analysis.h"
#include <TCanvas.h>
#include <TF2.h>
#include <TFile.h>
#include <TFitResult.h>
#include <TFitResultPtr.h>
#include <TH2D.h>
#include <TStyle.h>
#include <TTreeReader.h>
#include <TTreeReaderValue.h>

void exercise2() {
    PrepareDirectories();
    TFile input("output/gaussian.root", "READ");
    if (input.IsZombie()) throw std::runtime_error("Run exercise1 first");
    TTreeReader reader("events", &input);
    TTreeReaderValue<double> x(reader, "x"), y(reader, "y");
    TH2D hist("hxy", "Samples;x;y", 50, -5, 5, 50, -5, 5);
    hist.SetDirectory(nullptr);
    while (reader.Next()) hist.Fill(*x, *y);
    if (hist.GetEntries() != 10000)
        throw std::runtime_error("Wrong histogram entry count");
    // I选项计算bin平均值，因此计数模型要乘bin面积。
    const double area = hist.GetXaxis()->GetBinWidth(1)
                      * hist.GetYaxis()->GetBinWidth(1);
    TF2 model("gaussian2d",
        "[0]*[6]/(2*TMath::Pi()*[2]*[4]*sqrt(1-[5]*[5]))"
        "*exp(-0.5/(1-[5]*[5])*("
        "((x-[1])/[2])^2+((y-[3])/[4])^2"
        "-2*[5]*(x-[1])*(y-[3])/([2]*[4])))",
        -5, 5, -5, 5);
    model.SetParNames("N", "mu_x", "sigma_x", "mu_y",
                      "sigma_y", "rho", "bin_area");
    model.SetParameters(10000, 0, 1, 0, 1, 0, area);
    model.FixParameter(6, area);
    model.SetParLimits(0, 1, 20000);
    model.SetParLimits(2, 0.2, 3);
    model.SetParLimits(4, 0.2, 3);
    model.SetParLimits(5, -0.95, 0.95);
    TFitResultPtr fit = hist.Fit(&model, "SLIR0Q");
    if (int(fit) != 0 || !fit->IsValid() || fit->CovMatrixStatus() != 3)
        throw std::runtime_error("Fit did not converge reliably");
    std::ofstream out("output/fit-statistics.json");
    if (!out) throw std::runtime_error("Cannot save fit statistics");
    out << std::setprecision(17)
        << "{\n  \"status\": " << int(fit)
        << ",\n  \"covariance_status\": " << fit->CovMatrixStatus()
        << ",\n  \"entries\": " << hist.GetEntries()
        << ",\n  \"in_range\": " << hist.Integral()
        << ",\n  \"bin_area\": " << area;
    const double truth[] = {10000, 0, 1, 0, 1, 0};
    for (int i = 0; i < 6; ++i) {
        const double value = fit->Parameter(i), error = fit->ParError(i);
        if (!(error > 0)) throw std::runtime_error("Invalid fit error");
        const double pull = (value - truth[i]) / error;
        out << ",\n  \"" << model.GetParName(i) << "\": " << value
            << ",\n  \"" << model.GetParName(i) << "_error\": " << error
            << ",\n  \"" << model.GetParName(i) << "_pull\": " << pull;
        std::cout << model.GetParName(i) << " = " << value
                  << " +/- " << error << ", pull = " << pull << '\n';
    }
    out << "\n}\n";
    out.close();
    if (!out) throw std::runtime_error("Failed writing fit statistics");
    std::cout << "Fit status = " << int(fit)
              << ", covariance status = " << fit->CovMatrixStatus() << '\n';
    // 字符串公式TF2可随拟合结果保存、重新读取。
    TFile output("output/fit.root", "RECREATE");
    if (output.IsZombie()) throw std::runtime_error("Cannot save fit file");
    hist.Write(); model.Write(); fit->Write("fit_result");
    gStyle->SetOptStat(0);
    model.SetTitle("Fitted expected counts;x;y");
    model.SetNpx(100); model.SetNpy(100);
    TCanvas canvas("fit2d", "", 1400, 650);
    canvas.Divide(2, 1);
    canvas.cd(1); gPad->SetRightMargin(0.14); hist.Draw("COLZ");
    canvas.cd(2); gPad->SetRightMargin(0.14); model.Draw("COLZ");
    canvas.SaveAs("pic/fit2d.png");
    canvas.SaveAs("output/fit2d.pdf");
}
