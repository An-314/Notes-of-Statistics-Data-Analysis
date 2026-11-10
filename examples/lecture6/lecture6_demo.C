#include <TCanvas.h>
#include <TFile.h>
#include <TF1.h>
#include <TGraph.h>
#include <TH1D.h>
#include <TLegend.h>
#include <TMultiGraph.h>
#include <TRandom3.h>
#include <TStyle.h>
#include <TTree.h>
#include <cmath>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <vector>

void competition() {
    constexpr int n = 1000000;
    TRandom3 random(42);
    TFile file("competition.root", "RECREATE");
    TTree tree("tree", "Competing exponential processes");
    double r1, r2, step;
    int flag;
    tree.Branch("L1", &r1, "L1/D");
    tree.Branch("L2", &r2, "L2/D");
    tree.Branch("Lstep", &step, "Lstep/D");
    tree.Branch("flag", &flag, "flag/I");
    TH1D h1("h1", "Unconditional sampled distances;Distance;Probability density", 120, 0, 15);
    TH1D h2("h2", "", 120, 0, 15);
    TH1D win1("win1", "Distance conditional on winning;Distance;Conditional probability density", 120, 0, 15);
    TH1D win2("win2", "", 120, 0, 15);
    double sum1=0, sum2=0, sum=0, sumwin1=0, sumwin2=0;
    long long nwin1=0, nwin2=0;
    for (int i=0; i<n; ++i) {
        r1=random.Exp(2.0); r2=random.Exp(5.0);
        flag=(r1<r2)?0:1;
        step=(flag==0)?r1:r2;
        sum1+=r1;sum2+=r2;sum+=step;
        h1.Fill(r1);h2.Fill(r2);
        if(flag==0){++nwin1;sumwin1+=step;win1.Fill(step);}
        else{++nwin2;sumwin2+=step;win2.Fill(step);}
        tree.Fill();
    }
    tree.Write();
    std::ofstream out("competition.json");
    out<<std::setprecision(16)<<"{\n  \"n\": "<<n
       <<",\n  \"seed\": 42,\n  \"lambda1\": 2,\n  \"lambda2\": 5,\n  \"lambda_total\": "<<10.0/7
       <<",\n  \"mean_r1\": "<<sum1/n<<",\n  \"mean_r2\": "<<sum2/n
       <<",\n  \"mean_min\": "<<sum/n<<",\n  \"count_flag0\": "<<nwin1
       <<",\n  \"count_flag1\": "<<nwin2<<",\n  \"fraction_flag0\": "<<double(nwin1)/n
       <<",\n  \"mean_step_given_flag0\": "<<sumwin1/nwin1
       <<",\n  \"mean_step_given_flag1\": "<<sumwin2/nwin2<<"\n}\n";
    out.close();
    const double width=h1.GetBinWidth(1);
    h1.Scale(1.0/(n*width));h2.Scale(1.0/(n*width));
    win1.Scale(1.0/(nwin1*width));win2.Scale(1.0/(nwin2*width));
    h1.SetLineColor(kBlue+1);h1.SetLineWidth(2);
    h2.SetLineColor(kRed+1);h2.SetLineWidth(2);
    win1.SetLineColor(kBlue+1);win1.SetLineWidth(2);
    win2.SetLineColor(kRed+1);win2.SetLineWidth(2);win2.SetLineStyle(2);
    TCanvas c("competition_plot", "", 1500, 650);c.Divide(2,1);
    c.cd(1);h1.Draw("HIST");h2.Draw("HIST SAME");
    TLegend l1(.51,.70,.89,.88);l1.SetBorderSize(0);
    l1.AddEntry(&h1,"L_{1} ~ Exp(mean=2)","l");
    l1.AddEntry(&h2,"L_{2} ~ Exp(mean=5)","l");l1.Draw();
    c.cd(2);win1.Draw("HIST");win2.Draw("HIST SAME");
    TF1 theory("theory", "0.7*exp(-0.7*x)", 0, 15);
    theory.SetLineColor(kBlack);theory.SetLineStyle(3);theory.Draw("SAME");
    TLegend l2(.45,.65,.89,.88);l2.SetBorderSize(0);
    l2.AddEntry(&win1,"Process 1 wins","l");
    l2.AddEntry(&win2,"Process 2 wins","l");
    l2.AddEntry(&theory,"0.7 exp(-0.7 L)","l");l2.Draw();
    c.SaveAs("competition.png");c.SaveAs("competition.pdf");
    std::cout<<"competition: mean_min="<<sum/n<<", conditional="<<sumwin1/nwin1<<","<<sumwin2/nwin2<<", flag0="<<double(nwin1)/n<<std::endl;
}

void transport() {
    constexpr int n=200000;
    constexpr double pi=3.14159265358979323846;
    TRandom3 random(42);
    TFile file("transport.root","RECREATE");
    TTree tree("particles","2D scattering plus annihilation");
    double total,last,x,y,displacement;
    int nscatter;
    tree.Branch("total",&total,"total/D");tree.Branch("last",&last,"last/D");
    tree.Branch("x",&x,"x/D");tree.Branch("y",&y,"y/D");
    tree.Branch("displacement",&displacement,"displacement/D");
    tree.Branch("nscatter",&nscatter,"nscatter/I");
    TH1D htotal("htotal","Path lengths until annihilation;Length [m];Probability density",120,0,30);
    TH1D hlast("hlast","",120,0,30),hscatter("hscatter","",120,0,30);
    double sumtotal=0,sumlast=0,sumscatter=0,sumdisplacement=0;
    long long totalscatter=0;
    TMultiGraph paths;
    paths.SetTitle("100 particle trajectories;x [m];y [m]");
    for(int i=0;i<n;++i){
        x=0;y=0;total=0;last=0;nscatter=0;
        double theta=random.Uniform(-pi/6,pi/6);
        TGraph* graph=nullptr;
        if(i<100){graph=new TGraph();graph->SetPoint(0,0,0);graph->SetLineColor(2+i%8);graph->SetLineWidth(1);}
        while(true){
            const double ls=random.Exp(2.0),la=random.Exp(5.0);
            const bool scatters=ls<la;
            const double step=scatters?ls:la;
            x+=step*std::cos(theta);y+=step*std::sin(theta);total+=step;
            if(graph)graph->SetPoint(graph->GetN(),x,y);
            if(!scatters){last=step;break;}
            ++nscatter;++totalscatter;sumscatter+=step;hscatter.Fill(step);
            theta+=random.Uniform(-pi/6,pi/6);
        }
        displacement=std::hypot(x,y);
        sumtotal+=total;sumlast+=last;sumdisplacement+=displacement;
        htotal.Fill(total);hlast.Fill(last);tree.Fill();
        if(graph)paths.Add(graph,"L");
    }
    tree.Write();
    std::ofstream out("transport.json");
    out<<std::setprecision(16)<<"{\n  \"n\": "<<n
       <<",\n  \"seed\": 42,\n  \"lambda_scatter\": 2,\n  \"lambda_annihilation\": 5"
       <<",\n  \"mean_total_path\": "<<sumtotal/n
       <<",\n  \"mean_annihilation_step\": "<<sumlast/n
       <<",\n  \"mean_scattering_step\": "<<sumscatter/totalscatter
       <<",\n  \"mean_number_scatterings\": "<<double(totalscatter)/n
       <<",\n  \"scattering_step_count\": "<<totalscatter
       <<",\n  \"mean_displacement\": "<<sumdisplacement/n<<"\n}\n";
    out.close();
    double xmin=0,xmax=0,ymin=0,ymax=0;
    for (auto object : *paths.GetListOfGraphs()) {
        auto graph=static_cast<TGraph*>(object);
        for(int j=0;j<graph->GetN();++j) {
            xmin=std::min(xmin,graph->GetPointX(j));xmax=std::max(xmax,graph->GetPointX(j));
            ymin=std::min(ymin,graph->GetPointY(j));ymax=std::max(ymax,graph->GetPointY(j));
        }
    }
    const double span=1.10*std::max(xmax-xmin,ymax-ymin);
    const double xc=(xmax+xmin)/2,yc=(ymax+ymin)/2;
    TCanvas cp("paths_plot","",1100,1100);cp.SetCanvasSize(1100,1100);
    cp.SetLeftMargin(.12);cp.SetRightMargin(.08);cp.SetTopMargin(.08);cp.SetBottomMargin(.12);
    cp.SetGrid();paths.Draw("AL");
    paths.GetXaxis()->SetLimits(xc-span/2,xc+span/2);
    paths.SetMinimum(yc-span/2);paths.SetMaximum(yc+span/2);
    cp.Modified();cp.Update();
    cp.SaveAs("paths.png");cp.SaveAs("paths.pdf");
    const double width=htotal.GetBinWidth(1);
    htotal.Scale(1.0/(n*width));hlast.Scale(1.0/(n*width));hscatter.Scale(1.0/(totalscatter*width));
    htotal.SetLineColor(kBlue+1);htotal.SetLineWidth(2);
    hlast.SetLineColor(kRed+1);hlast.SetLineWidth(2);
    hscatter.SetLineColor(kGreen+2);hscatter.SetLineStyle(2);hscatter.SetLineWidth(2);
    TCanvas cl("lengths_plot","",1200,850);cl.SetGrid();
    hlast.SetMaximum(.75);hlast.SetTitle("Total path versus winning step;Length [m];Probability density");
    hlast.Draw("HIST");hscatter.Draw("HIST SAME");htotal.Draw("HIST SAME");
    TLegend legend(.48,.65,.89,.88);legend.SetBorderSize(0);
    legend.AddEntry(&htotal,"Total path: mean 5 m","l");
    legend.AddEntry(&hscatter,"Winning scattering step: mean 10/7 m","l");
    legend.AddEntry(&hlast,"Final annihilation step: mean 10/7 m","l");legend.Draw();
    cl.SaveAs("path-lengths.png");cl.SaveAs("path-lengths.pdf");
    std::cout<<"transport: total="<<sumtotal/n<<", last="<<sumlast/n<<", scatter="<<sumscatter/totalscatter<<", nscatter="<<double(totalscatter)/n<<std::endl;
}

void lecture6_demo(){
    gStyle->SetOptStat(0);
    competition();transport();
}
