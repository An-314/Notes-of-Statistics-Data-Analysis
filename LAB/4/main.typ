#import "@preview/scripst:1.1.2": *

#show: scripst.with(
  title: [统计数据分析第4次实践作业],
  author: "刘骥安",
  time: "2026年11月",
  cb-counter-depth: 1,
  matheq-depth: 1,
  font-size: 13pt,
  par-leading: 0.6em,
  counter-depth: 1,
)

#set heading(numbering: none)
// #show heading: it => block(sticky: true, it)

#let result = json("output/statistics.json")
#let verification = json("output/verification.json")
#let f(value, digits: 6) = str(calc.round(value, digits: digits))

#block(breakable: false)[
  #exercise(subname: [二维散射与湮灭模拟])[
    模拟一个二维散射与湮灭同时发生的过程：
    - 散射过程的平均自由程为2米，湮灭过程的平均自由程为5米；每次散射后，方向相对当前方向在$[-30 degree,+30 degree]$内均匀变化。
    - 物质为无限大的均匀平面。
    - 入射粒子的位置为$(0,0)$，初始方向相对正$x$轴在$[-30 degree,+30 degree]$内均匀分布。

    完成以下内容：
    + 描绘单个粒子在二维平面内的径迹。
    + 使用ROOT的`TGraph`绘制100条粒子的径迹叠加图。
    + 根据模拟得到路程分布与平均值，并解释其数值：
      - a. 湮灭前的总路程。
      - b. 每次实际发生散射的路程。
      - c. 每次实际发生湮灭的路程。
      - d. 理解上述均值与两个输入平均自由程的关系。
  ]
]

本次模拟使用ROOT #verification.root_version，固定随机种子42，生成 #result.n 个粒子，用全部粒子统计路程分布，并从中取前100条轨迹绘图。

// “均匀”指介质中散射中心的空间分布，所有入射粒子仍从题目指定的原点出发。模型只改变粒子的运动方向，两个过程的发生率在整个输运过程中保持恒定。

== 模型与三种路程的定义

设散射、湮灭过程单独存在时的平均自由程分别为
$ lambda_s=2 "m", quad lambda_a=5 "m" $
对应单位路程内的发生率为
$
  mu_s=1/lambda_s=0.5 "m"^(-1), quad
  mu_a=1/lambda_a=0.2 "m"^(-1)
$
// 两个过程竞争决定下一次作用发生在哪里，以及是哪一种作用。一次湮灭后，该粒子的轨迹即结束。
#newpara()

对第$p$个粒子，记湮灭前散射了$n_p$次，第$j$次真实散射前走过的这一步长度为$S_(p j)$，末次湮灭步长为$A_p$，则
$
  T_p=sum_(j=1)^(n_p) S_(p j)+A_p
$
是该粒子从入射到最终湮灭的总路程。

三组样本分别为：
- *总路程*：每个粒子贡献一个$T_p$，共$N$个数。
- *散射步长*：把全部粒子的所有$S_(p j)$放入同一个样本，共$M_s=sum_p n_p$个数。未发生散射的粒子贡献0个散射步，而不是向该样本填入一个0。
- *湮灭步长*：每个粒子贡献一个$A_p$，共$N$个数。它从上一次相互作用位置开始计量；没有散射时，就从原点开始计量。

总路程是各段折线长度之和。末点到原点的距离
$ R_p=sqrt(x_p^2+y_p^2)<=T_p $
是位移大小，可作为程序的几何检查，但不能代替总路程。

== 随机抽样与输运算法

=== 指数分布抽样

在发生率恒定的均匀介质中，单一过程的自由程$L_i$服从指数分布：
$ f_i(l)=1/lambda_i exp(-l/lambda_i), quad l>=0 $
若$U$在$(0,1)$内均匀分布，由生存概率反演可得
$ U=exp(-L_i/lambda_i), quad L_i=-lambda_i ln U $
ROOT的`TRandom3::Exp(lambda)`使用均值参数$lambda$，因此每一步独立产生
```cpp
const double ls = random.Exp(2.0);
const double la = random.Exp(5.0);
const bool scatter = ls < la;
const double step = scatter ? ls : la;
```
`ls`、`la`是两个*候选距离*，真正移动的是其中较短的一段。散射获胜时不执行湮灭；湮灭获胜时，移动到作用位置后结束轨迹。

=== 位置与方向更新

程序中的角度使用弧度，$30 degree=pi/6$。初始方向为
$ theta_0~op("Uniform")(-pi/6,pi/6) $
先沿当前方向移动一步：
$
  x_(k+1)=x_k+L_k cos theta_k, quad
  y_(k+1)=y_k+L_k sin theta_k
$
若该步发生散射，再产生偏转角
$
  Delta theta_k~op("Uniform")(-pi/6,pi/6), quad
  theta_(k+1)=theta_k+Delta theta_k
$
后续方向在此前方向上累积变化，并不在每次散射后重新限制到正$x$轴附近。散射不增加额外路程，折线的每一段只累计一次。

// 每次散射后重新产生两个候选距离，利用了指数分布在当前恒定发生率下的无记忆性。由于介质无限大，不需要边界截断；粒子以概率1最终发生湮灭。

=== 单粒子模拟的完整实现

`simulation.h`定义一条轨迹的数据结构和模拟函数：每一步先记入位置与步长，再根据过程类型决定继续或结束。保存两个候选距离，便于检查输入的2米和5米；统计真实散射步时只保存获胜的散射段。

#raw(read("simulation.h"), lang: "cpp", block: true)


== 单粒子的二维径迹

图中选择前100个粒子里首个至少散射3次的真实事例，标明原点、散射点和最终湮灭点。`event`从0开始编号；单轨迹展示使用 `event =` #result.single_event，散射次数为 #result.single_nscatter，总点数为 #result.single_points。

#figure(
  image("pic/single-track.png", width: 86%),
  caption: [单个粒子的TGraph径迹。横纵坐标均以米为单位，并使用相同的长度比例；线段是自由飞行，转折点是散射位置，最后一点是湮灭位置。],
)

一条包含$n_p$次散射的轨迹，有$n_p+1$段自由飞行和$n_p+2$个坐标点，包括入射原点。单条径迹有明显的随机性，分布和平均值需要对大量粒子统计。

== 100条粒子的径迹叠加

每个粒子单独建立一个`TGraph`，入射点先用`SetPoint(0,0,0)`保存，每一步后再加入新坐标。将前100个图加入`TMultiGraph`并用折线绘制，同时固定横纵坐标的长度比例：

#figure(
  image("pic/tracks-100.png", width: 90%),
  caption: [前100条粒子的二维径迹叠加图。所有粒子从原点出发，初始方向处于正$x$轴两侧30度以内，散射后的方向逐步累积改变。],
)

发生多次偏转后，运动方向可以超出初始入射锥。每条轨迹终点为该粒子的湮灭点；不同长度、不同散射次数的轨迹都保留在样本中。

== 路程分布与模拟得到的均值

=== 未分箱数据的均值与标准误差

对包含$M$个路程值$l_i$的样本，计算
$
  overline(l)=1/M sum_(i=1)^M l_i, quad
  s_l^2=1/(M-1) sum_(i=1)^M (l_i-overline(l))^2
$
均值的蒙特卡洛标准误差估计为
$ "SE"(overline(l))=s_l/sqrt(M) $
// 下面的“$plus.minus$”表示一次标准误差，描述有限模拟样本对平均值的统计精度。散射步样本按全部实际散射段池化，使用其总段数$M_s$作为分母；不先对每个粒子求散射均值再平均。

// 所有均值直接由完整的未分箱样本累计。

// 作图的横轴范围有限，超过右端的数值进入上溢bin，仍保留在均值统计和总计数中。概率密度直方图的归一化分母使用完整样本数乘以bin宽，不把显示范围内的面积强行重归一化为1。
#newpara()
#figure(three-line-table[
  | 路程样本 | 样本数 | 模拟均值 / m | 标准误差 / m | 理论均值 / m |
  | --- | --- | --- | --- | --- |
  | 湮灭前总路程$T$ | #result.total.n | #f(result.total.mean) | #f(result.total.se) | 5 |
  | 真实散射步$S$ | #result.scatter.n | #f(result.scatter.mean) | #f(result.scatter.se) | $10/7$ |
  | 末次湮灭步$A$ | #result.last.n | #f(result.last.mean) | #f(result.last.se) | $10/7$ |
])

三个均值相对理论值的偏离，分别为 #f(verification.theory.total.pull, digits: 3)、#f(verification.theory.scatter.pull, digits: 3)、#f(verification.theory.last.pull, digits: 3) 倍标准误差，均处于本次有限样本波动的合理范围。

=== 三组路程分布

三组数据分别画直方图，叠加相应的理论概率密度。总路程服从均值5米的指数分布；真实散射步与末次湮灭步都服从均值$10/7$米的指数分布。

#figure(
  image("pic/path-lengths.png", width: 95%),
  caption: [三组路程的概率密度直方图及理论指数分布。总路程比单步路程更宽；真实散射步和末次湮灭步具有相同的条件分布。],
)

理论上指数分布的标准差等于均值。本次总路程样本标准差为 #f(result.total.sample_std) m，散射步为 #f(result.scatter.sample_std) m，末次湮灭步为 #f(result.last.sample_std) m，分别接近5 m、$10/7$ m、$10/7$ m。

// == 为什么得到这些数值

// === 过程竞争缩短下一次实际步长

令$L=min(L_s, L_a)$。两个候选距离独立，所以
$
  P(L>l)=P(L_s>l)P(L_a>l)
  =exp[-(mu_s+mu_a)l]
$
因此下一次相互作用的总发生率为
$ mu=mu_s+mu_a=0.7 "m"^(-1) $
实际步长的平均值为
$ Lambda=1/mu=1/(1/2+1/5)=10/7 "m" approx 1.428571 "m" $
两种过程在下一步获胜的概率分别为
$ p_s=mu_s/mu=5/7, quad p_a=mu_a/mu=2/7 $

在路程$l$处发生散射，要求散射恰好发生且湮灭此前没有发生。该联合概率密度为
$ f_(L,J=s)(l)=mu_s exp(-mu_s l) exp(-mu_a l)=mu_s exp(-mu l) $
除以散射获胜的概率$p_s$，得到实际散射步的条件密度
$ f_(L|J=s)(l)=(f_(L,J=s)(l))/p_s=mu exp(-mu l) $
同理
$ f_(L|J=a)(l)=mu exp(-mu l) $
所以
$ E[S]=E[A]=Lambda=10/7 "m" $
实际能够结束于某一种作用的步，已经同时受到另一种作用的竞争筛选。两个过程的*获胜概率*不同，但给定获胜类型后的*步长形状*相同。

// === 总路程仍由湮灭率决定

沿着粒子已经走过的累计路程，散射只改变方向，既没有移除粒子，也没有改变后续的湮灭发生率。粒子走过总路程$t$仍未湮灭的概率为
$ P(T>t)=exp(-mu_a t)=exp(-t/lambda_a) $
故
$ f_T(t)=1/lambda_a exp(-t/lambda_a), quad E[T]=lambda_a=5 "m" $
路径可以发生弯折，但均匀、无限介质中的累计路程湮灭率始终为$0.2 "m"^(-1)$。

也可以从散射次数理解总路程。令$N_s$为湮灭前散射次数，每一步以$p_a=2/7$的概率结束，因此
$ P(N_s=k)=p_a p_s^k, quad k=0,1,2,dots $
$ E[N_s]=p_s/p_a=2.5 $
本次模拟的平均散射次数为 #f(result.nscatter.mean)。理论上有$P(N_s=0)=2/7 approx 28.57%$的粒子未发生散射就直接湮灭。

联合密度可分解为$f_(L,J=i)(l)=p_i f_L(l)$，说明在本模型中步长与获胜过程类型独立。因此给定$N_s=k$时，总共走$k+1$个均值为$Lambda$的步，故
$ E[T|N_s=k]=(k+1)Lambda $
$ E[T]=(E[N_s]+1)Lambda=(2.5+1) times 10/7=5 "m" $
两个角度的推导得到相同结果。

// === 输入的2米和5米体现在哪里

输入参数描述的是每种过程单独抽样时的候选距离。对所有步骤产生的候选数值直接统计，本次得到：

#figure(three-line-table[
  | 统计对象 | 模拟均值 / m | 理论均值 / m |
  | --- | --- | --- |
  | 散射候选距离$L_s$ | #f(result.raw_scatter.mean) | 2 |
  | 湮灭候选距离$L_a$ | #f(result.raw_annihilation.mean) | 5 |
  | 散射获胜时的实际步长 | #f(result.scatter.mean) | $10/7$ |
  | 湮灭获胜时的实际步长 | #f(result.last.mean) | $10/7$ |
])

b、c两问按照输运过程中*实际发生的相邻作用之间的路程*统计；如果要检查单独某个过程的输入平均自由程，应统计候选距离。总路程则跨越沿途的全部散射段，直到最终湮灭，均值重新得到5米。

== 运行方式、输出与独立核对

从仓库根目录运行：
```sh
bash LAB/4/run.sh
```
脚本自动进入自身目录，执行ROOT宏、生成数据与图片，再调用独立核对程序：

#raw(read("run.sh"), lang: "bash", block: true)

输出包括：
- `output/transport.root`：逐粒子的路程、末次步、散射步与候选距离，原始计数直方图，以及100条轨迹和单轨迹`TGraph`对象。
- `output/statistics.json`：全部样本的计数、均值、样本标准差和标准误差。
- `output/verification.json`：独立读取ROOT文件的核对结果。
- `pic/`中的三张图，以及记录运行过程的`run-output.txt`。

#block(sticky: true)[独立核对程序逐粒子检查]
$ T_p=A_p+sum_j S_(p j), quad R_p<=T_p $
并核对全部样本的均值、标准差、标准误差、直方图的完整计数，以及前100条`TGraph`与保存坐标是否一致。将逐粒子的恒等式加总，还必须满足样本上的精确关系
$ overline(T)=overline(A)+(M_s/N) overline(S) $
这里的系数使用本次实际散射次数$M_s/N$，并非把理论值2.5代入有限样本的恒等式。

报告中的数值由JSON结果直接读取。完整运行和独立核对通过后，可在仓库根目录编译：
```sh
make builds/LAB/LAB4.pdf
```

== 完整统计与绘图宏

`exercise.C`调用前面的单粒子函数，用完整样本累计统计，保存`TTree`和原始计数直方图，利用`TGraph`绘制径迹，再将三组路程分布与理论曲线比较。所有长度以米为单位，随机种子和粒子数在程序中固定，便于复现。

#raw(read("exercise.C"), lang: "cpp", block: true)
