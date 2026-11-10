#import "@preview/scripst:1.1.2": *

#show: scripst.with(
  title: [统计数据分析第6次作业],
  author: "Anzreww",
  time: "2026年11月",
  cb-counter-depth: 1,
  matheq-depth: 1,
  font-size: 13pt,
  par-leading: 0.6em,
  counter-depth: 1,
)

#let snippet(id) = {
  let exercise = id.slice(0, 3)
  let src = read("6/macros/ex" + exercise.replace(".", "_") + ".C")
  let lines = src.split("// BEGIN " + id).at(1).split("// END " + id).at(0).split("\n")
  let nonempty = lines.enumerate().filter(pair => pair.last().trim() != "")
  let lines = lines.slice(nonempty.first().first(), nonempty.last().first() + 1)
  let indent = calc.min(
    ..lines.filter(line => line.trim() != "").map(line => line.match(regex("^\\s*")).text.len()),
  )
  let code = lines.map(line => line.slice(calc.min(indent, line.len()))).join("\n")
  raw(code, lang: "cpp", block: true)
}

#let input = csv("6/data/ex4_4.csv").slice(1)
#let results = (
  csv("pic/6/4-4-results.csv")
    .slice(1)
    .map(row => (
      model: row.at(0),
      total: float(row.at(1)),
      q: float(row.at(2)),
      p-chi: float(row.at(3)),
      toys: int(row.at(4)),
      seed: int(row.at(5)),
      tail: int(row.at(6)),
      p-mc: float(row.at(7)),
      se: float(row.at(8)),
      mean: float(row.at(9)),
      variance: float(row.at(10)),
      variance-exact: float(row.at(11)),
    ))
)

// 题目与数据来源：files/SDA_exercises2020-mark.pdf，第12–13页。

#exercise(subname: [4.3])[
  正负电子对撞中观测到的具有特殊运动学性质的事例数可以被认为是一个Poisson变量。假设对于给定积分亮度（即给定束流强度时的取数时间），从某已知过程得到的事例数为3.9，然而实际上观测到16个。假设没有新物理过程对观测到的事例数有贡献，计算该假设的 $p$值。计算Poisson分布的求和时，可以利用关系式
  $
    sum_(n=0)^m P(n;nu)=1-F_(chi^2) (2nu;n_("dof"))
  $
  其中 $P(n;nu)$ 是均值为 $nu$ 的Poisson分布的概率，$F_(chi^2)$ 是自由度数目 $n_("dof")=2(m+1)$ 的 $chi^2$分布的累积分布函数。可以调用ROOT里面的 `TMath` 名字空间下的函数计算，或者查表得到。
]

#solution[
  在仅有已知过程的假设 $H_0$ 下，取预期计数为确定的 $nu=3.9$，则
  $
    N tilde "Poisson"(3.9), quad
    P(N=n|H_0)=e^(-3.9) (3.9)^n/n!
  $
  观测到的事例过多是所关心的偏离，所以应把16个及以上的结果都计入右尾
  $
    p & =P(N>=16|H_0) \
      & =sum_(n=16)^oo e^(-3.9) (3.9)^n/n! \
      & =1-sum_(n=0)^15 e^(-3.9) (3.9)^n/n!
  $
  取 $m=15$，得到自由度 $2(15+1)=32$，因此
  $
    p=F_(chi^2) (2 times 3.9;32)
    =F_(chi^2) (7.8;32)
    approx 3.57970 times 10^(-6)
  $
  这里Poisson的右尾对应 $chi^2$的下尾累积概率。程序分别用Poisson补累积分布函数与 $chi^2$累积分布函数交叉计算：
  #snippet("4.3")

  若用单侧标准Gauss尾概率表示，则
  $
    Z=Phi^(-1)(1-p)approx 4.48889
  $
  // 这个 $p$值是在仅本底模型下，得到至少16个事例的概率；单点概率 $P(N=16)$ 不能代替它，也不能把 $p$解释为该模型为真的概率。
]


#exercise(subname: [4.4])[
  @data44 是实验获得的数据与期待值的两种理论预言。前两列是区间的边界，第三列是对应的实验观测事例数 $n_i$，$i=1,dots,20$，服从Poisson分布。第四列和第五列给出期待值 $nu_i=E[n_i]$ 的两种理论预言。

  (a) 写一段程序，用直方图表示数据，画到一张图上，并根据 _Statistical Data Analysis_ 的(4.39)式计算 $chi^2$统计量。

  (b) 因为很多区间的事例数很少甚至为零，前面计算的统计量不太可能服从 $chi^2$分布。写一段程序，根据两种理论假设 `theory1` 和 `theory2` 给出真实的 $chi^2$分布。如果利用(a)中的数据计算统计检验，其 $p$值是多少？如果利用正常的 $chi^2$分布计算，$p$值是多少？
]

#show figure: set block(breakable: true)
#figure(
  table(
    columns: (1fr, 1fr, 1fr, 1.3fr, 1.3fr),
    stroke: none,
    inset: 4pt,
    table.hline(stroke: 0.7pt),
    table.header([*$x_("min")$*], [*$x_("max")$*], [*$n_i$*], [*$nu_i$ (`theory1`)*], [*$nu_i$ (`theory2`)*]),
    table.hline(stroke: 0.4pt),
    ..input.map(row => row.map(value => [#value])).flatten(),
    table.hline(stroke: 0.7pt),
  ),
  kind: table,
  caption: [实验观测计数与两种理论预期。程序和本文从同一份CSV读取这20行数据。],
) <data44>

#solution[
  *(a)* 记模型编号为 $j=1,2$。根据题给的各分箱预期值计算
  $
    Q_j=chi_(P,j)^2=sum_(i=1)^20 (n_i-nu_(j i))^2/nu_(j i)
  $
  分母是理论预期 $nu_(j i)$，不能改成观测数 $n_i$。特别地，空分箱 $n_i=0$ 的贡献仍为 $nu_(j i)$，所以不能删去。

  程序在 $[0,10]$ 上建立20个等宽分箱，分别填入观测计数和两种理论预期。数据误差棒取 $sqrt(n_i)$，仅用于画图；检验仍按上式使用Poisson模型的预期方差。核心计算为
  #snippet("4.4a")

  总计数及总预期分别为
  $
    sum_i n_i=49, quad sum_i nu_(1 i)=50.4, quad sum_i nu_(2 i)=47.8
  $
  逐箱求和得到
  $
    Q_1 approx 15.819254, quad Q_2 approx 35.965269
  $
  // 两种理论的绝对预期计数均由题目给定，不把它们重新归一化为观测总数49，也不从这批数据拟合任何参数。
]

#figure(
  image("pic/6/4-4-data-theory.svg", width: 100%),
  caption: [观测计数及两种理论的分箱预期。误差棒取 $sqrt(n_i)$，不用于改变Pearson统计量的分母。],
)

#solution[
  *(b)* 对每个模型 $j$，独立产生
  $
    N_(j i)^* tilde "Poisson"(nu_(j i)), quad i=1,dots,20
  $
  各分箱计数独立，因此每次伪实验的总事例数会涨落，不能强制固定为49；固定总数会把问题改成多项分布检验。每次都用该模型同一组预期值计算
  $
    Q_j^*=sum_(i=1)^20 (N_(j i)^*-nu_(j i))^2/nu_(j i)
  $
  反复产生 $B$ 组伪实验，按观测统计量的右尾直接计数：
  $
    K_j=sum_(b=1)^B bold(1)_(Q_(j b)^*>=Q_(j,"obs")), quad
    hat(p)_j=K_j/B
  $
  程序的核心循环如下，`nu` 为当前模型的20个预期值，`observed` 为其未舍入的观测统计量：
  #snippet("4.4b")

  每个模型使用 #results.at(0).toys 次伪实验，两个独立的非零随机种子分别为 #results.at(0).seed 和 #results.at(1).seed。尾概率由全部伪实验的比较得到，包含图示范围外的结果，不用直方图分箱去近似尾部积分。

  若直接采用渐近 $chi^2$分布，由于20个Poisson分箱的预期值均已指定，既没有固定总数约束，也没有从数据拟合参数，自由度应取20
  $
    p_(chi^2,j)=P(chi_(20)^2>=Q_(j,"obs"))
  $
  两种方法的数值结果为
  #table(
    columns: (0.7fr, 0.85fr, 1.5fr, 1fr),
    stroke: none,
    inset: 5pt,
    table.hline(stroke: 0.7pt),
    table.header([*模型*], [*$Q_("obs")$*], [*$hat(p)_("MC")$及其标准误差*], [*$chi_(20)^2$近似 $p$*]),
    table.hline(stroke: 0.4pt),
    ..results
      .map(r => (
        [#r.model],
        [#calc.round(r.q, digits: 6)],
        [$#calc.round(r.p-mc, digits: 6) plus.minus #calc.round(r.se, digits: 6)$],
        [#calc.round(r.p-chi, digits: 6)],
      ))
      .flatten(),
    table.hline(stroke: 0.7pt),
  )

  表中的Monte Carlo标准误差为 $sigma_("MC") approx sqrt((hat(p)(1-hat(p)))/B)$。

  低计数时，Pearson统计量仍然有定义，但其参考分布并不是标准 $chi^2$分布。差异可以从矩直接看出：对单个 $N_i tilde "Poisson"(nu_i)$
  $
    E[(N_i-nu_i)^2]=nu_i, quad
    E[(N_i-nu_i)^4]=nu_i+3nu_i^2
  $
  因而在各分箱独立时
  $
    E[Q]=20, quad
    "Var"[Q]=sum_(i=1)^20 (2+1/nu_i)
  $
  两种理论分别给出 $"Var"[Q_1]approx 71.3451$、$"Var"[Q_2]approx 55.9841$，明显大于 $chi_(20)^2$分布的方差40。Monte Carlo得到的均值、方差为
  #table(
    columns: (1fr, 1fr, 1fr, 1fr),
    stroke: none,
    inset: 5pt,
    table.hline(stroke: 0.7pt),
    table.header([*模型*], [*模拟均值*], [*模拟方差*], [*精确方差*]),
    table.hline(stroke: 0.4pt),
    ..results
      .map(r => (
        [#r.model],
        [#calc.round(r.mean, digits: 4)],
        [#calc.round(r.variance, digits: 4)],
        [#calc.round(r.variance-exact, digits: 4)],
      ))
      .flatten(),
    table.hline(stroke: 0.7pt),
  )

  这也核验了程序生成的是题目所指定的Poisson总体。两种尾概率的差异远大于模拟误差，应采用实际参考分布校准的结果。若以5%显著水平判断，`theory1`不被拒绝，`theory2`被拒绝。
]

#figure(
  image("pic/6/4-4-pearson-toys.svg", width: 100%),
  caption: [两种理论下Pearson统计量的Monte Carlo分布与20自由度的 $chi^2$密度。],
  // 竖线标出对应的观测值，尾概率使用全部伪实验直接计数。],
)
