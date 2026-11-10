#ifndef LAB4_SIMULATION_H
#define LAB4_SIMULATION_H

#include <TRandom3.h>
#include <cmath>
#include <vector>

namespace lab4 {
constexpr double pi = 3.14159265358979323846;
constexpr double angle_limit = pi / 6.0;
constexpr double lambda_scatter = 2.0;
constexpr double lambda_annihilation = 5.0;

struct Track {
    double theta0 = 0.0, total = 0.0, last = 0.0;
    double x = 0.0, y = 0.0;
    std::vector<double> path_x{0.0}, path_y{0.0};
    std::vector<double> scatter_steps, turns;
    std::vector<double> candidate_scatter, candidate_annihilation;
};

inline Track Simulate(TRandom3& random) {
    Track track;
    double theta = track.theta0 = random.Uniform(-angle_limit, angle_limit);
    while (true) {
        const double ls = random.Exp(lambda_scatter);
        const double la = random.Exp(lambda_annihilation);
        track.candidate_scatter.push_back(ls);
        track.candidate_annihilation.push_back(la);
        const bool scatter = ls < la;
        const double step = scatter ? ls : la;
        track.x += step * std::cos(theta);
        track.y += step * std::sin(theta);
        track.total += step;
        track.path_x.push_back(track.x);
        track.path_y.push_back(track.y);
        if (!scatter) {
            track.last = step;
            break;
        }
        track.scatter_steps.push_back(step);
        const double turn = random.Uniform(-angle_limit, angle_limit);
        track.turns.push_back(turn);
        theta += turn;  // 偏转相对当前方向累加，不重置绝对方向。
    }
    return track;
}
}  // namespace lab4
#endif
