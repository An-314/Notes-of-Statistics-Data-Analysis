from array import array
from ROOT import gRandom, TFile, TTree


def tree1w(filename="tree1.root"):
    file = TFile(filename, "RECREATE")
    t1 = TTree("t1", "test tree")
    px, py, pz = (array("f", [0]) for _ in range(3))
    random = array("d", [0])
    i = array("i", [0])
    t1.Branch("px", px, "px/F")
    t1.Branch("py", py, "py/F")
    t1.Branch("pz", pz, "pz/F")
    t1.Branch("random", random, "random/D")
    t1.Branch("i", i, "i/I")
    gRandom.SetSeed(42)
    for entry in range(5000):
        gRandom.Rannor(px, py)
        pz[0] = px[0] ** 2 + py[0] ** 2
        random[0] = gRandom.Rndm()
        i[0] = entry
        t1.Fill()
    t1.Write()
    file.Close()


if __name__ == "__main__":
    tree1w()
