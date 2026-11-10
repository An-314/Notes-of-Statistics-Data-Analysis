#include "simulation.h"
#include <TArrow.h>
#include <TCanvas.h>
#include <TFile.h>
#include <TF1.h>
#include <TGraph.h>
#include <TH1D.h>
#include <TLatex.h>
#include <TLegend.h>
#include <TMultiGraph.h>
#include <TROOT.h>
#include <TStyle.h>
#include <TSystem.h>
#include <TTree.h>
#include <TPaveText.h>
#include <algorithm>
#include <cstdint>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <limits>
#include <sstream>
#include <stdexcept>
#include <string>

namespace lab4 {
struct Moments {
    std::int64_t n = 0;
    double mean = 0.0, m2 = 0.0;
    void Add(double value) {
        ++n;
        const double delta = value - mean;
        mean += delta / n;
        m2 += delta * (value - mean);
    }
    double Std() const { return n > 1 ? std::sqrt(m2 / (n - 1)) : 0.0; }
    double SE() const { return n ? Std() / std::sqrt(double(n)) : 0.0; }
    void Write(std::ostream& out) const {
        out << "{\"n\": " << n << ", \"mean\": " << mean
            << ", \"sample_std\": " << Std() << ", \"se\": " << SE() << "}";
    }
};

void SquareAxes(TCanvas& canvas, TGraph& graph,
                double xmin, double xmax, double ymin, double ymax) {
    canvas.SetCanvasSize(1100, 1100);
    canvas.SetLeftMargin(.12); canvas.SetRightMargin(.08);
    canvas.SetBottomMargin(.12); canvas.SetTopMargin(.08);
    canvas.SetGrid();
    const double span = 1.18 * std::max(xmax - xmin, ymax - ymin);
    const double xc = .5 * (xmin + xmax), yc = .5 * (ymin + ymax);
    graph.Draw("AL");
    graph.GetXaxis()->SetLimits(xc - span/2, xc + span/2);
    graph.SetMinimum(yc - span/2); graph.SetMaximum(yc + span/2);
    graph.GetXaxis()->SetTitleOffset(1.3);
    graph.GetYaxis()->SetTitleOffset(1.4);
    canvas.Modified(); canvas.Update();
}

void PlotDensity(const TH1D& counts, const Moments& stats, double lambda,
                 const char* title, const char* suffix) {
    auto density = static_cast<TH1D*>(counts.Clone((std::string("density_") + suffix).c_str()));
    density->SetDirectory(nullptr);
    density->Scale(1.0 / (stats.n * density->GetBinWidth(1)));
    density->SetTitle(title);
    density->SetLineColor(kBlue + 1); density->SetLineWidth(2);
    density->SetMinimum(0.0);
    density->SetMaximum(1.13 * std::max(1.0/lambda, density->GetMaximum()));
    density->GetXaxis()->SetTitleSize(.045);
    density->GetYaxis()->SetTitleSize(.045);
    density->GetYaxis()->SetTitleOffset(1.25);
    density->Draw("HIST");
    auto theory = new TF1((std::string("theory_") + suffix).c_str(),
                         "[0]*exp(-[0]*x)", 0, counts.GetXaxis()->GetXmax());
    theory->SetParameter(0, 1.0 / lambda);
    theory->SetLineColor(kRed + 1); theory->SetLineStyle(2);
    theory->SetLineWidth(2); theory->Draw("SAME");
    auto legend = new TLegend(.39, .77, .89, .89);
    legend->SetBorderSize(0); legend->SetFillStyle(0);
    legend->AddEntry(density, "Simulation", "l");
    legend->AddEntry(theory, "Exponential theory", "l");
    legend->Draw();
    auto text = new TPaveText(.39, .55, .89, .75, "NDC");
    text->SetFillStyle(0); text->SetBorderSize(0); text->SetTextAlign(12);
    text->AddText(Form("N = %lld", static_cast<long long>(stats.n)));
    text->AddText(Form("Mean = %.5f #pm %.5f m", stats.mean, stats.SE()));
    text->AddText(Form("Theory mean = %.5f m", lambda));
    text->Draw();
}

void WriteHistogramInfo(std::ostream& out, const TH1D& h) {
    out << "{\"underflow\": " << h.GetBinContent(0)
        << ", \"overflow\": " << h.GetBinContent(h.GetNbinsX() + 1)
        << ", \"bin_count\": " << h.GetNbinsX()
        << ", \"xmax\": " << h.GetXaxis()->GetXmax() << "}";
}
}  // namespace lab4

void exercise() {
    using namespace lab4;
    gROOT->SetBatch(true);
    gStyle->SetOptStat(0);
    gStyle->SetTitleFontSize(.045);
    gSystem->mkdir("output", true); gSystem->mkdir("pic", true);
    constexpr int n = 200000;
    TRandom3 random(42);
    TFile file("output/transport.root", "RECREATE");
    if (file.IsZombie()) throw std::runtime_error("Cannot create transport.root");
    TTree tree("particles", "2D scattering and annihilation");
    Track track;
    int event = 0, nscatter = 0;
    double displacement = 0.0;
    std::vector<double> path_x, path_y, turns;
    tree.Branch("event", &event, "event/I");
    tree.Branch("nscatter", &nscatter, "nscatter/I");
    tree.Branch("total", &track.total, "total/D");
    tree.Branch("last", &track.last, "last/D");
    tree.Branch("x", &track.x, "x/D"); tree.Branch("y", &track.y, "y/D");
    tree.Branch("theta0", &track.theta0, "theta0/D");
    tree.Branch("displacement", &displacement, "displacement/D");
    tree.Branch("scatter_steps", &track.scatter_steps);
    tree.Branch("candidate_scatter", &track.candidate_scatter);
    tree.Branch("candidate_annihilation", &track.candidate_annihilation);
    tree.Branch("path_x", &path_x); tree.Branch("path_y", &path_y);
    tree.Branch("turns", &turns);
    TH1D h_total("h_total", "Total path;Length [m];Counts", 120, 0, 30);
    TH1D h_scatter("h_scatter", "Realized scattering steps;Length [m];Counts", 120, 0, 15);
    TH1D h_last("h_last", "Final annihilation step;Length [m];Counts", 120, 0, 15);
    TH1D h_nscatter("h_nscatter", "Number of scatterings;N_{s};Counts", 50, -.5, 49.5);
    Moments total, scatter, last, number, distance, raw_s, raw_a;
    TMultiGraph tracks;
    tracks.SetTitle("First 100 particle trajectories;x [m];y [m]");
    Track single;
    int single_event = -1;
    const int colors[] = {kBlue+1, kRed+1, kGreen+2, kMagenta+1,
                          kCyan+2, kOrange+7, kViolet+1, kTeal+2};
    double xmin = 0, xmax = 0, ymin = 0, ymax = 0;
    for (event = 0; event < n; ++event) {
        track = Simulate(random);
        nscatter = static_cast<int>(track.scatter_steps.size());
        displacement = std::hypot(track.x, track.y);
        if (displacement > track.total + 1e-11 * std::max(1.0, track.total))
            throw std::runtime_error("Displacement exceeds total path");
        total.Add(track.total); last.Add(track.last);
        number.Add(nscatter); distance.Add(displacement);
        h_total.Fill(track.total); h_last.Fill(track.last); h_nscatter.Fill(nscatter);
        for (double s : track.scatter_steps) { scatter.Add(s); h_scatter.Fill(s); }
        for (double s : track.candidate_scatter) raw_s.Add(s);
        for (double s : track.candidate_annihilation) raw_a.Add(s);
        path_x.clear(); path_y.clear(); turns.clear();
        if (event < 100) {
            path_x = track.path_x; path_y = track.path_y; turns = track.turns;
            auto graph = new TGraph(path_x.size(), path_x.data(), path_y.data());
            graph->SetName(Form("track_%03d", event));
            graph->SetTitle(Form("Event %d;x [m];y [m]", event));
            graph->SetLineColor(colors[event % 8]); graph->SetLineWidth(1);
            graph->Write(); tracks.Add(graph, "L");
            for (std::size_t j = 0; j < path_x.size(); ++j) {
                xmin = std::min(xmin, path_x[j]); xmax = std::max(xmax, path_x[j]);
                ymin = std::min(ymin, path_y[j]); ymax = std::max(ymax, path_y[j]);
            }
            if (single_event < 0 && nscatter >= 3) {
                single = track; single_event = event;
            }
        }
        tree.Fill();
    }
    if (single_event < 0) throw std::runtime_error("No representative track found");
    tree.Write(); h_total.Write(); h_scatter.Write(); h_last.Write(); h_nscatter.Write();
    TGraph single_graph(single.path_x.size(), single.path_x.data(), single.path_y.data());
    single_graph.SetName("single_track");
    single_graph.SetTitle(Form("Single trajectory (event %d);x [m];y [m]", single_event));
    single_graph.SetLineColor(kBlue + 1); single_graph.SetLineWidth(3);
    single_graph.Write();
    {
        TCanvas canvas("single_canvas", "", 1100, 1100);
        const auto xx = std::minmax_element(single.path_x.begin(), single.path_x.end());
        const auto yy = std::minmax_element(single.path_y.begin(), single.path_y.end());
        SquareAxes(canvas, single_graph, *xx.first, *xx.second, *yy.first, *yy.second);
        const int ns = static_cast<int>(single.scatter_steps.size());
        TGraph points(ns, single.path_x.data()+1, single.path_y.data()+1);
        points.SetMarkerStyle(20); points.SetMarkerColor(kBlue + 1); points.SetMarkerSize(1.4);
        points.Draw("P SAME");
        double ox = 0, oy = 0;
        TGraph origin(1, &ox, &oy);
        origin.SetMarkerStyle(20); origin.SetMarkerSize(1.7); origin.SetMarkerColor(kBlack);
        origin.Draw("P SAME");
        TGraph end(1, &single.x, &single.y);
        end.SetMarkerStyle(29); end.SetMarkerSize(2.7); end.SetMarkerColor(kRed + 1);
        end.Draw("P SAME");
        TLatex labels; labels.SetTextSize(.026); labels.SetTextColor(kBlue + 2);
        const double span = std::max(*xx.second-*xx.first, *yy.second-*yy.first);
        for (int j = 1; j <= ns; ++j)
            labels.DrawLatex(single.path_x[j]+.01*span, single.path_y[j]+.012*span, Form("%d", j));
        for (std::size_t j = 1; j < single.path_x.size(); ++j) {
            const double ax = single.path_x[j-1], ay = single.path_y[j-1];
            const double bx = single.path_x[j], by = single.path_y[j];
            TArrow arrow(ax+.48*(bx-ax), ay+.48*(by-ay),
                         ax+.70*(bx-ax), ay+.70*(by-ay), .012, "|>");
            arrow.SetLineColor(kBlue+1); arrow.SetFillColor(kBlue+1);
            arrow.DrawClone();
        }
        TLegend legend(.15, .76, .60, .90);
        legend.SetFillStyle(0); legend.SetBorderSize(0);
        legend.AddEntry(&origin, "Start at (0,0)", "p");
        legend.AddEntry(&points, "Scattering points (numbered)", "p");
        legend.AddEntry(&end, "Annihilation", "p"); legend.Draw();
        canvas.SaveAs("pic/single-track.png");
        canvas.SaveAs("output/single-track.pdf");
    }
    {
        TCanvas canvas("tracks_canvas", "", 1100, 1100);
        canvas.SetCanvasSize(1100,1100);
        canvas.SetLeftMargin(.12); canvas.SetRightMargin(.08);
        canvas.SetTopMargin(.08); canvas.SetBottomMargin(.12); canvas.SetGrid();
        const double span = 1.10 * std::max(xmax-xmin, ymax-ymin);
        const double xc = .5*(xmax+xmin), yc = .5*(ymax+ymin);
        tracks.Draw("AL");
        tracks.GetXaxis()->SetLimits(xc-span/2, xc+span/2);
        tracks.SetMinimum(yc-span/2); tracks.SetMaximum(yc+span/2);
        tracks.GetXaxis()->SetTitleOffset(1.3); tracks.GetYaxis()->SetTitleOffset(1.4);
        canvas.Modified(); canvas.Update();
        canvas.SaveAs("pic/tracks-100.png"); canvas.SaveAs("output/tracks-100.pdf");
    }
    {
        TCanvas canvas("lengths_canvas", "", 1100, 1500);
        canvas.SetCanvasSize(1100, 1500);
        canvas.Divide(1,3);
        for (int i=1; i<=3; ++i) {
            canvas.cd(i); gPad->SetLeftMargin(.12); gPad->SetBottomMargin(.15);
            gPad->SetRightMargin(.04); gPad->SetTopMargin(.09); gPad->SetGrid();
        }
        canvas.cd(1); PlotDensity(h_total,total,5.0,"Total path before annihilation;Length [m];Probability density [m^{-1}]","total");
        canvas.cd(2); PlotDensity(h_scatter,scatter,10.0/7,"Realized scattering step;Length [m];Probability density [m^{-1}]","scatter");
        canvas.cd(3); PlotDensity(h_last,last,10.0/7,"Final annihilation step;Length [m];Probability density [m^{-1}]","last");
        canvas.SaveAs("pic/path-lengths.png"); canvas.SaveAs("output/path-lengths.pdf");
    }
    std::ofstream out("output/statistics.json");
    if (!out) throw std::runtime_error("Cannot create statistics.json");
    out << std::setprecision(17)
        << "{\n  \"root_version\": \"" << gROOT->GetVersion() << "\",\n"
        << "  \"n\": " << n << ", \"seed\": 42,\n"
        << "  \"lambda_scatter\": 2, \"lambda_annihilation\": 5, \"lambda_step\": " << 10.0/7 << ",\n";
    const std::pair<const char*,const Moments*> summaries[] = {
        {"total",&total},{"scatter",&scatter},{"last",&last},{"nscatter",&number},
        {"displacement",&distance},{"raw_scatter",&raw_s},{"raw_annihilation",&raw_a}};
    for (const auto& item : summaries) {
        out << "  \"" << item.first << "\": "; item.second->Write(out); out << ",\n";
    }
    out << "  \"histograms\": {\n    \"total\": "; WriteHistogramInfo(out,h_total);
    out << ",\n    \"scatter\": "; WriteHistogramInfo(out,h_scatter);
    out << ",\n    \"last\": "; WriteHistogramInfo(out,h_last);
    out << "\n  },\n  \"single_event\": " << single_event
        << ", \"single_points\": " << single.path_x.size()
        << ", \"single_nscatter\": " << single.scatter_steps.size()
        << ",\n  \"single_total\": " << single.total << ", \"single_last\": " << single.last
        << ", \"single_x\": " << single.x << ", \"single_y\": " << single.y
        << ", \"single_theta0\": " << single.theta0 << ",\n  \"single_scatter_steps\": [";
    for (std::size_t i=0;i<single.scatter_steps.size();++i) {
        if (i) out << ", "; out << single.scatter_steps[i];
    }
    out << "]\n}\n"; out.close();
    std::cout << std::fixed << std::setprecision(6)
              << "Particles: " << n << "; scattering steps: " << scatter.n << '\n'
              << "Total path: " << total.mean << " +/- " << total.SE() << " m\n"
              << "Scattering step: " << scatter.mean << " +/- " << scatter.SE() << " m\n"
              << "Final annihilation step: " << last.mean << " +/- " << last.SE() << " m\n"
              << "Mean number of scatterings: " << number.mean << '\n'
              << "Single track: event " << single_event << ", " << single.scatter_steps.size() << " scattering points\n";
}
