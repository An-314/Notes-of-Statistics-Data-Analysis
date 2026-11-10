# 第4次实践作业：二维散射与湮灭

从仓库根目录运行：

```sh
bash LAB/4/run.sh
make builds/LAB/LAB4.pdf
```

报告输出为 `builds/LAB/LAB4.pdf`。单独运行宏时，先进入 `LAB/4` 再执行 `root -l -b -q exercise.C`。

- `simulation.h`：单粒子的竞争抽样与二维输运。
- `exercise.C`：模拟20万粒子、生成TTree、100条TGraph和三张图，输出未截断的统计结果。
- `check_results.py`：独立读回数据，逐步检查竞争选择、轨迹和全部直方图，并重新计算均值和标准误差。
- `run-output.txt`：已经实际运行通过的日志。
- `pic/`：单粒子、100粒子叠加和三种路程分布。
- `output/transport.root`：原始数据、原始计数直方图，以及 `track_000` 至 `track_099` 和 `single_track`。
- `output/statistics.json`、`output/verification.json`：报告直接读取的结果和核对记录。

ROOT宏使用固定种子42，长度以米计，角度在程序中使用弧度。运行脚本还需要Python 3和PyROOT。

统计口径：总路程是入射到湮灭的折线总长；散射步是所有实际结束于散射的相邻相互作用段；湮灭步是每个粒子的最后一段。理论均值分别为 `5 m`、`10/7 m`、`10/7 m`。候选距离的均值才是输入的 `2 m` 和 `5 m`，报告中另列候选数值作为检查。

结果由全部未分箱数据计算，直方图上溢不被丢弃。生成的ROOT文件和单张图的PDF已忽略版本跟踪，可由脚本重新生成。
