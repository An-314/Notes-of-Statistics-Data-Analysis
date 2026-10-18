#import "@preview/scripst:1.1.2": *

= 常用概率密度函数

本章关注三件事：*分布的数学形式、相应的平均值与方差、适用的物理情景*。离散计数使用概率质量函数（pmf），连续观测量使用概率密度函数（pdf）；讲义统称为“概率密度函数”。下文仍用 $E[x]$、$"Var"[x]$ 和 $sigma$ 表示期望、方差和标准差，$ln$ 为自然对数。

== 二项式分布

#definition(subname: [Bernoulli试验与二项式分布])[
  对一个实验重复进行 $N$ 次试验，要求
  + 每次只有成功与失败两种结果；
  + 每次成功的概率均为同一个 $p$，失败概率为 $1-p$；
  + 不同次试验的结果相互独立。

  单次试验称为Bernoulli试验，成功总次数 $r$ 服从*二项式分布*：
  $
    P(r;N,p) = binom(N, r) p^r (1-p)^(N-r)
    = N!/(r!(N-r)!) p^r (1-p)^(N-r)
  $
  其中 $r=0,1,dots,N$，$0<=p<=1$。
]

#newpara()
一个指定的成功、失败序列的概率为 $p^r(1-p)^(N-r)$；在 $N$ 次中选出 $r$ 次成功共有 $binom(N, r)$ 种排列。归一化直接来自二项式定理：
$
  sum_(r=0)^N P(r;N,p) = [p+(1-p)]^N = 1
$
二项式分布常用于*探测效率*和*衰变分支比*的统计。

#example(subname: [检查驾驶人是否佩戴安全带])[
  停车检查只有“佩戴”和“不佩戴”两种结果，但这并不足以保证可以使用二项式分布。
  - 不同年龄等人群不佩戴安全带的概率是否一样？这关系到各次试验是否具有相同的 $p$。
  - 同时、同地前后两辆车的驾驶人行为是否独立？前车接受检查可能影响后车行为。

  应根据实际采样方式判断是否满足Bernoulli试验的条件，再决定能否应用二项式分布。
]

#theorem(subname: [二项式分布的矩])[
  $
    E[r]=N p, quad "Var"[r]=N p(1-p)
  $
]
#proof[
  从定义出发，利用 $r/r!=1/(r-1)!$ 和 $N!=N(N-1)!$，得到
  $
    E[r] & = sum_(r=1)^N r N!/(r!(N-r)!) p^r(1-p)^(N-r) \
         & = N p sum_(r=1)^N (N-1)!/((r-1)!(N-r)!) p^(r-1)(1-p)^(N-r)
  $
  令 $r'=r-1$、$N'=N-1$，求和部分就是一个新的二项式分布的归一化和，因而 $E[r]=N p$。

  同理，$E[r(r-1)]=N(N-1)p^2$，因此
  $
      E[r^2] & = N(N-1)p^2+N p \
    "Var"[r] & = E[r^2]-E[r]^2 = N p(1-p)
  $
]

#newpara()
分布的形状随成功概率与试验次数改变，两组参数的组合影响分布的形态。

#figure(
  image("pic/chap2/binomial-shapes.png", width: 95%),
  caption: [二项式分布：$p=0.25,0.35$，分别比较 $N=4,8,16,32$。],
)

固定 $p$ 时，$N$ 增大使分布在计数轴上变宽，标准化后的形状趋向对称。固定 $N$ 时，$p$ 增大使分布更对称、更平缓。

#note[
  “给定 $N$，$p$ 越大越对称、越平缓”，这一趋势在图示的 $p<1/2$ 范围成立。一般应说：$p$ 越接近 $1/2$ 越对称，方差在 $p=1/2$ 处最大；超过 $1/2$ 后偏斜方向反转。固定 $p$、增大 $N$ 时，绝对宽度增大，但相对宽度 $sigma/E[r]$ 减小。
]

#definition(subname: [偏度与超额峭度])[
  *偏度*（skewness）刻画分布的不对称程度，*超额峭度*（excess kurtosis，峭度）刻画标准化四阶矩相对正态分布的差异：
  $
    gamma_1 & = E[(x-mu)^3]/sigma^3 \
    gamma_2 & = E[(x-mu)^4]/sigma^4 - 3
  $
  对二项式分布，$0<p<1$ 时有
  $
    gamma_1 = (1-2p)/sqrt(N p(1-p)), quad
    gamma_2 = (1-6p(1-p))/(N p(1-p))
  $
]

#figure(image("pic/chap2/skewness.png", width: 78%), caption: [正偏时尾巴在右，负偏时尾巴在左])

- 偏度的*绝对值*越大，不对称越明显。
- 峭度比较的是标准化四阶矩，不能仅凭它判断峰的高低或宽度。正态分布的超额峭度为零。

#example(subname: [MRPC探测效率])[
  以宇宙线测量多层阻性板室（MRPC）的探测效率。上下两块闪烁体同时击中形成符合，给出穿过MRPC的粒子数 $N$；其中MRPC记录到的击中数为 $N'$。
]
#figure(image("pic/chap2/mrpc.png", width: 32%), caption: [闪烁体1、MRPC和闪烁体2构成的效率测量装置])

#solution[
  在符合触发能正确选出穿过MRPC的粒子、各次探测独立且效率稳定时，$N'$ 服从二项式分布。效率及其统计误差估计为
  $
    hat(p)=N'/N, quad
    Delta p = (Delta N')/N approx sqrt((hat(p)(1-hat(p)))/N)
  $
  理论标准差为 $sqrt(p(1-p)/N)$，实际计算时用 $hat(p)$ 代入。
]

#example(subname: [大亚湾触发电子学板的故障率])[
  为大亚湾实验研制生产的触发电子学板，假设每块板的年故障率为 $10%$。实验使用20块板，一年内有5块需要维修，这一故障率假设是否可以接受？
]
#solution[
  在各板故障独立且故障率相同的假设下，$r$ 服从 $N=20,p=0.1$ 的二项式分布。应计算5块*或更多*故障的概率：
  $
    P(r>=5) & = 1-sum_(r=0)^4 P(r) \
            & = 1-sum_(r=0)^4 20!/(r!(20-r)!) 0.1^r 0.9^(20-r) \
            & approx 1-0.9568=0.0432
  $
  判定板的质量不能接受。按假设检验的语言，若事先采用 $5%$ 的单侧显著性水平，这一结果足以拒绝“年故障率为 $10%$”的假设；具体质量决策还取决于预先约定的验收规则。
]

== 多项式分布

#definition(subname: [多项式分布])[
  将每次试验的结果从两类推广为 $m$ 类，其概率为 $vb(p)=(p_1,dots,p_m)$，满足 $sum_(i=1)^m p_i=1$。独立重复 $N$ 次，各类的次数为 $vb(n)=(n_1,dots,n_m)$，满足 $sum_(i=1)^m n_i=N$，则
  $
    f(vb(n);N,vb(p)) = binom(n, n_1, dots, n_m) product_(i=1)^m p_i^(n_i) =N!/(n_1! n_2! dots n_m!) product_(i=1)^m p_i^(n_i)
  $
]
可以计算，各分量的平均值、方差与协方差为
#theorem(subname: [多项式分布的矩])[
  $
                      E[n_i] & = N p_i \
                  "Var"[n_i] & = N p_i (1-p_i) \
    V_(i j) = "cov"[n_i,n_j] & = -N p_i p_j, quad i!=j
  $
]
也可以统一写成 $V_(i j)=N(p_i delta_(i j)-p_i p_j)$。每一类的边缘计数服从二项式分布；固定总数时，一个区间多计入事例，会挤占其它区间的计数，因而协方差为负。

多项式分布适用于*固定总事例数的直方图频数误差估计*。它与后面“各区间为独立Poisson变量”的描述，区别在于是否把总数固定。

== Poisson分布

=== 从二项式分布取极限

#definition(subname: [Poisson分布])[
  二项式分布在 $N->oo$、$p->0$，而 $N p=lambda$ 保持不变时，趋于*Poisson分布*：
  $
    P(r;lambda)=e^(-lambda) lambda^r/r!, quad r=0,1,2,dots
  $
  其中 $lambda>=0$；$lambda=0$ 对应 $r=0$ 的退化情形。
]
#proof[
  对固定的非负整数 $r$，将二项式概率改写为
  $
    P(r;N,p) = (N p)^r/r! (1-(N p)/N)^(N-r)
    product_(k=0)^(r-1) (1-k/N)
  $
  当 $N p=lambda$ 时，乘积中的每个因子趋于1，而
  $
    lim_(N->oo) (1-lambda/N)^(N-r)=e^(-lambda)
  $
  因而得到所需极限。$1/N,dots,(r-1)/N->0$，这意味着上式的乘积趋于1。
]

归一化由指数级数得到 $sum_(r=0)^oo e^(-lambda)lambda^r/r!=1$。移动求和指标还可得到
#theorem(subname: [Poisson分布的矩])[
  $
         E[r] & =lambda \
    E[r(r-1)] & =lambda^2 \
     "Var"[r] & =lambda
  $
]
因此，标准差为 $sqrt(lambda)$，观测计数为 $n$ 时常用的误差估计是
$
  n plus.minus sqrt(n)
$
它常用于稀有衰变、一定通量下的事例计数以及上、下限估计。

#figure(
  image("pic/chap2/poisson-shapes.png", width: 48%),
  caption: [Poisson分布在均值为 $0.5,1,4,10$ 时的形状；均值越大，分布越接近对称],
)

#note[
  $sqrt(n)$ 是标准差的代入估计，不是对所有计数都精确成立的对称置信区间。特别是 $n=0$ 并不意味着真实均值被无误差地确定为零。
]

#example(subname: [搭便车])[
  一名学生站在路边搭便车，汽车平均每分钟经过一辆，每辆车允许搭乘的概率为 $1%$。经过60辆车后仍未搭上车的概率是多少？
]
#solution[
  对固定的60辆车，准确的模型是二项式分布，$N=60,p=0.01,r=0$：
  $
    P(r=0)=0.99^60 approx 0.5472
  $
  由于 $N$ 大、$p$ 小，令 $lambda=N p=0.6$，Poisson近似给出
  $
    P(r=0) approx e^(-0.6) 0.6^0/0! approx 0.5488
  $
  两者很接近。
]

#figure(
  image("pic/chap2/binomial-poisson.svg", width: 90%),
  caption: [固定 $N p=2$，比较 $N=10,20,50,100$ 的二项式分布与均值为2的Poisson分布],
)

保持 $N p$ 不变时，$N$ 越大，$p$ 越小。讲义从图上指出，当 $N>50$ 时，两种分布的差别几乎可以忽略；这是这组参数与图示精度下的观察，具体精度要求仍应直接比较概率。

#example(subname: [Super-Kamiokande的误击中计数])[
  探测器有11146根光电倍增管（PMT），每根PMT暗噪声率为 $3.5 "kHz"$。在总计 $500 "μs"$ 的时间内，以 $10 "ns"$ 为一个时间窗，分别出现5次、6次暗噪声击中的时间窗数，平均各有多少？
]
#figure(
  image("pic/chap2/super-kamiokande.png", width: 55%),
  caption: [日本Super-Kamiokande中微子探测器],
)
#solution[
  在各管暗噪声相互独立、事例率稳定的模型下，每个时间窗内总暗计数近似为Poisson分布，其均值为
  $
    lambda = 10^(-8) times 11146 times 3500 = 0.39011 approx 0.4
  $
  时间窗总数为 $M=(500 "μs")/(10 "ns")=5 times 10^4$。取 $lambda approx 0.4$，有
  $
    E[M_5] & = M e^(-0.4) 0.4^5/5! approx 3 "次" \
    E[M_6] & = M e^(-0.4) 0.4^6/6! approx 0.2 "次"
  $
  这些是平均次数，不是单次实验必然出现的整数结果；它们会影响触发阈值和数据分析中对偶然符合本底的处理策略。
]

#example(subname: [角分布的前后不对称])[
  考虑 $e^++e^- -> J"/"psi->e^++e^-$。以入射与出射正电子之间的夹角 $theta$ 划分前、后向，记前向计数为 $F$、后向计数为 $B$，总数 $N=F+B$；前向单事例概率为 $f$。
]
#figure(
  image("pic/chap2/forward-backward.png", width: 95%),
  caption: [散射角与前、后向计数示意；$cos theta>0$ 为前向，$cos theta<0$ 为后向],
)
#solution[
  若总数服从均值为 $nu$ 的Poisson分布，而给定 $N$ 后前向计数为二项式分布，则
  $
    P_P (N) = e^(-nu) nu^N/N!, quad
    P_B (F|N) = N!/(F! B!) f^F(1-f)^B
  $
  两者相乘并利用 $N=F+B$，得到
  $
    P(F,B) & = P_P (N) P_B (F|N) \
           & = (e^(-nu f) (nu f)^F)/(F!)
             (e^(-nu(1-f)) [nu(1-f)]^B)/(B!) \
           & = P_P (F;nu f) P_P (B;nu(1-f))
  $
  它分解为两个Poisson概率的乘积，所以*不固定总数时*，前、后向计数相互独立，均值分别为 $nu f$、$nu(1-f)$。
]

将前、后向推广为多个直方图区间，可用两种等价的方式描述同一计数模型：
+ 总事例数服从Poisson分布，给定总数后各区间计数服从多项式分布；
+ 各区间分别服从相互独立的Poisson分布。

#figure(
  image("pic/chap2/histogram.png", width: 40%),
  caption: [总数为 $N$、各区间计数为 $n_i$ 的直方图及误差示意],
)

于是各区间误差可估计为 $Delta n_i=sqrt(n_i)$，总数误差满足
$
  (Delta N)^2 = sum_i (Delta n_i)^2 = sum_i n_i=N, quad Delta N=sqrt(N)
$
若分析时条件化在固定的 $N$ 上，则应恢复多项式分布的负协方差，不能再把各区间视为独立。

=== 复合Poisson分布

#definition(subname: [Poisson变量的随机个数求和])[
  设 $N$ 服从均值为 $lambda$ 的Poisson分布，每个 $n_i$ 独立地服从均值为 $mu$ 的Poisson分布，且与 $N$ 独立。随机总和
  $
    r=sum_(i=1)^N n_i
  $
  服从一种*复合Poisson分布*。给定 $N$，$r$ 为均值 $N mu$ 的Poisson变量，因此
  $
    P(r)=sum_(N=0)^oo ((N mu)^r e^(-N mu))/(r!)
    (lambda^N e^(-lambda))/(N!)
  $
  $N=0$ 时总和定义为0，相应的条件分布为 $P(r=0|N=0)=1$。
]

由全期望公式和全方差公式，
$
      E[r] & = E[E[r|N]]=E[N mu]=lambda mu \
  "Var"[r] & = E["Var"[r|N]]+"Var"[E[r|N]] \
           & = E[N mu]+"Var"[N mu]=lambda mu(1+mu)
$
方差比均值更大，额外的涨落来自“参与求和的项数 $N$ 本身也在涨落”。

// 讲义第19页
== Gauss分布与中心极限定理

=== 正态分布

#definition(subname: [Gauss分布（正态分布）])[
  连续随机变量 $x$ 的Gauss概率密度为
  $
    N(mu,sigma^2) = f(x;mu,sigma) = 1/(sigma sqrt(2 pi))
    exp(-(x-mu)^2/(2 sigma^2)), quad -oo<x<oo, sigma>0
  $
]

#theorem(subname: [Gauss分布的矩])[
  它关于 $x=mu$ 对称，满足
  $
           E[x] & =mu \
    E[(x-mu)^2] & =sigma^2 \
        gamma_1 & =E[(x-mu)^3]/sigma^3=0 \
        gamma_2 & =E[(x-mu)^4]/sigma^4-3=0
  $
]

Gauss分布在统计问题和科学研究中处于中心地位。测量误差，尤其是仪器的分辨率，常可用Gauss函数描述；即使真实分布并非严格正态，在合适范围内也可能给出很好的近似，但仍须检查尾部和适用条件。

=== 中心极限定理

#theorem(subname: [中心极限定理])[
  设 $x_i$ 相互独立，$E[x_i]=mu_i$，$"Var"[x_i]=sigma_i^2<oo$。在满足中心极限定理所需的附加条件时，标准化总和
  $
    Z_n=(sum_(i=1)^n x_i-sum_(i=1)^n mu_i)/sqrt(sum_(i=1)^n sigma_i^2)
  $
  在 $n->oo$ 时依分布收敛到 $N(0,1)$。

  特别地，若 $x_i$ 独立同分布、均值为 $mu$、方差为 $0<sigma^2<oo$，则
  $
    (sum_(i=1)^n x_i-n mu)/(sigma sqrt(n)) -> N(0,1)
  $
]

#note[
  讲义给出了独立、有限方差变量的标准化总和形式。对于*不必同分布*的变量，仅有独立性和各项方差有限并不足够，还要控制单项或尾部对总方差的支配，例如满足Lindeberg条件。独立同分布且方差有限是最常用的充分条件。
]

不论是否已经进入正态近似范围，只要独立且方差存在，总和 $y=sum_(i=1)^n x_i$ 就有
$
  E[y]=sum_(i=1)^n mu_i, quad "Var"[y]=sum_(i=1)^n sigma_i^2
$
中心极限定理解释了为什么许多小的独立加性扰动叠加后，测量误差常接近Gauss分布。

=== 与Gauss函数有关的积分

实际计算常遇到
$
  I_n (alpha)=integral_(-oo)^oo y^n e^(-alpha y^2) dd(y), quad alpha>0
$
#newpara()
*偶次幂积分*从基本积分开始：
$
  I_0=integral_(-oo)^oo e^(-y^2) dd(y)=sqrt(pi), quad
  I_0(alpha)=sqrt(pi/alpha)
$
对 $alpha$ 求导，可将被积函数乘上 $-y^2$：
$
  dv(I_0(alpha), alpha)
  =integral_(-oo)^oo (-y^2)e^(-alpha y^2) dd(y)
  =-I_2(alpha)=-1/(2 alpha) sqrt(pi/alpha)
$
反复求导得到
$
  I_(2k)(alpha)=(-1)^k dv(I_0(alpha), alpha, k)
  = ((2k-1)!!)/(2^k alpha^k) sqrt(pi/alpha)
$
其中 $k=0$ 时约定 $(-1)!!=1$。

*奇次幂积分*的被积函数为奇函数，因此 $I_(2k+1)(alpha)=0$。

#newpara()
半轴积分记作
$
  J_n(alpha)=integral_0^oo y^n e^(-alpha y^2) dd(y)
$
有
$
  J_1=1/2, quad J_1(alpha)=1/(2 alpha)
$
再通过对 $alpha$ 求导得到更高奇次幂的 $J_n$。统一的结果为
$
  J_n (alpha)=Gamma((n+1)/2)/(2 alpha^((n+1)/2)), quad n>-1
$
这里 $Gamma$ 函数将在 $chi^2$ 分布中定义；对偶数 $n$，也可以直接使用 $J_n (alpha)=(I_n (alpha))/2$。

// 讲义第22页
=== Poisson分布的Gauss近似

Poisson分布只在非负整数上取值，Gauss分布则连续并延伸到正、负无穷。Poisson均值 $lambda$ 越大，偏斜越小，在中心区域可以用
$
  mu=lambda, quad sigma=sqrt(lambda)
$
的Gauss分布近似。

#figure(
  image("pic/chap2/poisson-gauss.svg", width: 91%),
  caption: [Poisson分布与Gauss近似，$lambda=2,5,10$。实点为离散概率，实线仅连接其形状，虚线为Gauss密度。],
)

#note[
  “计数或事例数大于5时，可认为误差满足Gauss分布”。这个阈值只是粗略经验，不能保证尾概率或置信区间的精度。小计数和显著性计算宜保留精确Poisson概率；用连续分布近似整数区间时，可考虑连续性修正，例如
  $
    P(a<=r<=b) approx integral_(a-1/2)^(b+1/2) f(x;lambda,sqrt(lambda)) dd(x)
  $
]

// 讲义第23–24页
=== 标准差、半峰全宽与实验结果的含义

Gauss分布的标准差给出下列中心区间概率：
$
              P(mu-sigma<=x<=mu+sigma) & approx 0.6827 \
  P(mu-0.6745sigma<=x<=mu+0.6745sigma) & approx 0.5
$
因此，$0.6745sigma$ 对应含一半概率的对称区间半宽。

峰高的一半对应
$
  exp(-(x-mu)^2/(2 sigma^2))=1/2
$
解得*半峰全宽*（full width at half maximum，FWHM）
$
  "FWHM"=2 sigma sqrt(2 ln 2) approx 2.35sigma
$

#figure(
  image("pic/chap2/gauss-width.svg", width: 98%),
  caption: [Gauss分布的FWHM与 $mu plus.minus sigma$ 内的概率],
)

#example(subname: [如何理解发表的测量结果])[
  设物理量真值为 $X$，实验发表测量结果 $mu plus.minus sigma$。讲义将其解释为：“真值落在 $mu plus.minus sigma$ 内的概率为 $68.3%$，落在范围外的概率为 $31.7%$。”
]

#note[
  这句话需要区分第一章介绍的两种概率解释。
  - 在频率解释下，真值 $X$ 固定，变化的是重复测量的估计值。若估计值无偏且服从标准差为 $sigma$ 的Gauss分布，则反复构造的区间 $[mu-sigma,mu+sigma]$ 约有 $68.3%$ 覆盖真值。
  - 若将 $mu plus.minus sigma$ 解释为真值的后验概率区间，则需要给出Bayesian模型，并使后验确实具有相应的Gauss形式。

  无论采用哪种解释，*误差是实验结果的一部分*。除非不确定度远小于问题所要求的精度，否则在不知道真值时，仅发表一个没有误差的数值没有足够意义。
]

// 讲义第25页
=== 多维Gauss分布

#definition(subname: [多维Gauss分布])[
  对随机矢量 $vb(x)=(x_1,dots,x_n)^T$，设均值为 $vb(mu)$、协方差矩阵 $V$ 正定，则
  $
    f(vb(x);vb(mu),V)
    = 1/((2 pi)^(n/2) sqrt(det V))
    exp(-1/2 (vb(x)-vb(mu))^T V^(-1)(vb(x)-vb(mu)))
  $
  其中 $E[x_i]=mu_i$、$"cov"[x_i,x_j]=V_(i j)$。讲义的 $abs(V)$ 表示矩阵的行列式。
]

二维情况下，令
$
  rho="cov"[x_1,x_2]/(sigma_1 sigma_2), quad
  u_1=(x_1-mu_1)/sigma_1, quad u_2=(x_2-mu_2)/sigma_2
$
则
$
  f(x_1,x_2;mu_1,mu_2,sigma_1,sigma_2,rho) & =1/(2 pi sigma_1 sigma_2 sqrt(1-rho^2)) \
                                           & quad times exp(-(u_1^2+u_2^2-2 rho u_1 u_2)/(2(1-rho^2)))
$
这里 $abs(rho)<1$。将 $u_1,u_2$ 代回即可得到用 $(x_i-mu_i)/sigma_i$ 展开的形式。多维Gauss分布常用于描述测量结果间的相关性；$abs(rho)=1$ 时协方差矩阵奇异，需要退化分布的描述。

=== 二项式、Poisson与Gauss分布的联系

三种分布之间的关系可归纳为
$
  "Binomial"(N,p) arrow.r.long^(N->oo, N p=lambda) "Poisson"(lambda)
$
$
  "Binomial"(N,p) arrow.r.long^(N->oo, 0<p<1) "Gauss"(mu=N p, sigma=sqrt(N p(1-p)))
$
$
  "Poisson"(lambda) arrow.r.long^(lambda->oo) "Gauss"(mu=lambda, sigma=sqrt(lambda))
$
后两式表达的是相应标准化分布的正态极限。在实际近似中，二项式分布要求成功与失败的期望次数都足够大；若固定 $N p$ 取极限，首先得到的是Poisson分布。

// 讲义第27–28页
== 对数正态分布

=== 定义、矩与形状

#definition(subname: [对数正态分布])[
  若 $y$ 服从均值 $mu$、方差 $sigma^2$ 的Gauss分布，则 $x=e^y$ 服从*对数正态分布*：
  $
    f(x;mu,sigma^2)=cases(
      1/(x sqrt(2 pi sigma^2)) exp(-(ln x-mu)^2/(2 sigma^2)) & quad x>0,
      0 & quad "其它"
    )
  $
  其中 $sigma>0$。$mu,sigma^2$ 是 $ln x$ 的均值和方差，不能直接当成 $x$ 的均值和方差。
]

由一维变量变换，$y=ln x$、$abs(dv(y, x))=1/x$，立即得到上式。进一步用Gauss积分配方可求得
$
  E[x^k]=E[e^(k y)]=exp(k mu+k^2 sigma^2/2)
$
所以
#theorem(subname: [对数正态分布的矩])[
  对数正态分布的均值和方差为
  $
        E[x] & = exp(mu+sigma^2/2) \
    "Var"[x] & = exp(2mu+sigma^2)(exp(sigma^2)-1)
  $
  偏度与超额峭度为
  $
    gamma_1 & = sqrt(e^(sigma^2)-1)(e^(sigma^2)+2) \
    gamma_2 & = (e^(sigma^2)-1)(e^(3sigma^2)+3e^(2sigma^2)+6e^(sigma^2)+6)
  $
]

#figure(
  image("pic/chap2/lognormal-shapes.png", width: 94%),
  caption: [两组对数正态分布：左图固定 $mu=0$、比较 $sigma=0.5,1.0,1.5$；右图比较 $mu=0,0.5,1.5$],
)

#note[
  讲义分别把两组图称为“同均值不同方差”和“同方差不同均值”，这里应理解为*对数变量*的参数。右图原图标注 $sigma=0$，与图中的连续密度曲线不相容；$sigma=0$ 应退化为集中在 $e^mu$ 的点分布。原图保留供核对，不据此将零宽度当成连续密度。
]

若一个随机量由许多小的倍增因子组成，取对数后就转化为加性扰动。因此，对数正态分布可用于描述许多小的乘性误差共同作用的过程。

// 讲义第29–30页
=== 区间概率与风险分析例题

利用取对数后的正态分布，可以把任意正值区间的概率化为标准正态累积分布之差。

定义标准正态累积分布函数
$
  Phi(t)=1/sqrt(2 pi) integral_(-oo)^t e^(-s^2/2) dd(s)
$
它对应讲义中的 $F$。对于 $0<a<b$，有
$
  P(a<x<b) & = integral_a^b 1/(x sqrt(2 pi sigma^2))
             exp(-(ln x-mu)^2/(2 sigma^2)) dd(x) \
           & = integral_(ln a)^(ln b) 1/sqrt(2 pi sigma^2)
             exp(-(y-mu)^2/(2 sigma^2)) dd(y)
$
这里先作代换 $y=ln x$，再令 $t=(y-mu)/sigma$，就得到
$
  P(a<x<b)=Phi((ln b-mu)/sigma)-Phi((ln a-mu)/sigma)
$
因此可以查标准正态分布表求得区间概率。

#example(subname: [蒸汽发生器支撑系统的风险模型])[
  核电站工程师用模型估计支撑蒸汽发生器的强度，以防地震峰值加速度造成破坏。假设相关加速度阈值服从 $mu=4.0$、$sigma^2=0.09$ 的对数正态分布，以累积概率表示瓦解概率。峰值加速度为33时，支撑系统仍能承受的概率是多少？
]
#solution[
  为明确概率方向，记随机承受阈值为 $x$，外加峰值为33；系统可承受对应 $x>33$。令 $sigma=0.30$，则
  $
    (ln 33-4.0)/0.30 approx -1.68
  $
  按讲义查表精度，
  $
    P("承受") & = 1-Phi(-1.68)=0.9535 \
    P("瓦解") & = Phi(-1.68)=0.0465
  $
]

== 均匀分布

#definition(subname: [均匀分布])[
  在区间 $(a,b)$ 上均匀分布的连续变量，密度为
  $
    f(x)=cases(1/(b-a) & quad a<x<b, 0 & quad "其它")
  $
  其平均值和方差为
  $
    E[x]=(a+b)/2, quad "Var"[x]=(b-a)^2/12
  $
]

对称性给出平均值；将 $x-(a+b)/2$ 的平方在 $(a,b)$ 上积分即可得到方差。

#theorem(subname: [累积分布变换])[
  若 $F(x)$ 是连续随机变量 $x$ 的连续累积分布函数，则 $y=F(x)$ 服从 $(0,1)$ 上的均匀分布。
]
#proof[
  $x$服从$f(x)$分布，$y$服从$g(y)$分布。由连续变量变换公式，在可使用密度变换的区间内，
  $
    dv(y, x)=dv(, x) integral_(-oo)^x f(x') dd(x')=f(x)
  $
  因而
  $
    g(y)=f(x) abs(dv(x, y))=f(x) abs(dv(y, x))^(-1)=1
  $
  $y$ 的取值范围是 $(0,1)$，所以这正是均匀密度。更一般的连续累积分布也可直接用累积概率证明该结论。
]

均匀分布是用Monte Carlo方法模拟随机现象的基础。反过来，生成 $u$ 的 $(0,1)$ 均匀分布，再令 $x=F^(-1)(u)$，便可生成目标分布；必要时使用广义逆累积分布。

// 讲义第33–34页
== 指数分布

#definition(subname: [指数分布])[
  以 $xi>0$ 为尺度参数的指数分布，记为 $"Exp"(xi)$，定义为
  $
    f(x;xi)=cases(1/xi e^(-x/xi) & quad x>=0, 0 & quad "其它")
  $
]

#theorem(subname: [指数分布的矩])[
  指数分布的均值和方差为
  $
        E[x] & = integral_0^oo x/xi e^(-x/xi) dd(x)=xi \
    "Var"[x] & = integral_0^oo (x-xi)^2/xi e^(-x/xi) dd(x)=xi^2
  $
]

#figure(image("pic/chap2/exponential.png", width: 60%), caption: [平均尺度 $xi=1,2,5$ 的指数分布])

#example(subname: [不稳定粒子的寿命])[
  不稳定粒子的固有衰变时间为 $x$，平均寿命为 $xi$，则 $x$ 的概率密度服从指数分布。存活到时间 $t$ 的概率为
  $
    P(x>t)=integral_t^oo 1/xi e^(-x/xi) dd(x)=e^(-t/xi)
  $
]

指数分布具有*无记忆性*。已存活 $s$ 后，再存活 $t$ 的条件概率满足
$
  P(x>s+t|x>s)=(e^(-(s+t)/xi))/(e^(-s/xi))=e^(-t/xi)=P(x>t)
$
因此，在该模型下，粒子“已经活了多久”不改变余下寿命的分布。

== $chi^2$ 分布

#definition(subname: [$chi^2$ 分布])[
  设 $x_1,dots,x_n$ 是相互独立的Gauss随机变量，均值、方差分别为 $mu_i,sigma_i^2$，则
  $
    z=sum_(i=1)^n ((x_i-mu_i)/sigma_i)^2
  $
  服从自由度为 $n$ 的 $chi^2$ 分布，其密度为
  $
    f(z;n)=cases(
      z^(n/2-1)/(2^(n/2) Gamma(n/2)) e^(-z/2) & quad z>0,
      0 & quad z<0
    )
  $
  单点 $z=0$ 处的密度值按极限理解，不影响概率。$Gamma$ 函数定义为
  $
    Gamma(r)=integral_0^oo x^(r-1)e^(-x) dd(x), quad r>0
  $
]

因为每个标准正态变量的平方均值为1、方差为2，所以独立求和得到
#theorem(subname: [$chi^2$ 分布的矩])[
  设 $z$ 服从自由度为 $n$ 的 $chi^2$ 分布，则
  $
    E[z]=n, quad "Var"[z]=2n
  $
]
#newpara()
$chi^2$ 分布通常用来检验假设或拟合结果与实际数据的符合程度。

#figure(image("pic/chap2/chi-square.png", width: 61%), caption: [自由度 $n=1,2,5,10$ 的 $chi^2$ 分布])

#note[
  *为什么是这个形状？* 令 $u_i=(x_i-mu_i)/sigma_i$，则 $z=sum_i u_i^2$ 是 $n$ 维标准Gauss随机向量到原点的*距离平方*。其联合密度正比于 $e^(-z/2)$，但 $z$ 的密度还要计入“有多少组 $u_i$ 给出相同的距离”：半径为 $r=sqrt(z)$ 的薄球壳体积正比于 $r^(n-1) dd(r)$，因此
  $
    f(z) dd(z) & prop e^(-r^2/2) r^(n-1) dd(r) \
               & = 1/2 e^(-z/2) z^(n/2-1) dd(z)
  $
  所以，$e^(-z/2)$ 来自Gauss密度，$z^(n/2-1)$ 来自球壳的体积以及 $r -> z$ 的变量变换；归一化后便得到上面的 $chi^2$ 密度。这两个因子的竞争决定曲线形状：
  - $n=1$ 时，密度在 $z -> 0^+$ 处像 $1/sqrt(z)$ 一样增大，但积分有限，$P(z=0)=0$。
  - $n=2$ 时，幂次因子为1，密度就是单调下降的指数函数。
  - $n>2$ 时，原点处密度为零；由 $(upright(d) ln f)/(upright(d) z)=(n/2-1)/z-1/2=0$ 得到峰位 $z=n-2$。自由度越大，越难让所有分量同时接近零，峰便向右移动。

  当 $n$ 很大时，$z$ 是许多独立平方项之和，中心极限定理给出 $(z-n)/sqrt(2n)$ 近似服从标准Gauss分布，曲线因此逐渐接近对称的钟形。

  *为什么能用于检验？* 假设 $H_0$ 给出各测量值的预期值 $mu_i$，且测量误差独立、为Gauss分布、标准差 $sigma_i$ 已知，则每项 $(x_i-mu_i)^2/sigma_i^2$ 表示“偏离预期多少个标准差”的平方。它们的和 $z$ 衡量*相对于测量精度的总偏差*；更关键的是，若 $H_0$ 成立，我们知道重复实验中 $z$ 应如何涨落：$z tilde chi_n^2$。

  观测到 $z_("obs")$ 后，可计算右尾概率
  $
    p=P(Z>=z_("obs") | H_0)=integral_(z_("obs"))^oo f(t;nu) dd(t)
  $
  它表示在假设成立时，出现不小于当前总偏差的概率。若 $p$ 小于事先选定的显著性水平 $alpha$，便拒绝 $H_0$；这不是“$H_0$ 为真的概率”，较大的 $p$ 也不能证明模型正确。

  这里 $nu$ 是*独立残差方向的数目*。预期值完全给定时 $nu=n$；若用同一批数据拟合 $k$ 个独立参数，拟合会消去 $k$ 个残差方向，在线性Gauss模型且设计矩阵满秩时，$z_(min) tilde chi_(n-k)^2$；非线性模型通常只近似成立。因此应比较 $z$ 与相应自由度的分布，不能只看 $z$ 的绝对大小。常用的 $z/nu$ 在假设成立时均值为1，标准差为 $sqrt(2/nu)$。

  若误差相关，应使用已知协方差矩阵构造 $z=(vb(x)-vb(mu))^TT V^(-1)(vb(x)-vb(mu))$；在联合Gauss分布且 $V$ 正定时，这等价于先把残差变换为独立标准Gauss变量再平方求和。误差模型、协方差或自由度不正确，都会使上述尾概率失去相应的检验意义。
]


#example(subname: [圆弧径迹拟合])[
  带电粒子在均匀磁场中的横向径迹为圆弧。设拟合半径为 $R$，各测量点对应半径为 $R_i$，测量误差为 $sigma_i$，构造
  $
    z(R)=sum_i ((R-R_i)/sigma_i)^2
  $
  选择使 $z(R)$ 最小的 $R$，据此求横动量。
]

#figure(
  grid(
    columns: (1fr, 1fr),
    gutter: 12pt,
    image("pic/chap2/track-detector.png", width: 100%), image("pic/chap2/track-residuals.png", width: 100%),
  ),
  caption: [均匀磁场中的探测器径迹，以及测量点相对圆弧的偏差],
)

$P_(x y)="光速" times "磁场" times R$。其含义是横动量与磁场强度、曲率半径成正比；单位换算和电荷量必须与所用约定一致。例如，对电荷量为 $abs(q)=abs(z_q)e$ 的粒子，常用实验单位下
$
  p_T ["GeV/c"] approx 0.2998 abs(z_q) B["T"] R["m"]
$

#note[
  用 $z$ 的 $chi^2$ 分布判断 $R$ 的拟合质量
  - 如果残差独立且为Gauss分布、误差估计正确、模型成立，拟合后的最小 $z$ 应与相应自由度的 $chi^2$ 分布比较。
  - 若有 $m$ 个测量点并拟合 $k$ 个独立参数，在线性或适用的近似条件下自由度为 $m-k$；只拟合半径时通常为 $m-1$，不能把拟合前的测量点数直接当作拟合后的自由度。
  - 明显不符合可能来自模型不合适、误差低估、残差相关、非Gauss尾部、异常点或未建模的探测器效应，应逐项检查。
]

== Cauchy与Breit-Wigner分布

#definition(subname: [Cauchy分布与Breit-Wigner分布])[
  标准Cauchy密度为
  $
    f(x)=1/pi 1/(1+x^2), quad -oo<x<oo
  $
  它是Breit-Wigner分布的特例。后者写作
  $
    f(x;Gamma,x_0)=1/pi (Gamma/2)/(Gamma^2/4+(x-x_0)^2), quad Gamma>0
  $
  其中 $x_0$ 为峰的位置，$Gamma$ 为FWHM；标准Cauchy对应 $x_0=0,Gamma=2$。
]

#figure(
  image("pic/chap2/breit-wigner.png", width: 60%),
  caption: [Breit-Wigner分布：$(x_0,Gamma)=(0,1),(2,1),(0,2)$（讲义第37页）。],
)

$E[x]$ 不好定义，$"Var"[x]=oo$。准确地说，Cauchy分布通常意义的均值不存在，二阶矩发散，所以没有有限方差；不能以对称主值为零替代期望的存在性。其长尾也说明，不能不加条件地对任何分布套用有限方差的中心极限定理。

Breit-Wigner函数常用于描述共振态粒子的不变质量分布，峰位置和宽度是两个关键参数。

#example(subname: [共振态 $phi(1020)$])[
  BES（北京谱仪）实验在 $J "/" psi -> K^+ K^- K^+ K^-$ 中的 $K^+K^-$ 不变质量谱，用Breit-Wigner分布确定共振峰位置与宽度。实验结果为
  $
        m & = (1019.456 plus.minus 0.020) "MeV" \
    Gamma & = (4.26 plus.minus 0.05) "MeV"
  $
  此处按讲义使用自然单位，质量以MeV表示。
]
#figure(
  image("pic/chap2/phi-resonance.png", width: 66%),
  caption: [BES的 $phi(1020)$ 共振峰与拟合曲线],
)

== Landau分布

对于速度 $beta=v/c$ 的带电粒子穿过厚度为 $d$ 的物质，单次能量损失 $Delta$ 存在涨落；薄层中的电离能损常用Landau分布描述，具有明显的高能损长尾。

#definition(subname: [Landau能损分布])[
  参数化写作
  $
    f(Delta;beta)=1/xi phi(lambda)
  $
  其中标准函数为
  $
    phi(lambda)=1/pi integral_0^oo exp(-u ln u-lambda u) sin(pi u) dd(u)
  $
  讲义所列的变量和尺度定义为
  $
      lambda & = 1/xi [Delta-xi(ln(xi/epsilon')+1-1/sqrt(1-beta^2))] \
          xi & = (2 pi N_A e^4 z^2 rho sum Z)/(m_e c^2 sum A) d/beta^2 \
    epsilon' & = (I^2(1-beta^2) exp(beta^2))/(2m_e c^2 beta^2)
  $
  这里 $I$ 为平均激发能；$N_A$ 为Avogadro常数，$m_e$ 为电子质量，$rho$ 为物质密度，$z$ 为入射粒子的电荷数，$(sum Z)/(sum A)$ 沿用讲义对物质组成的记号。
]

#figure(
  image("pic/chap2/landau.png", width: 72%),
  caption: [不同速度 $beta=0.4,0.6,0.95,0.999$ 对应的能损分布],
)

Landau分布常用于描述粒子的电离能损或能量沉积。讲义指出，厚度 $d$ 增大时，能损分布趋向正态形状；这里描述的是实际厚吸收层中多次能量转移累积的物理过程，并不是说把理想Landau密度的尺度单独增大就能消除它的长尾。

== 常见分布与实验用途

从应用角度回顾本章，先确定实验中*什么在随机变化、哪些条件被固定*，再选择相应分布。

#table(
  columns: (1.1fr, 2fr),
  stroke: none,
  inset: 5pt,
  table.hline(stroke: 0.8pt),
  table.header([*分布*], [*典型用途*]),
  table.hline(stroke: 0.5pt),
  [二项式分布], [探测效率、衰变分支比],
  [多项式分布], [固定总数时直方图的统计误差],
  [Poisson分布], [一定通量下的事例估计],
  [均匀分布], [Monte Carlo模拟],
  [指数分布], [粒子的固有衰变时间],
  [Gauss分布], [测量分辨率],
  [多维Gauss分布], [测量结果的相关性],
  [对数正态分布], [许多小的倍增误差共同贡献的误差],
  [$chi^2$ 分布], [检验拟合结果的好坏],
  [Cauchy / Breit-Wigner分布], [共振态的质量与宽度],
  [Landau分布], [粒子的电离能损],
  table.hline(stroke: 0.8pt),
)

*这些分布都可以在ROOT平台中给出*。实际使用时，应核对函数的参数含义、归一化约定和拟合区间，而不只是核对名称。

== 电磁量能器的能量沉积函数

=== Crystal Ball经验函数

实验中常用Crystal Ball函数拟合电磁量能器的能量沉积分布。它用Gauss形状描述峰的核心，用幂律描述一侧尾部。

#definition(subname: [Crystal Ball函数])[
  令 $t=(x-mu)/sigma$，对讲义图示的低能端尾部，取 $alpha>0,sigma>0,n>1$，有
  $
    f_("CB")(x;mu,sigma,alpha,n)
    = N cases(
      exp(-t^2/2) & quad t>-alpha,
      A(n/abs(alpha)-abs(alpha)-t)^(-n) & quad t<=-alpha
    )
  $
  其中
  $
    A=(n/abs(alpha))^n exp(-abs(alpha)^2/2)
  $
  $N$ 为归一化常数。$mu,sigma$ 控制核心的位置与尺度，$alpha$ 控制接合位置，$n$ 控制幂律尾部。
]

它是分段经验函数，“函数的物理意义不清楚”。这提示我们：拟合参数和真实的全吸收能量、分辨率之间不一定存在简单的一一对应，尾部描述也可能依赖所选拟合范围。

#example(subname: [CsI晶体阵列的模拟与拟合])[
  一个 $9 times 9$ 的CsI晶体阵列，每块晶体尺寸为 $7 "cm" times 7 "cm" times 32 "cm"$，晶体间隙为 $0.5 "mm"$，间隙材料为Mylar。
]
#figure(image("pic/chap2/csi-array.png", width: 78%), caption: [CsI阵列的几何和材料设置])
#figure(
  image("pic/chap2/crystal-ball-fit.png", width: 81%),
  caption: [同一CsI能谱在两种拟合范围下的Crystal Ball拟合],
)

图中红线采用与后述量能器函数相同的拟合范围，绿线采用Crystal Ball自身较合适的范围。

// 图示数值为
// #table(
//   columns: (1.5fr, 1fr, 1fr),
//   stroke: none,
//   inset: 5pt,
//   table.hline(stroke: 0.8pt),
//   table.header([*拟合量*], [*红线：相同范围*], [*绿线：最佳范围*]),
//   table.hline(stroke: 0.5pt),
//   [Peak / MeV], [49.390], [49.444],
//   [Width / MeV], [2.145], [2.110],
//   [$chi^2 / "NDF"$], [8383/395], [1411/176],
//   table.hline(stroke: 0.8pt),
// )
// 这保留了讲义中关于拟合范围、峰位置和宽度变化的比较。

=== 全吸收峰、泄漏尾部与分辨率卷积

重新从能量沉积过程出发，将响应分为三部分：
+ *全吸收峰*：粒子能量被完整吸收，在理想情况下集中在一个能量值；
+ *能量泄漏尾部*：部分能量逃出有效探测体积，使沉积能量落在峰的低能侧；
+ *Gauss型能量分辨率*：测量过程对前两部分进行展宽，用卷积表示。

#figure(
  image("pic/chap2/calorimeter-components.png", width: 53%),
  caption: [展宽前的全吸收峰与泄漏尾部、展宽后的总谱，以及分开的峰和尾贡献],
)

#definition(subname: [量能器响应模型])[
  能量沉积响应函数为
  $
    f_("cal") & = (alpha f_("peak")+(1-alpha)f_("tail")) ⊗ f_("resolution") \
              & = (alpha delta+(1-alpha)f_("tail")) ⊗ "Gauss"
  $
  此处 $0<=alpha<=1$ 表示全吸收部分的权重，与Crystal Ball函数中的接合参数 $alpha$ 含义不同；$⊗$ 表示卷积。
]

更明确地，若全吸收能量为 $E_0$，可写 $f_("peak")(E)=delta(E-E_0)$。将真实沉积能量 $E'$ 与分辨率响应积分，得到
$
  f_("cal")(E)=integral [alpha delta(E'-E_0)+(1-alpha)f_("tail")(E')]
  f_("resolution")(E-E') dd(E')
$
这样，峰、尾和展宽分别对应明确的物理过程。讲义未进一步给出 $f_("tail")$ 的具体形式，故这里保留为模型的一部分，不自行指定。

// === 与Crystal Ball拟合的比较

// 讲义第43页比较了液体闪烁体、标定源和CsI晶体阵列三个例子。下表按原表逐项保留数值；“峰位、分辨率、峰面积”对应原表的 Peak accu.、Resolution accu.、Peak area accu.，百分数的符号沿用原表。

// #table(
//   columns: (1.2fr, 0.9fr, 0.9fr, 0.9fr),
//   stroke: none,
//   inset: 4pt,
//   table.hline(stroke: 0.8pt),
//   table.header([*比较量*], [*量能器函数*\ 最佳范围], [*Crystal Ball*\ 相同范围], [*Crystal Ball*\ 最佳范围]),
//   table.hline(stroke: 0.5pt),
//   table.cell(colspan: 4)[*液体闪烁体（Liquid scintillator）*],
//   [峰位], [$-0.042%$], [$-0.80%$], [$-0.53%$],
//   [分辨率], [$0.044%$], [$4.8%$], [$1.9%$],
//   [峰面积], [$-0.59%$], [$22%$], [$19%$],
//   [$chi^2 / "NDF"$], [119/118], [9027/120], [115/47],
//   table.hline(stroke: 0.4pt),
//   table.cell(colspan: 4)[*标定源（Calibration source）*],
//   [峰位], [$0.0054%$], [$-0.40%$], [$-0.25%$],
//   [分辨率], [$0.22%$], [$5.8%$], [$2.6%$],
//   [峰面积], [$-0.095%$], [$18%$], [$14%$],
//   [$chi^2 / "NDF"$], [59/35], [5197/35], [81/15],
//   table.hline(stroke: 0.4pt),
//   table.cell(colspan: 4)[*CsI晶体阵列（CsI crystal array）*],
//   [峰位], [$-0.18%$], [$-1.2%$], [$-1.1%$],
//   [分辨率], [$0.15%$], [$7.3%$], [$5.5%$],
//   [峰面积], [$17%$], [$128%$], [$124%$],
//   [$chi^2 / "NDF"$], [378/395], [8383/395], [1411/176],
//   table.hline(stroke: 0.8pt),
// )

// 这组比较说明，在讲义给出的例子中，显式区分全吸收、泄漏与分辨率的模型改善了峰位和分辨率的提取，尤其是使用相同拟合范围时。它也提示：判断一个响应函数是否合适，除了曲线形状，还要同时检查拟合优度、拟合范围和物理参数的偏差。
