#ifndef MUON_H
#define MUON_H

#include "Particle.h"

class Muon : public Particle {
public:
    Muon(double px, double py, double pz, bool isTight)
        : Particle(px, py, pz, 105.66, -1), isTight_(isTight) {}

    const char* name() const override { return "Muon"; }
    bool isTight() const { return isTight_; }

private:
    bool isTight_;
};

#endif
