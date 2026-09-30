#include "Electron.h"
#include "Muon.h"
#include "ParticleInfo.h"

#include <iomanip>
#include <iostream>

int main() {
    const Muon muon(300.0, 400.0, 500.0, true);
    const Electron electron(600.0, 800.0, -1000.0, false);

    const Particle* particles[] = {&muon, &electron};
    std::cout << std::fixed << std::setprecision(6) << std::boolalpha;
    for (const Particle* p : particles) {
        PrintParticleInfo(p);
        std::cout << '\n';
    }

    std::cout << "Muon isTight = " << muon.isTight() << '\n'
              << "Electron hasConversionVeto = "
              << electron.hasConversionVeto() << '\n';
    return 0;
}
