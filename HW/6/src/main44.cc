#include <exception>
#include <iostream>
#include <stdexcept>
#include <string>

void ex4_4(const char *output, long long toys, const char *dataPath);
int main(int argc, char **argv) {
  if (argc > 4 || (argc == 2 && std::string(argv[1]) == "--help")) {
    std::cerr << "Usage: " << argv[0] << " [output-directory] [toys] [data-csv]\n";
    return argc > 4 ? 2 : 0;
  }
  try {
    long long toys = 2000000;
    if (argc > 2) {
      std::size_t parsed = 0;
      toys = std::stoll(argv[2], &parsed);
      if (parsed != std::string(argv[2]).size()) throw std::runtime_error("Invalid toy count");
    }
    ex4_4(argc > 1 ? argv[1] : "../pic/6", toys,
           argc > 3 ? argv[3] : "data/ex4_4.csv");
  } catch (const std::exception &error) { std::cerr << error.what() << '\n'; return 1; }
}
