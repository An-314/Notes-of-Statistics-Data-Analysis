#import "@preview/scripst:1.1.2": *

#show: scripst.with(
  title: [统计数据分析第5次作业],
  author: "Anzreww",
  time: "2026年10月",
  cb-counter-depth: 1,
  matheq-depth: 1,
  font-size: 13pt,
  par-leading: 0.6em,
  counter-depth: 1,
)

// 题目来源：files/SDA_exercises2020-mark.pdf，第11–12页。

#exercise(subname: [4.1])[
  带电粒子穿过气体会产生电离现象，电离数依赖于入射粒子的类型。假设基于电离测量构造了某统计检验量 $t$，使其服从Gauss分布。如果带电粒子是电子，Gauss分布中心值为0，标准偏差为1；如果带电粒子是 $pi$ 介子，则Gauss分布中心值为2，标准偏差为1。构造某个检验，通过要求 $t<1$ 将电子选择出来。

  (a) 该检验的显著水平（significance level）如何？（即，在拒绝域中接受电子的概率）

  (b) 该检验排除假设粒子为 $pi$ 介子的功效（power）多大？有多大概率将 $pi$ 介子鉴别为电子？

  (c) 假设已知粒子样本中包含99%的 $pi$ 介子以及1%的电子，$t<1$ 的判选条件得到的电子样本的纯度（purity）有多少？

  (d) 假设我们要求电子样本的纯度至少95%，统计检验的拒绝域应该如何选（即判选条件）？如果选用该判选条件，该检验接受电子的效率有多大，显著水平有多大？
]

// #figure(
//   image("pic/5/4-1-gauss-selection.svg", width: 88%),
//   caption: [判选电子与 $pi$ 介子的统计检验量 $t$],
// )

#solution[
  以电子假设为 $H_0$、$pi$ 介子假设为 $H_1$。记标准Gauss密度及其累积分布函数为
  $
    phi(z)=1/sqrt(2 pi) e^(-z^2/2), quad
    Phi(z)=integral_(-oo)^z phi(u) dd(u)
  $
  两种粒子的统计量密度分别是
  $
    g(t|e)=phi(t), quad g(t|pi)=phi(t-2)
  $
  对一般阈值 $c$，电子接收域为 $A_c=(-oo,c)$，拒绝域为 $omega_c=[c,oo)$，因此
  $
    epsilon_e (c) & =P(t<c|e)=Phi(c) \
         alpha(c) & =P(t>=c|e)=1-Phi(c) \
          beta(c) & =P(t<c|pi)=Phi(c-2)
  $
  其中 $epsilon_e$ 是电子效率，$alpha$ 是真电子被误拒的概率，$beta$ 是 $pi$ 介子被误判为电子的概率。

  *(a) 显著水平。* 取 $c=1$，有
  $
    alpha=P(t>=1|e)=1-Phi(1)
    approx 0.158655
  $
  这里显著水平按第一类错误定义。

  *(b) 功效与误判概率。* $pi$ 介子通过电子选择的概率为
  $
    beta=P(t<1|pi)=Phi(-1)
    approx 0.158655
  $
  以 $H_0=e,H_1=pi$ 的约定，功效是 $pi$ 介子为真时正确拒绝电子假设的概率
  $
    1-beta=P(t>=1|pi)=1-Phi(-1)
    approx 0.841345
  $
  // 若将“排除 $pi$ 假设”表述为以 $pi$ 为原假设、电子为备择，则相应功效是 $P(t<1|e)=epsilon_e=Phi(1)approx 84.1345%$。两个方向的功效在本题恰好相等，是因为阈值位于两个同宽Gauss分布均值的中点；它们所用的条件概率不同，一般情况下数值也不相等。
  #newpara()

  *(c) 选中样本的电子纯度。* 设原始电子与 $pi$ 的份额为 $a_e=0.01$、$a_pi=0.99$。由Bayes定理
  $
    p_e (c) & =P(e|t<c) \
            & =(a_e P(t<c|e))/(a_e P(t<c|e)+a_pi P(t<c|pi)) \
            & =(0.01 Phi(c))/(0.01 Phi(c)+0.99 Phi(c-2))
  $
  所以在 $c=1$ 时
  $
    p_e (1) & =(0.01 times 0.841345)/(0.01 times 0.841345+0.99 times 0.158655) \
            & approx 0.0508420
  $
  // 例如原始样本有10000个粒子，预期100个电子与9900个 $pi$ 介子。通过cut后，电子约84.13个，而 $pi$ 本底约1570.69个，因此所选样本仍主要是 $pi$ 介子。电子效率高并不意味着样本纯度高。
  #newpara()

  *(d) 至少95%纯度的选择条件。* 两类密度的似然比为
  $
    r(t)=(g(t|e))/(g(t|pi))
    =exp(-t^2/2+(t-2)^2/2)=exp(2-2t)
  $
  它随 $t$ 单调下降，所以越小的 $t$ 越有利于电子假设。按Neyman-Pearson引理，在相同电子效率下，优先保留小 $t$ 的左尾区域使 $pi$ 泄漏最少，因此采用 $t<c$ 的形式。

  纯度条件给出
  $
    (0.01 Phi(c))/(0.01 Phi(c)+0.99 Phi(c-2))>=0.95
  $
  // 整理为
  $
    0.0005 Phi(c)>=0.9405 Phi(c-2)
    quad ==> quad (Phi(c))/(Phi(c-2))>=1881
  $
  // 扩大左尾接收域会加入相对更像 $pi$ 的事例，使纯度下降。因此在满足纯度要求的左尾cut中，取等号所得的最大阈值可以保留最多电子。
  数值求解
  $
    Phi(c_*)=1881 Phi(c_*-2)
  $
  得到
  $
    c_* approx -2.51529650
  $
  所有 $c<=c_*$ 都满足至少95%的纯度；效率最高的选择及其拒绝域分别为
  $
    t<c_*, quad omega_*=[c_*,oo)
  $
  // 取五位小数可写成 $t<-2.51530$。
  在临界阈值处，
  $
    epsilon_e (c_*) & =Phi(c_*)approx 0.00594662 \
          beta(c_*) & =Phi(c_*-2)approx 3.16141 times 10^(-6) \
         alpha(c_*) & =1-Phi(c_*)approx 0.994053
  $
  // 代回纯度公式恰得 $p_e (c_*)=0.95$。由于原始样本中 $pi$ 本底占绝大多数，要得到很纯的电子样本必须大幅减少 $pi$ 泄漏，同时也损失绝大多数电子，故显著水平很高、电子效率很低。
]

// #note[
//   本题要求的是*整个选中样本*有95%的纯度，不是每个保留事例的后验电子概率都至少95%。单事例后验为
//   $
//     P(e|t)=(0.01 phi(t))/(0.01 phi(t)+0.99 phi(t-2))
//     =1/(1+99 exp(2t-2))
//   $
//   若逐点要求 $P(e|t)>=0.95$，会得到更严的 $t<=1-1/2 ln 1881 approx -2.76978$。这并非题目所求的最大效率条件；样本纯度必须用区域积分的比值计算。
// ]


#exercise(subname: [4.2])[
  考虑某统计检验量由输入变量 $bold(x)=(x_1,dots,x_n)$ 的线性组合构成，系数为 $bold(a)=(a_1,dots,a_n)$，
  $
    t(bold(x))=sum_(i=1)^n a_i x_i=bold(a)^TT bold(x)
  $
  假设在 $H_0$ 和 $H_1$ 两种假设下，$bold(x)$ 的均值分别为 $bold(mu)_0$ 和 $bold(mu)_1$，协方差矩阵分别为 $V_0$ 和 $V_1$，统计检验量 $t$ 的均值分别为 $tau_0$ 和 $tau_1$，方差为 $Sigma_0^2$ 和 $Sigma_1^2$（见 _Statistical Data Analysis_ 第4.4.1节）。

  (a) 证明使分离
  $
    J(bold(a))=(tau_0-tau_1)^2/(Sigma_0^2+Sigma_1^2)
  $
  达到最大的系数 $bold(a)$ 由下式给出
  $
    bold(a)=W^(-1)(bold(mu)_0-bold(mu)_1), quad W=V_0+V_1
  $
  这定义了Fisher线性甄别式。

  (b) 假设 $V_0=V_1=V$，并且输入变量的概率密度函数 $f(bold(x)|H_0)$ 和 $f(bold(x)|H_1)$ 是多维Gauss分布，中心值分别为 $bold(mu)_0$ 和 $bold(mu)_1$（参见 _Statistical Data Analysis_ 的方程(4.26)）。取两个假设的先验概率分别为 $pi_0$ 和 $pi_1$。利用Bayes定理，求出后验概率 $P(H_0|bold(x))$ 和 $P(H_1|bold(x))$ 作为 $t$ 的函数。

  (c) 证明通过推广统计检验量，使其包含一个偏置，
  $
    t(bold(x))=a_0+sum_(i=1)^n a_i x_i
  $
  后验概率 $P(H_0|bold(x))$ 可以表示为
  $
    P(H_0|bold(x))=1/(1+e^(-t))
  $
  其中偏置 $a_0$ 为
  $
    a_0=-1/2 bold(mu)_0^TT V^(-1)bold(mu)_0
    +1/2 bold(mu)_1^TT V^(-1)bold(mu)_1
    +ln(pi_0/pi_1)
  $
]

#solution[
  *(a) 最大化分离度。* 记两类均值之差为 $bold(delta)=bold(mu)_0-bold(mu)_1$。由期望的线性性，
  $
    tau_k=E[t|H_k]=bold(a)^TT bold(mu)_k, quad k=0,1
  $
  利用协方差矩阵，投影方差为
  $
    Sigma_k^2 & =sum_(i,j=1)^n a_i a_j "cov"[x_i,x_j|H_k] \
              & =bold(a)^TT V_k bold(a)
  $
  故
  $
    J(bold(a))=(bold(a)^TT bold(delta))^2/(bold(a)^TT W bold(a)),
    quad W=V_0+V_1
  $
  // 假设 $W$ 正定且 $bold(delta)!=bold(0)$。取 $W$ 的对称正定平方根，并
  令
  $
    bold(u)=W^(1/2)bold(a), quad
    bold(v)=W^(-1/2)bold(delta)
  $
  于是 $bold(a)^TT bold(delta)=bold(u)^TT bold(v)$，由Cauchy不等式，
  $
    (bold(a)^TT bold(delta))^2 & =(bold(u)^TT bold(v))^2 \
                               & <=(bold(u)^TT bold(u))(bold(v)^TT bold(v)) \
                               & =(bold(a)^TT W bold(a))(bold(delta)^TT W^(-1)bold(delta))
  $
  因此
  $
    J(bold(a))<=bold(delta)^TT W^(-1)bold(delta)
  $
  等号成立当且仅当 $bold(u)=c bold(v)$，即
  $
    bold(a)=c W^(-1)bold(delta), quad c!=0
  $
  所有这样的非零倍数都给出最大值
  $
    J_("max")=bold(delta)^TT W^(-1)bold(delta)
  $
  取 $c=1$，即s $bold(a)=W^(-1)(bold(mu)_0-bold(mu)_1)$。

  // 由于 $J(c bold(a))=J(bold(a))$，Fisher准则确定的是方向，不能唯一确定系数的整体尺度。

  *(b) 后验概率作为Fisher统计量的函数。* 以下假设 $V$ 正定，$pi_0,pi_1>0$ 且 $pi_0+pi_1=1$。两类Gauss密度为
  $
    f_k (bold(x))=1/((2 pi)^(n/2) sqrt(det V))
    exp(-1/2 (bold(x)-bold(mu)_k)^TT V^(-1)(bold(x)-bold(mu)_k))
  $
  由Bayes定理，
  $
    P(H_0|bold(x)) & =(pi_0 f_0 (bold(x)))/(pi_0 f_0 (bold(x))+pi_1 f_1 (bold(x))) \
    P(H_1|bold(x)) & =(pi_1 f_1 (bold(x)))/(pi_0 f_0 (bold(x))+pi_1 f_1 (bold(x)))
  $
  两类密度具有共同的归一化因子，故对数似然比为
  $
    ln((f_0 (bold(x)))/(f_1 (bold(x)))) & =-1/2 (bold(x)-bold(mu)_0)^TT V^(-1)(bold(x)-bold(mu)_0) +1/2 (bold(x)-bold(mu)_1)^TT V^(-1)(bold(x)-bold(mu)_1) \
    & =bold(delta)^TT V^(-1)bold(x)
    -1/2 bold(mu)_0^TT V^(-1)bold(mu)_0
    +1/2 bold(mu)_1^TT V^(-1)bold(mu)_1
  $
  // 这里 $bold(x)^TT V^(-1)bold(x)$ 的二次项相互抵消，且 $V^(-1)$ 对称。
  定义与 $bold(x)$ 无关的常数
  $
    b=-1/2 bold(mu)_0^TT V^(-1)bold(mu)_0
    +1/2 bold(mu)_1^TT V^(-1)bold(mu)_1
    +ln(pi_0/pi_1)
  $
  则后验概率的对数比为
  $
    ln((P(H_0|bold(x)))/(P(H_1|bold(x))))
    =ln((pi_0 f_0 (bold(x)))/(pi_1 f_1 (bold(x))))
    =b+bold(delta)^TT V^(-1)bold(x)
  $

  当 $V_0=V_1=V$ 时，$W=2V$。若沿用(a)中 $c=1$ 的归一化，记
  $
    bold(a)_F=W^(-1)bold(delta)=1/2 V^(-1)bold(delta), quad
    t_F=bold(a)_F^TT bold(x)
  $
  就有 $bold(delta)^TT V^(-1)bold(x)=2t_F$，因此
  $
    P(H_0|bold(x)) & =1/(1+exp(-(b+2t_F))) \
    P(H_1|bold(x)) & =1/(1+exp(b+2t_F))
  $
  // 这给出了以题目(a)的Fisher统计量为自变量的后验概率。等协方差条件使所有与分类有关的 $bold(x)$ 依赖都压缩进 $t_F$，先验概率则只改变偏置。

  *(c) 引入偏置。* 利用(a)的尺度自由度，改取同一最优方向上的系数
  $
    tilde(bold(a))=V^(-1)bold(delta)=2 bold(a)_F
  $
  再令 $a_0=b$，定义含偏置的统计量
  $
    t_L (bold(x)) & =a_0+tilde(bold(a))^TT bold(x) \
                  & =a_0+2t_F \
                  & =ln((pi_0 f_0 (bold(x)))/(pi_1 f_1 (bold(x))))
  $
  因此
  $
    exp(t_L)=(P(H_0|bold(x)))/(P(H_1|bold(x)))
  $
  又由于两个后验概率之和为1，可解得
  $
    P(H_0|bold(x))=exp(t_L)/(1+exp(t_L))=1/(1+e^(-t_L)), quad
    P(H_1|bold(x))=1/(1+e^(t_L))
  $
  把重新归一化后的 $t_L$ 简记为题目中的 $t$，即得到标准的Logistic sigmoid形式，其中
  $
    a_0=-1/2 bold(mu)_0^TT V^(-1)bold(mu)_0
    +1/2 bold(mu)_1^TT V^(-1)bold(mu)_1
    +ln(pi_0/pi_1)
  $
]

// #note[
//   (a)中 $bold(a)=W^(-1)bold(delta)$ 与(c)中标准Logistic形式的线性系数相差一个因子2，但两者给出相同的Fisher方向与事例排序。若保持(a)的系数不变，就必须保留指数中的 $2t_F$；仅增加偏置而不调整尺度，不能直接得到 $1/(1+e^(-t))$。

//   上述最大化推导讨论 $W$ 可逆且两类均值不同的情形。若 $bold(mu)_0=bold(mu)_1$，则所有合法非零方向的分离度均为0；在(b)的等协方差Gauss情形，两类密度也相同，后验概率就等于先验概率。
// ]
