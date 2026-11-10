#include <exception>
#include <iostream>
#include <string>

void ex4_3(const char *output);
int main(int argc, char **argv) {
  if (argc > 2 || (argc == 2 && std::string(argv[1]) == "--help")) {
    std::cerr << "Usage: " << argv[0] << " [output-directory]\n";
    return argc > 2 ? 2 : 0;
  }
  try { ex4_3(argc > 1 ? argv[1] : "../pic/6"); }
  catch (const std::exception &error) { std::cerr << error.what() << '\n'; return 1; }
}
