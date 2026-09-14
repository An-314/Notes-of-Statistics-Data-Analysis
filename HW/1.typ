#import "@preview/scripst:1.1.2": *

#show: scripst.with(
  title: [统计数据分析第1次作业],
  author: "Anzreww",
  time: "2026年9月",
  cb-counter-depth: 1,
  matheq-depth: 1,
  font-size: 13pt,
  par-leading: 0.6em,
  counter-depth: 1,
)

// 题目来源：files/SDA_exercises2020-mark.pdf，第1页（PDF第4页）。
#exercise(subname: [1.2])[
  证明
  $
    P(A union B) = P(A) + P(B) - P(A inter B)
  $
  （提示：将 $A union B$ 表示成 3 个不相交的子集的并。）
]

#proof[
  将 $A union B$ 分解为三个两两不相交的事件
  $
    C = A inter overline(B), quad
    D = A inter B, quad
    E = overline(A) inter B
  $
  #figure(
    image("pic/1.2.svg", width: 65%),
    caption: [全集 $S$ 中，$C$、$D$、$E$ 两两不相交，其并为 $A union B$],
  )
  则 $A union B = C union D union E$，且 $A = C union D$、$B = D union E$。
  由概率对不相交事件的可加性，
  $
    P(A union B) & = P(C) + P(D) + P(E) \
            P(A) & = P(C) + P(D) \
            P(B) & = P(D) + P(E)
  $
  因而
  $
    P(A) + P(B) - P(A inter B) & = P(C) + 2 P(D) + P(E) - P(D) \
                               & = P(C) + P(D) + P(E) \
                               & = P(A union B)
  $
  即得所证结论。
]

#exercise(subname: [1.3])[
  某粒子束流包含 $10^(-4)$ 的电子，其余为光子。粒子通过某双层探测器，可能在 2 层都给出信号，也可能只有一层给出信号或者没有任何信号。电子 ($e$) 和光子 ($gamma$) 在穿过该双层探测器给出 0，1 或 2 个信号的概率如下
  $
    P(0|e) & = 0.001 & quad P(0|gamma) & = 0.99899 \
    P(1|e) & = 0.01  & quad P(1|gamma) & = 0.001 \
    P(2|e) & = 0.989 & quad P(2|gamma) & = 10^(-5)
  $
  + 如果只有一层给出信号，该粒子为光子的概率是多少？
  + 如果两层都给出了信号，该粒子为电子的概率是多少？
]

#solution[

  记 $N$ 为给出信号的层数。束流中电子和光子的先验概率分别为
  $
    P(e) = 10^(-4), quad P(gamma) = 1 - 10^(-4) = 0.9999
  $
  电子与光子构成互斥且完备的事件组，由全概率公式，
  $
    P(N=n) = P(n|e) P(e) + P(n|gamma) P(gamma)
  $
  再利用Bayes公式，将探测响应概率转化为观测到信号后的粒子种类概率。

  - *只有一层给出信号*
    $
      P(N=1) & = 0.01 times 10^(-4) + 0.001 times 0.9999 \
             & = 0.0010009
    $
    因而该粒子为光子的概率为
    $
      P(gamma|1) & = (P(1|gamma) P(gamma)) / P(N=1) \
                 & = (0.001 times 0.9999) / 0.0010009 \
                 & approx 0.9990009 approx 99.90%
    $

  - *两层都给出信号*
    $
      P(N=2) & = 0.989 times 10^(-4) + 10^(-5) times 0.9999 \
             & = 0.000108899
    $
    因而该粒子为电子的概率为
    $
      P(e|2) & = (P(2|e) P(e)) / P(N=2) \
             & = (0.989 times 10^(-4)) / 0.000108899 \
             & approx 0.90818097 approx 90.82%
    $
]
