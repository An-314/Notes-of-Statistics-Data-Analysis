#import "@preview/scripst:1.1.2": *

= 基本概念

*实验测量*给出每个事例的特征量(能动量，末态粒子数…)，*理论预言*给出上述各特征量的分布，而且可能还会包含自由参数。我们通过实验数据来检验理论预言的正确性，或者通过实验数据来确定理论预言中的自由参数。统计数据分析就是在这个过程中所使用的数学方法。

由于我们的探测器并不是完美的，在实验中除了原初物理之外还受到分辨率、探测效率、本底噪声等影响。我们的物理目标是从实验数据中去掉这些影响，得到原初物理的分布。

```
物理目标 -> 设计实验 -> 采集数据 -> 统计分析 - 估计(测量)参数         -> 结论
                                          - 量化参数估计的不确定度
                                          - 检验理论与实验的符合程度
```

#newpara()
*粒子物理与核物理中随机性的主要来源*
- 理论本身是非确定的：量子力学，统计力学
- 测量的随机不确定性：即使没有量子效应也存在
- 有些因素原则上可以确定但实际不确定：受限于所需费用、时间、方法等
这些不确定性可以用概率量化描述

*概率与统计的差别*
- 概率：给定模型，预测数据
- 统计：给定数据，推断模型

== 概率的定义与诠释

#definition(subname: [随机事件])[
  在一定的实验条件下，现象$A$可能发生，也可能不发生，并且只有发生或不发生这样两种可能性，这是偶然现象中一种比较简单的情形，我们把发生了现象$A$的事例称为*随机事件$A$*，简称*事件$A$*。随机事件也称随机事例。
]

概率的定义由 Kolmogorov 给出，概率的诠释有频率诠释、主观诠释、逻辑诠释等。
#definition(subname: [Kolmogorov公理])[
  考虑一全集$S$， 其子集$A,B,...$
  + $P(A) >= 0, forall A subset S$
  + $P(S) = 1$
  + $P(A union B) = P(A) + P(B), forall A,B subset S, A inter B = emptyset$
  就称$P(A)$为事件$A$的概率，$P$为概率函数。
]
可以得到
$
  P(overline(A)) = 1 - P(A)\
  P(A union overline(A)) = 1\
  A subset B => P(A) <= P(B)\
$
以及
$
  P(A union B) = P(A) + P(B) - P(A inter B)\
$
#newpara()
#definition(subname: [条件概率])[
  在给定事件$B$发生的条件下，事件$A$发生的概率称为*条件概率*，记为$P(A|B)$。其定义为
  $
    P(A|B) = (P(A inter B)) / P(B), P(B) > 0\
  $
]

#definition(subname: [事件独立])[
  如果事件$A$发生与否不影响事件$B$发生的概率，称事件$A$与事件$B$是*独立的*，其定义为
  $
    P(A inter B) = P(A)P(B)\
  $
]

#newpara()
如果$A,B$是独立的，则有
$
  P(A|B) = (P(A inter B)) / P(B) = (P(A)P(B)) / P(B) = P(A)\
$
这意味着事件$A$发生与否不影响事件$B$发生的概率，反之亦然。

#note[
  *独立和互斥*是不同的概念。这意味着
  $
    P(A inter B) = 0
  $<->
  不意味着
  $
    P(A|B) = P(A)
  $<->
]

#newpara()

下面讨论*概率的诠释*。

#definition(subname: [概率的诠释：相对频率（频率论者）])[
  假设$A,B,...$是可*重复实验的一组结果*，则概率为
  $
    P(A) = lim_(n -> oo) n_A / n
  $
  其中
  - $n$为实验总次数
  - $n_A$为事件$A$发生的次数
]
在量子力学、粒子散射、辐射衰变、宇宙线等实验中，事件$A$的发生是随机的，且每次实验都是独立的。随着实验次数$n$的增加，事件$A$发生的相对频率$n_A/n$会趋于一个稳定值，这个稳定值就是事件$A$的概率。

实际问题中，统计量总是有限的。$P(A)$完全取决于$A$的划分与总统计量的大小；概率大小会出现波动。频率的概率解释不适用于某些特殊情况：例如惰性中微子存在？暗物质存在？


#definition(subname: [概率的诠释：主观概率（Bayesian）])[
  如果$A,B,...$是一些*假设*(真或假的一些陈述)，那么概率
  $
    P(A) = "degree of belief in" A\
  $
  表示对$A$为真的信心程度。
]
例如对于大爆炸理论、超弦理论的正确性，我们无法通过实验来验证其概率，但我们可以根据现有的理论和实验结果来判断其正确性的可能性。

主观概率有一些吸引人的地方，例如对于不可重复现象的处理中，显得比较自然
- 系统误差(重复实验时仍保持不变)；
- 在某个事例出现的粒子是正电子；
- 自然界是超对称的；
- 明天将下雨(将来事件的不确定性)。
结论中包含了主观上对事件为真的信念。

这两种解释皆与Kolmogorov公理相容。频率解释的概率是客观的，主观解释的概率是主观的。粒子物理与核物理实验中常用相对频率解释，但是主观概率对不可重复现象可以提供更自然的处理：系统不确定度，某个粒子存在的概率，置信区间的解释等。

#newpara()

#theorem(subname: [Bayes定理])[
  对于事件$A,B, P(A)!=0, P(B)!=0$，有
  $
    P(A|B) = (P(B|A)P(A)) / P(B)\
  $
]
#proof[
  根据条件概率的定义，有
  $
    P(A|B) = (P(A inter B)) / P(B)\
  $
  同时有
  $
    P(B|A) = (P(A inter B)) / P(A)\
  $
  将$P(A inter B)$消去，得到
  $
    P(A|B) = (P(B|A)P(A)) / P(B)\
  $
]

#theorem(subname: [全概率公式])[
  对于事件$B$，以及样本空间$S$的划分$A_1,A_2,...,A_n$
  $
    A_i inter A_j = emptyset, forall i!=j\
    union.big_(i=1)^n A_i = S\
  $
  则有
  $
    P(B) = sum_(i=1)^n P(B|A_i)P(A_i)\
  $
]

#proof[
  根据条件概率的定义，有
  $
    P(B|A_i) = (P(A_i inter B)) / P(A_i)\
  $
  将$P(A_i inter B)$消去，得到
  $
    P(A_i inter B) = P(B|A_i)P(A_i)\
  $
  因为$A_1,A_2,...,A_n$是样本空间$S$的划分，所以有
  $
    B = union.big_(i=1)^n (A_i inter B)\
  $
  且
  $
    (A_i inter B) inter (A_j inter B) = emptyset, forall i!=j\
  $
  根据概率的可加性，有
  $
    P(B) & = sum_(i=1)^n P(A_i inter B) \
         & = sum_(i=1)^n P(B|A_i)P(A_i) \
  $
]

Bayes定理也可以写成
$
  P(A_i|B) = (P(B|A_i)P(A_i)) / P(B) = (P(B|A)P(A)) / (sum_(i=1)^n P(B|A_i)P(A_i))\
$
#newpara()

Bayes理论通常用于主观概率问题
$
  P("理论"|"实验") = (P("实验"|"理论")P("理论")) / P("实验")\
$
即*验后概率*等于*先验概率*乘以*似然性*。这是个“认识-实践-再认识-再实践”的迭代过程：
- 如果实验证明 $P("理论"|"实验") = 0$，则表明理论不能接受
- 大的 $P("理论"|"实验")$ 会增加对理论的信任度
- 通过实验结果可以修改 $P("理论")$
- 改进的 $P("理论")$ 可应用于对重复实验结果的预测
- $P("理论"|"实验")$ 对先验理论的依赖将最终消失

#example(subname: [Bayes定理的应用])[
  假设对任意一个人而言，感染上AIDS的概率为
  $
    P("AIDS") = 0.001, P("not AIDS") = 0.999\
  $
  任何一次AIDS检查的结果只有阴性(-)或阳性(+)两种
  $
    P(+|"AIDS") = 0.98, P(-|"AIDS") = 0.02\
    P(+|"not AIDS") = 0.03, P(-|"not AIDS") = 0.97\
  $
  如果某人检查结果为阳性(+)，而他却觉得自己无明显感染渠道。那么他是否应担心自己真的感染了AIDS？
]

#solution[
  我们想求$P("AIDS"|+)$

  Bayes定理给出
  $
    P("AIDS"|+) & = (P(+|"AIDS")P("AIDS")) / P(+) \
                & = (P(+|"AIDS")P("AIDS")) / (P(+|"AIDS")P("AIDS") + P(+|"not AIDS")P("not AIDS")) \
                & = (0.98 times 0.001) / (0.98 times 0.001 + 0.03 times 0.999) \
                & approx 0.032 \
  $
  - 从个人角度看：对自己染上AIDS结果的可信度为3.2%。
  - 从医生角度看：象这样的人有3.2%感染上了AIDS。
]

== 随机变量与概率密度

#definition(subname: [随机变量])[
  *随机变量*是样本空间元素的一个实值单值函数，它将样本空间$S$中的每个事件$A$映射到实数集$RR$中的一个实数$x$，即
  $
    X: S -> RR\
  $
  随机变量的取值$x$是随机的。随机变量可以是离散的，也可以是连续的。
]
#newpara()
假设实验结果为连续值$x$，则在$x$附近的区间$[x,x+dd(x)]$内，事件$A$发生的概率为
$
  P(x in [x,x+dd(x)]) = f(x)dd(x)\
$
这就定义了概率密度函数$f(x)$。
#definition(subname: [概率密度函数])[
  *概率密度函数*(pdf)$f(x)$是一个非负的实值函数，它满足
  $
    P(x in [x,x+dd(x)]) = f(x)dd(x)\
  $
  且
  $
    integral_(-oo)^(oo) f(x)dd(x) = 1\
  $
]
$f(x)$自身不具备概率的含义。而对于离散随机变量，概率密度函数$f(x)$就是概率质量函数。
#definition(subname: [概率质量函数])[
  *概率质量函数*(pmf)$f(x)$是一个非负的实值函数，它满足
  $
    P(X=x) = f(x)\
  $
  且
  $
    sum_(x in S) f(x) = 1\
  $
]
#newpara()
还可以定义*累积分布函数*
#definition(subname: [累积分布函数])[
  *累积分布函数*(cdf)$F(x)$是一个非负的实值函数，它满足
  $
    F(x) = P(X <= x) = integral_(-oo)^x f(x')dd(x')\
  $
  且
  $
    lim_(x -> oo) F(x) = 1\
  $
]
概率密度函数可以定义为
$
  f(x) = pdv(F(x), x)\
$
由此我们可以定义$alpha$分位数
#definition(subname: [分位数，中位数])[
  *分位数*(quantile)是一个实数$x_alpha$，它满足
  $
    P(X <= x_alpha) = F(x_alpha) = alpha\
  $
  其中$alpha in [0,1]$。因此分位点
  $
    x_alpha = F^(-1)(alpha)\
  $
  特别地，*中位数*(median)是一个实数$x_m$，它满足
  $
    P(X <= x_m) = F(x_m) = 0.5, alpha = 0.5\
  $
  随机变量$x$被观测到大于或小于中位数的概率相等。
]

#definition(subname: [模])[
  *模*(mode)是一个实数$x_0$，它满足
  $
    f(x_0) = max(f(x))\
  $
  模是概率密度函数的最大值点。对于离散随机变量，模是概率质量函数的最大值点。
]

直方图与概率密度函数的关系是：直方图可以用来估计概率密度函数。在每个区间内，直方图的高度表示该区间内数据的频率，而概率密度函数则表示该区间内数据的概率。概率密度函数 pdf 就是样本无穷大，区间宽度为零，且归一化到单位面积的直方图。
$
  f(x) = (N(x))/(n Delta x)\
$
其中
- $N(x)$为落在区间$[x,x+Delta x]$内的样本数
- $n$为样本总数
- $Delta x$为区间宽度
而$n -> oo, Delta x -> 0$时，直方图就变成了概率密度函数。

如果观测量不止一个，则可以定义*联合概率密度函数*
#definition(subname: [联合概率密度函数])[
  *联合概率密度函数*(joint pdf)$f(x_1,x_2,...,x_n)$是一个非负的实值函数，它满足
  $
    P(x_1 in [x_1,x_1+dd(x_1)], x_2 in [x_2,x_2+dd(x_2)],..., x_n in [x_n,x_n+dd(x_n)]) \
    = f(x_1,x_2,...,x_n)dd(x_1)dd(x_2)...dd(x_n)\
  $
  且
  $
    integral_(-oo)^(oo) ... integral_(-oo)^(oo) f(x_1,x_2,...,x_n)dd(x_1)dd(x_2)...dd(x_n) = 1\
  $
]
如果我们只关心其中的一个观测量$x_i$，则可以定义*边缘概率密度函数*
#definition(subname: [边缘概率密度函数])[
  *边缘概率密度函数*(marginal pdf)$f(x_i)$是一个非负的实值函数，它满足
  $
    f_x_i (x_i) = integral_(-oo)^(oo) ... integral_(-oo)^(oo) f(x_1,x_2,...,x_n)dd(x_1)...dd(x_(i-1))dd(x_(i+1))...dd(x_n)\
  $
]
#definition(subname: [随机变量独立])[
  如果随机变量$X_1,X_2,...,X_n$的联合概率密度函数可以分解为各自的边缘概率密度函数的乘积，即
  $
    f(x_1,x_2,...,x_n) = f_x_1 (x_1)f_x_2 (x_2)...f_x_n (x_n)\
  $
  则称随机变量$X_1,X_2,...,X_n$是*独立的*。
]
有时，我们关心联合pdf中某个变量为常数的情况，这就是*条件概率密度函数*
#definition(subname: [条件概率密度函数])[
  *条件概率密度函数*(conditional pdf)$f(x_i|x_j)$是一个非负的实值函数，它满足
  $
    h(x_i|x_j) = f(x_i,x_j) / (f_x_j (x_j)), f_x_j (x_j) > 0\
    g(x_j|x_i) = f(x_i,x_j) / (f_x_i (x_i)), f_x_i (x_i) > 0\
  $
  且
  $
    integral_(-oo)^(oo) f(x_i|x_j)dd(x_i) = 1\
  $
  Bayes定理也可以写成
  $
    f(x_i|x_j) = (f(x_j|x_i)f_x_i (x_i)) / (f_x_j (x_j))\
  $
]

#example(subname: [条件概率密度函数])[
  已知联合概率密度$f(x,y)$，求条件概率密度$h(y|x_1)$
]

#solution[
  将$f(x,y)$中的$x$固定为$x_1$，则有
  $
    h(y|x_1) = f(x_1,y) / (f_x (x_1)), f_x (x_1) > 0\
  $
]

== 随机变量的函数

#example(subname: [数据分析中的问题])[
  粒子物理与核物理实验中对动量的测量通常是分别测量
  $
    p_T = sqrt(p_x^2 + p_y^2), p_z
  $
  有分布
  $
    f(p_T, p_z)
  $
  在已知两分量测量值的概率密度函数情况下，总动量为
  $
    p = sqrt(p_T^2 + p_z^2)
  $
  如何导出总动量的测量值的概率密度函数
  $
    g(p)
  $
  是研究随机变量函数的p.d.f问题。
]
随机变量的函数自身也是一个随机变量。

=== 一维随机变量的函数

假设随机变量$x$服从概率密度$f(x)$，对于函数$a(x)$，其概率密度$g(a)$为何？

如果$a(x)$是单调函数，则有
$
  g(a) dd(a) & = integral_(a in [a,a+dd(a)]) f(x') dd(x') \
             & = integral_(x(a))^(x(a) + abs(dv(x, a)) dd(a)) f(x') dd(x') \
             & = f(x(a)) abs(dv(x, a)) dd(a) \
$
事实上如果即$a$的累积分布为$G(a)$，$x$的累积分布为$F(x)$，则有
$
  G(a) = F(x(a))\
  g(a) = dv(G(a), a) = dv(F(x(a)), a) = dv(F(x(a)), x(a)) dv(x(a), a) = f(x(a)) abs(dv(x, a))\
$
#newpara()
假如$a(x)$的逆并不是一个单值函数，而是一个多值函数，则$a -> a+ dd(a)$将包括多个$x$区间
$
  g(a) dd(a) & = sum_(i=1)^n integral_(x_i (a))^(x_i (a) + abs(dv(x, a)) dd(a)) f(x') dd(x') \
             & = sum_(i=1)^n f(x_i (a)) abs(dv(x, a)) dd(a) \
$
其中
$
  a(x_i) = a, i = 1,2,...,n\
$

#example(subname: [])[
  例如$a = x^2, x = plus.minus sqrt(a)$
  $
    dd(x) = plus.minus dd(a)/(2 sqrt(a))\
  $
  故
  $
    g(a) dd(a) & = integral_(sqrt(a))^(sqrt(a) + dd(x)) f(x') dd(x') + integral_(-sqrt(a))^(-sqrt(a) + dd(x)) f(x') dd(x') \
               & = f(sqrt(a)) dd(a)/(2 sqrt(a)) + f(-sqrt(a)) dd(a)/(2 sqrt(a)) \
               & = (f(sqrt(a)) + f(-sqrt(a))) dd(a)/(2 sqrt(a)) \
  $
]

=== 多维随机变量的函数

考虑多维随机变量$vb(x) = (x_1,x_2,...,x_n)$，其联合概率密度函数为$f(vb(x))$。对于函数$a(vb(x))$，其联合概率密度函数为$g(a)$
$
  g(a) dd(a) = integral_(dd(S)) f(vb(x)) dd(vb(x))
$
其中$dd(S)$是在$a(vb(x)) -> a + dd(a)$时，$vb(x)$在空间中的一个微小区域
$
  dd(S) = {vb(x) : a(vb(x)) in [a, a + dd(a)]}
$
也通常写作
$
  g(a)= integral_(RR^n) f(vb(x)) delta(a - a(vb(x))) dd(vb(x))
$
它等价于
$
  g(a) = integral_(a(vb(x)) = a) f(vb(x))/norm(grad(a(vb(x)))) dd(Sigma)\
$

#example()[
  如果两个随机变量$x,y>0$，服从联合概率密度 $f(x,y)$，考虑函数$z = x y$，其概率密度函数$g(z)$是什么形式？

  给定$x$，当$z in (z, z + dd(z))$，$y in (z/x, z/x + dd(z)/x)$，则有
  $
    g(z) dd(z) & = integral_(dd(S)) f(x,y) dd(x) dd(y) \
               & = integral_(0)^(oo) dd(x) integral_(z/x)^(z/x + dd(z)/x) f(x, y) dd(y) \
               & = integral_(0)^(oo) dd(x) (f(x, z/x) dd(z)/x) \
               & = ( integral_(0)^(oo) f(x, z/x) dd(x)/ x) dd(z) \
  $
  从而
  $
    g(z) & = integral_(0)^(oo) f(x, z/x) dd(x)/ x \
    g(z) & = integral_(0)^(oo) f(z/y, y) dd(y)/ y \
  $
]

#example()[
  如果两个随机变量$x,y>0$，服从联合概率密度 $f(x,y)$，考虑函数$z = x + y$，其概率密度函数$g(z)$是什么形式？

  给定$x$，当$z in (z, z + dd(z))$，$y in (z - x, z - x + dd(z))$，则有
  $
    g(z) dd(z) & = integral_(dd(S)) f(x,y) dd(x) dd(y) \
               & = integral_(0)^(oo) dd(x) integral_(z - x)^(z - x + dd(z)) f(x, y) dd(y) \
               & = integral_(0)^(oo) dd(x) (f(x, z - x) dd(z)) \
               & = ( integral_(0)^(oo) f(x, z - x) dd(x)) dd(z) \
  $
  从而
  $
    g(z) & = integral_(0)^(oo) f(x, z - x) dd(x) \
    g(z) & = integral_(0)^(oo) f(z - y, y) dd(y) \
  $
]

=== Mellin卷积与Fourier卷积

上面的分析给出：假设随机变量$x, y$相互独立，分别服从概率密度函数$g(x)$和$h(y)$分布。

$z = x y$的概率密度函数为
$
  g(z) & = integral_(-oo)^(oo) g(x) h(z/x) dd(x)/abs(x) \
  g(z) & = integral_(-oo)^(oo) g(z/y) h(y) dd(y)/abs(y) \
$
这是Mellin卷积。

$z = x + y$的概率密度函数为
$
  g(z) & = integral_(-oo)^(oo) g(x) h(z - x) dd(x) \
  g(z) & = integral_(-oo)^(oo) g(z - y) h(y) dd(y) \
$
这是Fourier卷积。

=== 多维随机变量的函数与Jacobian

考虑随机矢量$vb(x) = (x_1,x_2,...,x_n)$，其联合概率密度函数为$f(vb(x))$。对于函数$vb(a) = (a_1(vb(x)), a_2(vb(x)),..., a_n(vb(x)))$，且其逆$vb(x) = (x_1(vb(a)), x_2(vb(a)),..., x_n(vb(a)))$存在，其联合概率密度函数为$g(vb(a))$
$
  g(vb(a)) dd(vb(a)) = det jacobianmatrix(vb(x); vb(a), delim: "|") f(vb(x)) dd(vb(x))
$
其中Jacobian矩阵为
$
  jacobianmatrix(vb(x); vb(a), delim: "|") = jacobianmatrix(x_1, x_2, ..., x_n; a_1, a_2, ..., a_n, delim: "|")
$

对联合概率密度$g(vb(a))$积分掉其他不关心的变量，可以得到任意一个边缘概率密度 $g_i(a_i)$。这是数据分析中误差传递的基础。

== 期待值、方差

=== 期待值、方差、标准差

#definition(subname: [期望])[
  考虑概率密度为$f(x)$的随机变量$x$，定义*期待(平均)值*为
  $
    E[x] = mu = integral x f(x) dd(x)\
  $
  对离散型变量，有
  $
    E[x] = mu = sum_(i = 1)^n x_i P(x_i)\
  $
]
对概率密度为$g(y)$的函数$y(x)$，有
$
  E[y] = integral y g(y) dd(y) = integral y(x) f(x) dd(x)\
$
其中
$
  g(y) dd(y) = f(x) dd(x)\
$

#definition(subname: [方差])[
  考虑概率密度为$f(x)$的随机变量$x$，定义*方差*为
  $
    "Var"[x] = sigma^2 = E[(x - E[x])^2] = integral (x - mu)^2 f(x) dd(x)\
  $
  对离散型变量，有
  $
    "Var"[x] = sigma^2 = E[(x - E[x])^2] = sum_(i = 1)^n (x_i - mu)^2 P(x_i)\
  $
  定义*标准差*为
  $
    sigma = sqrt("Var"[x])\
  $
]

=== 协方差与相关系数

#definition(subname: [协方差与相关系数])[
  考虑概率密度为$f(x,y)$的随机变量$x,y$，定义*协方差*为
  $
    "cov"[x, y] & = E[(x - E[x])(y - E[y])] = E[x y] - E[x]E[y] \
                & = integral (x - mu_x)(y - mu_y) f(x, y) dd(x) dd(y) \
  $
  定义*相关系数*为
  $
    rho_(x y) = "cov"[x, y] / (sigma_x sigma_y)\
  $
  无量纲。
]
如果$x,y$相互独立，即
$
  f(x, y) = f_x (x) f_y (y)\
  E[x y] = integral x y f_x (x) f_y (y) dd(x) dd(y) = E[x] E[y]\
  "cov"[x, y] = 0 , rho_(x y) = 0\
$
即$x,y$不相关。

#note[
  - $E[x]$是不是$x$的函数？

    并非，$E[x]$是$f(x)$的泛函。

  - $x,y$的相关系数$rho_x,y =0$，则$x,y$是否独立？

    并非，$rho_x,y =0$仅说明$x,y$线性不相关
    $
      Y = X^2 ==> rho_(X,Y) = 0
    $
]

#example(subname: [样本均值])[
  假设实验研究某核素衰变寿命，探测效率$100%$，共测量了$n$次，每次探测结果为$t_i$。求平均寿命(即寿命的期待值)。

  概率密度$P(t_i)$，根据相对频率的概率诠释
  $
    P(t_i) = 1/n
  $
  因此，平均寿命（或期待值）为
  $
    E[t] = mu = sum_(i=1)^n t_i P(t_i) = 1/n sum_(i=1)^n t_i\
  $
]

== 不确定度的传递

=== 不确定度的传递

$n$个随机变量$vb(x) = (x_1,x_2,...,x_n)$，其联合概率密度函数为$f(vb(x))$，其协方差矩阵$V_(i j) = "cov"[x_i, x_j]$（表征与$x_i$有关的测量不确定度）。我们希望计算$y$的不确定度。

可以用求概率密度函数的方法，硬核计算法
$
  "Var"[y] = E[y^2] - E^2[y]
$
但现实中过程经常比较复杂。

事实上在实际计算中，现实中通常只能根据测量得到$vb(x)$的估计，假设我们已知
$
  vb(mu) = E[vb(x)]
$
对$y(vb(x))$在$vb(mu)$处进行Taylor展开
$
  y(vb(x)) = y(vb(mu)) + sum_(i=1)^n evaluated(pdv(y, x_i))_(vb(x) = vb(mu)) (x_i - mu_i) + O((x_i - mu_i)^2)
$
为了得到$"Var"[y]$，我们需要计算$E[y - E[y]]^2$，由于
$
  E[x_i - mu_i] = 0
$
有
$
  E[y(vb(x))] = y(vb(mu)) + O((x_i - mu_i)^2)
$
而
$
  E[(y - E[y])^2] &= E[(sum_(i=1)^n evaluated(pdv(y, x_i))_(vb(x) = vb(mu)) (x_i - mu_i))(sum_(j=1)^n evaluated(pdv(y, x_j))_(vb(x) = vb(mu)) (x_j - mu_j))] + O((x_i - mu_i)^3) \
  &= sum_(i=1)^n sum_(j=1)^n evaluated(pdv(y, x_i))_(vb(x) = vb(mu)) evaluated(pdv(y, x_j))_(vb(x) = vb(mu)) E[(x_i - mu_i)(x_j - mu_j)] + O((x_i - mu_i)^3) \
  &= sum_(i=1)^n sum_(j=1)^n evaluated(pdv(y, x_i))_(vb(x) = vb(mu)) evaluated(pdv(y, x_j))_(vb(x) = vb(mu)) "cov"[x_i, x_j] + O((x_i - mu_i)^3) \
$
因此，$y(vb(x))$的方差为
$
  sigma_y^2 approx sum_(i,j=1)^n evaluated(pdv(y, x_i) pdv(y, x_j))_(vb(x) = vb(mu)) V_(i j)
$
这是*不确定度传递公式*，也称为*误差传递公式*。

#theorem(subname: [不确定度传递公式])[
  考虑$n$个随机变量$vb(x) = (x_1,x_2,...,x_n)$，其联合概率密度函数为$f(vb(x))$，其协方差矩阵$V_(i j) = "cov"[x_i, x_j]$。对于函数$y(vb(x))$，其方差为
  $
    sigma_y^2 approx sum_(i,j=1)^n evaluated(pdv(y, x_i) pdv(y, x_j))_(vb(x) = vb(mu)) V_(i j)\
  $
]
#newpara()

如果$x_i$不相关，即
$
  V_(i j) = sigma_i^2 delta_(i j)
$
则
$
  sigma_y^2 approx sum_(i=1)^n evaluated((pdv(y, x_i))^2)_(vb(x) = vb(mu)) sigma_i^2\
$
类似地，对于$m$组函数$vb(y)(vb(x)) = (y_1(vb(x)), y_2(vb(x)),..., y_m(vb(x)))$，其协方差矩阵$U_(i j) = "cov"[y_i, y_j]$，有
$
  U_(k l) approx sum_(i,j=1)^n evaluated(pdv(y_k, x_i) pdv(y_l, x_j))_(vb(x) = vb(mu)) V_(i j)\
$
或者，写成矩阵形式
$
  U approx J V J^TT\
$
其中
$
  J = jacobianmatrix(vb(y); vb(x))_(vb(x) = vb(mu)) , J_(k i) = (pdv(y_k, x_i))_(vb(x) = vb(mu))\
$
是Jacobian矩阵。

不确定度传递公式告诉我们，如何用原始变量$x$的协方差表示一组函数$vb(y)(vb(x))$。其局限性是：
- 只有当$vb(y)(vb(x))$为线性时才严格成立
- 如果函数在与$sigma_i$差不多的范围内是非线性的，这个近似不再适用
前面的推导并没有要求$x_i$的概率密度的严格形式。

#example(subname: [不确定度传递的一些特例])[
  $
    y = x_1 + x_2
  $
  则有
  $
    sigma_y^2 = sigma_1^2 + sigma_2^2 + 2 "cov"[x_1, x_2]\
  $
  #newpara()
  $
    y = x_1 x_2
  $
  则有
  $
    sigma_y^2/y^2 = sigma_1^2/x_1^2 + sigma_2^2/x_2^2 + (2 "cov"[x_1, x_2])/(x_1 x_2)\
  $
  如果$x_i$不相关：
  - 和的不确定度的平方等于不确定度的平方和
  - 积的相对不确定度的平方等于相对不确定度的平方和
  #example(count: false)[
    考$y=x_1-x_2$，其中：$mu_1 = mu_2 = 10$， $sigma_1 = sigma_2 = 1$。
    - 如果$rho = 0$，即$x_1,x_2$不相关，则有
      $
        sigma_y^2 = sigma_1^2 + sigma_2^2 = 2\
      $
    - 如果$rho = 1$，即$x_1,x_2$完全相关，则有
      $
        sigma_y^2 = sigma_1^2 + sigma_2^2 + 2 "cov"[x_1, -x_2] = 0\
      $
      即，对于 100% 相关的两个变量，其差的不确定度为零。

      这种特征有时候是有益的：将共同的或难以估计的不确定度，通过适当的数学处理将它们消掉，达到减小不确定度的目的。
  ]
]


#example(subname: [用近、远探测器减小共同不确定度])[
  大亚湾实验的主要目标是精确测量中微子振荡混合角 $theta_13$。反应堆发射的电子反中微子在传播过程中发生振荡，存活概率 $P(overline(nu)_e -> overline(nu)_e)$ 随传播距离改变。

  讲义用下式概括距离为 $r$ 处的探测信号：
  $
    Delta I_r prop (Delta S)/(4 pi r^2) I
    f(Delta m, sin theta_13) sigma_("xsec") epsilon_("eff")
  $
  其中各因子的含义为
  - $r$：探测器与反应堆的距离；$Delta S$：探测器对应的面元。
  - $I$：反应堆发射中微子的源强，几何稀释因子为 $1/(4 pi r^2)$。
  - $f(Delta m, sin theta_13)$：存活概率 $P(overline(nu)_e -> overline(nu)_e)$，讲义省略了其对距离和能量的依赖。
  - $sigma_("xsec")$：中微子与探测器的反应截面；$epsilon_("eff")$：探测效率。
  - $Delta m$、$sin theta_13$：振荡模型中的待测量或待约束参数。

  到达探测器面元的通量由 $(Delta S)/(4 pi r^2) I P(overline(nu)_e -> overline(nu)_e)$ 给出；再计入反应截面、效率以及靶粒子数等归一化因素，才得到探测信号。上式是这些因素的示意关系。

  讲义以实现约 $1%$ 的测量精度为目标：除了在振荡效应较大的远处放置探测器，还在靠近反应堆的位置放置两个近点探测器。*这样做为什么有效？*
]

#figure(
  image("pic/chap1/daya-bay-layout.png", width: 66%),
  caption: [大亚湾近点、远点探测器的布局示意],
)

#solution[
  近点探测器测量反应堆源强，远点探测器对振荡造成的存活概率变化更敏感。对同一能量区间，在简化的单源模型中，令 $K_a=(Delta S_a)/(4 pi r_a^2)$，则经几何修正的远近信号比满足
  $
    R = (Delta I_("far")/K_("far"))/(Delta I_("near")/K_("near"))
    approx P_("far")/P_("near")
    epsilon_("far")/epsilon_("near")
  $
  这里比较了等效靶粒子数、曝光时间均已校正的信号；共同的源强 $I$ 和反应截面因子在比值中抵消。若近点的振荡效应较小，$P_("near") approx 1$，比值便主要约束远点的存活概率。

  从不确定度传递来看，记经校正的远、近信号为 $F,N$，则 $R=F/N$ 的相对方差为
  $
    sigma_R^2/R^2 approx sigma_F^2/F^2 + sigma_N^2/N^2
    - (2 "cov"[F,N])/(F N)
  $
  共同归一化误差使 $F,N$ 正相关，因而在比值中抵消。例如 $F=(1+delta) F_0$、$N=(1+delta) N_0$ 时，$F/N=F_0/N_0$ 与 $delta$ 无关。

  实际有多组反应堆，两个近点探测器分别约束不同反应堆组的通量，再按各反应堆到远点的贡献加权。探测器的相对效率、非共同本底和统计误差仍需单独处理；关键是减小*共同的系统不确定度*。
]

=== 坐标变换下的不确定度矩阵

实验上测量带电粒子动量通常是测量粒子在探测器中各点的击中坐标 $x,y$，然后拟合径迹。径迹往往用极坐标$(r, theta)$描述。一般来说，$(x, y)$的测量不相关。$r, theta$是否相关？

两种坐标的变换关系：
$
  r^2 = x^2 + y^2, tan theta = y/x\
$
有
$
  V_(x y) = mat(sigma_x^2, 0; 0, sigma_y^2), U_(r theta) = mat(sigma_r^2, "cov"[r, theta]; "cov"[r, theta], sigma_theta^2)\
$
变换的Jacobian矩阵为
$
  J = jacobianmatrix((r, theta); (x, y)) = mat(pdv(r, x), pdv(r, y); pdv(theta, x), pdv(theta, y)) = mat(x/r, y/r; -y/r^2, x/r^2)\
$
由于
$
  U approx J V J^TT\
$
则有
$
  U_(r theta) approx mat(x/r, y/r; -y/r^2, x/r^2) mat(sigma_x^2, 0; 0, sigma_y^2) mat(x/r, -y/r^2; y/r, x/r^2) \
  = 1/r^2 mat(x^2 sigma_x^2 + y^2 sigma_y^2, (-x y (sigma_x^2 - sigma_y^2))/r; (-x y (sigma_x^2 - sigma_y^2))/r, (y^2 sigma_x^2 + x^2 sigma_y^2)/r^2)\
$
除非处处满足$sigma_x = sigma_y$，否则$r, theta$有相关性。

#note[
  上面的结果采用一阶不确定度传递，导数在平均坐标处取值，并要求 $r != 0$、角度在所考虑的小邻域内连续。特别地，
  $
    "cov"[r,theta] approx (x y)/(r^3) (sigma_y^2-sigma_x^2)
  $
  因而 $sigma_x=sigma_y$ 时该近似协方差为零；在 $x y=0$ 的特殊位置也可为零。一般位置、一般测量分辨率下，$r,theta$ 会出现相关性。直角坐标到极坐标是*非线性变换*，与下面的线性正交变换不同。
]
#newpara()

随机变量的相关性依赖所选的变量。对于二维分布，改变坐标轴方向，就会改变沿两个坐标方向测得的协方差和相关系数。

#figure(
  image("pic/chap1/correlation-rotation.png", width: 85%),
  caption: [不同相关系数的散点分布，以及转动坐标轴的示意],
)

图中的 $rho=0.75,-0.75,0.95,0.25$ 分别展示正、负相关和不同程度的线性相关。沿点云的长轴、短轴选取坐标，可以消除两个新坐标间的线性相关。

#example(subname: [转动 $45 degree$ 的情形])[
  当两个变量的方差相等，$sigma_1^2=sigma_2^2=sigma^2$，且协方差为 $rho sigma^2$ 时，原协方差矩阵为
  $
    V=sigma^2 mat(1, rho; rho, 1)
  $
  将坐标原点移到均值处，再将坐标轴转动 $45 degree$，定义
  $
    y_1=((x_1-mu_1)+(x_2-mu_2))/sqrt(2), quad
    y_2=(-(x_1-mu_1)+(x_2-mu_2))/sqrt(2)
  $
  于是
  $
    U=mat(sigma^2(1+rho), 0; 0, sigma^2(1-rho))
  $
  新变量的协方差为零，原来的相关性转化为两个主轴方向上方差的不同。讲义图示中转动 $45 degree$ 的结论对应两个坐标具有相同方差的情况。
]

一般情况下，消除相关性所需的转角由协方差矩阵决定。令 $c="cov"[x_1,x_2]$，按
$
  A=mat(cos alpha, sin alpha; -sin alpha, cos alpha)
$
转动坐标轴，则新协方差的非对角元为
$
  U_(1 2)=c cos(2 alpha)+(sigma_2^2-sigma_1^2)/2 sin(2 alpha)
$
应选择使 $U_(1 2)=0$ 的 $alpha$；当分母非零时，可写为 $tan(2 alpha)=2c/(sigma_1^2-sigma_2^2)$。更一般、也更方便的方法是求协方差矩阵的本征矢量。

=== 正交变换消除随机变量间的相关性

考虑具有有限二阶矩的 $n$ 个实随机变量，写成列向量 $vb(x)=(x_1,dots,x_n)^TT$，协方差矩阵为 $V$。希望通过线性变换重新定义 $n$ 个变量，令
$
  y_i=sum_(j=1)^n A_(i j) x_j, quad vb(y)=A vb(x)
$
使新协方差矩阵 $U$ 的非对角元都为零。

#theorem(subname: [线性变换的协方差矩阵])[
  对常数矩阵 $A$，若 $vb(y)=A vb(x)$，则
  $
    E[vb(y)]=A E[vb(x)], quad U=A V A^TT
  $
  给 $vb(y)$ 再加一个常数向量不会改变 $U$，因此也可以先将 $vb(x)$ 减去其均值再作变换。
]

#proof[
  利用协方差对各个变量的线性性，逐分量计算：
  $
    U_(i j) & = "cov"[sum_(k=1)^n A_(i k) x_k, sum_(l=1)^n A_(j l) x_l] \
            & = sum_(k,l=1)^n A_(i k) A_(j l) "cov"[x_k,x_l] \
            & = sum_(k,l=1)^n A_(i k) V_(k l) (A^TT)_(l j) \
            & = (A V A^TT)_(i j)
  $
  这与前面的不确定度传递公式相对应：线性变换时 $J=A$，上式严格成立；非线性变换时，一般只有 $U approx J V J^TT$。
]

#newpara()
*如何选取 $A$？* 协方差矩阵 $V$ 是实对称矩阵，因而可以选取一组正交归一的本征列向量 $vb(r)_i$，满足
$
  V vb(r)_i=lambda_i vb(r)_i, quad
  vb(r)_i^TT vb(r)_j=sum_(k=1)^n r_(k i) r_(k j)=delta_(i j)
$
这里 $r_(k i)$ 是第 $i$ 个本征向量的第 $k$ 个分量。若有简并本征值，可在相应的本征子空间中选取正交归一基。

将这些本征向量按行排成变换矩阵：
$
  A=mat(vb(r)_1^TT; vb(r)_2^TT; dots; vb(r)_n^TT), quad
  A_(i j)=r_(j i), quad (A^TT)_(i j)=r_(i j)
$
于是
$
  (A A^TT)_(i k)=sum_(j=1)^n r_(j i) r_(j k)=delta_(i k), quad
  A A^TT=A^TT A=I_n
$
因此 $A$ 是正交矩阵。

#theorem(subname: [协方差矩阵的正交对角化])[
  取 $V$ 的一组正交归一本征向量作为 $A$ 的各行，则变换 $vb(y)=A vb(x)$ 后，
  $
    U=A V A^TT="diag"(lambda_1,lambda_2,dots,lambda_n), quad
    "cov"[y_i,y_j]=lambda_i delta_(i j)
  $
  各个新变量互不相关，其方差等于原协方差矩阵的本征值：$"Var"[y_i]=lambda_i$。
]

#proof[
  用本征方程 $sum_(l=1)^n V_(k l) r_(l j)=lambda_j r_(k j)$，得到
  $
    U_(i j) & = sum_(k,l=1)^n r_(k i) V_(k l) r_(l j) \
            & = sum_(k=1)^n r_(k i) lambda_j r_(k j) \
            & = lambda_j vb(r)_i^TT vb(r)_j \
            & = lambda_j delta_(i j)
  $
  当 $i=j$ 时为 $lambda_i$，当 $i!=j$ 时为零。
]

#newpara()
正交变换对应坐标轴的转动（也可以包含反射），不改变向量模长：
$
  norm(vb(y))^2=vb(y)^TT vb(y)=vb(x)^TT A^TT A vb(x)=norm(vb(x))^2
$
若事先减去了均值，这一结论对应的是离均值的位移向量。由于 $V$ 半正定，各本征值 $lambda_i>=0$；$lambda_i=0$ 表示该方向的线性组合没有涨落。

#note[
  正交变换保证*不相关*，一般不保证*独立*。只有在联合Gauss分布等具有额外条件的情形下，对角协方差矩阵才同时意味着各分量独立。方差为零的分量是常数，其相关系数本身没有定义。

  不相关变量往往便于计算和拟合，但新变量是原变量的线性组合，其物理含义不一定直观。
]

#example(subname: [利用变量变换进行粒子鉴别])[
  带电粒子在闪烁体中的射程与动量有关。不同粒子类型在“射程—动量”平面上形成不同的分布带；原坐标直接反映射程随动量的变化关系。
]

#figure(
  grid(
    columns: (1.2fr, 1fr),
    gutter: 1em,
    align: center + horizon,
    image("pic/chap1/range-momentum.png", width: 100%), image("pic/chap1/particle-separation.png", width: 100%),
  ),
  caption: [射程与动量的关联，以及构造新变量后对 $pi^+$、$mu^+$ 的区分，来源为 Physical Review D 77, 052003 (2008)。],
)

沿分布带方向及其横向构造新的坐标，可以将原来二维的相关分布转化为更适合鉴别粒子的变量。图右使用相对于预期 $pi^+$ 射程的偏离量，$pi^+$ 与 $mu^+$ 的分布明显分开，可通过对该变量施加选择条件（cut）来区分粒子类型。

这里改变的是*描述测量结果的变量*：粒子的实际射程、动量没有改变；新坐标混合了两者，不再直接表示某一个原始物理量，却可以更适合粒子鉴别。这正体现了讲义所说的“变换后更容易处理，但不一定更容易作物理解释”。

#note[
  射程与动量具有不同单位。讨论这类坐标“转动”时，应先说明所用的尺度或无量纲化方式；散点图上视觉上的转角会受坐标轴比例影响。构造的具体鉴别变量也可以包含对预期射程的修正，不必局限于一次线性正交变换。
]

#block(breakable: false)[
  == 本章小结

  - *概率的定义与诠释*：随机事件；概率的相对频率诠释和主观诠释；条件概率、Bayes定理与全概率定理。
  - *随机变量与概率密度*：随机变量、概率密度和直方图；联合概率密度、边缘概率密度与条件概率密度。
  - *随机变量的函数*：一维与多维变量变换；Mellin卷积、Fourier卷积；用Jacobian行列式处理积分测度的变化。
  - *期待值与方差*：均值、方差和标准差描述分布的位置与涨落；协方差、相关系数描述变量间的线性关联。
  - *不确定度的传递*：一般非线性函数采用局部线性近似 $U approx J V J^TT$，线性变换则有严格关系 $U=A V A^TT$；共同误差可在差值或比值中抵消；通过协方差矩阵的正交对角化，可构造互不相关的新变量。
]

#pagebreak(weak: true)
