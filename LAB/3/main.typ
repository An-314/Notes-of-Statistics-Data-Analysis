#import "@preview/scripst:1.1.2": *

#show: scripst.with(
  title: [统计数据分析第3次实践作业],
  author: "Anzreww",
  time: "2026年10月",
  cb-counter-depth: 1,
  matheq-depth: 1,
  font-size: 13pt,
  par-leading: 0.6em,
  counter-depth: 1,
)

#set heading(numbering: none)

#let tree = json("output/tree-statistics.json")
#let fit = json("output/fit-statistics.json")
#let rdf = json("output/rdf-statistics.json")
#let verification = json("output/verification.json")
#let f(value, digits: 6) = str(calc.round(value, digits: digits))

#newpara()
本次实验使用ROOT #verification.root_version，固定`TRandom3`种子为42。数据按10000组$(x_i,y_i)$保存，每组中的两个变量独立服从标准正态分布。三道题分别实现逐条读取、二维分布拟合和`RDataFrame`分析。

#exercise(subname: [TTree创建与基本分析])[
  生成10000个正态分布随机数$x$和$y$，均值为0、标准差为1，保存在`TTree`和`TFile`中。读取`TTree`，计算$x$和$x+y$的标准差，以及$x$和$y$的相关系数。验证相关系数是否接近0，因为$x$和$y$是独立生成的。
]

== 理论预期与统计定义

由独立性，
$
  E[x] = E[y] = 0, quad op("Var")(x) = op("Var")(y) = 1, quad op("Cov")(x,y) = 0
$
因此
$
  op("Var")(x+y) = op("Var")(x) + op("Var")(y) + 2 op("Cov")(x,y) = 2
$
即总体标准差应为$sigma_x=1$、$sigma_(x+y)=sqrt(2) approx 1.414$，总体相关系数为$rho_(x y)=0$。

有限样本采用分母为$N-1$的样本方差与样本协方差：
$
  overline(x) = 1/N sum_(i=1)^N x_i, quad
  s_x^2 = 1/(N-1) sum_(i=1)^N (x_i-overline(x))^2
$
$
  s_(x y) = 1/(N-1) sum_(i=1)^N (x_i-overline(x))(y_i-overline(y)), quad
  r_(x y) = s_(x y)/(s_x s_y)
$
$x+y$的标准差也采用同一定义。无偏的是方差估计$s_x^2$，对其开平方所得$s_x$仍有很小的有限样本偏差。

== 公共统计工具

`analysis.h`使用Welford递推累计均值、离差平方和和交叉离差，避免直接计算两个大数之差。`Summary`存放结果，`SaveSummary()`同时输出终端信息和JSON文件，报告直接读取这些结果。

#raw(read("analysis.h"), lang: "cpp", block: true)

== 创建、写入并重新读取数据

将下面的宏保存为`exercise1.C`。先逐组生成$x,y$，写入两条`Double_t`类型branch；关闭输出文件后重新打开，用`TTreeReader`读取全部记录。

#raw(read("exercise1.C"), lang: "cpp", block: true)

运行：
```sh
root -l -b -q exercise1.C
```

原始数据保存在`output/gaussian.root`中的`events`树里，branch名为`x`、`y`。每一条entry对应一组独立生成的数值。两次`Gaus(0,1)`调用分别生成$x$和$y$，没有让它们共享同一个抽样值。

#figure(
  image("pic/distributions.png", width: 100%),
  caption: [$x$与$x+y$的样本分布。右图比左图更宽，与$sigma_(x+y)=sqrt(2)$的预期一致。],
)

== 结果与相关系数验证

#figure(three-line-table[
  | 统计量 | 总体预期 | 样本结果 |
  | --- | --- | --- |
  | $N$ | 10000 | #tree.n |
  | $overline(x)$ | 0 | #f(tree.mean_x) |
  | $overline(y)$ | 0 | #f(tree.mean_y) |
  | $s_x$ | 1 | #f(tree.std_x) |
  | $s_y$ | 1 | #f(tree.std_y) |
  | $s_(x+y)$ | $sqrt(2)$ | #f(tree.std_sum) |
  | $r_(x y)$ | 0 | #f(tree.correlation) |
])

// 在$rho=0$、$N=10000$时，相关系数的典型统计波动约为
// $
//   sigma_r approx 1/sqrt(N-1) approx 0.0100
// $
// 本次$r_(x y)=$ #f(tree.correlation)，约为一个标准误差的偏离。用Fisher变换$z=op("atanh")(r)$及近似标准误差$1/sqrt(N-3)$，得到$rho$的95%置信区间为
// $ [#f(verification.correlation_ci_low), #f(verification.correlation_ci_high)] $
// 其中包含0，结果与独立标准正态模型相容。有限样本相关系数无需严格等于0；一般而言，相关系数为0也不能单独证明独立性。

// 同一组数据还满足
// $
//   s_(x+y)^2 = s_x^2 + s_y^2 + 2 r_(x y) s_x s_y
// $
// 自动核对程序同时检查这一恒等式。$s_x$约有$1/sqrt(2(N-1)) approx 0.0071$的统计误差，$s_(x+y)$约有0.0100的统计误差，因此本次标准差相对总体值的偏差也处于有限样本波动的合理范围。

#exercise(subname: [二维直方图与拟合])[
  利用第1题产生的`TTree`，生成$x$与$y$的二维直方图，写一个二维高斯函数拟合该直方图。验证拟合得到的均值、标准差和相关系数与真实值一致。
]

== 相关二维高斯模型

以$x$为横轴、$y$为纵轴。定义
$
  u = (x-mu_x)/sigma_x, quad v = (y-mu_y)/sigma_y
$
相关二维高斯概率密度为
$
  f(x,y) = 1/(2 pi sigma_x sigma_y sqrt(1-rho^2))
  exp[-(u^2 - 2 rho u v + v^2)/(2(1-rho^2))]
$
其中$sigma_x,sigma_y>0$、$abs(rho)<1$。独立标准正态分布对应
$
  mu_x=mu_y=0, quad sigma_x=sigma_y=1, quad rho=0
$
不能在拟合函数中固定$rho=0$，否则无法检验拟合是否恢复了接近零的相关系数。

直方图范围为$[-5,5) times [-5,5)$，两个方向各50个bin，bin面积为$A=0.2 times 0.2=0.04$。计数直方图中第$(i,j)$个bin的期望为
$
  nu_(i j) = N_("fit") integral_(x_i)^(x_(i+1)) integral_(y_j)^(y_(j+1)) f(x,y) dif y dif x
$
归一化参数$N_("fit")$与五个形状参数一起自由拟合。

== 拟合方法与完整代码

采用泊松似然处理二维计数，空bin也参与拟合。ROOT的`I`选项使用函数在bin内的积分除以bin面积，因此`TF2`定义为
$
  F(x,y) = N_("fit") A f(x,y)
$
这样bin平均值恰好等于上面的期望计数$nu_(i j)$。`bin_area`是固定参数，六个自由参数为$N_("fit")$、$mu_x$、$sigma_x$、$mu_y$、$sigma_y$、$rho$。

#figure(three-line-table[
  | 选项 | 作用 |
  | --- | --- |
  | `S` | 返回完整的`TFitResult` |
  | `L` | 使用泊松似然 |
  | `I` | 对每个bin计算积分平均，减少bin中心近似偏差 |
  | `R` | 使用函数定义的拟合范围 |
  | `0` | 拟合时不自动绘制函数 |
  | `Q` | 减少拟合器常规输出 |
])

宏`exercise2.C`直接读取第1题的文件。拟合结束后保存直方图、可重新读取的公式型`TF2`、拟合结果和参数表：

#raw(read("exercise2.C"), lang: "cpp", block: true)

运行：
```sh
root -l -b -q exercise2.C
```

#figure(
  image("pic/fit2d.png", width: 100%),
  caption: [左：二维计数直方图；右：拟合模型给出的每bin期望计数在各位置的连续近似显示。两幅图均以$x$为横轴、$y$为纵轴。],
)

== 拟合结果

拟合返回状态为 #fit.status，协方差矩阵状态为 #fit.covariance_status，即拟合成功且协方差矩阵准确。表中的误差来自拟合协方差矩阵，定义偏差
$ "pull" = (hat(theta)-theta_("true")) / (delta hat(theta)) $
用来比较估计值相对生成参数的偏离程度。

#figure(three-line-table[
  | 参数 | 真实值 | 拟合值 | 标准误差 | pull |
  | --- | --- | --- | --- | --- |
  | $mu_x$ | 0 | #f(fit.mu_x) | #f(fit.mu_x_error) | #f(fit.mu_x_pull, digits: 3) |
  | $mu_y$ | 0 | #f(fit.mu_y) | #f(fit.mu_y_error) | #f(fit.mu_y_pull, digits: 3) |
  | $sigma_x$ | 1 | #f(fit.sigma_x) | #f(fit.sigma_x_error) | #f(fit.sigma_x_pull, digits: 3) |
  | $sigma_y$ | 1 | #f(fit.sigma_y) | #f(fit.sigma_y_error) | #f(fit.sigma_y_pull, digits: 3) |
  | $rho$ | 0 | #f(fit.rho) | #f(fit.rho_error) | #f(fit.rho_pull, digits: 3) |
])

归一化参数为$N_("fit")=$ #f(fit.N, digits: 2) $plus.minus$ #f(fit.N_error, digits: 2)。全部10000条数据都用于第1题的原始统计；其中 #fit.in_range 条落在当前二维范围内，另有 #int(fit.entries - fit.in_range) 条进入上溢或下溢。

// 拟合使用普通bin，并对所选范围内的模型积分，不能把越界记录误计成丢失的文件数据。

均值接近0、两个标准差接近1，相关系数为 #f(fit.rho) $plus.minus$ #f(fit.rho_error)，与0相容。$sigma_x$偏高约2.40个拟合误差，比其余参数的偏差明显一些；各形状参数的绝对pull均小于3，结果与本次有限样本波动相容。

// 这不意味着每次重新抽样都必然满足同一阈值。

// 直方图拟合包含分bin及范围限制，参数不必与第1题的未分bin样本矩逐位相等。两组估计又来自同一批数据，因此不能把它们当作两次独立测量来合并误差。

#exercise(subname: [RDataFrame重写])[
  将第1题用`RDataFrame`重写，实现相同的功能。
]

== 生成、保存与重新分析

`exercise3.C`使用只有10000条entry的`RDataFrame`作为数据源。在一个`Define()`中生成一对随机数，再拆成`x`、`y`两列；这可确保每条entry的两个数作为同一组被保存。生成阶段使用单线程和相同种子，保持与第1题一致的抽样顺序。

先用`Snapshot()`写入文件，再从该文件创建新的`RDataFrame`进行统计。这样访问统计结果不会重新生成随机数。所有统计action预订后才触发计算，读取统计阶段只需一次事例循环。

#raw(read("exercise3.C"), lang: "cpp", block: true)

运行：
```sh
root -l -b -q exercise3.C
```

`StdDev()`采用分母为$N-1$的样本定义。计算相关系数时，`Mean("xy_product")`给出$overline(x y)$，所以还需要修正样本协方差的分母：
$
  s_(x y) = N/(N-1) (overline(x y)-overline(x) dot overline(y)), quad
  r_(x y) = s_(x y)/(s_x s_y)
$
#figure(three-line-table[
  | 统计量 | 逐条读取 | RDataFrame |
  | --- | --- | --- |
  | $N$ | #tree.n | #rdf.n |
  | $s_x$ | #f(tree.std_x, digits: 8) | #f(rdf.std_x, digits: 8) |
  | $s_(x+y)$ | #f(tree.std_sum, digits: 8) | #f(rdf.std_sum, digits: 8) |
  | $r_(x y)$ | #f(tree.correlation, digits: 8) | #f(rdf.correlation, digits: 8) |
])

// 独立核对程序确认两个文件的10000组$(x,y)$逐组完全一致，均值、标准差与相关系数也与Python标准库的独立计算一致，数值差异小于$10^(-12)$。这不仅比较了打印出来的有限小数，也检查了实际保存的数据。

// 若要开启多线程，需要另行设计随机数状态管理。不能让多个线程同时访问这个捕获的`TRandom3`实例，也不能直接假定改变线程数后仍会得到相同的逐entry序列。

// == 一次运行与结果复核

// 脚本`run.sh`按题号依次执行三个宏，再用`check_results.py`检查文件、统计量、拟合状态及保存后重新读取的函数：

// #raw(read("run.sh"), lang: "bash", block: true)

// ```sh
// bash run.sh
// ```

// `check_results.py`直接读取两个ROOT文件，使用Python标准库的`statistics.stdev()`和`statistics.correlation()`独立核对；还检查方差恒等式、二维直方图的越界计数，以及重新打开的`TF2`能否正确计算数值。所有检查均已通过；完整输出保存在`run-output.txt`，核对摘要如下：

// #raw(
//   read("run-output.txt")
//     .split("\n")
//     .filter(line => line.starts-with("PASS:") or line.starts-with("Correlation 95%"))
//     .join("\n"),
//   lang: "text",
//   block: true,
// )

// 在仓库根目录编译报告：
// ```sh
// make builds/LAB/LAB3.pdf
// ```

// 接口细节可查阅#link("https://root.cern.ch/doc/master/classTH1.html")[ROOT直方图拟合文档]和#link("https://root.cern.ch/doc/master/classROOT_1_1RDataFrame.html")[RDataFrame参考文档]。
