#import "@preview/scripst:1.1.2": *

#pagebreak(weak: true)

= Monte Carlo方法

Monte Carlo方法用随机抽样进行数值计算，把概率模型转化为积分、分布和实验观测量的估计。关键在于选择正确的抽样分布，并区分有限样本的统计涨落与模型本身的误差。

== Monte Carlo方法的基本思想

// 来源：第3章，第4–6页。
现实系统的几何、材料、边界条件和相互作用可能十分复杂。即使基本定律已知，也往往难以直接求出解析结果；模拟通过逐次抽样这些过程，研究其综合影响。


#definition(subname: [Monte Carlo方法])[
  *Monte Carlo方法*（简称MC）是利用随机数计算概率、积分、均值等量的数值方法。其基本过程是：产生均匀随机数，按目标概率分布变换或筛选，再用样本估计所求的量。

  例如，从归一化密度 $f(x)$ 独立抽样 $x_1,dots,x_N$，则
  $
    P(a<=x<=b)=integral_a^b f(x) dd(x)
    approx 1/N sum_(i=1)^N bold(1)_(a<=x_i<=b)
  $
  其中 $bold(1)_A$ 是事件 $A$ 的示性函数。
]


MC既可用于*数值计算*，也可用于*产生模拟数据*：前者由抽样估计积分或期望，后者从物理模型出发产生事例，再经过探测器响应、重建和分析，预测实验条件下的观测结果。

== 随机数的产生与检验

=== 真随机数与伪随机数

// 来源：第3章，第7–8页。
#table(
  columns: (1fr, 1.2fr, 1.4fr),
  stroke: none,
  inset: 6pt,
  table.hline(stroke: 0.7pt),
  table.header([*产生方式*], [*可重复性*], [*特点*]),
  table.hline(stroke: 0.4pt),
  [物理过程产生真随机数], [不能复现同一串数], [依赖物理随机源及其采集设备],
  [数学算法产生伪随机数], [给定算法和种子即可复现], [便于大量抽样、调试和结果比较],
  table.hline(stroke: 0.7pt),
)


RAND公司曾利用真空管噪声制作随机数表；其出版物 _A Million Random Digits with 100,000 Normal Deviates_ 包含一百万个随机数字及十万个正态偏差数。#footnote[#link("https://www.rand.org/pubs/monograph_reports/MR1418.html")[RAND随机数表的说明与生成方法。]]

从*可压缩性*看，伪随机序列可以由较短的“算法与种子”描述，理想随机序列则没有这样的确定性短描述。不过，有限数据不可压缩并不能证明它来自真随机过程；数值模拟真正需要的是适合所研究问题的统计性质。产生速度取决于设备和算法实现。

=== 线性乘同余产生子

// 来源：第3章，第9–10页。
*线性乘同余法*（multiplicative linear congruential generator，MLCG）通过整数递推产生近似均匀随机数：
$
  n_(i+1)=(a n_i) "mod" m, quad r_i=n_i/m
$
其中 $n_0$ 是种子，$a$ 是乘子，$m$ 是模量，$"mod"$ 表示取余。给定参数和种子后，整个序列完全确定；有限状态的递推最终会重复。

取 $m=2^K$、$a=5^(2q+1)$、$n_0=1$，其中 $K>=3$、$q$ 为非负整数，周期为 $2^(K-2)$：


#table(
  columns: (1fr, 1fr, 0.8fr, 1.5fr),
  stroke: none,
  inset: 6pt,
  table.hline(stroke: 0.7pt),
  table.header([*模量 $m$*], [*乘子 $a$*], [*种子*], [*周期*]),
  table.hline(stroke: 0.4pt),
  [$2^32$], [$5^13$], [1], [$2^30 approx 10^9$],
  [$2^36$], [$5^13$], [1], [$2^34 approx 2 dot 10^10$],
  [$2^42$], [$5^17$], [1], [$2^40 approx 10^12$],
  table.hline(stroke: 0.7pt),
)



#note[
  周期长不等于随机性好。还须检查均匀性和多维相关性，并避免不同批次重复使用同一段序列。实现模乘时应保持整数运算精确：若 $a n_i$ 超过浮点数可精确表示的整数范围，先乘再取模会产生错误；可用足够宽的整数或无溢出的模乘算法。
]


=== 随机数的质量

// 来源：第3章，第11页。
一维直方图检查 $r_i$ 的均匀性，二维散点图检查 $(r_i,r_(i+1))$ 是否呈现明显结构。有限样本的区间计数本来就有统计涨落，不能要求每格完全相同。

#figure(
  image("pic/chap3/rng-uniform-correlation.png", width: 58%),
  caption: [均匀性与相邻数相关性的初步检查，样本量为 $10^4$。],
)

这些检查不能替代对不同滞后和高维相关性的检验。模拟应记录产生子、参数及种子以便复现；每次抽样时重新设置同一个种子会重复同一序列。

== Monte Carlo积分与精度

=== 积分估计量及其误差

// 来源：第3章，第12页。
考虑 $I=integral_a^b f(x) dd(x)$。若原函数已知，可直接求 $I=F(b)-F(a)$；规则网格求积则以有限个代表点近似积分。MC用随机点代替固定网格，估计量本身也是随机变量。

#block(breakable: false)[
  令 $X_i$ 相互独立，均匀分布于 $[a,b]$，则*平均值法*给出
  $
    hat(I)=(b-a)/N sum_(i=1)^N f(X_i)
  $
]
由 $E[f(X)]=I/(b-a)$ 及独立性可得
$
  E[hat(I)]=I, quad
  "Var"[hat(I)]=(b-a)^2/N "Var"[f(X)]
$
#block(breakable: false)[
  因此它是无偏估计量。令 $overline(f)=1/N sum_(i=1)^N f(X_i)$，以样本方差估计未知的 $"Var"[f(X)]$，标准误差为
  $
    s_f^2=1/(N-1) sum_(i=1)^N (f(X_i)-overline(f))^2, quad
    hat(sigma)_(hat(I))=(b-a) s_f/sqrt(N)
  $
]
平均值法允许 $f$ 取正值或负值，但上述方差和误差估计要求相应的二阶矩有限。

#block(breakable: false)[
  #example(subname: [投点法])[
    若 $0<=f(x)<=h$，在矩形 $[a,b] times [0,h]$ 中独立均匀投 $N$ 个点，记落在曲线下的点数为 $N_("in")$，则
    $
      hat(I)=(b-a)h N_("in")/N
    $
    曲线下面积占矩形面积的比例，就是单点被接受的概率。
  ]
]

#figure(
  image("pic/chap3/hit-or-miss-integral.svg", width: 58%),
  caption: [用曲线下的点数比例估计面积。],
)

=== 误差与维数

// 来源：第3章，第13页。
独立抽样且方差有限时，MC标准误差按 $N^(-1/2)$ 下降；标准误差缩小一半，通常需要四倍的样本量。

#block(breakable: false)[
  #table(
    columns: (1fr, 1fr, 1fr),
    stroke: none,
    inset: 6pt,
    table.hline(stroke: 0.7pt),
    table.header([*积分维数*], [*MC标准误差*], [*梯形法误差*]),
    table.hline(stroke: 0.4pt),
    [一维], [$O(N^(-1/2))$], [$O(n^(-2))$],
    [$d$ 维], [$O(N^(-1/2))$], [$O(n^(-2/d))$],
    table.hline(stroke: 0.7pt),
  )
]

其中一维的 $n$ 为子区间数，多维的 $n$ 为张量网格的总规模。多维网格若每个方向细分相同次数，总点数会随维数迅速增长；MC的收敛*指数*与维数无关，误差系数却仍受函数、区域及抽样策略影响。

#note[
  对光滑函数的普通张量网格梯形法与有限方差MC作渐近比较，$d>4$ 时MC的误差指数更有利。这不保证MC对所有高维问题都最优；确定性算法的光滑性条件、所需精度及MC的方差系数也必须考虑。
]


== 从均匀分布到目标分布

=== 反函数法

// 来源：第3章，第14–18页。
设 $r$ 在 $[0,1]$ 上均匀分布，目标密度为 $f(x)$，累计分布函数为
$
  F(x)=integral_(-infinity)^x f(x') dd(x')
$
当 $F$ 连续且严格递增时，令 $x=F^(-1)(r)$，便有
$
  P(x<=z)=P(r<=F(z))=F(z)
$
即 $x$ 服从目标分布。变换的是*累计概率*，不是将随机数直接代入概率密度。

#figure(
  image("pic/chap3/cdf-transform.png", width: 58%),
  caption: [反函数变换使均匀分布与目标分布的累计概率相等。],
)

若 $F$ 不严格递增，可用广义反函数 $F^(-1)(r)=inf\{x:F(x)>=r\}$；这也适用于离散分布。Gauss、$chi^2$、Gamma、二项式、Poisson和Student等分布都可按累计概率抽样，但反函数未必能写成初等函数，实际计算可用数值反演或专门算法。

#example(subname: [指数分布])[
  对 $f(x)=1/xi exp(-x/xi)$，$x>=0$、$xi>0$，有 $F(x)=1-exp(-x/xi)$，故
  $
    x=-xi ln(1-r)
  $
  也可用同分布的 $x=-xi ln r$。每次变换均给出有效样本；实现时须避开使对数发散的端点。
]


#example(subname: [均匀方向])[
  球面的立体角元为 $dd(Omega)=sin theta dd(theta) dd(phi)$，故均匀立体角要求 $phi$ 和 $cos theta$ 均匀，而非 $theta$ 均匀。用独立均匀数 $r_1,r_2$ 取
  $
    phi=2 pi r_1, quad
    cos theta=cases(r_2 & quad "上半球", 2r_2-1 & quad "整个球面")
  $
  二维方向取 $phi=2 pi r$；其分量 $cos phi$、$sin phi$ 的边缘密度均为 $1/(pi sqrt(1-x^2))$，$-1<x<1$，两者不能作为独立变量抽样。
]

=== 舍选法

// 来源：第3章，第19–21页。
设 $f(x)>=0$ 定义于 $[a,b]$，且已知 $h>=f(x)$。$f$ 可以尚未归一化。每次用两个独立均匀随机数构造
$
  x=a+(b-a)r_1, quad u=h r_2
$
若 $u<f(x)$ 就接受 $x$，否则重新抽样。

#figure(
  image("pic/chap3/rejection-envelope.svg", width: 60%),
  caption: [接受包络矩形中曲线下的点。],
)

在给定 $x$ 处的接受概率为 $f(x)/h$，因而接受后 $x$ 的密度与 $f(x)$ 成正比。总接受率为
$
  eta=(integral_a^b f(x) dd(x))/((b-a)h)
$

包络越贴合目标函数，接受率越高；上界过低则会使分布有偏。抽样后应检查目标分布、接受率和随机数的相关性。


#table(
  columns: (0.7fr, 1.2fr, 1.5fr),
  stroke: none,
  inset: 6pt,
  table.hline(stroke: 0.7pt),
  table.header([*方法*], [*优点*], [*要求与代价*]),
  table.hline(stroke: 0.4pt),
  [反函数法], [每次变换均给出样本], [需要累计分布的反函数，或进行数值反演],
  [舍选法], [可处理未归一化的复杂函数], [需要有效包络；接受率低时须增加尝试次数],
  table.hline(stroke: 0.7pt),
)


进一步的抽样方法可参见 #link("https://pdg.lbl.gov/2011/reviews/rpp2011-rev-monte-carlo-techniques.pdf")[PDG：Monte Carlo techniques]。

== 模拟中的统计量与选择

=== 派生量与误差传播

// 来源：第3章，第22–23页。
若 $bold(x)$ 服从给定联合分布，关心的量为 $y=g(bold(x))$，可反复抽样输入向量，逐次计算 $y$，再求其分布和矩。这尤其适合非线性变换或难以解析积分的情况。必须保留输入变量之间的相关性，否则得到的是另一个概率模型。

对 $N$ 个独立结果 $y_i$，有
$
  overline(y)=1/N sum_(i=1)^N y_i, quad
  s_y^2=1/(N-1) sum_(i=1)^N (y_i-overline(y))^2
$
$s_y$ 描述变量本身的分散程度；$s_y/sqrt(N)$ 才是均值估计的标准误差。比较直方图与理论密度时，每个区间的预期计数为 $N$ 乘该区间内密度的积分，窄区间近似为 $N f(y) Delta y$。

#example(subname: [Gauss变量的平方和])[
  若 $x_1,dots,x_4$ 是独立的标准Gauss变量，$X=sum_(i=1)^4 x_i^2$ 服从自由度为4的 $chi^2$ 分布：
  $
    f(X)=X/4 exp(-X/2), quad X>=0; quad E[X]=4, quad "Var"[X]=8
  $
  模拟结果可用来检查抽样、独立性、变量变换与直方图归一化是否一致。
]

=== 选择效率与偶然本底

// 来源：第3章，第24–29页。
选择条件把原始事例转化为最终样本，信号效率与本底计数都依赖完整的选择规则。时间窗的启动、重叠和多重性条件会互相影响，不能只靠单个粒子的探测效率推算最终效率。模拟应从混合事件序列出发，执行与数据相同的选择，再与解析预期逐项比较。

#example(subname: [快慢符合])[
  大亚湾利用 $overline(nu)_e+p arrow e^++n$ 的快慢信号探测反中微子：正电子给出快信号，中子被H或Gd俘获给出慢信号。典型俘获时间分别约为 $200 mu"s"$ 和 $30 mu"s"$，释放能量约为2.2 MeV和8 MeV。

  若孤立本底以恒定率 $R_s$ 构成Poisson过程，在长度 $T_c$ 的窗内有
  $
    P(k|R_s T_c)=(R_s T_c)^k/k! e^(-R_s T_c)
  $
  记孤立信号启动搜索窗的概率为 $P_("start")$，则 $R_("start")=R_s P_("start")$。要求窗内恰有另一个孤立信号时，偶然符合率为
  $
    R_("acc")=R_("start") P(1|R_s T_c)
  $
  在相应的窗口模型中，若真快信号也具有相同的启动概率，符合效率可分解为
  $
    epsilon_("IBD")=P_("start") epsilon_e epsilon_("n|e")
    integral_0^(T_c) P_("delay") (t) dd(t) e^(-R_s T_c)
  $
  各因子依次描述窗口启动、快信号选择、条件下的慢信号选择、时间窗接受度，以及没有额外孤立信号的概率。若延迟服从均值为 $tau$ 的指数分布，时间接受度为 $1-e^(-T_c/tau)$。启动概率还取决于 $μ$ 子反符合、窗口重叠等规则，须按具体模型计算。
]


== 物理事例与探测器响应

=== 物理产生子与粒子输运

// 来源：第3章，第30–39页。
#definition(subname: [物理产生子])[
  物理产生子（event generator）按给定理论或模型抽样物理事例，输出末态粒子的种类及四动量。它给出产生层面的分布，尚未包含探测器和事件重建的影响。
]


#example(subname: [$e^+ e^- arrow mu^+ mu^-$ 的角分布])[
  以束流方向为极轴，令 $c_theta=cos theta$，可按归一化密度
  $
    f(c_theta;A_("FB"))=3/8(1+c_theta^2)+A_("FB") c_theta,
    quad -1<=c_theta<=1
  $
  抽样极角，并独立取 $phi=2 pi r$。$A_("FB")$ 是前后不对称度，须满足 $|A_("FB")|<=3/4$ 以保证密度非负；随后由能量和动量守恒构造末态四动量。
]


常用物理产生子的例子包括：

#table(
  columns: (1fr, 2fr),
  stroke: none,
  inset: 6pt,
  table.hline(stroke: 0.7pt),
  table.header([*物理过程*], [*程序包*]),
  table.hline(stroke: 0.4pt),
  [$e^+ e^- arrow$ 强子], [JETSET（PYTHIA）、HERWIG、ARIADNE],
  [$p p arrow$ 强子], [ISAJET、PYTHIA、HERWIG],
  [$e^+ e^- arrow W^+ W^-$], [KORALW、EXCALIBUR、ERATO],
  table.hline(stroke: 0.7pt),
)


*探测器模拟*接收末态粒子，模拟它们在材料中的多重散射、衰变、电离能损、电磁和强子簇射，再产生读出与电子学响应。输出交给重建程序，以与实验数据相同的流程得到观测量。通用工具包括GEANT3（FORTRAN）和Geant4（C++）；Geant4也用于空间科学和医学物理。

#example(subname: [水中的Cherenkov光])[
  给定带电粒子的速度与轨迹，先抽样光子产额和波长，再按光锥方向产生光子：
  $
    cos theta_("C")=1/(beta n(lambda)), quad beta n(lambda)>1
  $
  方位角绕粒子方向均匀分布；随后按材料中的传播和相互作用概率抽样光子的吸收、散射。光锥方向的抽样与整个球面的各向同性抽样不同。
]


几何、材料、相互作用模型、读出及重建共同决定模拟结果。模拟可用于初期设计、效率与性能估计和系统效应研究，但仍需用已知输入或标定数据检验。

=== 效率与分辨率

// 来源：第3章，第40–42页。

设真实变量 $x$ 的密度为 $f(x)$，选择效率为 $epsilon(x)$，给定真实值后的重建响应密度为 $R(x'|x)$。若
$
  0<=epsilon(x)<=1, quad integral R(x'|x) dd(x')=1
$
则选中事例的重建分布为
$
  g(x')=(integral f(x) epsilon(x) R(x'|x) dd(x)) /
  (integral f(x) epsilon(x) dd(x))
$
分母是总选择效率，保证 $g$ 归一化。若还限制重建变量 $x'$ 的范围，归一化分母应改为分子在该范围内的积分。


*效率*在真实变量处改变权重，*分辨率*把同一真实值分散到不同的重建值。只有当响应平移不变，即 $R(x'|x)=R(x'-x)$ 时，响应积分才是通常的卷积。复杂响应难以写成显式函数时，可直接抽样响应并施加选择。


#example(subname: [共振质量谱])[
  真实质量服从Breit–Wigner密度，而重建质量具有Gauss响应时，
  $
       f(M) & =1/pi (Gamma_0/2)/((M-m_0)^2+Gamma_0^2/4), \
    R(M'|M) & =1/sqrt(2 pi sigma^2) exp(-(M'-M)^2/(2 sigma^2))
  $
  将二者与 $epsilon(M)$ 代入响应积分，即得观测质量谱。峰宽和形状都可改变，重建分布一般已不是原来的Breit–Wigner函数。
]


=== 快速模拟与结果验证

// 来源：第3章，第43–50页。
完整模拟依次进行*物理事例产生、粒子输运与探测器响应、事件重建、观测量计算*。最终分布须与经过相同选择的实验数据比较。

*Toy Monte Carlo*以参数化模型代替完整探测器输运，适合早期设计和精度估计。例如，动量测量可用Gauss响应，电离能损可用Landau分布，寿命可用指数分布。反复产生、扰动和重建，考察分辨率及选择条件对结果的影响。


#example(subname: [中间态的质量分辨率])[
  对级联 $A arrow B+C$、$C arrow D+E$、$E arrow H+I$，稳定末态为 $B,D,H,I$。在 $c=1$ 的单位制下，由测得的 $H,I$ 四动量重建
  $
    p_E=p_H+p_I, quad M_E^2=(E_H+E_I)^2-|bold(p)_H+bold(p)_I|^2
  $
  多次模拟得到的质量分布可估计所假设测量模型下的分辨率；组合本底、效率变化和测量相关性也应纳入模型。
]


验证时既要检查抽样分布和统计误差，也要检查模型对输入变化的响应。增加样本只能减小模拟统计误差，不能修正错误的物理模型或选择规则。

#example(subname: [大气温度与地下$μ$子率])[
  宇宙线在大气中产生的 $pi$、K衰变为$μ$子。温度改变密度，影响介子衰变与相互作用的竞争以及$μ$子的存活概率。小扰动下，计数率响应可写成
  $
    (Delta R_mu)/R_(mu 0)=alpha_T (Delta T_("eff"))/T_("eff")
  $
  $T_("eff")$ 是按$μ$子产生和输运加权的有效温度，不能直接用地面温度代替。响应系数依赖原初宇宙线谱、强子产生、大气剖面及探测阈值；可用模拟检验解析关系及其适用范围。
]


== 本章小结

- *计算思想*：用样本频率、均值等统计量估计概率与积分，并给出相应的统计误差。
- *随机数与抽样*：均匀随机数须有合适的统计性质；反函数法按累计概率变换，舍选法接受包络下满足 $u<f(x)$ 的样本。
- *精度条件*：独立抽样且方差有限时，标准误差按 $N^(-1/2)$ 下降；增加样本不能消除模型误差。
- *实验预测*：从物理产生子到探测器响应、选择和重建，逐步得到可与数据比较的观测分布。
