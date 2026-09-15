#import "@preview/scripst:1.1.2": *

#show: scripst.with(
  template: "book",
  title: [统计数据分析],
  author: ("Anzreww",),
  time: "丙午秋冬于清华园",
  contents: true,
  font-size: 12pt,
  par-leading: 0.8em,
  content-depth: 3,
  matheq-depth: 3,
  lang: "zh",
)

#include "chap1.typ"
