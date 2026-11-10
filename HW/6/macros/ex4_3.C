#include "../include/HW6Common.h"

// Run from HW/6: root -l -b -q 'macros/ex4_3.C()'
void ex4_3(const char *output = "../pic/6") {
  using namespace hw6;
  initialize();
  Output files(output, "4-3");
  // BEGIN 4.3
  const double expected = 3.9;
  const int observed = 16;
  const double pPoisson =
      ROOT::Math::poisson_cdf_c(observed - 1, expected);
  const double pChi2 =
      ROOT::Math::chisquared_cdf(2 * expected, 2 * observed);
  const double z = ROOT::Math::normal_quantile_c(pPoisson, 1.0);
  // END 4.3
  if (std::abs(pPoisson - pChi2) > 1e-12 * pPoisson)
    throw std::runtime_error("Poisson/chi-square identity failed");
  files.stats << "expected,observed,p_poisson,p_chi2_lower,Z\n"
              << expected << ',' << observed << ',' << pPoisson << ','
              << pChi2 << ',' << z << '\n';
  files.meta << "Null: Poisson with fixed mean 3.9\n"
             << "Right tail includes observed count 16.\n"
             << "The equivalent chi-square probability is the LOWER tail.\n";
  std::cout << std::setprecision(12) << "4.3: p=" << pPoisson
            << ", chi-square lower CDF=" << pChi2 << ", Z=" << z << '\n';
}
