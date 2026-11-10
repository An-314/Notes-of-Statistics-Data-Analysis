#include <TFile.h>
#include <TTree.h>
#include <TRandom.h>

void gen() {
    TFile file("test.root", "RECREATE");
    const double L1 = 2.0, L2 = 5.0;
    double r1, r2, r;
    int flag;
    TTree tree("tree", "Competing processes");
    tree.Branch("Lstep", &r, "Lstep/D");
    tree.Branch("L1", &r1, "L1/D");
    tree.Branch("L2", &r2, "L2/D");
    tree.Branch("flag", &flag, "flag/I");
    gRandom->SetSeed(42);
    for (int i = 0; i < 1000000; ++i) {
        r1 = gRandom->Exp(L1);
        r2 = gRandom->Exp(L2);
        if (r1 < r2) {
            r = r1;
            flag = 0;
        } else {
            r = r2;
            flag = 1;
        }
        tree.Fill();
    }
    tree.Write();
}
