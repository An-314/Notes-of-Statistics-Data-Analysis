#import "@preview/scripst:1.1.2": *

#pagebreak(weak: true)
#show figure: set block(breakable: true)

= ROOT数据分析入门（一）

// 来源：第1—3、18页。
本章内容：
- ROOT的用途、基本模块与使用环境
- C++交互命令、宏文件与PyROOT
- 图形类`TGraph`、`TGraphErrors`
- 随机数、随机种子与`gRandom`
- 直方图、ROOT文件的写入和读取
- 数学函数、参数设置与数据拟合

*学习目标*：能够把数据组织成图形或直方图，使用随机数生成模拟样本，定义模型函数并拟合数据，将分析对象与图像保存下来。

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

#block(breakable: false)[
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
]

#figure(image("pic/chap4-lab/myfit-refined.png", width: 80%), caption: [同一组2500个事例更换初值后的拟合结果。])

#block(breakable: false)[
  #note(subname: [补充：形状参数与归一化])[
    生成随机数时，`FillRandom()`按函数的归一化形状抽样；拟合的对象则是每个bin内的计数。因此，即使形状相同，拟合振幅也不必等于生成函数的振幅2。

    对等宽bin，期望计数近似为$N (Delta x f(x)) / (integral f(x) dif x)$。比较生成值与拟合值时，应先区分函数形状、概率密度和每bin期望计数。对较低计数，泊松似然拟合往往比简单的$chi^2$近似更合适，需要按实际问题选择拟合目标。
  ]
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

== 本章小结

// 来源：第39页；第40—51页的复习内容已合并到相应主题。
+ ROOT把数据处理、存储、图形与统计分析组织为可组合的C++类，并通过PyROOT提供Python接口。
+ `TGraph`描述给定坐标点，`TGraphErrors`加入测量误差；直方图则按bin累加事例或权重。
+ 随机种子决定伪随机序列的可重复性，正式分析同样需要记录随机数配置。
+ `TFile`保存可重新分析的对象，画布的`SaveAs()`保存图像；两者作用不同。
+ `TF1`等类把表达式、参数和数值计算组织起来，`Fit()`用数据估计参数。拟合结果需要结合归一化、误差、状态和物理意义解释。
