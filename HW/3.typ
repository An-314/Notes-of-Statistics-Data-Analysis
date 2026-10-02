#import "@preview/scripst:1.1.2": *

#show: scripst.with(
  title: [统计数据分析第3次作业],
  author: "Anzreww",
  time: "2026年10月",
  cb-counter-depth: 1,
  matheq-depth: 1,
  font-size: 13pt,
  par-leading: 0.6em,
  counter-depth: 1,
)

#exercise(subname: [2.1])[
  考虑 $N$ 个服从多项分布的随机变量 $vb(n)=(n_1,dots,n_N)$，概率为 $vb(p)=(p_1,dots,p_N)$，并且总试验次数为 $n_("tot")=sum_(i=1)^N n_i$。假设变量 $k$ 定义为前 $M$ 个 $n_i$ 之和，
  $
    k=sum_(i=1)^M n_i, quad M<=N
  $<->
  利用误差传递以及多项分布的协方差
  $
    "cov"[n_i,n_j]
    =delta_(i j) n_("tot") p_i (1-p_i)
    +(delta_(i j)-1) p_i p_j n_("tot")
  $<->
  求 $k$ 的方差。证明该方差等于 $p=sum_(i=1)^M p_i$ 并且总试验次数为 $n_("tot")$ 的二项分布的方差。
]

#solution[
  多项分布中总试验次数 $n_("tot")$ 固定，而各类计数 $n_i$ 之间一般不独立。先将题给协方差化简为
  $
    "cov"[n_i,n_j]=n_("tot")(delta_(i j) p_i-p_i p_j)
  $
  因为 $k$ 是 $n_i$ 的线性组合，误差传递公式在这里严格成立。对前 $M$ 个分量有 $pdv(k, n_i)=1$，其余分量的导数为零，故
  $
    V[k] & =sum_(i=1)^M sum_(j=1)^M "cov"[n_i,n_j] \
         & =n_("tot") sum_(i,j=1)^M (delta_(i j) p_i-p_i p_j) \
         & =n_("tot") (sum_(i=1)^M p_i
             -(sum_(i=1)^M p_i)(sum_(j=1)^M p_j))
  $
  记 $p=sum_(i=1)^M p_i$，得到
  $
    V[k]=n_("tot") p(1-p)
  $
  这正是总试验次数为 $n_("tot")$、成功概率为 $p$ 的二项分布的方差。
]


#exercise(subname: [2.2])[
  假设随机变量 $x$ 均匀分布于区间 $[alpha,beta]$，$alpha,beta>0$。求 $1/x$ 的期待值，并将结果与 $1/E[x]$ 进行比较，取 $alpha=1,beta=2$。
]

#solution[
  设 $0<alpha<beta$。均匀分布的密度为
  $
    f(x)=cases(
      1/(beta-alpha) & quad alpha<=x<=beta,
      0 & quad "其它"
    )
  $
  因此
  $
    E[1/x] & =integral_alpha^beta 1/x 1/(beta-alpha) dd(x) \
           & =(ln beta-ln alpha)/(beta-alpha) \
           & =ln(beta/alpha)/(beta-alpha)
  $
  而
  $
    E[x]=1/(beta-alpha) integral_alpha^beta x dd(x)
    =(alpha+beta)/2
  $
  所以
  $
    1/E[x]=2/(alpha+beta)
  $
  取 $alpha=1,beta=2$，得到
  $
    E[1/x]=ln 2 approx 0.693147, quad
    1/E[x]=2/3 approx 0.666667
  $
  两者相差约 $0.026481$，并不相等。

  这种差异来自函数的非线性。由于 $g(x)=1/x$ 在 $x>0$ 上严格凸，$g''(x)=2/x^3>0$，Jensen不等式给出
  $
    E[1/x]>1/E[x]
  $
  对非退化的正区间均匀分布，不等号严格成立；只有在区间缩为单点、$x$ 无涨落的极限下两者相等。
]


#exercise(subname: [2.3])[
  考虑指数分布
  $
    f(x;xi)=1/xi e^(-x/xi), quad x>=0
  $<->
  (a) 证明对应的累积分布函数为
  $
    F(x)=1-e^(-x/xi), quad x>=0
  $<->
  (b) 证明给定 $x>x_0$ 时 $x$ 处于 $x_0$ 与 $x_0+x'$ 之间的条件概率等于 $x$ 小于 $x'$ 的概率（非条件概率），即
  $
    P(x<=x_0+x'|x>=x_0)=P(x<=x')
  $<->
  (c) 产生于大气上层的宇宙线 $mu$ 子进入海平面的探测器，其中的一部分在探测器中停止并衰变。进入探测器与衰变的时间差 $t$ 服从指数分布，$t$ 的均值等于 $mu$ 子的平均寿命（近似为 $2.2 thin "μs"$）。解释为什么 $mu$ 子进入探测器前存活的时间对确定平均寿命没有影响。
]

#solution[
  - 对 $xi>0$，有
    $
      F(x)=integral_0^x 1/xi e^(-u/xi) dd(u)
      =[-e^(-u/xi)]_0^x=1-e^(-x/xi), quad x>=0
    $

  - 设 $x_0>=0,x'>=0$，由条件概率的定义，有
    $
      P(x<=x_0+x'|x>=x_0) & =(P(x_0<=x<=x_0+x'))/(P(x>=x_0)) \
                          & =(F(x_0+x')-F(x_0))/(1-F(x_0)) \
                          & =(e^(-x_0/xi)-e^(-(x_0+x')/xi))/(e^(-x_0/xi)) \
                          & =1-e^(-x'/xi)=P(x<=x')
    $
    即在已经存活到 $x_0$ 的条件下，剩余寿命 $x-x_0$ 仍服从均值为 $xi$ 的指数分布。

  - 令 $T$ 为从产生起算的总固有寿命，$tau$ 为平均寿命。对已经存活到固有时刻 $t_0$ 的粒子，剩余寿命 $t=T-t_0$ 满足
    $
      P(t>u|T>=t_0)
      =(e^(-(t_0+u)/tau))/(e^(-t_0/tau))
      =e^(-u/tau), quad u>=0
    $
    因此其密度仍为 $e^(-t/tau)/tau$，均值仍为 $tau approx 2.2 thin "μs"$，与 $t_0$ 无关。即使不同粒子到达前的存活时间不同，混合后的剩余寿命分布也相同；先前的衰变只改变到达的粒子数，不改变这一条件分布。
]


#exercise(subname: [2.4])[
  假设 $y$ 服从均值为 $mu$，方差为 $sigma^2$ 的Gauss分布。

  (a) 证明
  $
    x=(y-mu)/sigma
  $
  服从标准Gauss分布 $phi(x)$（即，均值为零，方差为1）。

  (b) 证明累积分布函数 $F(y)$ 与 $Phi(x)$ 相等，即
  $
    F(y)=Phi((y-mu)/sigma)
  $
]

#proof[
  - 设 $sigma>0$，原变量的密度为
    $
      f_Y (y)=1/(sqrt(2 pi) sigma)
      exp(-(y-mu)^2/(2 sigma^2))
    $
    由 $y=mu+sigma x$ 以及 $abs(dv(y, x))=sigma$，新变量的密度为
    $
      f_X (x) & =f_Y (mu+sigma x) sigma \
              & =1/sqrt(2 pi) exp(-x^2/2)=phi(x), quad -oo<x<oo
    $
    这正是标准Gauss密度。其均值和方差也可直接验证：
    $
      E[x]=(E[y]-mu)/sigma=0, quad
      V[x]=V[y]/sigma^2=1
    $

  - 为区分随机变量与积分上限，以下用大写 $X,Y$ 表示随机变量。因为 $sigma>0$，变换保持不等号方向，故
    $
      F(y) & =P(Y<=y) \
           & =P((Y-mu)/sigma <= (y-mu)/sigma) \
           & =P(X<=(y-mu)/sigma) \
           & =Phi((y-mu)/sigma)
    $
    其中 $Phi(a)=integral_(-oo)^a phi(u) dd(u)$。
]


#exercise(subname: [2.5])[
  (a) 证明，如果 $y$ 服从均值为 $mu$、方差为 $sigma^2$ 的Gauss分布，则 $x=e^y$ 服从对数正态分布，
  $
    f(x;mu,sigma^2)
    =1/sqrt(2 pi sigma^2) 1/x
    exp(-(log x-mu)^2/(2 sigma^2))
  $
  #newpara()

  (b) 通过积分
  $
    E[x]=integral x f(x;mu,sigma^2) dd(x), quad
    V[x]=integral (x-E[x])^2 f(x;mu,sigma^2) dd(x)
  $
  求 $x$ 的均值与方差。

  (c) 将(b)中求得的方差与通过误差传递（$V[y]=sigma^2$）得到的近似结果进行比较。在什么条件下误差传递近似成立？（注意 $y$ 是无量纲的，因而 $sigma^2$ 也是无量纲的。）
]

#solution[
  - 设 $sigma>0$。由于 $x=e^y>0$，反变换为 $y=ln x$，且 $abs(dv(y, x))=1/x$。因此
    $
      f_X (x)=cases(
        1/(sqrt(2 pi) sigma x)
        exp(-(ln x-mu)^2/(2 sigma^2)) & quad x>0,
        0 & quad x<=0
      )
    $
    这就是对数正态分布。

  - 对任意实数 $a$，令 $y=ln x$，则
    $
      E[x^a] & =integral_0^oo x^a f_X (x) dd(x) \
             & =1/(sqrt(2 pi) sigma)
               integral_(-oo)^oo exp(a y-(y-mu)^2/(2 sigma^2)) dd(y)
    $
    将指数配方：
    $
      a y-(y-mu)^2/(2 sigma^2)
      =-(y-mu-a sigma^2)^2/(2 sigma^2)+a mu+(a^2 sigma^2)/2
    $
    剩余积分是均值为 $mu+a sigma^2$、方差为 $sigma^2$ 的Gauss密度的归一化积分，故
    $
      E[x^a]=e^(a mu+a^2 sigma^2/2)
    $
    分别取 $a=1,2$，得到
    $
      E[x]=e^(mu+sigma^2/2), quad E[x^2]=e^(2 mu+2 sigma^2)
    $
    将方差积分展开，并利用 $integral_0^oo f_X (x) dd(x)=1$，有
    $
      V[x] & =E[x^2]-E[x]^2 \
           & =e^(2 mu+2 sigma^2)-e^(2 mu+sigma^2) \
           & =e^(2 mu+sigma^2)(e^(sigma^2)-1)
    $

  - 对 $x(y)=e^y$ 在 $y=mu$ 处作一阶Taylor展开，
    $
      x approx e^mu+e^mu (y-mu)
    $
    因而一阶误差传递给出
    $
      V_("lin")[x]
      =(evaluated(dv(x, y))_(y=mu))^2 V[y]
      =e^(2 mu) sigma^2
    $
    对比精确结果，令 $s=sigma^2$，则
    $
      V[x]=e^(2 mu)(e^(2s)-e^s)
    $
    在 $s=0$ 附近展开，
    $
      e^(2s)-e^s=s+3/2 s^2+7/6 s^3+O(s^4)
    $
    所以
    $
      V[x]
      =e^(2 mu) sigma^2
      (1+3/2 sigma^2+7/6 sigma^4+O(sigma^6))
    $
    因此，当
    $
      sigma^2 << 1
    $
    时，一阶误差传递近似成立。
]


#exercise(subname: [2.6])[
  证明自由度为 $n$ 的 $chi^2$ 分布的累积分布函数可以表示为
  $
    F_(chi^2)(x;n)=P(x/2,n/2)
  $
  其中 $P$ 为不完全Gamma函数（incomplete gamma function）
  $
    P(x,n)=1/Gamma(n) integral_0^x e^(-t) t^(n-1) dd(t)
  $
]

#proof[
  自由度为 $n>0$ 的 $chi^2$ 分布密度为
  $
    f_(chi^2)(u;n)=cases(
      1/(2^(n/2) Gamma(n/2)) u^(n/2-1) e^(-u/2) & quad u>0,
      0 & quad u<0
    )
  $
  对 $x>=0$，其累积分布函数为
  $
    F_(chi^2)(x;n)
    =1/(2^(n/2) Gamma(n/2)) integral_0^x u^(n/2-1) e^(-u/2) dd(u)
  $
  令 $t=u/2$
  $
    F_(chi^2)(x;n) & =1/(2^(n/2) Gamma(n/2))
                     integral_0^(x/2) (2t)^(n/2-1) e^(-t) 2 dd(t) \
                   & =1/Gamma(n/2) integral_0^(x/2) t^(n/2-1) e^(-t) dd(t) \
                   & =P(x/2,n/2)
  $
]

#exercise(subname: [])[
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
  $y$ 的取值范围是 $(0,1)$，所以这正是均匀密度。
]
