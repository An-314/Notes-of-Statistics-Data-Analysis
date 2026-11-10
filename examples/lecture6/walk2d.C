#include <TGraph.h>
#include <TRandom3.h>
#include <TMath.h>
#include <cmath>

void walk2d() {
    TRandom3 random(42);
    const double angle = TMath::Pi() / 6;
    double x = 0, y = 0;
    double theta = random.Uniform(-angle, angle);
    auto path = new TGraph();
    path->SetTitle("One particle;x [m];y [m]");
    path->SetPoint(0, x, y);
    while (true) {
        const double ls = random.Exp(2.0);
        const double la = random.Exp(5.0);
        const bool scatter = ls < la;
        const double step = scatter ? ls : la;
        x += step * std::cos(theta);
        y += step * std::sin(theta);
        path->SetPoint(path->GetN(), x, y);
        if (!scatter) break;
        theta += random.Uniform(-angle, angle);
    }
    path->Draw("AL");
}
