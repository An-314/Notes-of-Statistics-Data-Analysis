#include "Particle.h"

#include <cmath>
#include <limits>

Particle::Particle(double px, double py, double pz,
                   double mass, int charge)
    : px_(px), py_(py), pz_(pz), mass_(mass), charge_(charge) {}

double Particle::energy() const {
    const double momentum = std::hypot(px_, py_, pz_);
    return std::hypot(momentum, mass_);
}

double Particle::pt() const {
    return std::hypot(px_, py_);
}

double Particle::eta() const {
    const double transverse = pt();
    if (transverse > 0.0) {
        // 等价于 -log(tan(theta / 2))，不必先求 theta。
        return std::asinh(pz_ / transverse);
    }
    if (pz_ > 0.0) {
        return std::numeric_limits<double>::infinity();
    }
    if (pz_ < 0.0) {
        return -std::numeric_limits<double>::infinity();
    }
    // 零动量的方向未定义，因而赝快度也未定义。
    return std::numeric_limits<double>::quiet_NaN();
}
