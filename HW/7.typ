#import "@preview/scripst:1.1.2": *

#show: scripst.with(
  title: [统计数据分析第7次作业],
  author: "Anzreww",
  time: "2026年11月",
  cb-counter-depth: 1,
  matheq-depth: 1,
  font-size: 13pt,
  par-leading: 0.6em,
  counter-depth: 1,
)

// 题目来源：files/SDA_exercises2020-mark.pdf，第15页（印刷页码12）。

#exercise(subname: [5.1])[
  考虑随机数 $x$，其均值和方差分别为 $mu$ 和 $sigma^2$。假设样本空间由 $n$ 次观测结果 $x_1,x_2,dots,x_n$ 构成。本题的目的是证明样本均值
  $
    overline(x)=1/n sum_(i=1)^n x_i
  $
  为均值 $mu$ 的一致性估计量。

  (a) 第一步要证明Chebyshev不等式，即只要 $x$ 的方差存在，对任意 $a>0$，下面式子成立：
  $
    P(abs(x-mu)>=a)<=sigma^2/a^2.
  $
  该式的证明需要用到方差的定义，
  $
    sigma^2=integral_(-oo)^oo (x-mu)^2 f(x) dd(x),
  $
  其中 $f(x)$ 为随机变量 $x$ 的概率密度函数。利用如下事实：如果积分区域限定为 $abs(x-mu)>=a$，则上式的积分会变小，如果用 $a^2$ 替换 $(x-mu)^2$，则积分会更小。

  (b) 利用Chebyshev不等式证明大数弱定理，即，对任意 $epsilon>0$，
  $
    lim_(n->oo) P(abs(1/n sum_(i=1)^n x_i-mu)>=epsilon)=0.
  $
  这等价于，$overline(x)$ 是 $mu$ 的一致性估计量，只要 $x$ 的方差存在。
]

#solution[
  // 以下将 $x_1,dots,x_n$ 视为来自同一分布的独立观测，且 $E[x_i]=mu$、$"Var"[x_i]=sigma^2<oo$。

  *(a)* 记 $A_a={x:abs(x-mu)>=a}$。由于 $(x-mu)^2 f(x)>=0$，在 $A_a$ 上又有 $(x-mu)^2>=a^2$，所以
  $
    sigma^2 & =integral_(-oo)^oo (x-mu)^2 f(x) dd(x) \
            & >=integral_(A_a) (x-mu)^2 f(x) dd(x) \
            & >=a^2 integral_(A_a) f(x) dd(x) \
            & =a^2 P(abs(x-mu)>=a)
  $
  因为 $a>0$，两边除以 $a^2$，即得
  $
    P(abs(x-mu)>=a)<=sigma^2/a^2
  $
  // 不等式给出偏离均值至少 $a$ 的概率上界，不要求 $x$ 服从Gauss分布。

  *(b)* 先求样本均值的期望与方差。由期望的线性性，
  $
    E[overline(x)]
    =1/n sum_(i=1)^n E[x_i]=mu
  $
  各次观测相互独立，故不同 $x_i,x_j$ 的协方差为零，因而
  $
    "Var"[overline(x)]
    =1/n^2 sum_(i=1)^n "Var"[x_i]
    =sigma^2/n
  $
  对随机变量 $overline(x)$ 使用(a)的Chebyshev不等式，对任意固定的 $epsilon>0$，有
  $
    0<=P(abs(overline(x)-mu)>=epsilon)
    <=("Var"[overline(x)])/epsilon^2
    =sigma^2/(n epsilon^2)
  $
  当 $n->oo$ 时，右侧趋于零，因此
  $
    lim_(n->oo) P(abs(overline(x)-mu)>=epsilon)=0
  $
  // 这就是有限方差条件下的弱大数定理，也说明 $overline(x)$ 依概率收敛于 $mu$，即为 $mu$ 的一致性估计量。

  // 这里独立抽样使均值的方差按 $1/n$ 缩小。仅有各次观测的方差有限还不够：若所有 $x_i$ 都是同一个随机变量的复制，则 $overline(x)=x_1$，其方差不会随 $n$ 增大而减小。
]


// #pagebreak(weak: true)

#exercise(subname: [5.2])[
  考虑均值为 $mu$，方差为 $sigma^2$ 的随机变量 $x$，并得到样本值为 $x_1,x_2,dots,x_n$ 的样本空间。

  (a) 假设均值 $mu$ 已经利用样本均值 $overline(x)$ 估计。证明样本方差
  $
    s^2=1/(n-1) sum_(i=1)^n (x_i-overline(x))^2
    =n/(n-1)(overline(x^2)-overline(x)^2)
  $
  为方差 $sigma^2$ 的无偏估计量。（利用 $E[x_i x_j]=mu^2$（$i!=j$），$E[x_i^2]=mu^2+sigma^2$（$i=1,2,dots,n$）。）

  (b) 假设均值 $mu$ 已知。证明 $sigma^2$ 的无偏估计量为
  // #footnote[下式保留原题写法，末个等号不是一般的样本恒等式，正确展开见(b)的解答。]
  $
    S^2=1/n sum_(i=1)^n (x_i-mu)^2
    =overline(x^2)-mu^2.
  $
]

#solution[
  仍取独立同分布样本，记
  $
    overline(x)=1/n sum_(i=1)^n x_i, quad
    overline(x^2)=1/n sum_(i=1)^n x_i^2
  $
  // 其中 $overline(x^2)$ 是平方的样本均值，$overline(x)^2$ 是样本均值的平方，二者不同。
  #newpara()

  *(a)* 当 $n>=2$ 时，利用 $sum_i x_i=n overline(x)$，先展开平方残差和：
  $
    sum_(i=1)^n (x_i-overline(x))^2 & =sum_i x_i^2-2overline(x)sum_i x_i+n overline(x)^2 \
                                    & =sum_i x_i^2-n overline(x)^2 \
                                    & =n(overline(x^2)-overline(x)^2)
  $
  // 这证明了题目中 $s^2$ 的两种写法等价。由题给各阶矩，
  从而
  $
    E[overline(x^2)]
    =1/n sum_i E[x_i^2]
    =mu^2+sigma^2
  $
  再将 $E[overline(x)^2]$ 的双重求和分成 $i=j$ 的 $n$ 项和 $i!=j$ 的 $n(n-1)$ 项，得到
  $
    E[overline(x)^2] & =1/n^2 sum_(i,j=1)^n E[x_i x_j] \
                     & =(n(mu^2+sigma^2)+n(n-1)mu^2)/n^2 \
                     & =mu^2+sigma^2/n
  $
  因此
  $
    E[s^2] & =n/(n-1)(E[overline(x^2)]-E[overline(x)^2]) \
           & =n/(n-1)(sigma^2-sigma^2/n)=sigma^2
  $
  所以 $s^2$ 为总体方差 $sigma^2$ 的无偏估计量。

  // 若仍除以 $n$，期望只能得到 $(n-1)sigma^2/n$；用同一批数据估计均值，会使残差平方和平均减少一个 $sigma^2$，这正是分母改为 $n-1$ 的原因。

  *(b)* 若总体均值 $mu$ 已知，则对 $n>=1$，每项都有
  $
    E[(x_i-mu)^2]="Var"[x_i]=sigma^2
  $
  因而直接取期望，
  $
    E[S^2]
    =1/n sum_(i=1)^n E[(x_i-mu)^2]
    =1/n n sigma^2=sigma^2
  $
  故 $S^2$ 同样无偏。此时没有利用这批样本重新估计均值，分母取 $n$。

  // 题目最后一个等号需要修正。对一个具体样本，正确展开为
  $
    S^2
    =1/n sum_i (x_i^2-2mu x_i+mu^2)
    =overline(x^2)-2mu overline(x)+mu^2 = overline(x^2)- mu^2
  $
  // 均值 $mu$ 已知，并不意味着每次样本的 $overline(x)$ 都恰好等于 $mu$，所以不能把中间项直接替换成 $-2mu^2$。只有取期望后，才有
  // $
  //   E[S^2]
  //   =E[overline(x^2)]-2mu E[overline(x)]+mu^2
  //   =(mu^2+sigma^2)-2mu^2+mu^2
  //   =sigma^2
  // $
  // 另一个量 $overline(x^2)-mu^2$ 虽也满足期望等于 $sigma^2$，却不等于题目定义的 $S^2$，且可能为负；平方残差的平均 $S^2$ 则始终非负。以上无偏性均不要求总体为Gauss分布。
]
