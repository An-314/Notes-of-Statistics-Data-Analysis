#include <TROOT.h>
#include <exception>
#include <iostream>
#include <string>

// The build selects exactly one exercise for each executable.
#ifndef HW4_ENTRY
#error "Define HW4_ENTRY as ex3_1, ..., ex3_6"
#endif
void HW4_ENTRY(const char *output);

int main(int argc, char **argv) {
  if (argc > 2 || (argc == 2 && std::string(argv[1]) == "--help")) {
    std::cerr << "Usage: " << argv[0] << " [output-directory]\n";
    return argc > 2 ? 2 : 0;
  }
  gROOT->SetBatch(true);
  try {
    HW4_ENTRY(argc == 2 ? argv[1] : "../pic/4");
  } catch (const std::exception &error) {
    std::cerr << error.what() << '\n';
    return 1;
  }
  return 0;
}
