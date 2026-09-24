#import "@preview/scripst:1.1.2": *

#show: scripst.with(
  title: [统计数据分析第2次作业],
  author: "Anzreww",
  time: "2026年9月",
  cb-counter-depth: 1,
  matheq-depth: 1,
  font-size: 13pt,
  par-leading: 0.6em,
  counter-depth: 1,
)

// 题目来源：files/SDA_exercises2020-mark.pdf，第1–2页（PDF第4–5页）。
#exercise(subname: [1.4])[
  假设随机变量 $x$ 的概率密度函数为 $f(x)$。证明 $y=x^2$ 的概率密度函数为
  $
    g(y) = 1/(2 sqrt(y)) f(sqrt(y)) + 1/(2 sqrt(y)) f(-sqrt(y))
  $
]

#proof[
  因为 $y=x^2 >= 0$，当 $y<0$ 时 $g(y)=0$。对于 $y>0$，其累积分布函数为
  $
    G(y) & = P(x^2 <= y) \
         & = P(-sqrt(y) <= x <= sqrt(y)) \
         & = integral_(-sqrt(y))^(sqrt(y)) f(t) dd(t)
  $
  对 $y$ 求导
  $
    g(y) & = f(sqrt(y)) 1/(2 sqrt(y))
           - f(-sqrt(y)) (-1/(2 sqrt(y))) \
         & = (f(sqrt(y)) + f(-sqrt(y))) / (2 sqrt(y))
  $
  #newpara()
  事实上这是
  $
    g(y) = sum_(i = 1)^n f(x_i (y)) abs(dv(x, y))
  $
  的一种证明。
]

#exercise(subname: [1.5])[
  假设两个独立的随机变量 $x$ 和 $y$ 都服从 0 到 1 之间的均匀分布，即概率密度函数 $g(x)$ 为
  $
    g(x) = cases(1 & quad 0<x<1, 0 & quad "其它")
  $
  概率密度函数 $h(y)$ 与 $g(x)$ 类似。

  - 利用 _Statistical Data Analysis_ 中的
    $
      g(z) & = integral_(0)^(oo) f(x, z/x) dd(x)/ abs(x)
    $
    式，证明，$z=x y$ 的概率密度函数 $f(z)$ 为
    $
      f(z) = cases(-log z & quad 0<z<1, 0 & quad "其它")
    $
  - 利用 _Statistical Data Analysis_ 的
    $
      g(vb(a)) dd(vb(a)) = det jacobianmatrix(vb(x); vb(a), delim: "|") f(vb(x)) dd(vb(x))
    $
    其中Jacobian矩阵为
    $
      jacobianmatrix(vb(x); vb(a), delim: "|") = jacobianmatrix(x_1, x_2, ..., x_n; a_1, a_2, ..., a_n, delim: "|")
    $
    通过另外定义一个函数 $u=x$，求 $z=x y$ 的概率密度函数。首先求 $z$ 和 $u$ 的联合概率密度函数，然后对 $u$ 进行积分求出 $z$ 的概率密度函数。
  - 证明 $z$ 的累积分布为
    $
      F(z) = z(1-log z)
    $
]

#proof[
  - $x,y$的联合概率密度为
    $
      p(x,y) = g(x) h(y) = cases(1 & quad x\, y in (0,1), 0 & quad "其它")
    $
    从而
    $
      f(z) & = integral_(0)^(oo) p(x, z/x) dd(x)/ abs(x) \
           & = integral_z^1 1/x dd(x) = -ln z, quad 0<z<1
    $


  - 令 $z=x y, u=x$，则反变换为
    $
      x=u, quad y=z/u
    $
    其 Jacobian 行列式为
    $
      det(pdv((x,y), (z,u)))
      = det mat(0, 1; 1/u, -z/u^2) = -1/u
    $
    原来的单位正方形变为三角形区域 $0<z<u<1$，因此 $(z,u)$ 的联合密度为
    $
      p(z,u) = cases(1/u & quad 0<z<u<1, 0 & quad "其它")
    $
    对 $u$ 积分得到边缘密度
    $
      f(z) = integral_z^1 p(z,u) dd(u)
      = integral_z^1 1/u dd(u) = -ln z, quad 0<z<1
    $
    与前一致。

    - 对 $0<z<1$，有
      $
        F(z) & = integral_0^z (-ln t) dd(t) \
             & = [-t ln t + t]_0^z = z(1-ln z)
      $
      即
      $
        F(z) = cases(0 & quad z<=0, z(1-ln z) & quad 0<z<1, 1 & quad z>=1)
      $
]

#exercise(subname: [1.6])[
  考虑随机变量 $x$ 与常数 $alpha$ 和 $beta$。证明
  $
    E[alpha x + beta] & = alpha E[x] + beta \
    V[alpha x + beta] & = alpha^2 V[x]
  $
]

#proof[

  $
    E[alpha x + beta] & = integral_(-infinity)^infinity (alpha x+beta) f(x) dd(x) \
                      & = alpha integral_(-infinity)^infinity x f(x) dd(x)
                        + beta integral_(-infinity)^infinity f(x) dd(x) \
                      & = alpha E[x] + beta
  $
  记 $mu=E[x]$，则
  $
    (alpha x+beta)-E[alpha x+beta] = alpha(x-mu)
  $
  由方差的定义，
  $
    V[alpha x+beta] & = E[((alpha x+beta)-E[alpha x+beta])^2] \
                    & = E[alpha^2 (x-mu)^2] \
                    & = alpha^2 E[(x-mu)^2] = alpha^2 V[x]
  $
]

#exercise(subname: [1.7])[
  考虑两个随机变量 $x$ 和 $y$。
  + 证明 $alpha x+y$ 的方差为
    $
      V[alpha x+y] & = alpha^2 V[x]+V[y]+2 alpha "cov"[x,y] \
                   & = alpha^2 V[x]+V[y]+2 alpha rho sigma_x sigma_y
    $
    其中 $alpha$ 为任意常数，$sigma_x^2=V[x]$，$sigma_y^2=V[y]$，关联系数 $rho="cov"[x,y]/(sigma_x sigma_y)$。
  + 利用 1 的结果，证明关联系数总是位于区间 $-1<=rho<=1$。（利用 $V[alpha x+y]$ 的方差总是大于或等于零。）
]

#proof[
  - 假设 $x,y$ 的二阶矩 $mu_x=E[x], mu_y=E[y]$。由期望的线性性
    $
      V[alpha x+y] & = E[(alpha(x-mu_x)+(y-mu_y))^2] \
                   & = alpha^2 E[(x-mu_x)^2]+E[(y-mu_y)^2] + 2 alpha E[(x-mu_x)(y-mu_y)] \
                   & = alpha^2 V[x]+V[y]+2 alpha "cov"[x,y]
    $
    若 $sigma_x,sigma_y>0$，由
    $
      "cov"[x,y]=rho sigma_x sigma_y
    $
    即得第二个等式
    $
      V[alpha x+y] & = alpha^2 V[x]+V[y]+2 alpha rho sigma_x sigma_y
    $

  - 配方，得到
    $
      V[alpha x+y]
      = (alpha sigma_x+rho sigma_y)^2 + sigma_y^2(1-rho^2)
    $
    因为该式对任意实数 $alpha$ 都非负，特别取 $alpha = -(rho sigma_y)/sigma_x$，便有
    $
      0 <= sigma_y^2(1-rho^2)
      => rho^2<=1 => -1<=rho<=1
    $
]

#exercise(subname: [1.8])[
  假设随机变量 $vb(x)=(x_1,dots,x_n)^TT$ 用联合概率密度函数 $f(vb(x))$ 描述，而变量 $vb(y)=(y_1,dots,y_n)^T$ 由下面的线性变换定义
  $
    y_i = sum_(j=1)^n A_(i j) x_j
  $
  假设反变换 $vb(x)=A^(-1) vb(y)$ 存在。

  + 证明 $vb(y)$ 的联合概率密度函数为
    $
      g(vb(y)) = f(A^(-1) vb(y)) abs(det(A^(-1)))
    $
  + 当 $A$ 为矩阵，即 $A^(-1)=A^T$ 时，求 $g(vb(y))$。
]

#solution[
  - 由 $vb(x)=A^(-1) vb(y)$，Jacobian 为 $A^(-1)$，故体积元满足
  $
    upright(d)^n vb(x) = abs(det(A^(-1))) upright(d)^n vb(y)
  $
  对任意可测区域 $R$，其概率可以用两种变量表示为
  $
    P(vb(y) in R) & = integral_(A^(-1) R) f(vb(x)) upright(d)^n vb(x) \
                  & = integral_R f(A^(-1) vb(y)) abs(det(A^(-1))) upright(d)^n vb(y)
  $
  与概率密度的定义比较，得到
  $
    g(vb(y)) = f(A^(-1) vb(y)) abs(det(A^(-1)))
    = f(A^(-1) vb(y))/abs(det A)
  $

  - $A^(-1)=A^T$，则
    $
      A^TT A = I => (det A)^2=1 => abs(det A)=1
    $
    代入上式即得
    $
      g(vb(y)) = f(A^TT vb(y))
    $
    正交变换保持体积元不变。
]

#exercise(subname: [])[
  验算不确定度传递公式
  $
    U = A V A^TT
  $
]

#proof[
  假设我们已知
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
  类似地，对于$m$组函数$vb(y)(vb(x)) = (y_1(vb(x)), y_2(vb(x)),..., y_m (vb(x)))$，其协方差矩阵$U_(i j) = "cov"[y_i, y_j]$，有（只需要给上面的推导加上角标）
  $
    U_(k l) approx sum_(i,j=1)^n evaluated(pdv(y_k, x_i) pdv(y_l, x_j))_(vb(x) = vb(mu)) V_(i j)\
  $
  或者，写成矩阵形式
  $
    U approx A V A^TT\
  $
  其中
  $
    A = jacobianmatrix(vb(y); vb(x))_(vb(x) = vb(mu)) , A_(k i) = (pdv(y_k, x_i))_(vb(x) = vb(mu))\
  $
  是Jacobian矩阵。
]
