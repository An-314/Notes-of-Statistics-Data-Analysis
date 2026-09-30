#ifndef PARTICLE_H
#define PARTICLE_H

class Particle {
public:
    // 采用自然单位 c = 1；动量和质量均以 MeV 为单位。
    Particle(double px, double py, double pz, double mass, int charge);
    virtual ~Particle() = default;

    double px() const { return px_; }
    double py() const { return py_; }
    double pz() const { return pz_; }
    double mass() const { return mass_; }
    int charge() const { return charge_; }

    double energy() const;
    double pt() const;
    double eta() const;
    virtual const char* name() const { return "Particle"; }

private:
    double px_;
    double py_;
    double pz_;
    double mass_;
    int charge_;
};

#endif
