#import "@preview/scripst:1.1.2": *

#show: scripst.with(
  title: [统计数据分析第4次作业],
  author: "Anzreww",
  time: "2026年10月",
  cb-counter-depth: 1,
  matheq-depth: 1,
  font-size: 13pt,
  par-leading: 0.6em,
  counter-depth: 1,
)

#let snippet(id) = {
  let src = read("4/macros/ex" + id.replace(".", "_") + ".C")
  let lines = src.split("// BEGIN " + id).at(1).split("// END " + id).at(0).split("\n")
  let nonempty = lines.enumerate().filter(pair => pair.last().trim() != "")
  let lines = lines.slice(nonempty.first().first(), nonempty.last().first() + 1)
  // 去掉公共缩进，保留代码内部的相对缩进。
  let indent = calc.min(
    ..lines
      .filter(line => line.trim() != "")
      .map(
        line => line.match(regex("^\\s*")).text.len(),
      ),
  )
  let code = lines.map(line => line.slice(calc.min(indent, line.len()))).join("\n")
  raw(code, lang: "cpp", block: true)
}

// #note[
//   以下图表均由ROOT 6.40.04实际运行生成。C++项目位于 `HW/4/`，习题3.1—3.6分别由 `macros/ex3_1.C` 至 `macros/ex3_6.C` 独立完成；公共统计和绘图工具在 `include/HW4Common.h`。文中的代码直接读取对应宏的核心抽样部分。

//   从笔记项目根目录运行全部习题：
//   ```sh
//   cd HW/4
//   bash run_all.sh
//   ```
//   只运行一道题，例如习题3.2：
//   ```sh
//   root -l -b -q 'macros/ex3_2.C()'
//   ```
//   也提供Makefile编译方式，详见 `HW/4/README.md`。程序采用 `TRandom3`，基础种子为20261014；各题沿用不同偏移，习题3.2每次实验自动更新种子。图像与每题独立的CSV默认写入 `HW/pic/4/`；统一入口还生成汇总文件 `results.csv` 和 `run-info.txt`。单独运行某题不会覆盖其他题的统计结果。
// ]

事先写了`Moments`结构体来满足计算矩的需要，方便计算样本均值、方差和超额峭度：
```cpp
struct Moments {
  long n = 0;
  double s1 = 0, s2 = 0, s3 = 0, s4 = 0;
  void add(double x) {
    ++n;
    s1 += x;
    s2 += x * x;
    s3 += x * x * x;
    s4 += x * x * x * x;
  }
  double mean() const { return s1 / n; }
  double variance() const { return (s2 - s1 * s1 / n) / (n - 1); }
  double excess() const {
    double m = mean(), v = s2 / n - m * m;
    return (s4 / n - 4 * m * s3 / n + 6 * m * m * s2 / n -
            3 * m * m * m * m) /
               (v * v) -
           3;
  }
};
```

#exercise(subname: [3.1], lab: "3.1")[
  写一段小程序，利用ROOT中的随机数产生子产生 $10^4$ 个 $(0,1]$ 之间均匀分布的随机数，将结果画到直方图中（分100个区间）。
]

#solution[
  在 $[0,1]$ 上设置100个等宽区间，每个区间宽度 $Delta u=0.01$。产生 $N=10^4$ 个均匀随机数，用 `TH1D::Fill` 填入相应区间：
  #snippet("3.1")

  本次模拟的样本平均为 $overline(u)=0.498623$，样本标准偏差为 $s_u=0.289062$；理论值分别为 $1/2$ 和 $1/sqrt(12) approx 0.288675$。
]

#figure(
  image("pic/4/3-1-uniform.svg", width: 100%),
  caption: [$10^4$ 个均匀随机数、100个区间蓝：线为ROOT模拟，红线为每区间的预期计数100],
)

// #note[
//   `TRandom3::Rndm()` 返回的数严格位于 $(0,1)$，不包含0和1；代码的 $u=1-r$ 同样位于这个区间，满足题目要求的取值范围。连续均匀分布的单点概率为零，端点是否包含不改变其理论分布，也避免了恰为1的数进入ROOT上溢区间。#footnote[#link("https://root.cern.ch/doc/master/classTRandom3.html")[ROOT：TRandom3参考文档。]]
// ]

#exercise(subname: [3.2])[
  修改 @3.1 中的直方图，使其只有5个区间，事例数 $N=100$。产生的直方图可以看作对矢量 $(n_1,dots,n_5)$ 的观测，该矢量满足参数 $N=100$、$p_i=0.2$（$i=1,dots,5$）的多项分布。

  (a) 将上面的程序代码放到循环中产生直方图，重复该MC实验100次，每次用不同的随机数种子。只要保证每次实验程序不中断，程序在下一次实验（即下一个循环）时自动更新种子。定义一个直方图，将每次实验第 $i$ 个区间（比如 $i=3$）的值填充其中。这应该服从均值为 $N p_i=20$、标准偏差为 $sqrt(N p_i (1-p_i))=4$ 的二项分布。

  (b) 为任意两个区间的值 $n_i$ 和 $n_j$ 作出散点图（二维直方图）。其协方差的理论值为 $"cov"[n_i,n_j]=-N p_i p_j=-4$，或者说关联系数 $rho=-4/4^2=-0.25$。
]

#solution[
  每个随机数以相同概率 $0.2$ 落入五个区间之一，故
  $
    P(n_1,dots,n_5)=100!/(n_1! dots n_5!) product_(j=1)^5 (0.2)^(n_j),
    quad sum_(j=1)^5 n_j=100
  $
  对一个指定区间，只区分“落入该区间”与“落入其他区间”，得到
  $
    n_3 tilde "Binomial"(100,0.2), quad E[n_3]=20, quad V[n_3]=16
  $
  对不同区间 $i!=j$，令 $I_(k i)$ 表示第 $k$ 个随机数落入第 $i$ 区间。一个随机数不能同时落入两个区间，所以
  $
    E[I_(k i) I_(k j)]=0, quad
    "cov"[I_(k i),I_(k j)]=-p_i p_j=-0.04
  $
  不同事件之间独立，因而
  $
    "cov"[n_i,n_j] & =sum_(k=1)^100 "cov"[I_(k i),I_(k j)]=-100(0.2)^2=-4 \
         rho_(i j) & =-4/(4 times 4)=-0.25
  $

  #newpara()
  每次循环重新设置不同的非零种子，清空五区间直方图，再填入100个事件。随后取第3区间的计数填入一维直方图，并将 $(n_2,n_3)$ 填入二维直方图：
  #snippet("3.2")

  100次模拟给出
  $
    overline(n)_3=19.67, quad s_(n_3)=3.93650 \
    hat("cov")[n_2,n_3]=-4.53071, quad hat(rho)_(2 3)=-0.28669
  $
  理论值是20、4、$-4$ 和 $-0.25$。

  散点的负相关可理解为：五个计数之和固定；一个区间多分到事件，就会减少其他区间可分到的事件。条件平均值为
  $
    E[n_3|n_2]=(100-n_2) 0.2/(1-0.2)=(100-n_2)/4
  $
]

#figure(
  image("pic/4/3-2-multinomial.svg", width: 100%),
  caption: [左：100次实验的 $n_3$ 直方图，红线为 $100 times P(n_3=k)$ 的二项分布预期。右：$(n_2,n_3)$ 的二维频数图，色标为重复次数，红线为条件平均值 $(100-n_2)/4$。],
)

#exercise(subname: [3.3])[
  考虑锯齿分布
  $
    f(x)=cases((2x)/x_("max")^2 & quad 0<x<x_("max"), 0 & quad "其它")
  $<->
  #newpara()
  (a) 参考课本3.2节，利用变换方法寻找函数 $x(r)$，以产生服从 $f(x)$ 的随机数。用程序实现该方法，并生成一个直方图。（可以取 $x_("max")=1$。）

  (b) 参考课本3.3节，编写一段程序，利用舍选法产生服从锯齿分布的随机数。画出相应的直方图。
]

#solution[
  *反函数法。* 对 $0<=x<=x_("max")$，累计分布函数为
  $
    F(x)=integral_0^x (2u)/x_("max")^2 dd(u)=x^2/x_("max")^2
  $
  令 $r=F(x)$，则
  $
    x(r)=x_("max") sqrt(r), quad r tilde U(0,1)
  $
  每个随机数都转换为一个有效样本，接受率为100%。

  *舍选法。* 目标函数的上界为 $f_("max")=2/x_("max")$。独立产生 $r_1,r_2$，令
  $
    x=x_("max") r_1, quad u=2/x_("max") r_2
  $
  当 $u<f(x)$ 时接受，即 $r_2<r_1$ 时接受。接受概率为
  $
    eta=(integral_0^(x_("max")) f(x) dd(x))/(x_("max") f_("max"))=1/2
  $
  条件于接受，横坐标密度与 $f(x)$ 成正比，正好是所求分布。

  取 $x_("max")=1$，两种方法分别产生10000个有效样本：
  #snippet("3.3")

  理论矩为
  $
    E[x]=integral_0^(x_("max")) x f(x) dd(x)=2/3 x_("max"), quad
    E[x^2]=x_("max")^2/2, quad V[x]=x_("max")^2/18
  $
  反函数法得到平均值0.664307、标准偏差0.235874；舍选法得到平均值0.670984、标准偏差0.235771。理论值分别为 $2/3 approx 0.666667$ 和 $1/sqrt(18) approx 0.235702$。舍选法共尝试20008次，接受10000次，实际接受率约49.980%，符合理论的50%。
]

#figure(
  image("pic/4/3-3-triangular.svg", width: 100%),
  caption: [两种方法抽样同一锯齿分布。每图50个区间、10000个有效样本；红线为按 $N Delta x f(x)$ 换算的预期计数。],
)

#exercise(subname: [3.4])[
  该练习的目的是产生服从Gauss分布的随机数。有很多算法可以产生Gauss分布，一个最简单的适合教学目的的算法基于中心极限定理：当 $n$ 很大时，$n$ 个随机数之和趋向于Gauss分布，只要其中任何一项不占绝对份额（参考课本第10章）。

  (a) 假设 $x$ 均匀分布于 $[0,1]$，考虑 $n$ 个独立随机变量 $x$ 之和，
  $
    y=sum_(i=1)^n x_i
  $<->
  证明 $y$ 的期待值为 $n/2$，方差为 $n/12$。并证明变量
  $
    z=(sum_(i=1)^n x_i-n/2)/sqrt(n/12)
  $<->
  均值为零，标准偏差为1。

  (b) 写一段小程序产生(a)中定义的变量 $z$，$n$ 可以为任意值。分别取 $n=1,dots,20$，生成直方图，每个直方图包含 $10^4$ 个 $z$ 的值。何时 $z$ 的分布近似为Gauss分布？作为简单的Gauss分布产生子，可以取 $n=12$。评论此算法的局限性。选作：对于 $n=2$，推导出 $z$ 的概率密度函数的显式形式。
]

#solution[
  *均值与方差。* 对均匀变量，
  $
    E[x_i]=integral_0^1 x dd(x)=1/2, quad
    E[x_i^2]=1/3, quad V[x_i]=1/3-1/4=1/12
  $
  各项独立，故
  $
    E[y]=sum_(i=1)^n E[x_i]=n/2, quad
    V[y]=sum_(i=1)^n V[x_i]=n/12
  $
  标准化得到
  $
    E[z]=(E[y]-n/2)/sqrt(n/12)=0, quad
    V[z]=V[y]/(n/12)=1, quad sigma_z=1
  $
  这些矩的结果对每一个 $n>=1$ 都严格成立；“标准Gauss分布”则只在 $n arrow infinity$ 的极限中成立。

  完整程序对 $n=1,dots,20$ 循环，每个 $n$ 设置种子 `20261014 + 4000 + n`，建立自己的直方图。核心循环如下，其中 `h` 是当前 $n$ 的直方图：
  #snippet("3.4")

  各图蓝线为10000个模拟样本，红线为具有相同事件数与区间宽度的标准Gauss预期。$n=1$ 是均匀分布，$n=2$ 是三角形分布；$n$ 增加后中心区域逐渐呈钟形。在这些直方图的精度下，$n$ 为5左右已呈较明显的钟形，$n$ 为10至12时中心区域与标准Gauss分布较接近。但“何时近似”依赖于精度要求和所关心的区域，不能用一个固定的 $n$ 保证所有尾部概率准确。
]

#figure(image("pic/4/3-4-clt-1.svg", width: 100%), caption: [$n=1,dots,6$，每个 $n$ 的直方图各包含10000个样本。])
#figure(image("pic/4/3-4-clt-2.svg", width: 100%), caption: [$n=7,dots,12$。])
#figure(image("pic/4/3-4-clt-3.svg", width: 100%), caption: [$n=13,dots,18$。])
#figure(image("pic/4/3-4-clt-4.svg", width: 100%), caption: [$n=19,20$。])

*算法的局限性。* 标准化只能保证均值0和方差1，不能把有限 $n$ 的分布变成精确Gauss分布。特别是
$
  0<=y<=n quad arrow quad -sqrt(3n)<=z<=sqrt(3n)
$
所以它的范围有限，而标准Gauss分布在整个实轴上都有非零密度。取 $n=12$ 时
$
  z=sum_(i=1)^12 x_i-6, quad -6<=z<=6
$
每产生一个近似Gauss变量要消耗12个均匀随机数。

还可定量看出差异。均匀变量的中心四阶矩为 $1/80$，四阶累积量为
$
  kappa_4 (x)=1/80-3(1/12)^2=-1/120
$
独立变量的累积量可相加，因此标准化后
$
  gamma_2(z)=(kappa_4 (y))/(V[y]^2)=(-n/120)/(n/12)^2=-6/(5n)
$
有限 $n$ 时超额峭度严格小于0；标准Gauss的超额峭度为0。


*$n=2$ 的显式密度。* 对 $y=x_1+x_2$，卷积给出
$
  f_Y (y)=integral f_X (u) f_X (y-u) dd(u)
  =cases(y & quad 0<=y<=1, 2-y & quad 1<y<=2, 0 & quad "其它")
$

此时 $z=sqrt(6)(y-1)$，所以 $y=1+z/sqrt(6)$，Jacobian为 $1/sqrt(6)$。得到
$
  f_Z (z)=cases(
    1/sqrt(6)(1-abs(z)/sqrt(6)) & quad abs(z)<=sqrt(6),
    0 & quad "其它"
  )
$


#exercise(subname: [3.5])[
  变量 $t$ 服从均值 $tau=1$ 的指数分布，$x$ 服从均值 $mu=0$、标准偏差 $sigma=0.5$ 的Gauss分布。写一段MC程序，产生变量
  $
    y=t+x
  $<->
  这里 $t$ 可以表示不稳定粒子的真实衰变时间，$x$ 表示测量误差，所以 $y$ 表示测量到的衰变时间。画出 $y$ 的直方图。修改程序以研究 $tau<<sigma$ 和 $tau>>sigma$ 的情形。
]

#solution[
  假设真实衰变时间 $t$ 与测量误差 $x$ 独立，分别调用 `Exp(tau)` 和 `Gaus(0,sigma)`，再相加。固定 $sigma=0.5$，取 $tau=0.05,1,5$，分别对应 $tau/sigma=0.1,2,10$。每组产生100000个事件：
  #snippet("3.5")
  #newpara()
  指数分布与Gauss分布的卷积为
  $
    f_Y (y)=integral_0^infinity 1/tau e^(-t/tau)
    1/(sqrt(2 pi) sigma) e^(-(y-t)^2/(2 sigma^2)) dd(t)
  $
  对 $t$ 积分得到指数修饰Gauss分布（ex-Gaussian）：
  $
    f_Y (y)=1/(2 tau) exp(sigma^2/(2 tau^2)-y/tau)
    "erfc"((sigma^2/tau-y)/(sqrt(2) sigma)), quad -infinity<y<infinity
  $
  其中 $"erfc"(a)=2/sqrt(pi) integral_a^infinity e^(-v^2) dd(v)$。均值、方差为
  $
    E[y]=tau, quad V[y]=tau^2+sigma^2
  $
]

#figure(
  image("pic/4/3-5-exgaussian.svg", width: 95%),
  caption: [从上至下：$tau=0.05,1,5$，均取 $sigma=0.5$，每组100000个事件。蓝线为模拟，红线为卷积密度换算的预期计数。],
)

本次模拟与理论矩的比较为：
#table(
  columns: (0.55fr, 1fr, 1fr, 1fr, 1fr),
  stroke: none,
  inset: 5pt,
  table.hline(stroke: .7pt),
  table.header([*$tau$*], [*理论均值*], [*样本均值*], [*理论标准差*], [*样本标准差*]),
  table.hline(stroke: .4pt),
  [0.05],
  [0.05],
  [0.049709],
  [0.502494],
  [0.502935],
  [1],
  [1],
  [1.002707],
  [1.118034],
  [1.124056],
  [5],
  [5],
  [4.996127],
  [5.024938],
  [5.018741],
  table.hline(stroke: .7pt),
)

- 当 $tau<<sigma$ 时，真实时间的涨落远小于测量误差，$y$ 的主要形状近似为均值 $tau$、标准偏差约 $sigma$ 的Gauss分布。
- 当 $tau>>sigma$ 时，长尾主要由指数衰变决定。远离起点时接近指数衰减，$y=0$ 附近的起点被测量分辨率抹平。
- 对 $tau=1,sigma=0.5$，两个效应均可见：起点附近有展宽，正侧保留明显的指数长尾。

#exercise(subname: [3.6])[
  考虑服从Cauchy（Breit-Wigner）分布的随机变量 $x$，
  $
    f(x)=1/pi 1/(1+x^2)
  $<->
  #newpara()
  (a) 证明如果 $r$ 均匀分布于 $[0,1]$，则
  $
    x(r)=tan[pi(r-1/2)]
  $<->
  服从Cauchy分布。

  (b) 利用(a)中的结果，写一段小程序产生Cauchy分布的随机数。产生 $10^4$ 个事例并画出直方图。

  (c) 修改(b)中的程序，重复进行实验，每次实验抽取 $n$ 个独立的Cauchy分布数值（如取 $n=10$）。对每个样本，计算样本平均值 $overline(x)=1/n sum_(i=1)^n x_i$。比较 $overline(x)$ 的直方图与 $x$ 的原始直方图。（参见习题10.8。）
]

#solution[
  *(a)* 密度的累计分布函数为
  $
    F(x)=integral_(-infinity)^x 1/(pi(1+u^2)) dd(u)
    =1/2+1/pi arctan x
  $
  令 $r=F(x)$，则
  $
    arctan x=pi(r-1/2) quad arrow quad x=tan[pi(r-1/2)]
  $
  这个变换在 $0<r<1$ 上严格递增。也可由Jacobian直接验证：
  $
    (upright(d) r)/(upright(d) x)=1/(pi(1+x^2))=f(x)
  $
  #newpara()

  *(b, c)* 先产生10000个单独的 $x$；再重复10000次实验，每次产生10个新的独立 $x_i$，计算它们的算术平均值。核心代码为
  #snippet("3.6")
]
标准Cauchy的特征函数是
$
  phi_X (k)=E[e^(i k X)]=integral_(-infinity)^infinity e^(i k x)/(pi(1+x^2)) dd(x)=e^(-abs(k))
$
对 $k>0$，在复平面上半平面闭合积分路径，留数来自 $x=i$，得到 $e^(-k)$；对 $k<0$ 用对称性得到 $e^k$，$k=0$ 时为1。于是独立性给出
$
  phi_(overline(X)) (k)=product_(i=1)^n phi_X (k/n)
  =[e^(-abs(k)/n)]^n=e^(-abs(k))
$
与原来的特征函数完全相同，因此对任何正整数 $n$，
$
  overline(X) tilde "Cauchy"(0,1)
$


#figure(
  image("pic/4/3-6-cauchy.svg", width: 100%),
  caption: [单独Cauchy变量（蓝）与10个独立变量的样本平均值（绿），各10000个样本；红线为同一个标准Cauchy理论密度。平均后的分布没有变窄。],
)
