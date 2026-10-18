# 第4次作业：ROOT Monte Carlo 项目

习题3.1–3.6使用 **C++ 和 ROOT**，每题是一个可以单独执行的 `.C` 宏。
LAB第2、3讲介绍C++；ROOT讲义第12页介绍PyROOT，第14页展示宏的解释、编译及批处理运行，第15页明确ROOT使用C++语法，第36–37页提供完整的C++宏示例。本项目采用这些讲义中的C++宏方式。

## 目录

```text
HW/
├── 4.typ                    作业题目、解析和模拟结果
├── 4.pdf                    编译后的作业
├── 4/
│   ├── README.md
│   ├── run_all.sh           顺序运行六题并汇总结果
│   ├── Makefile
│   ├── include/
│   │   └── HW4Common.h      样本矩、分位数、绘图样式和输出工具
│   ├── macros/
│   │   ├── ex3_1.C          均匀随机数
│   │   ├── ex3_2.C          多项分布与区间计数关联
│   │   ├── ex3_3.C          反函数法与舍选法
│   │   ├── ex3_4.C          中心极限定理，n=1,...,20
│   │   ├── ex3_5.C          指数衰变时间加Gauss测量误差
│   │   └── ex3_6.C          Cauchy分布及样本平均值
│   ├── src/
│   │   └── main.cc          六个可执行程序共用的命令行入口
│   └── bin/                Make生成的六个可执行文件
└── pic/4/                  图片、每题CSV及汇总结果
```

每道题的抽样、绘图及统计计算都在对应宏中，公共头文件只提供通用工具。`run_all.sh`依次调用六个程序，汇总它们已经写出的结果；它不包含抽样或绘图算法。作业中的代码片段直接从对应宏读取，避免文档和程序各自维护一份。

## 环境

- ROOT 6，提供`root`和`root-config`；本次运行验证使用ROOT 6.40.04。
- 直接解释执行宏时无需手动编译。
- 编译执行时需要C++编译器，语言标准与本机ROOT一致。Make通过`root-config`获取本机ROOT的编译、链接参数。
- 构建需要GNU Make。
- 统一运行脚本使用Bash，不依赖Python。
- 重新生成作业PDF时需要Typst和项目已使用的Scripst包。

下面的命令均从`HW/4/`目录运行。结果默认写入`../pic/4/`，与作业中的图片路径一致。

## 方式一：ROOT宏

运行全部六题：

```sh
bash run_all.sh
```

单独运行，例如习题3.2：

```sh
root -l -b -q 'macros/ex3_2.C()'
```

指定输出目录：

```sh
root -l -b -q 'macros/ex3_2.C("output")'
bash run_all.sh output
```

ROOT交互环境也可以加载宏后调用：

```text
root [0] .L macros/ex3_2.C
root [1] ex3_2("output")
```

函数运行后会保存图片和统计文件。使用ACLiC编译时，把加载命令写成`.L macros/ex3_2.C+`。这里展示ROOT提示符，实际输入时只输入提示符后面的部分。

## 方式二：Make编译

```sh
make -j2
./bin/ex3_2                    # 单独运行3.2
./bin/ex3_2 output             # 指定输出目录
make run                      # 运行全部六题并汇总
make run OUTPUT=output        # 指定全部结果的输出目录
```

生成`bin/ex3_1`到`bin/ex3_6`，每个程序只链接对应题目的宏。Make也提供`make macros`，直接以ROOT宏方式运行全部六题。
`make clean`仅删除这六个可执行文件，保留图片和CSV。

ROOT安装在非系统目录时，把该安装的`bin/`加入`PATH`，或通过`make ROOT_CONFIG=/path/to/root-config`指定其路径。

## 输出及复现

保留原始随机数种子及抽样次序：基础种子为20261014，六题分别使用偏移1000到6000；3.2按重复实验编号、3.4按`n`、3.5按`tau`组继续加偏移。固定ROOT版本时，拆分前后的数值结果一致。

| 宏 | 抽样量 | 生成的SVG |
| --- | --- | --- |
| `ex3_1.C` | 10000个随机数，100个bin | `3-1-uniform.svg` |
| `ex3_2.C` | 100次实验，每次100个事件 | `3-2-multinomial.svg` |
| `ex3_3.C` | 两种方法各10000个有效样本 | `3-3-triangular.svg` |
| `ex3_4.C` | 20种`n`，各10000个样本 | `3-4-clt-1.svg`至`3-4-clt-4.svg` |
| `ex3_5.C` | 三种`tau`，各100000个事件 | `3-5-exgaussian.svg` |
| `ex3_6.C` | 原始值与10项均值各10000个 | `3-6-cauchy.svg` |

每题分别写入`3-1-results.csv`到`3-6-results.csv`及对应的`3-i-run-info.txt`。**单独运行某题只更新该题的文件**。`run_all.sh`和`make run`在六题全部完成后，将CSV按题号合并成`results.csv`，并生成`run-info.txt`。单独重跑某题后，如需更新总表，应再次运行统一入口。

CSV列为`case,N,mean,sd,auxiliary1,auxiliary2`；`sd`使用除数`N-1`的样本标准差，3.6的总体均值与标准差不存在，相关列写`NA`。辅助列含义如下：

| 记录 | `auxiliary1` | `auxiliary2` |
| --- | --- | --- |
| 3.1 | 下溢计数 | 上溢计数 |
| 3.2 | `n2,n3`的样本协方差 | 样本相关系数 |
| 3.3反函数法 | 未使用，填0 | 未使用，填0 |
| 3.3舍选法 | 总尝试数 | 接受率 |
| 3.4 | 样本超额峭度 | 对标准Gauss CDF的经验KS距离，不是p值 |
| 3.5 | 负测量时间比例 | 绘图范围外计数 |
| 3.6 | 样本中位数 | 样本四分位距 |

## 重新编译作业

先运行统一入口更新图片，再回到笔记项目根目录：

```sh
cd ../..
typst compile --root . HW/4.typ HW/4.pdf
```

现有笔记项目的`make builds/HW/4.pdf`规则同样可用。构建文件和可执行文件位于本项目自己的目录，不占用其他LAB的构建目录。
