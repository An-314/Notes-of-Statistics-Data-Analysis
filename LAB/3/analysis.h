#ifndef LAB3_ANALYSIS_H
#define LAB3_ANALYSIS_H
#include <cmath>
#include <filesystem>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <stdexcept>
#include <string>

struct Summary {
    unsigned long long n;
    double mean_x, mean_y, std_x, std_y, std_sum, correlation;
};

// Welford更新：使用全部entry，不依赖直方图范围或bin中心。
struct Moments {
    unsigned long long n = 0;
    double mean_x = 0, mean_y = 0, mean_sum = 0;
    double m2_x = 0, m2_y = 0, m2_sum = 0, cross = 0;
    void Add(double x, double y) {
        ++n;
        const double dx = x - mean_x, dy = y - mean_y;
        const double ds = x + y - mean_sum;
        mean_x += dx / n;
        mean_y += dy / n;
        mean_sum += ds / n;
        m2_x += dx * (x - mean_x);
        m2_y += dy * (y - mean_y);
        m2_sum += ds * (x + y - mean_sum);
        cross += dx * (y - mean_y);
    }
    Summary Result() const {
        if (n < 2 || m2_x <= 0 || m2_y <= 0)
            throw std::runtime_error("Not enough nonconstant data");
        return {n, mean_x, mean_y, std::sqrt(m2_x / (n - 1)),
                std::sqrt(m2_y / (n - 1)), std::sqrt(m2_sum / (n - 1)),
                cross / std::sqrt(m2_x * m2_y)};
    }
};
inline void PrepareDirectories() {
    std::filesystem::create_directories("output");
    std::filesystem::create_directories("pic");
}
inline void SaveSummary(const Summary& s, const std::string& path) {
    std::ofstream out(path);
    if (!out) throw std::runtime_error("Cannot write " + path);
    out << std::setprecision(17)
        << "{\n  \"n\": " << s.n << ",\n  \"mean_x\": " << s.mean_x
        << ",\n  \"mean_y\": " << s.mean_y << ",\n  \"std_x\": " << s.std_x
        << ",\n  \"std_y\": " << s.std_y << ",\n  \"std_sum\": " << s.std_sum
        << ",\n  \"correlation\": " << s.correlation << "\n}\n";
    if (!out) throw std::runtime_error("Failed writing " + path);
    std::cout << std::fixed << std::setprecision(8)
              << "N = " << s.n << '\n' << "s(x) = " << s.std_x << '\n'
              << "s(x+y) = " << s.std_sum << '\n'
              << "r(x,y) = " << s.correlation << '\n';
}
#endif
