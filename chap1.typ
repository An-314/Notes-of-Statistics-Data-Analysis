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

=== 随机变量的正交变换

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
