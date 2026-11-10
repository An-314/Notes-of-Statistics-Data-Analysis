#import "@preview/scripst:1.1.2": *

// 抵消模板在长目录末尾的额外留白，避免生成空白目录页。
#show outline: it => [#it#v(-15pt)]

#show: scripst.with(
  template: "book",
  title: [粒子物理与核物理实验中的数据分析],
  author: ("Anzreww",),
  time: "丙午秋冬于清华园",
  contents: true,
  font-size: 12pt,
  par-leading: 0.8em,
  content-depth: 3,
  matheq-depth: 3,
  lang: "zh",
)

#include "chap1-lab.typ"

#include "chap2-lab.typ"

#include "chap3-lab.typ"

#include "chap4-lab.typ"

#include "chap5-lab.typ"

#include "chap6-lab.typ"

#include "chap7-lab.typ"
