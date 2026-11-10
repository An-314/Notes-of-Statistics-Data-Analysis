#import "@preview/scripst:1.1.2": *

#pagebreak(weak: true)
#show figure: set block(breakable: true)

= ROOT数据分析入门

// 来源：第1—3、18页。
本章内容：
- ROOT的用途、基本模块与使用环境
- C++交互命令、宏文件与PyROOT
- 图形类`TGraph`、`TGraphErrors`
- 随机数、随机种子与`gRandom`
- 直方图、ROOT文件的写入和读取
- 数学函数、参数设置与数据拟合
- TTree列式存储、创建、读取、精简与多文件分析
- RDataFrame声明式分析、惰性执行与隐式多线程
- 变长数组、STL容器与友元树

*学习目标*：能够把数据组织成图形或直方图，使用随机数生成模拟样本，定义模型函数并拟合数据，将分析对象与图像保存下来，并能用TTree保留逐事例数据、使用RDataFrame建立筛选与统计流程。

前面学习的类、继承和多态是理解ROOT接口的基础。普通C++项目可以直接使用`g++`或Makefile编译：
```bash
g++ -o hello.exe -I./include ./src/*.cc
make
make clean
```
`-o`指定输出程序，`-I`指定头文件目录，`make clean`执行项目中定义的清理规则。ROOT则进一步提供现成的分析类、交互解释器和图形工具。

== ROOT简介

=== 数据分析中的任务

// 来源：第4、43页。
ROOT是起源于CERN、主要使用C++开发的数据处理与分析框架，也提供Python接口。它广泛用于高能物理、核物理和天体物理等领域，覆盖数据处理、统计分析、可视化与数据存储。

比较测量结果与理论模型时，通常需要完成三类工作：
+ *可视化*：画出数据点、误差棒、直方图和模型曲线。
+ *参数估计*：通过拟合确定模型中的未知参数。
+ *一致性检验*：量化数据与模型之间的差异。

ROOT将这些操作组织为一组面向对象的接口，设计上重视大量数据的存储与高效分析。实验中的质量谱、排除域、数据与模拟比较图，以及发现希格斯玻色子时使用的许多分析图，都可以用这套工具完成。

=== 主要模块

// 来源：第5页。
#figure(three-line-table[
  | 模块 | 典型功能 |
  | --- | --- |
  | 数据分析 | 直方图、数据点图、函数与拟合 |
  | `RDataFrame` | 声明式的数据筛选、变换与分析 |
  | RooFit／RooStats | 概率模型、参数估计与统计推断 |
  | I/O与`TTree` | 对象持久化，以及数据集的列式存储 |
  | 数学工具 | 误差函数、Bessel函数、数值积分与优化 |
  | C++解释器Cling | 交互执行C++代码，加载和编译宏 |
  | TMVA | 多变量分析，如提升决策树与神经网络 |
  | 图形与显示 | 二维、三维绘图，探测器几何和事例显示 |
  | 其他接口 | HTTP服务、JavaScript可视化等 |
])

对象存储需要相应的类型信息和序列化支持；并不是任意C++对象都能在完全没有字典或额外配置的情况下直接写入文件。

=== 起源与发展

// 来源：第6、44页。
1994年，René Brun与Fons Rademakers开始探索用C++实现科学计算工具。当时基于Fortran的PAW难以满足未来LHC对数据规模和软件结构的要求。他们从直方图功能入手，在实际编程中检验C++的可行性，并于1995年发布ROOT的早期版本。

此后的发展包括：
- 2000年代，`TTree`与ROOT文件成为LHC实验中常见的数据组织和存储方式。
- 2017年前后，`RDataFrame`引入更高层的声明式分析接口，并支持多线程处理。
- 较新的版本继续改善Python生态兼容性，例如ROOT 6.36起提供的UHI直方图接口。

学习工具时，可以先用它解决一个具体问题，再逐步理解底层机制。ROOT的许多设计也与实际分析任务、大数据量和运行效率密切相关。

=== LHC实验的数据处理

// 来源：第7页。
实验数据通常依次经历触发或事例过滤、重建、进一步筛选与精简（skimming），最后进入物理分析：
$ "原始数据" arrow.r "重建数据" arrow.r "分析数据" arrow.r "事例选择、统计处理与图像" $

重建负责把探测器信号转化为径迹、能量沉积和粒子候选；分析阶段再根据研究目标选择事例、填充统计量并比较模型。数据可以保存在本地或网络存储中，ROOT及类似的对象存储格式贯穿多个环节。

#figure(image("pic/chap4-lab/lhc-workflow.png", width: 100%), caption: [LHC实验从原始数据到物理分析的处理流程。])

=== 图形与事例显示

// 来源：第8、42页。
ROOT能够绘制带三维注释的曲面图、参数排除区域、数据与模拟的比值图，也可以显示探测器几何、天文图像，并提供图形用户界面工具。

#figure(
  grid(
    columns: (1fr, 1fr, 1fr),
    gutter: 6pt,
    image("pic/chap4-lab/gallery-surface.png", width: 100%, height: 100pt, fit: "contain"),
    image("pic/chap4-lab/gallery-exclusion.png", width: 100%, height: 100pt, fit: "contain"),
    image("pic/chap4-lab/gallery-data-mc.png", width: 100%, height: 100pt, fit: "contain"),

    image("pic/chap4-lab/gallery-detector.png", width: 100%, height: 100pt, fit: "contain"),
    image("pic/chap4-lab/gallery-astronomy.png", width: 100%, height: 100pt, fit: "contain"),
    image("pic/chap4-lab/gallery-gui.png", width: 100%, height: 100pt, fit: "contain"),
  ),
  caption: [依次为曲面、排除域、数据与模拟比较、探测器、天文图和图形界面示例。],
)

事例显示把一次碰撞或相互作用的重建信息画在探测器几何中，帮助观察径迹、击中位置和能量沉积。例如超级神冈的重建事例与ALICE的模拟重建事例：

#figure(image("pic/chap4-lab/events.png", width: 100%), caption: [超级神冈与ALICE的事例显示。])

=== 文档与示例目录

// 来源：第9—10页。
- #link("https://root.cern.ch")[ROOT网站]
- #link("https://root.cern.ch/primer/")[初学者指南]
- #link("https://root.cern/doc/master/group__Tutorials.html")[按主题分组的教程]
- #link("https://github.com/root-project/root")[ROOT源代码]
- #link("https://github.com/root-project/training")[培训材料]
- #link("https://github.com/root-project/student-course")[学生课程]
- #link("https://root.cern.ch/gallery")[图形示例集]

== 环境与执行方式

=== 安装与验证

// 来源：第11页。
可以通过Conda安装指定版本，例如：
```bash
conda install -c conda-forge root=6.36
```
版本号用于固定环境，便于重现分析；选择其他版本时，应确认它与Python及所需依赖兼容。安装后，在Python交互环境中检查版本并画一个高斯直方图：
```python
import ROOT

print(f"ROOT版本: {ROOT.gROOT.GetVersion()}")
h = ROOT.TH1F("h", "我的第一个直方图", 100, -5, 5)
h.FillRandom("gaus", 1000)
h.Draw()
```
这里创建100个bin、范围为$[-5,5)$的直方图，再从高斯形状抽取1000个随机数填入。图形窗口需要可用的图形环境；批处理时可以保存图像文件。

=== PyROOT：Python接口与C++计算

// 来源：第12页。
PyROOT允许在Python中使用ROOT的C++类：
```python
import ROOT

h = ROOT.TH1D("my_histo", "Example histogram", 100, -4, 4)
```
也可以向C++解释器提交函数定义，然后从Python调用：
```python
ROOT.gInterpreter.ProcessLine(
    "double add(double a, double b)"
    " { return a + b; }"
)
print(ROOT.add(3.14, 100))  # 103.14
```
这种方式适合“Python组织分析流程，C++承担主要计算”的组合。性能收益主要来自把大量计算放进C++内部；逐次跨语言调用本身仍有开销。

=== ROOT交互环境

// 来源：第13页。
在终端执行`root`进入ROOT，执行`root -l`可以省略启动信息。提示符形如`root [0]`，它不是需要输入的命令。

```text
root [0] .help
root [1] .ls
root [2] .! ls
root [3] .q
```

#figure(three-line-table[
  | 命令 | 作用 |
  | --- | --- |
  | `.help`或`.?` | 查看解释器的交互命令帮助 |
  | `.ls` | 列出当前ROOT目录中的对象 |
  | `.! ls` | 通过系统Shell列出当前文件目录 |
  | `.q` | 退出ROOT |
])

点号开头的是解释器的特殊命令，普通C++表达式和ROOT成员函数调用仍按C++语法书写，例如`h->Draw();`。查找`TH1F`或`TGraph`等类的接口时，使用类参考文档和Tab补全；`.help`主要用于解释器命令本身。

=== 宏的解释执行与编译执行

// 来源：第14页。
宏文件（macro）通常以`.C`结尾，保存一段分析代码。以`hsimple.C`为例，可以直接从终端执行：
```bash
root hsimple.C
```
也可以在ROOT中执行，或先加载定义再调用函数：
```text
root [0] .x hsimple.C
root [1] .L hsimple.C
root [2] hsimple()
```
`.x`加载并执行宏；`.L`加载定义，之后可以调用其中的函数。对包含入口函数的宏，直接执行`name.C`时通常调用同名的`name()`。

使用ACLiC编译宏时，在文件名后添加`+`：
```text
root [0] .L hsimple.C+
root [1] hsimple()
```
ACLiC调用系统编译器生成共享库，通常命名为`hsimple_C.so`，然后加载它。编译执行有利于发现缺少头文件、类型不匹配等问题，也适合重复运行较重的计算；编译成功仍不能替代对运行结果的检查。

Python脚本也可以执行后保留交互环境：
```bash
python -i hsimple.py
```

=== 批处理与命令行选项

// 来源：第14、40页。
#figure(three-line-table[
  | 选项 | 含义 |
  | --- | --- |
  | `-b` | 批处理模式，不弹出交互图形窗口 |
  | `-l` | 不显示启动横幅 |
  | `-q` | 执行完命令行指定的宏后退出 |
  | `-n` | 不执行`.rootrc`指定的登录、退出宏 |
  | `-x` | 出现异常时退出 |
  | `-?`、`-h`、`--help` | 打印命令行帮助 |
  | `-config` | 显示构建配置信息 |
])

常见写法如下；带参数的宏需要自身定义相应的函数参数：
```bash
root -l -b -q hsimple.C > out.txt
root -l -b -q 'hsimple.C(3)' > out.txt
root -l -b -q 'hsimple.C("x")' > out.txt
root -l -b -q 'hsimple.C+' > out.txt
```
外层单引号让Shell把宏及其参数作为一个整体传递；字符串参数仍需要内层双引号。`> out.txt`保存标准输出，若还要保存错误信息，可用`> out.txt 2>&1`。`-b`表示无图形界面的批处理，并不自动把进程放到Shell后台。

已编译的宏也可以直接使用其共享库文件，例如`root -l -b -q hsimple_C.so`；文件名和入口函数必须与实际生成的宏匹配。命令行也接受目录参数，在执行宏之前切换目录。较旧帮助中的`-memstat`属于版本相关选项，使用前应查看本机`root --help`。

== 基本语法与类体系

=== 命名约定

// 来源：第15页。
ROOT使用C++语法，常见命名习惯如下：
#figure(three-line-table[
  | 约定 | 含义 | 例子 |
  | --- | --- | --- |
  | 类名以`T`开头 | 常见ROOT类 | `TFile`、`TH1F`、`TTree` |
  | 类型名以`_t`结尾 | ROOT类型别名 | `Int_t`、`Float_t`、`Double_t` |
  | 成员函数首字母大写 | 常见成员函数风格 | `Draw()`、`Fill()`、`Write()` |
  | 全局对象或指针以`g`开头 | 当前环境或全局服务 | `gStyle`、`gRandom`、`gROOT` |
])

`Int_t`、`Float_t`和`Double_t`分别对应ROOT约定的32位整数、32位浮点数和64位浮点数。这些是类型别名，不是新的基本类型；例如当前常见平台上的`Int_t`就是`int`。ROOT支持的平台和I/O规则共同保证数据的可移植性。

=== 继承与共同接口

// 来源：第16、41、46页。
`TObject`是许多传统ROOT类的共同基类，提供`Write()`、`Print()`、`Draw()`、`Clone()`等接口。`TNamed`在其基础上增加名称和标题；`TH1`进一步提供直方图的填充、统计和拟合操作。

主要继承关系可以写成：
```text
TObject
├── TNamed
│   ├── TH1
│   │   ├── TH1F、TH1D、TH1I……
│   │   ├── TH2 → TH2F、TH2D……
│   │   └── TH3 → TH3F、TH3D……
│   ├── TGraph → TGraphErrors……
│   ├── TTree → TChain
│   ├── TF1 → TF2 → TF3
│   └── TDirectory → TDirectoryFile → TFile
└── TVirtualPad → TPad → TCanvas
```

这里省略了绘图属性等多重继承关系。例如`TH1`还继承线条、填充和标记属性类，所以可以直接调用`SetLineColor()`、`SetFillColor()`和`SetMarkerStyle()`。`TFile`也通过目录类间接继承`TNamed`；`TH2F`则通过`TH2`继承`TH1`。

#figure(
  image("pic/chap4-lab/hist-family.png", width: 100%),
  caption: [直方图家族及其继承关系。`TProfile`等类用于保存各区间内的统计平均信息。],
)

ROOT还有不继承`TObject`的现代接口，不能把该基类视为所有C++或ROOT类型的强制要求。

=== 常用类与全局对象

// 来源：第17—18页。
#figure(three-line-table[
  | 用途 | 类 |
  | --- | --- |
  | 基础对象 | `TObject`、`TNamed` |
  | 数学函数 | `TF1`、`TF2`、`TF3` |
  | 图形 | `TGraph`、`TGraphErrors`、`TGraph2D` |
  | 文件 | `TFile` |
  | 画布与子画布 | `TCanvas`、`TPad` |
  | 随机数 | `TRandom`、`TRandom1`、`TRandom2`、`TRandom3` |
  | 树与树链 | `TTree`、`TChain` |
])

`gRandom`指向当前随机数发生器；`gROOT`管理ROOT全局环境；`gStyle`控制默认绘图风格；`gPad`指向当前画布区域；`gFile`表示当前文件，`gEnv`用于环境配置。了解对象当前属于哪个文件、画在哪个pad上，有助于理解后续的读写和绘图行为。

== 数据点图与绘图属性

=== TGraph：用坐标点绘图

// 来源：第19页。
`TGraph`保存一组$(x,y)$坐标，可以画散点、折线或平滑曲线。它与直方图不同：每个点的位置由输入数据直接指定，不需要先分bin。

常见构造方式包括空图、预先给定点数、坐标数组、ASCII文件，以及从其他对象构造。坐标数组形式为：
```cpp
TGraph(Int_t n, const Double_t* x, const Double_t* y);
```
其中`n`是点数，`x`和`y`分别指向横、纵坐标数组。类通常提供多种重载，可查阅#link("https://root.cern.ch/doc/master/classTGraph.html")[TGraph参考文档]，或在交互环境中输入`TGraph`、构造函数开头后按Tab查看可用接口。

=== 一个完整的TGraph示例

// 来源：第20页。
取20个点，令$x_i = 0.1 i$、$y_i = 10 sin(x_i + 0.2)$：
```cpp
void graph_simple() {
    TCanvas* c1 = new TCanvas("c1", "");
    static const int n(20);
    double x[n], y[n];
    for (int i = 0; i < n; ++i) {
        x[i] = i * 0.1;
        y[i] = 10 * sin(x[i] + 0.2);
    }
    auto gr = new TGraph(n, x, y);
    gr->SetTitle("Graph title;X-Axis;Y-Axis");
    gr->Draw("AL*");
    c1->Draw();
}
```

标题字符串用分号依次分隔“图标题；横轴标题；纵轴标题”。`Draw()`选项可以组合使用：
#figure(three-line-table[
  | 选项 | 效果 |
  | --- | --- |
  | `A` | 创建并绘制坐标轴 |
  | `L` | 用直线连接相邻数据点 |
  | `C` | 用平滑曲线连接数据点 |
  | `P` | 按设置的marker样式画点 |
  | `*` | 使用星号标记 |
  | `SAME` | 与已有对象叠加绘制的常用写法 |
  | `ACP` | 坐标轴、平滑曲线和标记点 |
])

`AL*`因此表示“坐标轴＋折线＋星号”。叠加`TGraph`时通常不再使用`A`，以保留已有坐标轴；`SAME`不负责新建画布。更完整的选项见#link("https://root.cern.ch/doc/master/classTGraphPainter.html")[TGraphPainter]。

#figure(image("pic/chap4-lab/graph-simple.png", width: 80%), caption: [20个坐标点组成的折线图。])

=== TGraphErrors：从ASCII文件读取误差图

// 来源：第21页。
`TGraphErrors`在每个点上增加对称的横向和纵向误差。文件构造函数的接口为：
```cpp
TGraphErrors(const char* filename,
             const char* format = "%lg %lg %lg %lg",
             Option_t* option = "");
```
四列默认对应$x$、$y$、$sigma_x$、$sigma_y$；使用三列格式`"%lg %lg %lg"`时，对应$x$、$y$、$sigma_y$，横向误差取零。使用其他数据列布局时，应明确指定读取格式。

下面把期望值画成黄色误差带，把测量值画成带误差棒的点：
```cpp
void grapherr() {
    auto c = new TCanvas("c", "");
    c->SetGrid();
    TGraphErrors graph_expected(
        "./macro2_input_expected.txt", "%lg %lg %lg");
    graph_expected.SetTitle(
        "Measurement XYZ and Expectation;length [cm];Arb.Units");
    graph_expected.SetFillColor(kYellow);
    auto expectedDrawn = graph_expected.DrawClone("E3AL");

    TGraphErrors graph("./macro2_input.txt", "%lg %lg %lg");
    graph.SetMarkerStyle(kCircle);
    graph.SetFillColor(0);
    auto measuredDrawn = graph.DrawClone("PESame");

    TLegend leg(.1, .7, .3, .9, "Lab. Lesson 2");
    leg.SetFillColor(0);
    leg.AddEntry(expectedDrawn, "Expected Points", "lf");
    leg.AddEntry(measuredDrawn, "Measured Points", "pe");
    leg.DrawClone("Same");
}
```
`E3`把纵向误差画成连续填充带，`TLegend`提供图例。这里使用`DrawClone()`，使画布上的绘图副本在函数结束、局部对象销毁之后仍然存在。图例也引用这些绘图副本，避免持有已销毁的局部对象指针。

#block(breakable: false)[
  #note(subname: [补充：便于独立运行的小数据集])[
    可以使用下面两组演示数据检查文件读取，三列依次是$x$、$y$和$sigma_y$。`macro2_input_expected.txt`：
    ```text
    0  1.0  0.2
    1  2.0  0.2
    2  3.0  0.2
    ```
    `macro2_input.txt`：
    ```text
    0  0.9  0.1
    1  2.1  0.1
    2  2.8  0.1
    ```
  ]
]

#figure(image("pic/chap4-lab/graph-errors.png", width: 80%), caption: [使用上述演示数据绘制的期望误差带与测量点。])

=== 标记样式

// 来源：第22页。
`SetMarkerStyle()`设置数据点的形状，`SetMarkerSize()`设置大小：
```cpp
gr->SetMarkerStyle(kFullCircle);
gr->SetMarkerSize(1.0);
```

#figure(image("pic/chap4-lab/markers.png", width: 100%), caption: [常用marker的形状与编号。])

符号名比数字更容易阅读，常用对应关系如下：
#figure(three-line-table[
  | 编号 | 名称 | 编号 | 名称 |
  | --- | --- | --- | --- |
  | 1 | `kDot` | 2 | `kPlus` |
  | 3 | `kStar` | 4 | `kCircle` |
  | 5 | `kMultiply` | 6 | `kFullDotSmall` |
  | 7 | `kFullDotMedium` | 8 | `kFullDotLarge` |
  | 20 | `kFullCircle` | 21 | `kFullSquare` |
  | 22 | `kFullTriangleUp` | 23 | `kFullTriangleDown` |
  | 24 | `kOpenCircle` | 25 | `kOpenSquare` |
  | 26 | `kOpenTriangleUp` | 27 | `kOpenDiamond` |
  | 28 | `kOpenCross` | 29 | `kFullStar` |
  | 30 | `kOpenStar` | 31 | `kOpenThreeTriangles` |
  | 32 | `kOpenTriangleDown` | 33 | `kFullDiamond` |
  | 34 | `kFullCross` |  |  |
])

=== 颜色

// 来源：第23页。
线、标记和填充区域分别设置颜色：
```cpp
gr->SetLineColor(kRed);
gr->SetMarkerColor(kPink);
gr->SetFillColor(kBlue - 4);
```

`kRed`、`kBlue`、`kGreen`、`kOrange`、`kMagenta`等是预定义颜色编号，加减整数可以选择同一色系附近的颜色。设置填充色只改变属性，还需要相应的绘制选项才能显示填充区域。

#figure(image("pic/chap4-lab/colors.png", width: 65%), caption: [ROOT颜色轮与颜色编号的相对偏移。])

== 随机数

=== 随机数的用途与生成器

// 来源：第24、45页。
随机数在分析中有两类典型用途：
+ *蒙特卡洛模拟*：模拟粒子的相互作用、散射、能量沉积，以及探测器对粒子的响应。Geant4等模拟程序在大量步骤中都需要抽样。
+ *赝数据（toy MC）*：从已知模型和参数产生数据，检验分析方法能否恢复输入值，评估偏差与统计波动。

ROOT的传统随机数发生器包括：
#figure(three-line-table[
  | 类 | 算法 | 周期量级 | 参考耗时 |
  | --- | --- | --- | --- |
  | `TRandom` | 线性同余 | $10^9$ | 3 ns／次 |
  | `TRandom1` | RANLUX | $10^171$ | 80 ns／次 |
  | `TRandom2` | Tausworthe | $10^26$ | 5 ns／次 |
  | `TRandom3` | Mersenne Twister | $10^6000$ | 5 ns／次 |
])

这些耗时用于比较量级，实际速度取决于CPU、编译器和软件版本。`TRandom1/2/3`都继承`TRandom`的公共抽样接口，`TRandom3`是`gRandom`所使用的默认生成器，也是本章例子的选择。

*周期*是发生器内部状态或序列开始重复前的长度。周期很长可以避免在通常样本规模下耗尽整个序列，但不代表单个随机数永远不会重复，也不自动保证统计质量。

#block(breakable: false)[
  #note(subname: [补充：生成器的适用性])[
    `TRandom`基类自身的线性同余算法有已知缺陷，不适合正式的统计研究。`TRandom3`速度快、周期长，但仍是有限精度的伪随机数发生器；精度要求或随机性检验更严格的计算，应根据需求选择生成器。参见#link("https://root.cern.ch/doc/master/classTRandom.html")[随机数类说明]。
  ]
]

=== 随机种子与gRandom

// 来源：第25、45页。
`gRandom`是指向当前随机数发生器的全局指针。对同一种算法，使用相同的非零种子并按相同顺序调用，可以重现同一序列：
```cpp
gRandom->SetSeed(42);
double x = gRandom->Gaus(0, 1);
```

种子为零是一个特殊请求：
```cpp
gRandom->SetSeed(0);  // 自动初始化随机状态
```
对`TRandom3`，这会利用UUID等信息初始化状态，不能理解为“固定种子0”。调试、方法比较以及需要复现的正式分析都可以使用固定种子；需要不同随机序列时，应明确安排并记录种子或完整状态。

也可以创建自己的发生器，避免不同分析步骤共用全局随机状态：
```cpp
TRandom3 rnd(42);
double x = rnd.Gaus(0, 1);

TRandom* generator = new TRandom2(42);
double u = generator->Rndm();
delete generator;
```
指针类型必须与对象类型相容；例如`TRandom3*`不能指向一个`TRandom2`对象，但共同基类`TRandom*`可以。

=== 常用分布

// 来源：第26页。
#figure(three-line-table[
  | 调用 | 分布或返回值 |
  | --- | --- |
  | `Binomial(ntot, p)` | $n = "ntot"$、成功概率$p$的二项分布 |
  | `BreitWigner(mean, gamma)` | 位置为`mean`、宽度为`gamma`的Breit–Wigner分布 |
  | `Exp(tau)` | 尺度为$tau$的指数分布 |
  | `Gaus(mean, sigma)` | 均值为`mean`、标准差为`sigma`的高斯分布 |
  | `Integer(imax)` | $0,1,dots,"imax"-1$中的随机整数 |
  | `Landau(mu, sigma)` | 位置参数$mu$、尺度参数$sigma$的Landau分布 |
  | `Poisson(mean)` | 泊松分布，返回整数类型 |
  | `PoissonD(mean)` | 泊松分布，返回浮点类型的整数值 |
  | `Rndm()` | $(0,1)$上的均匀随机数 |
  | `Uniform(x1, x2)` | 对均匀随机数作区间缩放 |
])

例如：
```cpp
double gauss = gRandom->Gaus(0, 1);
double uniform = gRandom->Uniform(-2, 2);
auto count = gRandom->Poisson(5);
auto index = gRandom->Integer(10);
```

其他分布的抽样以均匀伪随机数为基础。`TRandom3::Rndm()`不返回0或1；`Uniform(x1,x2)`按`x1 + (x2-x1)*Rndm()`变换，通常按开区间理解，同时应考虑浮点舍入。API的正确拼写是`BreitWigner`。

#block(breakable: false)[
  #note(subname: [补充：Landau分布的参数])[
    `Landau(mu,sigma)`中的`mu`和`sigma`是位置、尺度参数，不能分别当作均值和标准差。Landau分布的长尾使通常的均值、方差不收敛；在ROOT采用的标准化下，$mu=0$、$sigma=1$时的众数约为$-0.22278$。这也意味着`mu`不直接等于分布峰的位置。
  ]
]

== 直方图与ROOT文件

=== 直方图的含义

// 来源：第27—28、47—48页。
直方图把取值范围划分成若干区间（bin），统计每个区间内的事例数或权重和。可以把它看成一组投票箱：每个数值找到所属的箱子，并为该箱增加一次计数。

一维、二维和三维直方图分别统计一个、两个和三个变量：
```cpp
auto h1 = new TH1F("h1", "My Histogram;X;Entries",
                   100, 0, 10);
auto h2 = new TH2F("h2", "2D",
                   100, -5, 5, 100, -5, 5);
auto h3 = new TH3F("h3", "3D",
                   100, 0, 10, 100, 0, 10, 100, 0, 10);
```

一般形式为：
```cpp
TH1F(name, title, nx, xmin, xmax);
TH2F(name, title, nx, xmin, xmax, ny, ymin, ymax);
TH3F(name, title, nx, xmin, xmax,
     ny, ymin, ymax, nz, zmin, zmax);
```
`name`是供程序查找的对象名，`title`是显示标题，二者用途不同。标题中也可以用分号设置坐标轴名称。

直方图可以用来估计概率密度，但*原始计数不等于概率密度*。若第$i$个bin有$n_i$个事例，bin宽为$Delta x_i$，选定范围内共有$N$个事例，则归一化密度估计为
$ hat(f)_i = n_i / (N Delta x_i), quad sum_i hat(f)_i Delta x_i = 1. $
这里的$N$应与纳入归一化的bin范围一致。

=== 类型、精度与bin编号

// 来源：第28、41、46页。
命名规则是`TH<维度><精度>`，如`TH1F`表示一维、单精度bin内容的直方图：
#figure(three-line-table[
  | 类 | bin内容的存储类型 | 常见用途 |
  | --- | --- | --- |
  | `TH1F` | 32位浮点数 | 一般统计量，节省内存 |
  | `TH1D` | 64位浮点数 | 高精度、大统计量或加权统计 |
  | `TH1I` | 整数 | 整数计数 |
  | `TH2F` | 32位浮点数 | 二维分布 |
  | `TH3F` | 32位浮点数 | 三维分布，注意内存开销 |
])

bin数越多，能够分辨的结构越细，但每个bin内的统计量越少，相对波动越大。二维、三维的bin数相乘，内存消耗增长很快。

一维直方图有$N_("bin")$个普通bin时：
- 第0个bin是*下溢*（underflow），接收$x < x_(min)$的数据。
- 第1至$N_("bin")$个bin覆盖$[x_(min),x_(max))$，每个bin通常左闭右开。
- 第$N_("bin")+1$个bin是*上溢*（overflow），接收$x >= x_(max)$的数据。

例如`TH1F(...,100,0,10)`的bin宽是0.1，`10.0`进入overflow。单精度计数在很大的bin内容下可能不能继续分辨每次加1，需要时应改用`TH1D`。

=== 填充、权重与误差

// 来源：第29、47—48页。
```cpp
h1->Fill(3.14);       // 对应bin增加1
h1->Fill(3.14, 2.0);  // 对应bin增加权重2
h2->Fill(x, y);
h3->Fill(x, y, z);
h1->Draw();
```
对于`TH1`，`Fill(x,w)`的第二个参数是权重；对于`TH2`，`Fill(x,y)`的第二个参数是纵坐标。调用含义取决于对象的具体类型。

MC事例可能带有不同的截面、亮度或效率权重，`Fill(x,w)`用于累加这些权重。它反映的是加权后的分布，不能再简单地解释成原始事例计数。
// #note(subname: [补充：加权误差])[
//   对独立加权事例，某个bin的内容和常用统计误差估计分别为
//   $ H_i = sum_(j in i) w_j, quad sigma_i = sqrt(sum_(j in i) w_j^2). $
//   `Sumw2()`保存权重平方和。为使意图明确，可以在加权填充之前调用`h1->Sumw2()`。单位权重时，误差退化为$sqrt(n_i)$。`GetEntries()`统计填充次数，与权重和`GetSumOfWeights()`并非同一概念。
// ]


=== 完整示例：生成并保存Landau直方图

// 来源：第30、49页。
下面的`histw.C`生成10000个Landau随机数，同时保存ROOT对象和图像：
```cpp
void histw() {
    const Int_t NEntry = 10000;
    gRandom->SetSeed(42);  // 固定种子，便于重现本例
    auto file = new TFile("Landau.root", "RECREATE");
    auto h1 = new TH1F("h1", "A simple histo", 100, 0, 1);
    for (int i = 0; i < NEntry; ++i) {
        h1->Fill(gRandom->Landau(0.2, 0.1));
    }
    h1->GetXaxis()->SetTitle("X Title, #sqrt{#Delta_{2}}");
    h1->GetXaxis()->CenterTitle();
    h1->GetYaxis()->SetTitle("Y Title, Entries/0.01");
    TCanvas* c1 = new TCanvas("c1", "");
    h1->Draw();
    file->Write();
    c1->SaveAs("Landau.pdf");
}
```

执行：
```bash
root -l -b -q histw.C
```
过程依次是：*准备文件 → 创建直方图 → 随机抽样并填充 → 画图与保存*。

- `RECREATE`创建新文件；若同名文件已经存在，会覆盖其内容。
- `file->Write()`保存ROOT对象，可供后续读取、计算和重新绘图。
- `SaveAs("Landau.pdf")`保存当前画布的图像。
- 区间$[0,1)$分成100个bin，所以bin宽为0.01，纵轴写作`Entries/0.01`。
- `#sqrt{#Delta_{2}}`使用ROOT图形文字的类LaTeX语法，显示$sqrt(Delta_2)$。

Landau分布有长尾，抽样值可能落在绘图区间之外。因此`GetEntries()`为10000，不意味着100个普通bin的内容之和也恰好等于10000；还要考虑underflow和overflow。

#figure(image("pic/chap4-lab/landau.png", width: 80%), caption: [固定随机种子42后生成的Landau直方图，共填充10000次。])

`gROOT->Reset()`会重置全局环境，独立运行宏时通常不需要在函数中调用。若要重复执行分析，更适合明确管理对象名称、文件和对象的生命周期。

=== 打开ROOT文件

// 来源：第31、50页。
可以在启动时直接打开文件：
```bash
root -l Landau.root
```
也可以在ROOT内部打开：
```text
root [0] TFile f1("Landau.root");
root [1] .ls
root [2] h1->Draw();
```
交互解释器可以按当前目录中的对象名查找对象。图形环境中还可以运行`TBrowser b;`，通过浏览器展开文件并查看对象。

在可重复执行的C++代码中，宜显式取得对象指针，而不依赖交互式名称查找。

=== 读取直方图的宏

// 来源：第31、51页。
最简的`histr.C`包含打开文件、获取直方图、绘制三步：
```cpp
void histr() {
    auto file = new TFile("Landau.root", "READ");
    TH1F* h1 = (TH1F*)file->Get("h1");
    h1->Draw();
}
```
不带模板参数的`Get("h1")`返回`TObject*`，这里用类型转换得到`TH1F*`。前提是文件中确实有该对象，而且类型匹配。

#note(subname: [补充：检查文件和对象])[
  分析代码应处理文件打不开、对象不存在和类型不匹配等情况。可以使用带类型信息的`GetObject()`，避免盲目的C风格转换：
  ```cpp
  TFile file("Landau.root", "READ");
  if (file.IsZombie()) {
      throw std::runtime_error("Cannot open Landau.root");
  }
  TH1F* h1 = nullptr;
  file.GetObject("h1", h1);
  if (!h1) {
      throw std::runtime_error("Missing TH1F: h1");
  }
  h1->DrawCopy();
  ```
  代码需要`<stdexcept>`和相应ROOT头文件。文件通常拥有从中读取的直方图，关闭文件后原指针可能失效；`DrawCopy()`把绘图副本留在画布上。若要让原直方图脱离文件管理，可使用`SetDirectory(nullptr)`并自行管理其生命周期。
]


== 数学函数与拟合

=== TF1、TF2与TF3

// 来源：第32页。
`TF1`、`TF2`、`TF3`分别表示一维、二维和三维函数。构造时指定名称、表达式与自变量范围，使用`Draw()`绘制：
```cpp
auto f1 = new TF1("f1", "x*sin(x)", -5, 5);
f1->Draw();

auto f2 = new TF2("f2", "x*sin(x)+y*cos(y)",
                   -5, 5, -10, 10);
f2->Draw();

auto f3 = new TF3("f3", "x*sin(x)+y*cos(y)+z*exp(z)",
                   -5, 5, -10, 10, -20, 20);
f3->Draw();
```
每个变量分别给出下限和上限；函数对象也可以用于数值计算、积分和随机抽样。

=== 无待定参数的函数

// 来源：第33页。
可以直接使用数学表达式：
```cpp
auto f1 = new TF1("f1", "sin(x)/x", 0, 10);
```
也可以调用`TMath`提供的函数，如二重对数函数：
```cpp
auto f2 = new TF1("f2", "TMath::DiLog(x)", 0, 10);
```
或先向解释器定义一个C++函数：
```cpp
Double_t myFun(double x) {
    return x + sqrt(x);
}
```
随后构造：
```cpp
auto f3 = new TF1("f3", "myFun(x)", 0, 10);
```
字符串表达式调用自定义函数时，该函数需要对解释器可见；独立编译的程序也可以采用后面的函数指针接口。

`sin(x)/x`在$x=0$处的连续极限为1，但直接计算`0/0`会出错。需要包含该点时，可以显式写出极限值：
```cpp
auto sinc = new TF1("sinc", "x == 0 ? 1 : sin(x)/x", 0, 10);
```

=== 常用的预定义含参函数

// 来源：第34页。
拟合时，函数中的参数需要由数据决定。ROOT提供若干常用的表达式名称：

#block(sticky: true)[*高斯函数：`gaus`，3个参数。*]
$ f(x) = p_0 exp(-1/2 ((x-p_1)/p_2)^2). $
$p_0$是峰高，$p_1$是中心，$p_2$是宽度，通常要求$p_2>0$。

#block(sticky: true)[*归一化高斯形状：`gausn`，3个参数。*]
$ f(x) = p_0 / (p_2 sqrt(2 pi)) exp(-1/2 ((x-p_1)/p_2)^2). $
当$p_2>0$时，整个实轴上的积分为$p_0$；只有$p_0=1$时，它本身才是积分为1的概率密度。

#block(sticky: true)[*指数函数：`expo`，2个参数。*]
$ f(x) = exp(p_0 + p_1 x). $

#block(sticky: true)[*$N$阶多项式：`polN`，$N+1$个参数。*]
$ f(x) = p_0 + p_1 x + p_2 x^2 + dots + p_N x^N. $
具体使用`pol0`、`pol1`、`pol2`等名称。

#block(sticky: true)[*切比雪夫多项式：`chebyshevN`，$N+1$个参数。*]
它使用切比雪夫多项式作为基函数。在适当的变量区间上，这种基底有助于改善多项式表示的数值性质；应同时注意自变量的缩放和所选阶数。

#block(sticky: true)[*Landau形状：`landau`，3个参数。*]
参数用于控制幅度、位置和尺度。Landau密度通常由数值近似计算，没有简单的初等函数表达式。

这些名称可以直接用于创建函数或拟合直方图：
```cpp
auto f1 = new TF1("f1", "gaus", -5, 5);
histogram->Fit("gaus");
```

=== 自定义含参表达式

// 来源：第35页。
在字符串表达式中，`[0]`、`[1]`等表示待定参数：
```cpp
auto f1 = new TF1("f1", "[0]*sin([1]*x)/x", 0, 10);
f1->SetParameters(2., 1.5);
f1->SetParNames("amp", "freq");
```
`SetParameters()`按顺序设置多个参数的初值，`SetParNames()`设置易读的参数名称。这个表达式在$x=0$的连续极限为$p_0 p_1$，实际使用时同样应处理该点。

函数指针形式采用统一接口：
```cpp
Double_t myExp(Double_t* x, Double_t* par) {
    Double_t f = par[0] * exp(-x[0] / par[1]);
    return f;
}
```
然后指定函数指针、定义域和参数个数：
```cpp
TF1* f1 = new TF1("f1", myExp, 0, 10, 2);
f1->SetParameter(0, 100);
f1->SetParameter(1, 2);
```
`x[0]`是当前横坐标；`par[0]`、`par[1]`是函数参数。二维和三维函数还会使用`x[1]`、`x[2]`。这里的两个指针并不是“两个标量自变量”。

=== 自定义函数宏myfunc.C

// 来源：第36页。
定义
$ f(x) = p_0 abs(sin(p_1 x)/x + p_2). $
三个参数分别称为`constant`、`coefficient`和`offset`：
```cpp
Double_t myfunction(Double_t* x, Double_t* par) {
    Double_t xx = x[0];
    Double_t ratio = (xx == 0) ? par[1] : sin(par[1] * xx) / xx;
    return par[0] * TMath::Abs(ratio + par[2]);
}

void myfunc() {
    TF1* f1 = new TF1("myfunc", myfunction, 0, 10, 3);
    f1->SetParameters(2, 2.5, 1);
    f1->SetParNames("constant", "coefficient", "offset");
    f1->Draw();
}
```

这里在$x=0$处使用连续极限，避免除零。`myfunc.C`与入口函数`myfunc()`同名，便于使用`.x myfunc.C`直接运行；同一文件也可以定义其他辅助函数。

#figure(image("pic/chap4-lab/myfunc.png", width: 80%), caption: [参数为$(2,2.5,1)$时的自定义函数，$f(0)=7$。])

=== 从函数产生数据并拟合

// 来源：第37页。
在同一个`myfunc.C`文件中加入`myfit()`：
```cpp
void myfit() {
    // 这一部分设置图形属性
    gStyle->SetOptStat(0);
    gStyle->SetOptFit(1111);
    gStyle->SetStatX(0.9);
    gStyle->SetStatY(0.9);
    gStyle->SetStatW(0.35 / 1.5);
    gStyle->SetStatH(0.25 / 1.5);
    gStyle->SetHistMinimumZero(1);

    TH1F* h1 = new TH1F("h1", ";x;Entries", 100, 0, 10);
    h1->FillRandom("myfunc", 2500);
    h1->Sumw2();
    TF1* f1 = (TF1*)gROOT->GetFunction("myfunc");
    f1->SetParameters(40, 2, 1);
    TFitResultPtr result = h1->Fit("myfunc", "ES");
    std::cout << "Fit status = " << int(result) << std::endl;
}
```

依次加载、定义函数对象、生成数据并拟合：
```text
root [0] .L myfunc.C
root [1] myfunc();
root [2] gRandom->SetSeed(42);
root [3] myfit();
```
必须先执行`myfunc()`，使名为`"myfunc"`的函数对象存在；`FillRandom()`才能按该函数形状生成2500个随机数。

`SetOptStat(0)`隐藏普通统计框，`SetOptFit(1111)`显示拟合概率、$chi^2$／自由度、参数值及误差。`SetStatX/Y/W/H()`设置结果框的位置与尺寸。`SetHistMinimumZero(1)`使直方图纵轴从零开始显示。`Fit()`的选项中，`E`要求进行更充分的参数误差估计，`S`返回完整的拟合结果对象。返回状态为0通常表示拟合成功；还应检查参数误差、相关性、协方差矩阵与拟合曲线。

#figure(
  image("pic/chap4-lab/myfit.png", width: 70%),
  caption: [固定随机种子42生成2500个事例后的拟合示例。拟合前将参数初值设为$(40,2,1)$。],
)

#note(subname: [补充：拟合状态与局部极小值])[
  非线性拟合可能依赖初值。在ROOT 6.40.04中固定种子42，使用上述初值$(40,2,1)$时，返回状态虽然为0，却得到$chi^2 / "ndf" approx 449.27 / 97$，曲线与数据明显不符。这说明优化器的收敛状态并不保证找到了合适的最小值。

  对同一份直方图，把初值调整到$(20,2.5,1)$后重新拟合：
  ```cpp
  auto h = (TH1F*)gROOT->FindObject("h1");
  auto f = (TF1*)gROOT->GetFunction("myfunc");
  f->SetParameters(20, 2.5, 1);
  TFitResultPtr result = h->Fit(f, "ES");
  ```
  此时$chi^2 / "ndf" approx 86.39 / 97$，参数约为$(22.89,2.534,0.901)$。实际分析中应从模型和数据选择有依据的初值，并比较多组初值的结果；模拟例子已知生成参数，可以用来检查方法。
]


#figure(image("pic/chap4-lab/myfit-refined.png", width: 80%), caption: [同一组2500个事例更换初值后的拟合结果。])


#note(subname: [补充：形状参数与归一化])[
  生成随机数时，`FillRandom()`按函数的归一化形状抽样；拟合的对象则是每个bin内的计数。因此，即使形状相同，拟合振幅也不必等于生成函数的振幅2。

  对等宽bin，期望计数近似为$N (Delta x f(x)) / (integral f(x) dif x)$。比较生成值与拟合值时，应先区分函数形状、概率密度和每bin期望计数。对较低计数，泊松似然拟合往往比简单的$chi^2$近似更合适，需要按实际问题选择拟合目标。
]


=== 练习：设置图形属性

// 来源：第38页。

#exercise(subname: [三点折线图])[
  创建一个`TGraph`，完成以下设置：
  + 图标题为`My graph`，横轴标题为`myX`，纵轴标题为`myY`。
  + 加入三个点：$(1,0)$、$(2,3)$、$(3,4)$。
  + 使用红色实心方形标记。
  + 用橙色线段连接各点。
]

在ROOT交互环境中依次输入：
```cpp
TGraph g;
g.SetTitle("My graph;myX;myY");
g.SetPoint(0, 1, 0);
g.SetPoint(1, 2, 3);
g.SetPoint(2, 3, 4);
g.SetMarkerStyle(kFullSquare);
g.SetMarkerColor(kRed);
g.SetLineColor(kOrange);
g.Draw("APL");
```

`SetPoint(i,x,y)`的点编号从0开始；`kFullSquare`对应marker样式21；`APL`同时显示坐标轴、标记点和折线。

#figure(image("pic/chap4-lab/exercise.png", width: 70%), caption: [红色实心方形标记与橙色折线。])

=== 对象、直方图与拟合小结

// 来源：第39页；第40—51页的复习内容已合并到相应主题。
+ ROOT把数据处理、存储、图形与统计分析组织为可组合的C++类，并通过PyROOT提供Python接口。
+ `TGraph`描述给定坐标点，`TGraphErrors`加入测量误差；直方图则按bin累加事例或权重。
+ 随机种子决定伪随机序列的可重复性，正式分析同样需要记录随机数配置。
+ `TFile`保存可重新分析的对象，画布的`SaveAs()`保存图像；两者作用不同。
+ `TF1`等类把表达式、参数和数值计算组织起来，`Fit()`用数据估计参数。拟合结果需要结合归一化、误差、状态和物理意义解释。

== 从直方图到TTree

=== 为什么需要保留逐事例数据

// 来源：第1—3页。
直方图适合描述分布，但一组独立的一维直方图不能保留各变量逐事例的配对关系。例如，已经分别填好$μ$子的横动量$p_T$和赝快度$eta$分布后，不能仅凭这两张图重新画出“$p_T>20 "GeV"$的$μ$子的$eta$分布”。选择条件作用于哪个$μ$子，这一信息已经丢失。

二维直方图可以保留两个变量的分箱关联，但不能恢复原始数值，也不适合用高维细分箱代替逐事例存储。若每个维度有100个bin，三维就有$100^3=10^6$个bin，维度继续增加时，存储量迅速增长。实际一个事例往往有几十到几百个变量。

`TTree`保存逐事例的变量与对应关系，解决数据“怎样存”；`RDataFrame`在这些数据上定义筛选、计算和统计流程，解决数据“怎样分析”。两者可以配合使用。保留逐事例数据后，才能从不同角度考察关联、改变选择条件，重新构造需要的分布。

=== 列式存储与基本概念

// 来源：第4、9页。
行式组织以一个事例为单位保存各变量；列式组织把同一变量的多个事例放在一起。若只计算$p_T=sqrt(p_x^2+p_y^2)$，列式读取只需使用`px`、`py`，可以跳过`pz`、`m`等无关列。

#figure(
  grid(
    columns: (1fr, 1fr),
    gutter: 12pt,
    [
      #align(center)[*行式：以事例为单位*]
      #table(
        columns: (auto, 1fr, 1fr, 1fr, 1fr),
        stroke: none,
        inset: 3pt,
        align: center,
        table.hline(stroke: 0.5pt),
        [事例], [$p_x$], [$p_y$], [$p_z$], [$m$],
        table.hline(stroke: 0.5pt),
        [$e_1$], [0.3], [1.1], [−2.0], [0.5],
        [$e_2$], [−0.7], [0.2], [3.4], [0.5],
        [$e_3$], [1.9], [−1.5], [0.8], [0.5],
        table.hline(stroke: 0.5pt),
      )
    ],
    [
      #align(center)[*列式：以变量为单位*]
      #table(
        columns: (auto, 1fr),
        stroke: none,
        inset: 3pt,
        table.hline(stroke: 0.5pt),
        [$p_x$列], [0.3，−0.7，1.9，…],
        [$p_y$列], [1.1，0.2，−1.5，…],
        [$p_z$列], [−2.0，3.4，0.8，…],
        [$m$列], [0.5，0.5，0.5，…],
        table.hline(stroke: 0.5pt),
      )
    ],
  ),
  caption: [逐事例的行式组织与按变量的列式组织。计算横动量只需要读取相应的两列。],
)

同一列通常具有相同类型和相近的数值特征，有利于压缩；压到原体积的$1/3$至$1/5$是可能达到的量级，具体效果取决于数据、压缩算法及设置。
// 分析速度也取决于实际读取了哪些分支，不能仅因使用`TTree`就认为所有列都会自动跳过。

#figure(three-line-table[
  | 术语 | 含义 | 直观类比 |
  | --- | --- | --- |
  | `TTree` | 一个包含许多事例的数据集 | 实验记录本 |
  | Entry | 一个事例，对应一组同时记录的量 | 一次碰撞记录 |
  | Branch | 可单独组织和读取的分支 | 记录本的一栏 |
  | Leaf | 基本类型分支中的数据项 | 栏内的数值或数组 |
])

最简单的Branch只包含一个Leaf，但一个复合Branch也可以有多个Leaf，对象还可以进一步拆分为子Branch。例如：
```text
TTree "myData" (10000 entries)
├── px        (Float_t)
├── py        (Float_t)
├── charge    (Int_t)
├── nTracks   (Int_t)
└── track_pt  (Float_t[nTracks])
```
这里`nTracks`与`track_pt`是并列分支；后者的数组长度引用前者的计数Leaf。分支中的事例编号保持对应关系，各分支可以分别存储、压缩与读取。

=== 从定义到分析的流程

// 来源：第5—6页。
+ 创建`TFile`和`TTree`。
+ 定义Branch、Leaf及其对应的内存地址。
+ 在事例循环中为每个变量赋值，每完成一个事例调用一次`Fill()`。
+ 用`Write()`将树保存到ROOT文件。
+ 重新打开文件，读取树，进行选择、计算、绘图与统计。

`Fill()`记录的是调用时各地址中的当前值，并不会替程序生成事例。忘记更新某个变量，就会把上一个事例的旧值再次写入。

== Tree

=== 创建与填充TTree

==== 构造函数、Branch与Leaf类型

// 来源：第7—8页。
常用接口为：
```cpp
TTree(const char* name, const char* title);
TBranch* Branch(const char* name, void* address,
                const char* leaflist);
```
树的`name`用于查找对象，`title`用于描述数据。`Branch()`依次指定分支名、数据所在地址和Leaf列表：
```cpp
Int_t RunID = 0;
struct Point { Float_t x, y, z; } point{};
auto t1 = new TTree("t1", "test tree");
t1->Branch("RunID", &RunID, "RunID/I");
t1->Branch("point", &point, "x/F:y/F:z/F");
```
`RunID/I`表示名为`RunID`的`Int_t`数据项；复合Leaf用冒号分隔。常用类型码需要与实际内存类型相符，且大小写有区别：

#figure(three-line-table[
  | Leaf类型码 | 对应类型 | 含义 |
  | --- | --- | --- |
  | `/C` | 以零结尾的字符数组 | C风格字符串 |
  | `/I`、`/i` | `Int_t`、`UInt_t` | 有符号、无符号32位整数 |
  | `/F` | `Float_t` | 32位浮点数 |
  | `/D` | `Double_t` | 64位浮点数 |
  | `/L`、`/l` | `Long64_t`、`ULong64_t` | 有符号、无符号64位整数 |
  | `/O` | `Bool_t` | 布尔值 |
])

复合Leaf列表要求各字段的内存排列与声明相符，结构体可能含有对齐填充。上面的同类型`Point`较直接；混合类型时应格外注意布局与可移植性，简单变量通常分别建Branch更清楚。绑定地址所指的对象必须在填充期间保持有效。

也可以保存对象，例如：
```cpp
TH1F* hpx = new TH1F("hpx", "px", 100, -3, 3);
t1->Branch("hpx", "TH1F", &hpx, 128000, 0);
```
这里传入的是对象指针变量的地址`&hpx`，后面的参数控制缓冲区和拆分级别。ROOT不只支持继承`TObject`的类；一般类对象需要相应字典与I/O支持，STL容器也有相应接口。

==== C++：产生一个简单的树

// 来源：第10页；补全头文件、文件关闭与固定种子。
下面保留5000个事例及`px`、`py`、`pz`、`random`、`i`五个分支。保存为`tree1w.C`：
```cpp
#include <TFile.h>
#include <TTree.h>
#include <TRandom.h>

void tree1w() {
    TFile file("tree1.root", "RECREATE");
    TTree t1("t1", "test tree");
    Float_t px, py, pz;
    Double_t random;
    Int_t i;
    t1.Branch("px", &px, "px/F");
    t1.Branch("py", &py, "py/F");
    t1.Branch("pz", &pz, "pz/F");
    t1.Branch("random", &random, "random/D");
    t1.Branch("i", &i, "i/I");
    gRandom->SetSeed(42);
    for (i = 0; i < 5000; ++i) {
        gRandom->Rannor(px, py);
        pz = px*px + py*py;
        random = gRandom->Rndm();
        t1.Fill();
    }
    t1.Write();
}
```
在宏所在目录运行：
```sh
root -l -b -q tree1w.C
```
也可以在ROOT交互环境中使用`.x tree1w.C`。`Rannor(px,py)`一次产生两个独立标准正态随机数，`Rndm()`产生单位区间内的均匀随机数。

==== Python：用缓冲区绑定分支

// 来源：第11—12页。
PyROOT可以直接导入ROOT类，但Branch需要类型与大小明确、地址稳定的内存缓冲区。单个Python浮点数不能简单地替代这里的C++变量地址；可用`array`或类型合适的NumPy数组。保存为`tree1w.py`：
```python
from ROOT import gRandom, TFile, TTree
from array import array

f = TFile("tree1.root", "RECREATE")
t1 = TTree("t1", "test tree")
gRandom.SetSeed(42)
px, py, pz = (array("f", [0]) for _ in range(3))
random = array("d", [0])
i = array("i", [0])
t1.Branch("px", px, "px/F")
t1.Branch("py", py, "py/F")
t1.Branch("pz", pz, "pz/F")
t1.Branch("random", random, "random/D")
t1.Branch("i", i, "i/I")
for j in range(5000):
    gRandom.Rannor(px, py)
    pz[0] = px[0]**2 + py[0]**2
    random[0] = gRandom.Rndm()
    i[0] = j
    t1.Fill()
t1.Write()
f.Close()
```
运行`python3 tree1w.py`。`array("f",[0])`创建一个单精度浮点元素，`"d"`和`"i"`分别表示双精度浮点和整数；传入Branch的是缓冲区对象，更新其内容时则使用`[0]`。Python调用成员函数不用`->`，也不需要在每行末尾加分号。

Python的中间运算精度与C++的`Float_t`表达式可能略有不同；这不改变示例的分布，但不应无条件要求两种写法生成的每个浮点末位都相同。

==== 从ASCII文本导入数据

// 来源：第13页。
示波器导出的文本、表格软件另存的数值文件等，可以通过`TTree::ReadFile()`转成ROOT树。以下`basic.dat`每行是一个事例的$x,y,z$：
```text
-1.102279 -1.799389 4.452822
 1.867178 -0.596622 3.842313
-0.524181  1.868521 3.766139
-0.380611  0.969128 1.084074
 0.552454 -0.212309 0.350281
-0.184954  1.187305 1.443902
 0.205643 -0.770148 0.635417
 1.079222 -0.327389 1.271904
-0.274919 -1.721429 3.038899
 2.047779 -0.062677 4.197329
```
```cpp
TFile file("ex44.root", "RECREATE");
TTree tree("ntuple", "data from ascii file");
Long64_t nlines = tree.ReadFile("basic.dat", "x:y:z");
printf("found %lld points\n", nlines);
tree.Write();
```
第一个参数是文本文件名，第二个参数给出分支描述；未写类型时默认是`Float_t`，也可以显式写成`"x/F:y/F:z/F"`。导入前仍需确认分隔方式、表头与列的含义，成功读入的行数应与预期一致。

=== 读取TTree与表达式分析

==== 查看树、分支与事例

// 来源：第14—15页；第14页是流程提示。
在命令行打开文件：
```sh
root -l tree1.root
```
进入ROOT后可以依次查看：
```cpp
.ls
TTree* t1 = nullptr;
_file0->GetObject("t1", t1);
t1->Show(0);
t1->GetEntries();
t1->Scan();
t1->Print();
t1->Draw("px");
```
`.ls`列出文件中的对象；`Show(0)`显示第0个事例；`GetEntries()`返回事例总数；`Scan()`逐行列出数值；`Print()`显示树结构、分支类型、事例数和压缩等信息。`Scan("px:py:pz", "px>0", "", 10)`可以限制列、选择条件与检查条数，避免输出整棵大树。

`_file0`是用ROOT命令行打开第一个文件后提供的指针；在独立宏中应自行创建`TFile`，并通过`GetObject()`等接口取得树。文件名与树名是不同层次的名称。

==== Draw表达式速查

// 来源：第16页。
`Draw()`可以直接投影变量、计算表达式并加入选择条件：

#figure(three-line-table[
  | 用途 | 示例 |
  | --- | --- |
  | 一维分布 | `t1->Draw("px")` |
  | 二维散点 | `t1->Draw("px:py")` |
  | 表达式 | `t1->Draw("sqrt(px*px+py*py)")` |
  | 指定直方图与分箱 | `t1->Draw("px>>h1(100,0,20)")` |
  | 加入选择 | `t1->Draw("px", "px>0")` |
  | 选择与绘图选项 | `t1->Draw("px:py", "pz>0", "colz")` |
])

*二维表达式的次序是`"y:x"`*：`Draw("px:py")`以`py`为横轴、`px`为纵轴，而`TH2::Fill(px,py)`以`px`为横轴、`py`为纵轴。比较两种方式的图时，要先核对坐标定义。

`"px>>h1"`可把结果填入名为`h1`的直方图；附带`(100,0,20)`时指定100个bin及范围。`>>h1`默认重置内容，`>>+h1`可向已有直方图追加。正态样本包含负值，因此实际查看本例`px`时应按目的选择例如$[-3,3]$的范围，并留意上、下溢出。

常见算术、数学函数与选择条件可写进字符串，由ROOT的树表达式机制`TTreeFormula`解析，不能把它等同于任意C++语句。选择字符串还可表示数值权重；使用加权统计时，应区分事例数、权重和与误差定义。

==== C++：绑定地址并逐事例读取

// 来源：第17页。
复杂计算可用`SetBranchAddress()`指定变量地址，再通过`GetEntry()`逐个事例更新这些变量。核心过程为：
```cpp
TFile file("tree1.root");
TTree* t1 = nullptr;
file.GetObject("t1", t1);
Float_t px, py, pz;
t1->SetBranchAddress("px", &px);
t1->SetBranchAddress("py", &py);
t1->SetBranchAddress("pz", &pz);
TH1F hpx("hpx", "px distribution;px;Entries", 100, -3, 3);
TH2F hpxpy("hpxpy", "py vs px;px;py", 30, -3, 3, 30, -3, 3);
const Long64_t nentries = t1->GetEntries();
for (Long64_t entry = 0; entry < nentries; ++entry) {
    t1->GetEntry(entry);
    hpx.Fill(px);
    hpxpy.Fill(px, py);
}
hpx.DrawCopy();
t1->ResetBranchAddresses();
```
`GetEntry(entry)`之后，`px`、`py`、`pz`才是当前事例的数据。分支名与类型应匹配，绑定地址要在循环期间有效；大型数据集的事例编号用`Long64_t`，避免强制缩成32位整数。

文件、树和直方图也有生命周期。文件关闭后不应继续使用它拥有的对象；`DrawCopy()`可以把图形副本交给画布。更完整的可运行宏`examples/lecture5/tree1r.C`还检查树是否存在，并保存结果图。

==== Python：直接遍历TTree

// 来源：第18页。
PyROOT提供逐Entry迭代，不必手动为每个读取变量设置地址：
```python
import ROOT
f = ROOT.TFile.Open("tree1.root")
t1 = f.Get("t1")
hpx = ROOT.TH1F("hpx", "px distribution", 100, -3, 3)
hpxpy = ROOT.TH2F("hpxpy", "py vs px", 30, -3, 3, 30, -3, 3)
for event in t1:
    hpx.Fill(event.px)
    hpxpy.Fill(event.px, event.py)
hpx.DrawCopy()
f.Close()
```
直接迭代的写法简短，但每个事例都经过Python层，事例数较大时可能有明显开销。一次示例中C++循环约0.63 s、Python循环约50.85 s；这个计时只反映当时的数据量、环境和运行方式，不能当作固定速度比。比较性能时应统一输入和读取列，说明是否计入启动、编译、I/O与绘图时间。

用Python调用`RDataFrame`时，字符串表达式及主要事例循环可在C++侧执行，因此不能用上述逐事例Python循环的计时推断所有PyROOT分析都慢。

#figure(
  image("pic/chap4-lab/tree-distributions.png", width: 100%),
  caption: [固定种子42产生的5000个事例：$p_x$的一维分布和$p_y$与$p_x$的二维关联。两张图使用同一棵树，横纵坐标次序已明确标出。],
)

=== 精简TTree：选择列与选择事例

// 来源：第19—22页；第19页是流程提示。
大型ROOT文件往往有很多分支。精简数据包含两个独立操作：减少保留的变量，以及用选择条件减少事例。

==== CloneTree、CopyTree与分支状态

常用接口的主要参数为：
```cpp
TTree* CloneTree(Long64_t nentries = -1, Option_t* option = "");
TTree* CopyTree(const char* selection, Option_t* option = "",
                Long64_t nentries = kMaxEntries,
                Long64_t firstentry = 0);
void SetBranchStatus(const char* bname, Bool_t status = 1,
                     UInt_t* found = nullptr);
```
+ `CloneTree(-1)`复制所有事例；`CloneTree(0)`只复制当前激活分支的结构，不复制事例，用于之后自行填充。
+ `CopyTree("px>0")`在复制时加入事例选择；`nentries`限制的是检查的输入事例数，并不保证输出恰好有这么多条。
+ `SetBranchStatus("*",0)`关闭所有分支；再用`SetBranchStatus("p*",1)`激活以`p`开头的分支，或用精确名称激活某一列。

分支默认激活；`status=1`表示激活，`0`表示停用。精简前必须明确要读、要计算、要保存哪些变量。存在拆分子分支时，还需核对具体分支名和通配符是否覆盖所需内容。

==== 只保留必要分支，并可加入cut

下面关闭所有列，再激活`px`、`py`、`pz`和`i`，去掉`random`。先打开输出文件，使新树属于输出文件：
```cpp
void copytree() {
    TFile oldfile("tree1.root");
    TTree* oldtree = nullptr;
    oldfile.GetObject("t1", oldtree);
    oldtree->SetBranchStatus("*", 0);
    for (auto name : {"p*", "i"})
        oldtree->SetBranchStatus(name, 1);
    TFile newfile("small.root", "RECREATE");
    auto newtree = oldtree->CloneTree();
    // 若还要筛选事例，改成：
    // auto newtree = oldtree->CopyTree("px>0");
    newtree->Print();
    newfile.Write();
}
```
`"p*"`在本例匹配三列，再加`"i"`，实际共保留四个Branch。`CloneTree()`这一行保留全部事例，只有换成`CopyTree("px>0")`才会同时进行cut。输入树与输出树的地址存在联系，复制和填充期间应保持输入树、文件与绑定变量有效。

== 使用RDataFrame分析数据

=== 从事件循环到声明式分析

// 第五讲来源：第23—25页。
传统的`TTree`分析需要设置变量地址、逐事例调用`GetEntry()`、执行选择并填充统计量。分析变量增多后，重复的读入与循环代码也会增多；分支名、变量类型和地址不匹配，或漏读某个事例，都可能使结果出错。手动并行还需要处理线程之间的数据共享。

`RDataFrame`提供更高层的声明式分析接口。先说明需要哪些列、怎样筛选、怎样计算新量及产生什么结果，再由ROOT组织事件循环与数据读取。它可以处理`TTree`、CSV等数据源，C++和Python使用的主要接口相近。

一个分析通常包含三个环节：
+ *指定数据源*：创建`RDataFrame`。
+ *描述变换*：用`Filter()`选择事例，用`Define()`添加计算得到的新列。
+ *产生结果*：填直方图、计数、计算统计量，或把处理后的列写入文件。

例如，若输入树有`x`、`y`两列，选择$y>2$并画出$x$：
```cpp
ROOT::RDataFrame d("myTree", "file.root");
auto h = d.Filter("y > 2").Histo1D("x");
h->Draw();
```
`Filter()`和`Define()`返回分析图中的新节点，原来的节点仍可继续用于另一条分析路径。只调用`df.Define(...)`而不保存返回值，也不在其后继续链式操作，不会使原来的`df`自动多出新列。

已定义好的C++函数也可以作为操作的参数。假设`IsGoodEvent`和`DoStuff`接收的参数分别对应列`A`、`B`、`C`，可以写成：
```cpp
ROOT::RDataFrame d("myTree", "file.root", {"A", "B", "C"});
d.Filter(IsGoodEvent).Foreach(DoStuff);
```
最后一个参数提供默认列列表；也可以在相应操作中显式给出需要的列名。`Foreach()`用于逐事例执行用户操作，会立即触发事件循环。

=== 用10个事例创建一个TTree

// 第五讲来源：第26页。
`RDataFrame`不仅能读取已有文件，也能从给定的事例数出发生成数据：
```python
import ROOT

def fill_tree(tree_name, file_name):
    d = ROOT.RDataFrame(10)
    d.Define("b1", "static_cast<double>(rdfentry_)") \
     .Define("b2", "static_cast<int>(rdfentry_ * rdfentry_)") \
     .Snapshot(tree_name, file_name)

file_name = "df001_introduction_py.root"
tree_name = "myTree"
fill_tree(tree_name, file_name)
```
`10`表示有10个entries，编号为0到9。`rdfentry_`是框架提供的当前entry编号；旧名称`tdfentry_`仍是兼容别名。这里得到$b_1=i$、$b_2=i^2$，两列分别保存为双精度数和整数。

`Define()`的字符串表达式使用*C++语法*，即使外层脚本用Python编写也是如此。表达式经Cling即时编译，能够引用列名、数学函数和可见的C++函数；不能把所有`TTree::Draw()`专用语法不加转换地搬进来。

`Snapshot(tree_name, file_name)`把结果写入ROOT文件；当前例子得到一个含`b1`、`b2`的树。`Define()`自身只描述计算过程，并不自动把新列写回输入文件。

=== 惰性执行与共享事件循环

// 第五讲来源：第27页。
`Filter()`、`Define()`用于建立计算图。`Histo1D()`、`Count()`、`Mean()`等多数结果操作是*惰性动作*：调用时先登记任务，第一次访问结果时才运行事件循环。

假设另一个数据集含有`MET`和`pt_v`两列：
```cpp
ROOT::RDataFrame d("treeName", "file.root");
auto h1 = d.Filter("MET > 10.").Histo1D("pt_v");
auto h2 = d.Histo1D("pt_v");
h1->Draw();
h2->Draw("SAME");
```
前两次`Histo1D()`登记直方图任务。访问`h1`时，同一计算图中已登记的两个任务一起执行；访问已经得到的`h2`不需要重跑事件循环。*要让多个结果共享一次循环，应先登记所有任务，再访问任意一个结果。* 不同数据源创建的独立计算图不会因此自动合并。

C++中常用解引用或`->`访问结果；Python中可调用`GetValue()`取得具体数值。若先取出一个结果，再新建另一个动作，后者通常需要新的事件循环。`GetNRuns()`可用于检查已经运行的循环次数。

#block(breakable: false)[
  #note(subname: [补充：并非所有动作都是惰性的])[
    `Snapshot()`默认立即运行并写文件，`Foreach()`也立即执行。需要把文件输出和其他结果合并到同一次循环时，可以先登记其他惰性动作，再调用`Snapshot()`；也可以把`ROOT::RDF::RSnapshotOptions`中的`fLazy`设为`true`，并保留`Snapshot()`返回的结果句柄，随后由结果访问触发执行。
  ]
]

=== 开启隐式多线程

// 第五讲来源：第27页。
在创建`RDataFrame`之前开启隐式多线程，框架就可以把可并行的工作分配给多个线程：
```cpp
ROOT::EnableImplicitMT(4);
ROOT::RDataFrame d("myTree", "file_*.root");
auto myHisto = d.Histo1D("Branch_A");
myHisto->Draw();
```
这里请求使用4个工作线程，不等于保证正好占用4个独立物理核，也不保证运行时间缩短为四分之一；实际速度受数据规模、I/O和每个事例的计算量影响。

用户在`Define()`、`Filter()`、`Foreach()`中提供的函数仍需满足并发安全要求。简单的无副作用表达式通常容易满足；共享一个可变计数器或随机数发生器则需要额外处理，可以使用按slot分离的状态及`DefineSlot()`等接口。

多线程处理不保证输出事例保持原始顺序，`Snapshot()`、`Take()`和`AsNumpy()`均不能据此默认逐行对齐。需要追踪事例时，应保留稳定的事例标识；不能把多线程输出的行号直接作为原树的友元匹配依据。

=== 核心操作速查

// 第五讲来源：第28页。
下表使用Python调用形式；C++使用相应的命名空间、初始化列表和`->`访问结果。

#figure(three-line-table[
  | 方法 | 作用与典型调用 |
  | --- | --- |
  | `Define()` | `Define("pt", "sqrt(px*px+py*py)")`，定义新列 |
  | `Filter()` | `Filter("pt > 0.5 && abs(eta) < 2.5")`，选择事例 |
  | `Histo1D()` | `Histo1D(("h","",100,0,5), "pt")`，一维直方图 |
  | `Histo2D()` | `Histo2D(model, "x", "y")`，二维直方图 |
  | `Count()` | `Count().GetValue()`，得到通过选择的事例数 |
  | `Mean()`、`Sum()` | `Mean("pt").GetValue()`等，求均值或总和 |
  | `Snapshot()` | `Snapshot("t1", "output.root")`，写出处理后的列 |
  | `Report()` | `Report().Print()`，打印已命名筛选的通过情况 |
  | `AsNumpy()` | `AsNumpy(["px","py"])`，取得以列名为键的NumPy字典 |
])

`model`给出直方图的名称、标题、bin数和范围等设置；`Histo2D(model,"x","y")`的列参数顺序为横轴、纵轴。`eta`必须是已有或先前定义的列。`AsNumpy()`会把所选结果带入内存，仍需考虑数据规模。

=== 从不同数据源创建RDataFrame

// 第五讲来源：第29页。
从一个文件中的树创建分析框架，可以直接指定树名和文件名，也可以使用已经打开的文件或树：
```cpp
TFile file("tree1.root", "READ");
TTree* tree = nullptr;
file.GetObject("t1", tree);

ROOT::RDataFrame d1("t1", "tree1.root");
ROOT::RDataFrame d2("t1", &file);
ROOT::RDataFrame d3(*tree);
```
后两种方式使用外部对象时，应先确认文件打开成功、`tree`非空，并在结果计算结束前保持相关对象有效。

多个文件可以用文件列表、通配符或`TChain`描述：
```cpp
ROOT::RDataFrame d4("t1", {"file1.root", "file2.root"});
std::vector<std::string> files = {"file1.root", "file2.root"};
ROOT::RDataFrame d5("t1", files);
ROOT::RDataFrame d6("t1", "file*.root");

TChain chain("t1");
chain.Add("file1.root");
chain.Add("file2.root");
ROOT::RDataFrame d7(chain);
```
这些文件应包含名称及所需列结构相容的树。通配符只应匹配计划分析的文件，避免把同目录下刚生成的精简文件或其他样本再次读入。

对于带表头的CSV文件，当前接口为：
```cpp
auto csv = ROOT::RDF::FromCSV("input.csv");
```
Python对应`ROOT.RDF.FromCSV("input.csv")`，C++使用时可包含`<ROOT/RCsvDS.hxx>`。旧接口名称为`MakeCsvDataFrame()`，ROOT 6.28起改名，6.30起已移除旧名称。

=== Filter命名与筛选效率

// 第五讲来源：第30页。
读取前面生成的10个事例，为选择条件命名并打印报告：
```python
d = ROOT.RDataFrame("myTree", "df001_introduction_py.root")
filtered1 = d.Filter("b1 > 25", "Cut1")
all_cuts_report = d.Report()
all_cuts_report.Print()
```
`"Cut1"`是筛选名称，便于识别报告中的每一级cut。这个最小数据集的`b1`只有0到9，因此该选择通过数为0；通过率取决于实际输入数据，不能把另一组样本的报告直接套用。

报告通常给出`pass`、`all`、局部效率和累计效率。若某一级cut处理了25个事例、通过23个，则该级效率为$23/25=92%$；若原始样本共有50个事例，且这23个是整条筛选链最后留下的事例，累计效率为$23/50=46%$。两种分母对应不同问题。

对根节点调用`Report()`可取得计算图中已登记的命名筛选信息；对某个筛选节点调用，则取得从根节点到该节点这一条分析路径上的命名筛选报告。Python使用`cut.Report().Print()`，C++使用`cut.Report()->Print()`，*两种语言都支持筛选报告*。

=== 计数、最大值、最小值与均值

// 第五讲来源：第31页。
多个选择可以顺次应用。下面相当于对同时满足两个条件的事例计数：
```python
cutb1 = "b1 < 5."
cutb1b2 = "b2 % 2 && b1 < 4."
entries1 = d.Filter(cutb1).Filter(cutb1b2).Count()
print("entries passed all filters:", entries1.GetValue())
```
`b2 % 2`是C++表达式，非零时作为真值，因此选出奇数`b2`。在$b_1=i$、$b_2=i^2$的10个事例中，通过的编号为1、3，事例数为2。

对筛选后的列可以继续求统计量：
```python
selected = d.Filter(cutb1b2)
min_val = selected.Min("b1")
max_val = selected.Max("b1")
mean_val = selected.Mean("b1")
mean_b2 = selected.Mean("b2")
print(min_val.GetValue(), max_val.GetValue())
print(mean_val.GetValue(), mean_b2.GetValue())
```
这里结果依次为1、3、2、5。四个动作先登记，再访问结果，可共享一次事件循环；`Min()`等返回结果句柄，`GetValue()`取得数值。代码中的`entries1`和这四个动作若也都在首次访问前登记，可进一步共享同一计算图的一次循环。

=== 增加新变量、筛选并只保存必要列

// 第五讲来源：第32页。
对`tree1.root`中的`t1`选择$p_x>=0$，定义
$ p=sqrt(p_x^2+p_y^2+p_z^2), $
并只写出`px`、`py`、`pz`、`i`及新列`p`：
```python
import ROOT

df = ROOT.RDataFrame("t1", "tree1.root")
cut = df.Filter("px >= 0", "px>=0")
with_p = cut.Define("p", "sqrt(px*px + py*py + pz*pz)")
count = cut.Count()
report = cut.Report()
with_p.Snapshot("t1", "newtree_rdf.root",
                ["px", "py", "pz", "i", "p"])
report.Print()
print("done:", count.GetValue(), "entries")
```
这里先登记计数与报告，再由`Snapshot()`触发循环，输出、计数和报告一起得到。若在`Snapshot()`完成之后才新建`Count()`，计数通常还需要再运行一次循环。

指定列名列表可以同时达到减少Branch和保留新变量的目的。输入文件保持不变，输出文件只包含筛选后的事例与指定列；默认输出模式为`RECREATE`，重复运行会覆盖同名输出文件，因此使用独立的输出文件名。

前面构造的教学样本中，名为`pz`的列实际定义为`px*px+py*py`，并不是独立抽样的第三个动量分量。因此这里的`p`首先是演示列运算，不能把该样本误认为三维各向同性动量样本。

=== 同一任务的TTree循环版本

// 第五讲来源：第33页；补齐头文件与写文件步骤。
同一筛选和新列计算也可以使用`CloneTree(0)`及显式事件循环完成：
```cpp
#include <TFile.h>
#include <TTree.h>
#include <cmath>

void addvarreduce() {
    TFile input("tree1.root", "READ");
    TTree* t1 = nullptr;
    input.GetObject("t1", t1);
    Float_t px, py, pz, p;
    t1->SetBranchStatus("*", 0);
    t1->SetBranchStatus("p*", 1);
    t1->SetBranchStatus("i", 1);
    t1->SetBranchAddress("px", &px);
    t1->SetBranchAddress("py", &py);
    t1->SetBranchAddress("pz", &pz);

    TFile output("newtree_loop.root", "RECREATE");
    auto t2 = t1->CloneTree(0);
    t2->Branch("p", &p, "p/F");
    for (Long64_t entry = 0; entry < t1->GetEntries(); ++entry) {
        t1->GetEntry(entry);
        if (px < 0) continue;
        p = std::sqrt(px*px + py*py + pz*pz);
        t2->Fill();
    }
    t2->Write();
}
```
`CloneTree(0)`只复制激活Branch的结构，不复制事例。克隆树与原树的Branch地址保持关联，所以读取原树一个entry后，`t2->Fill()`可把原有激活列连同新列`p`一起写出。`i`也会随克隆树复制，不必用循环变量冒充原始事例编号。

两个实现表达相同的数据处理流程：先选择$p_x>=0$的事例，计算`p`，再保存所需列。比较结果时应检查通过数、列名和各事例的数值；多线程输出还应通过稳定的事例标识匹配，而不只比较行号。

接口参考：#link("https://root.cern.ch/doc/master/classROOT_1_1RDataFrame.html")[RDataFrame参考与执行模型]、#link("https://root.cern.ch/doc/master/df001__introduction_8py.html")[RDataFrame基础示例]、#link("https://root.cern.ch/doc/v630/release-notes.html")[CSV接口名称变更]。

== 用TChain连接多个文件

// 第五讲来源：第34—36页；第34页为流程提示。
实验数据常分散在许多ROOT文件中。若各文件中树的名称、所需分支结构和类型相容，可以用`TChain`把它们逻辑连接起来，像一棵大树一样分析：
```cpp
void exChain() {
    TChain chain("t1");
    chain.Add("Lec5/tree*.root");
    chain.Draw("px");
}
```
构造函数中的`"t1"`是树名，不是ROOT文件名。`Add()`支持文件通配符；链中总事例数是成功加入的各棵树的事例数之和。应检查匹配到的文件，避免把原始样本和它的复制文件重复计入。

`TChain`只是建立统一的读取入口，并未自动生成一个合并后的物理文件。它可使用`GetEntries()`、`Draw()`等与`TTree`相似的接口，也可作为`RDataFrame`的数据源。

若树保存在ROOT文件内部的`subdir`目录下，常用写法是：
```cpp
TChain chain("subdir/t1");
chain.Add("rootfiles/*.root");
```
也可以在添加时明确树的内部路径：
```cpp
TChain chain;
chain.Add("rootfiles/*.root/subdir/t1");
// 单文件，不展开通配符：
chain.AddFile("another.root", TTree::kMaxEntries, "subdir/t1");
```
`file.root/subdir/t1`是ROOT支持的兼容路径表示。系统目录`rootfiles`、ROOT文件内部的`TDirectory`和树对象`t1`属于不同层次，不能因为都写成路径就把它们看作同一种目录。`AddFile()`只添加指定文件，不能用`*`代替逐文件添加。

== 自动生成TTree分析框架

=== MakeClass与生成文件

// 第五讲来源：第37页。
树结构复杂时，手写全部Branch地址较繁琐。`MakeClass()`可以根据树结构生成类声明、变量、Branch绑定和分析循环骨架。

例如打开含有树`T`的`htree.root`后，在ROOT中运行：
```cpp
auto input = TFile::Open("htree.root");
input->ls();
TTree* tree = nullptr;
input->GetObject("T", tree);
tree->MakeClass();
// 或指定生成类名：
tree->MakeClass("AnaFrame");
```
默认生成与树同名的`T.h`、`T.C`；指定`"AnaFrame"`则生成`AnaFrame.h`和`AnaFrame.C`。这一步解决读树的重复代码，具体物理分析仍需补进`Loop()`。

=== 成员函数与Loop结构

// 第五讲来源：第38页。
生成类中的主要成员函数为：
```cpp
virtual Int_t    Cut(Long64_t entry);
virtual Int_t    GetEntry(Long64_t entry);
virtual Long64_t LoadTree(Long64_t entry);
virtual void     Init(TTree* tree);
virtual void     Loop();
virtual Bool_t   Notify();
virtual void     Show(Long64_t entry = -1);
```
`Init()`设置输入树及Branch地址；`LoadTree()`定位事例及当前文件；`Notify()`用于输入树或文件切换时的通知；`GetEntry()`读取数据；`Show()`检查一个事例；`Cut()`提供选择接口；`Loop()`组织分析。

典型循环的结构为：
```cpp
Long64_t nbytes = 0, nb = 0;
for (Long64_t jentry = 0; jentry < nentries; ++jentry) {
    Long64_t ientry = LoadTree(jentry);
    if (ientry < 0) break;
    nb = fChain->GetEntry(jentry);
    nbytes += nb;
    // if (Cut(ientry) < 0) continue;
    // 在这里增加选择、计算与填图。
}
```
对于`TChain`，`jentry`是整条链的全局编号，`LoadTree(jentry)`返回当前子树中的局部编号`ientry`。通过链本身调用`fChain->GetEntry()`仍使用全局编号；若直接读取当前子树或其Branch，才使用局部编号，不能混用。

编辑好`AnaFrame.C`中的分析内容后，可以编译加载并运行：
```cpp
.L AnaFrame.C+
AnaFrame analysis(tree);
analysis.Loop();
```
`.L`加载文件，末尾的`+`使用ACLiC编译。对整条链分析时，应在`TChain`上生成与运行框架，使其能考察全部输入文件，而不只依照第一棵树的结构或数组容量。

文件与生成对象的生命周期仍需留意。默认生成类的析构函数可能会删除当前输入文件，因此应检查生成代码的所有权约定，避免同时让另一个对象重复关闭或删除同一文件。

== 数据存储与分析流程小结

// 第五讲来源：第39页；第40页为空白分隔页。
+ `TTree`保留逐事例数据与变量间的对应关系；Branch的名称、类型和地址共同决定数据怎样读写。
+ `Fill()`保存一个事例，`Write()`保存树；读取时先取得entry，再使用被更新的变量。
+ 精简数据分别考虑“留下哪些列”和“留下哪些事例”。`CloneTree(0)`便于自行添加列与填充，`CopyTree()`可直接加入cut。
+ `RDataFrame`用数据源、变换和动作表达分析；预先登记多个惰性结果，可让它们共享一次事件循环。
+ `TChain`连接多文件，`MakeClass`生成读取骨架；它们并不代替对样本、类型和分析逻辑的核查。

通过`Snapshot()`保存中间结果，可以把数据准备、选择与后续统计分析连起来。进一步的工具包括用于统计建模和推断的RooFit／RooStats，以及用于BDT、神经网络等多变量分析的TMVA。

== 补充：数组、vector与友元树

=== 不定长数组与固定长度数组

// 第五讲来源：第41页。
一个事例中的末态粒子数或重建径迹数可能不同，可用计数Leaf决定各事例实际保存的数组长度：
```cpp
const Int_t kMaxTrack = 50;
Float_t px[kMaxTrack], py[kMaxTrack], pz[kMaxTrack];
Double_t pv[3];
Int_t ntrack;
TFile file("tracks.root", "RECREATE");
TTree t3("t3", "Reconst events");
t3.Branch("ntrack", &ntrack, "ntrack/I");
t3.Branch("px", px, "px[ntrack]/F");
t3.Branch("py", py, "py[ntrack]/F");
t3.Branch("pz", pz, "pz[ntrack]/F");
t3.Branch("pv", pv, "pv[3]/D");
```
`pv[3]/D`每个事例保存3个双精度数；`px[ntrack]/F`则只保存当前`ntrack`个单精度数。作为数组长度的计数Leaf应使用`Int_t`，并先定义该计数Branch。

每个事例中应先确定`ntrack`，检查$0<=n_("track")<=50$，再给`px`、`py`、`pz`的前`ntrack`个元素及`pv`赋值，最后调用`t3.Fill()`。数组上限50是程序分配的容量，并不意味着ROOT会替程序截断超出的数据。

读取进固定数组时同样必须核对容量；可能超限的未知文件，不能等数组已经读入后才检查`ntrack`。可以先读计数并核查，再读取对应数组，或使用适合该数据结构的动态容器和读取接口。

=== 把std::vector存入TTree

// 第五讲来源：第42页。
STL容器可以直接作为Branch对象。下面每个事例存放0到14个浮点数，共生成25000个事例：
```cpp
std::vector<float> vpx;
TTree t("tvec", "Tree with vectors");
t.Branch("vpx", &vpx);
for (Int_t i = 0; i < 25000; ++i) {
    Int_t npx = static_cast<Int_t>(gRandom->Rndm()*15);
    vpx.clear();
    for (Int_t j = 0; j < npx; ++j) {
        Float_t px, py;
        gRandom->Rannor(px, py);
        vpx.push_back(px);
    }
    t.Fill();
}
t.Write();
```
使用时包含`<vector>`及相应ROOT头文件，并先创建输出`TFile`。每个事例开始必须`clear()`，否则当前事例会把上一个事例的数据一起保存。容器能随元素个数变化，避免自行固定每个事例的最大数组长度；Branch所绑定的`vpx`对象仍需在填充期间有效。

=== AddFriend：访问另一棵树中的列

// 第五讲来源：第43页。
友元树（friend tree）可以把另一棵树中的变量引入当前分析，而不必把两棵树的所有Branch物理复制到一个文件中。

#figure(
  image("pic/chap4-lab/ttree-friends.png", width: 100%),
  caption: [主树和友元树的变量访问关系，以及按entry逐行对应的示意。],
)

默认顺序对应模式下，主树的第$i$个事例与友元树的第$i$个事例对应。因此友元树至少应覆盖要分析的全部主树事例，*更关键的是顺序和事例身份一致*；条数相同并不能保证对应正确。若经过筛选或重排，应使用共同的事件标识与合适的索引匹配，不能依赖新文件的行号。

=== 单独保存新变量，再连接分析

// 第五讲来源：第44页。
下面为主树的每个entry生成一个新高斯变量，保存为友元树；新变量只是演示补充列的访问方式：
```cpp
void tree1Addnew() {
    TFile file("tree1.root");
    TTree* t1 = nullptr;
    file.GetObject("t1", t1);
    const Long64_t nentries = t1->GetEntries();
    TFile friendfile("tree1f.root", "RECREATE");
    TTree t1f("t1f", "a friend Tree");
    Float_t new_v;
    t1f.Branch("new_v", &new_v, "new_v/F");
    gRandom->SetSeed(43);
    for (Long64_t i = 0; i < nentries; ++i) {
        new_v = gRandom->Gaus(0, 1);
        t1f.Fill();
    }
    t1f.Write();
}
```
如果新变量要由原事例计算，循环中还须先调用`t1->GetEntry(i)`，再从相应的原变量求出新值。完成写入后，另一次分析可以这样连接并作图：
```cpp
TFile file("tree1.root");
TTree* t1 = nullptr;
file.GetObject("t1", t1);
t1->AddFriend("t1f", "tree1f.root");
t1->Draw("t1f.new_v:px", "t1f.new_v>0");
```
`"t1f.new_v"`中的前缀指明变量来自哪棵树，避免同名变量混淆。这里横轴是主树的`px`，纵轴是友元树的`new_v`，选择条件也可以使用友元变量。调用`AddFriend()`只建立访问关系，并不自动核查物理事例是否匹配。

=== 配套示例与实际核对

为本节准备的完整示例位于`examples/lecture5/`。在该目录运行`bash run.sh`，即可重新生成树和图，分别执行C++与Python读写，检查传统循环与`RDataFrame`，并验证`TChain`、`MakeClass`、数组与友元访问。

#let tree-results = json("examples/lecture5/results.json")
#let tree-f(value, digits: 6) = str(calc.round(value, digits: digits))
#block(sticky: true)[固定种子42、5000个事例的实际统计为：]
#figure(three-line-table[
  | 统计量 | 理论期望 | 本次结果 |
  | --- | --- | --- |
  | $p_x$均值 | 0 | #tree-f(tree-results.mean_px) |
  | $p_x$样本标准差 | 接近1 | #tree-f(tree-results.sample_std_px) |
  | $p_z=p_x^2+p_y^2$均值 | 2 | #tree-f(tree-results.mean_pz) |
  | $p_x>=0$通过数 | 约2500 | #tree-results.selected_px_nonnegative |
  | $p_x>=0$通过率 | 约50% | #tree-f(tree-results.selection_efficiency * 100, digits: 2)% |
])

这些是有限样本的结果，不要求恰好等于总体参数。传统循环和`RDataFrame`得到的直方图逐bin一致；筛选后的五列及新变量也在浮点精度允许的范围内一致。RDataFrame计算图在访问结果前运行次数为0，所有已预订结果取得后运行次数为1。

#figure(
  image("pic/chap4-lab/rdf-comparison.png", width: 85%),
  caption: [对同一输入使用传统循环与RDataFrame得到的直方图；逐bin内容相同，包括上、下溢出。],
)

配套验证中的两文件`TChain`得到10000个事例；友元示例使用`new_v=2*px`核查全部5000条逐事例对应关系。它与上面的独立高斯友元列是两个用途不同的示例。

接口参考：#link("https://root.cern.ch/doc/master/classTTree.html")[TTree及I/O接口]、#link("https://root.cern.ch/doc/master/classTTreeFormula.html")[树表达式]、#link("https://root.cern.ch/doc/master/classTChain.html")[TChain与路径处理]。
