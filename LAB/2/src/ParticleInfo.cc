#include "ParticleInfo.h"
#include "Particle.h"

#include <iostream>

void PrintParticleInfo(const Particle* p) {
    if (p == nullptr) {
        std::cout << "Particle pointer is null.\n";
        return;
    }
    // p 的静态类型是基类指针，name() 根据对象的实际类型动态绑定。
    std::cout << "name = " << p->name() << '\n'
              << "mass = " << p->mass() << " MeV\n"
              << "charge = " << p->charge() << " e\n"
              << "pT = " << p->pt() << " MeV\n"
              << "eta = " << p->eta() << '\n'
              << "energy = " << p->energy() << " MeV\n";
}
