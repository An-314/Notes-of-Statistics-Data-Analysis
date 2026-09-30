#ifndef ELECTRON_H
#define ELECTRON_H

#include "Particle.h"

class Electron : public Particle {
public:
    Electron(double px, double py, double pz, bool hasConversionVeto)
        : Particle(px, py, pz, 0.511, -1),
          hasConversionVeto_(hasConversionVeto) {}

    const char* name() const override { return "Electron"; }
    bool hasConversionVeto() const { return hasConversionVeto_; }

private:
    bool hasConversionVeto_;
};

#endif
