#include <TFile.h>
#include <TTree.h>
#include <TRandom.h>

void tree1w() {
    TFile file("tree1.root", "RECREATE");
    TTree t1("t1", "test tree");
    Float_t px, py, pz;
    Double_t random;
    Int_t i;
    t1.Branch("px", &px, "px/F");
    t1.Branch("py", &py, "py/F");
    t1.Branch("pz", &pz, "pz/F");
    t1.Branch("random", &random, "random/D");
    t1.Branch("i", &i, "i/I");
    gRandom->SetSeed(42);
    for (i = 0; i < 5000; ++i) {
        gRandom->Rannor(px, py);
        pz = px * px + py * py;
        random = gRandom->Rndm();
        t1.Fill();
    }
    t1.Write();
}
