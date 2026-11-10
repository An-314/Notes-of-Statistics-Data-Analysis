# 第6次作业：统计检验

习题4.3与4.4使用两个独立的C++/ROOT宏；默认以Makefile编译运行，也可以直接使用ROOT。无需Python或CMake。

```text
HW/6/
├── data/ex4_4.csv       题目表4.1的20个分箱
├── include/HW6Common.h 数据读取、Pearson统计量与绘图工具
├── macros/ex4_3.C      Poisson右尾与χ²下尾CDF交叉核验
├── macros/ex4_4.C      数据图和两种理论的Poisson伪实验
├── src/main43.cc       独立可执行程序入口
├── src/main44.cc       独立可执行程序入口
├── Makefile
└── run_all.sh          依次运行两个ROOT宏
```

从笔记项目根目录编译并运行全部作业：

```sh
make -C HW/6 run
```

需要ROOT 6、`root-config`、C++编译器和GNU Make；本次验证使用ROOT 6.40.04。默认每个理论产生2,000,000组伪实验，两个独立的TRandom3种子分别为20261101和20261102。参数可调整：

```sh
make -C HW/6 run TOYS=1000000
make -C HW/6 run OUTPUT=/tmp/hw6-results
```

单独运行某题时，先进入项目目录：

```sh
cd HW/6
./bin/ex4_3
./bin/ex4_4 ../pic/6 2000000 data/ex4_4.csv
```

直接用ROOT宏运行，不需要手动编译：

```sh
cd HW/6
bash run_all.sh
root -l -b -q 'macros/ex4_3.C()'
root -l -b -q 'macros/ex4_4.C("../pic/6",2000000)'
```

`run_all.sh`可在任意当前目录调用，参数依次为输出目录、每个模型的伪实验数。`make clean`只删除本项目两个可执行程序，保留原始数据、图表和结果。

## 统计约定

- 4.3计算`P(N≥16|ν=3.9)`，即包含16的右尾；等价表达式是χ²分布32自由度在7.8处的**下尾CDF**。
- 4.4保留题给的固定预期计数。各分箱独立产生Poisson计数，既不把总数固定为49，也不重新归一化理论预期。
- Pearson统计量的分母是理论预期ν，空的观测分箱仍须保留。两种理论均未拟合参数，渐近比较采用20自由度。
- p值直接由未分箱统计量`Q*≥Qobs`的次数计算；比较时保留完整的观测统计量，使用`1e-12`绝对容差处理浮点相等。画图范围外的伪实验仍计入p值与归一化。
- 图中数据误差棒为`√n`，仅帮助显示计数起伏；它们不用于Pearson统计量的分母。

## 输出与复现

全部输出默认位于`HW/pic/6/`；每题只更新自己的文件。

| 文件 | 内容 |
| --- | --- |
| `4-3-results.csv` | 两种CDF计算的p值与单侧Gauss等效显著性 |
| `4-3-run-info.txt` | ROOT版本与尾部约定 |
| `4-4-results.csv` | 两理论的Q、渐近p、MC尾部计数、p及MC误差、样本矩和范围外计数 |
| `4-4-run-info.txt` | ROOT版本、数据路径、种子、模拟量及矩的核验 |
| `4-4-data-theory.svg` | 观测计数与两种理论预言 |
| `4-4-pearson-toys.svg` | 各理论下的Q分布、χ²20近似及观测Q位置 |

两种理论的精确矩为`E[Q]=20`、`Var[Q]=Σ(2+1/ν_i)`；MC结果可与之对照，而不是要求方差等于χ²20的40。改变ROOT版本或随机数算法可能改变具体MC结果；统计误差随样本量约按`1/√B`缩小。

生成图表后，从笔记项目根目录编译作业：

```sh
typst compile HW/6.typ builds/HW/6.pdf
```
