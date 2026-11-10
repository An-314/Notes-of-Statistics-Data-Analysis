#import "@preview/scripst:1.1.2": *

#pagebreak(weak: true)

#show figure: set block(breakable: true)

= 粒子物理模拟（二）

// 第七讲 lecture_7_Simulation2_v3.pdf，第1-3页。
本章内容
- Geant4的用途、软件组成及学习资料
- Conda环境和源代码安装
- B1示例的构建、运行和主程序
- 用户探测器类与C++多态
- 几何体、逻辑体和物理体
- 层状量能器、复制与参数化排布
- 几何重叠、布尔运算与GDML导入

*学习目标*是把截面、自由程和粒子输运原理落实到一个Geant4应用中，能够读懂基本示例的运行流程，并使用材料与几何层次描述一个简单探测器。

== 从输运原理到Geant4应用

=== 粒子输运的五个环节

// 来源第2页。
单一过程的平均自由程满足
$ lambda=1/(n sigma) $
在恒定发生率下，首次作用路程服从指数分布，可以用
$ L=-lambda ln U, quad U~op("Uniform")(0,1) $
抽样。存在多个离散过程时，各过程分别提出候选距离，最近的作用决定下一步的终点与过程类型。

完整模拟还要同时处理沿程能损、Cherenkov光产额、几何边界和次级粒子。几何边界可以先于候选碰撞限制步长，产生的次级粒子则要进入后续跟踪集合。实际程序需要把这些操作与物理模型、数据和几何导航组合起来，Geant4提供了相应的工程框架。

=== 工具包与用户应用

// 来源第4-8页。
GEANT取自GEometry ANd Tracking，Geant4项目始于1994年，主要使用C++。它提供粒子穿过物质时的输运与相互作用工具，应用涉及高能物理、核物理、空间科学、医学物理、材料科学、辐射防护和安全等领域。

可使用的模型覆盖电磁过程、强子过程、光核和轻核相关过程，以及光学光子的传播与相互作用。具体过程与适用能区由所选物理模型和Physics List决定。

构建应用时，通常从一个接近研究目标的示例出发，修改*用户应用的源文件*，加入所需几何、材料、粒子源和数据记录。宏命令负责运行时配置。示例程序已经实现的功能可以直接利用，新增功能则通过用户类和接口完成。

模拟会追踪粒子及其次级粒子的*产生、传播和终止*，并记录敏感区域中的*能量沉积、时间和空间分布*，再据此计算*探测器响应*。已知微观相互作用模型以后，探测效率和能量分辨率仍受探测器结构、材料与分析选择的共同影响。

#block(breakable: false)[
  #exercise(subname: [辨认电子与中子的相互作用])[
    观察电子和中子穿过分层探测器的过程，说明可以从哪些轨迹与次级粒子特征辨认入射粒子。
  ]
]

#figure(
  grid(
    columns: (1fr, 1fr),
    gutter: 12pt,
    image("pic/chap6-lab/interaction-left.png", width: 100%), image("pic/chap6-lab/interaction-right.png", width: 100%),
  ),
  caption: [两种入射过程的可视化起始帧。后续的相互作用、带电次级粒子及能量沉积用于比较不同粒子的响应。],
)

电子可以产生电离、多重散射和电磁级联，中子则通过与原子核的散射或核反应产生反冲及次级粒子。可视化中应结合粒子标识、过程名称和颜色图例分析这些现象。

=== 软件许可与科学引用

// 来源第9-10页。许可说明按Geant4官方文本核对。
Geant4按其软件许可证允许安装、使用、修改和再分发。再分发需要保留版权及许可声明，修改版本应清楚标明其身份，使用软件时应遵守归属和名称使用条件。许可证同时说明软件按现状提供，包含担保与责任限制。

科学出版物中应说明所用的Geant4版本、物理配置及相关模型，并按项目建议引用相应论文。基础参考文献包括
- S. Agostinelli等，*Geant4 - A Simulation Toolkit*，Nuclear Instruments and Methods A 506 (2003) 250-303。
- J. Allison等，*Geant4 Developments and Applications*，IEEE Transactions on Nuclear Science 53 (2006) 270-278。
- J. Allison等，*Recent Developments in Geant4*，Nuclear Instruments and Methods A 835 (2016) 186-225。

具体使用和再分发条件见#link("https://geant4.web.cern.ch/license/license")[Geant4软件许可证]。

== 安装环境与查找帮助

=== 使用Conda环境

// 来源第11页。
可以在一个独立环境中安装ROOT、Python、Geant4、CMake和Expat等依赖，示例命令为
```sh
conda create -c conda-forge --name hepnew \
  root python geant4 cmake expat -y
conda activate hepnew
```
`-c conda-forge`指定软件源，`--name hepnew`指定环境名，`-y`自动确认环境创建。具体可获得的版本取决于平台、软件源和依赖求解结果。需要固定环境时，应记录实际解析出的版本。

查看和退出环境使用
```sh
conda env list
conda deactivate
```
Geant4示例通常可从安装的共享目录或源代码发行包中取得。B1目录若随当前安装提供，可先检查
```sh
ls "$CONDA_PREFIX/share/Geant4/examples/basic/B1"
```
不同发行方式的共享目录布局可能不同，实际路径以该环境的安装内容为准。源代码包也提供`examples/`目录。

=== 从源代码构建

// 来源第12页。
下面以11.4.3版本号说明目录和构建步骤。https://geant4.web.cern.ch/support/download 。把`/YourPath`换为实际工作路径，并使源代码、构建目录和安装目录彼此分开。
```sh
cd /YourPath
tar -xzf geant4.11.4.3.tar.gz
cmake -S /YourPath/geant4.11.4.3 \
  -B /YourPath/geant4.11.4.3-build \
  -DGEANT4_USE_OPENGL_X11=ON \
  -DGEANT4_USE_QT=ON \
  -DGEANT4_INSTALL_DATA=ON \
  -DGEANT4_USE_SYSTEM_EXPAT=OFF \
  -DCMAKE_INSTALL_PREFIX=/YourPath/geant4.11.4.3-install
cmake --build /YourPath/geant4.11.4.3-build --parallel 4
cmake --install /YourPath/geant4.11.4.3-build
```
归档文件名和解压后的顶层目录名随下载方式而变化，例如也可能带有`v`前缀，命令中的路径要与实际名称一致。Shell续行符`\`应位于行末，说明文字放在独立注释行。

#figure(three-line-table[
  | 配置项 | 作用 |
  | --- | --- |
  | `GEANT4_USE_OPENGL_X11` | 启用相应的X11/OpenGL可视化驱动 |
  | `GEANT4_USE_QT` | 启用Qt用户界面和相应可视化支持 |
  | `GEANT4_INSTALL_DATA` | 在构建安装流程中下载并安装所需物理数据集 |
  | `GEANT4_USE_SYSTEM_EXPAT` | 选择系统Expat或随包提供的Expat |
  | `CMAKE_INSTALL_PREFIX` | 指定最终安装前缀 |
])

Qt与X11依赖需要与操作系统及Geant4版本匹配。例如在相应Debian／Ubuntu环境中，开发包可能包括
```sh
sudo apt install qtbase5-dev libx11-dev libxmu-dev
```
这里给出的是Qt 5相关开发包示例，具体版本要求应核对所安装版本的安装指南。图形界面支持与物理数据集都是构建配置的一部分，运行例子时也要具备该例子所需的数据文件。

=== 激活安装与定位依赖

// 来源第13-14页。
Bash等兼容Shell中，可加载安装前缀内的环境脚本
```sh
source /YourPath/geant4.11.4.3-install/bin/geant4.sh
```
`tcsh`使用对应脚本
```tcsh
source /YourPath/geant4.11.4.3-install/bin/geant4.csh
```
频繁使用时，可将适合自身Shell的环境设置放入启动文件。Conda环境则先完成相应Shell的Conda初始化，再运行`conda activate hepnew`。

在Conda中构建应用，如果CMake找不到环境里的依赖库，可显式给出环境前缀
```sh
cmake -S . -B build -DCMAKE_PREFIX_PATH="$CONDA_PREFIX"
cmake --build build --parallel 4
```
`CMAKE_PREFIX_PATH`提供查找软件包的前缀，有助于使Geant4、Expat等依赖来自同一环境。具体缺少的库或版本仍应根据CMake输出核对。

=== 文档、示例与代码搜索

// 来源第15页，第16页为后续内容提示。
#figure(three-line-table[
  | 资料 | 主要用途 |
  | --- | --- |
  | Application Developers Guide | 编写Geant4用户应用，查找几何、材料、物理与用户动作接口 |
  | Toolkit Developers Guide | 理解工具包内部架构及开发约定 |
  | Physics Reference Manual | 查看物理过程、模型、抽样方法与适用条件 |
  | Installation Guide | 核对编译器、依赖、构建选项及环境配置 |
  | `examples/`与LXR | 对照可运行应用，搜索类、构造函数和调用位置 |
])

官方主页及文档入口分别为#link("https://geant4.web.cern.ch/")[Geant4主页]和#link("https://geant4.web.cern.ch/docs")[文档目录]。代码可在#link("https://geant4.kek.jp/LXR/")[Geant4 LXR]中按类名、文件名或函数名搜索。查询接口时，尽量使文档、头文件和安装版本相互对应。

== 应用程序的组成

=== 各模块怎样配合

// 来源第17页。
Geant4应用将几类信息交给框架，再由运行管理器协调初始化与输运。

#figure(three-line-table[
  | 模块 | 典型类或入口 | 职责 |
  | --- | --- | --- |
  | 整体运行框架 | `G4RunManager`、`G4RunManagerFactory` | 初始化、管理run与event、协调各模块 |
  | 探测器几何 | Solid、LogicalVolume、PhysicalVolume | 描述形状、材料及放置层次 |
  | 材料 | `G4Material` | 提供组成、密度与相关属性 |
  | 物理配置 | `QBBC`、`FTFP_BERT`等Physics List | 注册粒子、过程及物理模型 |
  | 初始粒子 | `PrimaryGeneratorAction` | 生成事例的初级粒子 |
  | 输运内核 | tracking与stepping | 执行步长选择、状态更新与过程调用 |
  | 运行控制 | UI命令、宏和`BeamOn` | 设置参数并启动事例循环 |
  | 可视化 | `G4VisExecutive` | 显示几何、轨迹及相关信息 |
  | 用户动作 | Run、Event、Step等Action | 在运行、事例和步进阶段记录或处理数据 |
])

初始粒子、几何材料和物理过程共同确定模拟内容。用户动作提供数据记录与控制接口，能量沉积和轨迹等输出由用户应用选择保存。

=== C++多态与探测器接口

// 来源第18页。
框架通过抽象基类调用用户实现的派生类。例如`G4VUserDetectorConstruction`要求派生类实现`Construct()`，返回世界物理体。
```cpp
#include "G4VUserDetectorConstruction.hh"

class MyDetectorConstruction : public G4VUserDetectorConstruction {
public:
    G4VPhysicalVolume* Construct() override;
};
```
其抽象接口的关键声明是
```cpp
virtual G4VPhysicalVolume* Construct() = 0;
```
应用将派生类对象交给运行管理器。初始化期间，框架经基类接口调用`Construct()`，实际执行的是用户派生类中的函数体，这就是虚函数的动态分派。

=== 实例B1的项目结构

// 来源第19页。
基本示例B1包含主程序、头文件、用户类实现以及宏命令文件。常见目录结构为
```text
B1/
├── CMakeLists.txt
├── exampleB1.cc
├── include/
│   ├── ActionInitialization.hh
│   ├── DetectorConstruction.hh
│   ├── EventAction.hh
│   ├── PrimaryGeneratorAction.hh
│   ├── RunAction.hh
│   └── SteppingAction.hh
├── src/
│   └── 对应的用户类实现文件
├── init_vis.mac
├── vis.mac
├── run1.mac
└── run2.mac
```
`DetectorConstruction`提供探测器几何与材料，`PrimaryGeneratorAction`提供初始粒子，`ActionInitialization`创建并注册所需动作。`RunAction`、`EventAction`和`SteppingAction`则可以累计运行、事例与逐步信息。

这些类提供的功能随例子和版本而变化。阅读示例时，先从主程序观察对象怎样注册，再进入对应用户类查看实现。

==== 主程序的完整基本流程

// 来源第20-22页，补全头文件并保留B1命名空间。
下面按B1的组织方式列出主程序。`DetectorConstruction.hh`和`ActionInitialization.hh`来自B1用户应用。
```cpp
#include "DetectorConstruction.hh"
#include "ActionInitialization.hh"
#include "G4RunManagerFactory.hh"
#include "G4UIExecutive.hh"
#include "G4UImanager.hh"
#include "G4VisExecutive.hh"
#include "QBBC.hh"

using namespace B1;

int main(int argc, char** argv) {
    G4UIExecutive* ui = nullptr;
    if (argc == 1) {
        ui = new G4UIExecutive(argc, argv);
    }

    // 构造默认的运行管理器(强制)
    auto runManager = G4RunManagerFactory::CreateRunManager(
        G4RunManagerType::Default);
    // 初始化探测器模型
    runManager->SetUserInitialization(new DetectorConstruction());
    // 初始化物理模型
    runManager->SetUserInitialization(new QBBC());
    // 设置用户控制(包括初始粒子）
    runManager->SetUserInitialization(new ActionInitialization());
    // 设置可视化控制
    auto visManager = new G4VisExecutive(argc, argv);
    visManager->Initialize();
    // 设置G4和用户交互的管理器
    auto uiManager = G4UImanager::GetUIpointer();

    if (!ui) {
        // batch mode 批处理模式
        G4String command = "/control/execute ";
        G4String fileName = argv[1];
        uiManager->ApplyCommand(command + fileName);
    } else {
        // interactive mode 交互模式
        uiManager->ApplyCommand("/control/execute init_vis.mac");
        ui->SessionStart();
        delete ui;
    }
    // 结束作业(强制)
    delete visManager;
    delete runManager;
    return 0;
}
```

程序首先判断是否有命令行宏文件参数。没有额外参数时创建交互会话，有参数时执行指定宏。`G4RunManagerFactory`按安装配置及所选运行类型创建运行管理器，之后注册探测器、物理配置和用户动作，再初始化可视化。

`SetUserInitialization()`在这里完成*注册*。真正的内核初始化可通过宏中的`/run/initialize`触发，此时调用探测器构造及物理初始化。启动事例前，应使必要的用户初始化对象均已注册，并完成内核初始化。`/run/beamOn`用于执行所需数目的事例。

程序结束时，运行管理器管理的探测器描述、物理列表及相关用户动作随运行管理器清理。应用显式创建的UI和可视化管理对象按相应生命周期释放。

#block(breakable: false)[
  #note(subname: [注册次序与初始化次序])[
    示例依次注册探测器、Physics List和用户动作。Geant4在初始化阶段按照内核要求构造几何、材料和物理过程，因此应将“调用注册接口”与“执行对象初始化”区分开。
  ]
]

==== 编译与运行第一个例子

// 来源第23页。
在已经激活的环境中，把B1复制到自己的工作目录后构建
```sh
conda activate hepnew
mkdir -p Mypath
cd Mypath
cp -r "$CONDA_PREFIX/share/Geant4/examples/basic/B1" .
cmake -S B1 -B B1/build -DCMAKE_PREFIX_PATH="$CONDA_PREFIX"
cmake --build B1/build --parallel 4
cd B1/build
./exampleB1
```
这里的构建产物集中在`B1/build`中。使用源代码发行包时，可以把复制来源改成该发行包的`examples/basic/B1`。需要处理多个示例时，每个应用使用自己的构建目录，便于保持源文件与生成文件的对应关系。

批处理运行可指定宏文件
```sh
./exampleB1 run1.mac
```
宏文件中的典型控制命令包括
```text
/run/initialize
/gun/particle e-
/gun/energy 100 MeV
/run/beamOn 10
```
粒子源命令由应用实际提供的源类决定。可视化则还需要有效的图形驱动和相应宏设置。

#figure(image("pic/chap6-lab/b1-interface.png", width: 75%), caption: [B1基本示例的交互界面与几何显示。])

== 探测器构造与几何层次

=== DetectorConstruction的执行入口

// 来源第24-26页。
探测器构造类以普通的`public`继承实现`G4VUserDetectorConstruction`接口，`Construct()`使用`override`明确重写关系。一个按材料与几何拆分实现的类可以写成
```cpp
#include "G4VUserDetectorConstruction.hh"

class DetectorConstruction : public G4VUserDetectorConstruction {
public:
    DetectorConstruction() = default;
    ~DetectorConstruction() override = default;
    G4VPhysicalVolume* Construct() override;

private:
    void DefineMaterials();
    G4VPhysicalVolume* DefineVolumes();
};
```
```cpp
G4VPhysicalVolume* DetectorConstruction::Construct() {
    DefineMaterials();
    return DefineVolumes();
}
```
`DefineMaterials()`准备后面使用的材料，`DefineVolumes()`创建和放置几何体，最后返回最外层世界物理体`worldPV`。运行管理器在探测器初始化时调用这个入口。

#block(breakable: false)[
  #exercise(subname: [查找框架怎样调用用户函数])[
    在头文件中找到`G4VUserDetectorConstruction::Construct()`的声明，再搜索运行管理器初始化探测器时的调用位置。结合派生类的`override`说明实际执行的函数怎样确定。
  ]
]

=== Solid、LogicalVolume与PhysicalVolume

// 来源第27-28页。
复杂探测器由盒体、柱体、锥体、球体、环体等基本形状嵌套组合。Geant4把几何描述分为三个层次。

#figure(three-line-table[
  | 层次 | 典型类 | 保存的信息 |
  | --- | --- | --- |
  | 几何体Solid | `G4VSolid`及其派生类 | 形状、尺寸与自身局部坐标系 |
  | 逻辑体LogicalVolume | `G4LogicalVolume` | Solid、材料，以及可视化、敏感探测器等属性 |
  | 物理体PhysicalVolume | `G4VPhysicalVolume`及其派生类 | 逻辑体在母体中的位置、朝向和副本编号 |
])

同一个Solid可以与相应材料组合成逻辑体，同一个逻辑体也可以在几何层次中放置多次。放置的位置与朝向相对于*母逻辑体的坐标系*定义。

#figure(
  image("pic/chap6-lab/geometry-classes.png", width: 100%),
  caption: [Geant4几何描述的三个层次，以及材料、可视化和敏感探测器等属性与逻辑体的联系。],
)

=== 常见基本形状及参数

// 来源第29-30页，半径与半长术语按类接口核对。
#figure(
  grid(
    columns: (1fr, 1fr, 1fr, 1fr),
    // gutter: 7pt,
    [#align(center)[#image("pic/chap6-lab/solid-box.png", height: 100pt)\ `G4Box`]],
    [#align(center)[#image("pic/chap6-lab/solid-tubs.png", height: 100pt)\ `G4Tubs`]],
    [#align(center)[#image("pic/chap6-lab/solid-twisted-trd.png", height: 100pt)\ `G4TwistedTrd`]],
    [#align(center)[#image("pic/chap6-lab/solid-cons.png", height: 100pt)\ `G4Cons`]],

    [#align(center)[#image("pic/chap6-lab/solid-para.png", height: 100pt)\ `G4Para`]],
    [#align(center)[#image("pic/chap6-lab/solid-torus.png", height: 100pt)\ `G4Torus`]],
    [#align(center)[#image("pic/chap6-lab/solid-trap.png", height: 100pt)\ `G4Trap`]],
    [#align(center)[#image("pic/chap6-lab/solid-sphere.png", height: 100pt)\ `G4Sphere`]],
  ),
  caption: [用于构造探测器的若干基本几何形状。],
)

#figure(three-line-table[
  | 类 | 形状 | 主要几何参数 |
  | --- | --- | --- |
  | `G4Box` | 长方体 | $x,y,z$三个方向的半长 |
  | `G4Tubs` | 圆柱或圆筒区段 | 内半径、外半径、$z$半长、起始$phi$与$Delta phi$ |
  | `G4Cons` | 圆锥或圆台区段 | 负$z$端内外半径、正$z$端内外半径、$z$半长及方位角范围 |
  | `G4Sphere` | 球或球壳区段 | 内外半径，$phi$与$theta$各自的起始角和角范围 |
  | `G4Torus` | 圆环体 | 截面内外半径、环中心半径及方位角范围 |
  | `G4Para` | 平行六面体 | 三边半长及$alpha,theta,phi$三个角 |
  | `G4Trap` | 通用梯形台 | 半高、端面半长及角度参数，另有八顶点构造方式 |
  | `G4Trd` | 梯形台 | 两端面的$x$半长、两端面的$y$半长及$z$半长 |
])

长度参数的含义由具体类决定。`G4Box`的三个尺寸是半长，`G4Tubs`的`pDz`是半高，而`pRMin`和`pRMax`是半径。角度同样应带明确单位，例如`0.*deg`、`360.*deg`。具体参数顺序以对应版本的构造函数声明为准。

=== 世界体与相对坐标

// 来源第31页。
世界体World包含全部探测器及模拟所需的初始区域。子探测器放在World中，子探测器本身又可以作为下一层几何的母体，逐层构成包含关系。

对盒形母体，放置时的平移通常相对盒子的中心。若母体已经相对世界发生平移或旋转，子体的局部坐标还需通过层次变换才能得到世界坐标。

#figure(
  image("pic/chap6-lab/world-hierarchy.png", width: 42%),
  caption: [世界体包含多层子探测器，子体的位置按母体坐标系描述。],
)

=== 用B4a构造分层电磁量能器

==== 几何层次与尺寸关系

// 来源第32页。
B4a用交替的吸收体Absorber与间隙Gap组成一个Layer，再将多个Layer沿$z$方向排列成Calorimeter。整个量能器放在World内。

#figure(
  image("pic/chap6-lab/calorimeter.png", width: 90%),
  caption: [分层量能器的World、Calorimeter、Layer、Absorber与Gap层次。],
)

设吸收体厚度为$t_a$，Gap厚度为$t_g$，层数为$N$，则
$ t_("layer")=t_a+t_g, quad t_("calor")=N t_("layer") $
例如可以取10层、吸收体厚10 mm、Gap厚5 mm，横向全长10 cm。
```cpp
G4int nofLayers = 10;
G4double absoThickness = 10.*mm;
G4double gapThickness = 5.*mm;
G4double calorSizeXY = 10.*cm;
auto layerThickness = absoThickness + gapThickness;
auto calorThickness = nofLayers * layerThickness;
auto worldSizeXY = 1.2 * calorSizeXY;
auto worldSizeZ = 1.2 * calorThickness;
G4bool checkOverlaps = true;
```
下面的片段放在`DefineVolumes()`中，所用材料指针应已由材料定义阶段取得。类和单位的头文件包括`G4Box.hh`、`G4LogicalVolume.hh`、`G4PVPlacement.hh`、`G4PVReplica.hh`、`G4ThreeVector.hh`与`G4SystemOfUnits.hh`。

==== 创建World

// 来源第33页。
先定义包围整个探测器的盒体，再赋予背景材料，最后放在原点。World的母体指针为空。
```cpp
auto worldS = new G4Box("World",
    worldSizeXY/2, worldSizeXY/2, worldSizeZ/2);
auto worldLV = new G4LogicalVolume(
    worldS, defaultMaterial, "World");
auto worldPV = new G4PVPlacement(
    nullptr, G4ThreeVector(), worldLV, "World",
    nullptr, false, 0, checkOverlaps);
```
背景材料通过`defaultMaterial`指定。若选择空气，可使用已构造的空气材料指针，原版B4还可以使用其定义的稀薄背景材料，几何构造方式相同。

==== 将量能器放入World

// 来源第34页。
```cpp
auto calorimeterS = new G4Box("Calorimeter",
    calorSizeXY/2, calorSizeXY/2, calorThickness/2);
auto calorLV = new G4LogicalVolume(
    calorimeterS, defaultMaterial, "Calorimeter");
new G4PVPlacement(
    nullptr, G4ThreeVector(), calorLV, "Calorimeter",
    worldLV, false, 0, checkOverlaps);
```
这里使用`G4PVPlacement`接收母逻辑体的构造方式。传入的平移向量为零，因此量能器与World局部原点重合。几何层次建立以后，材料、空间边界与导航关系才能共同确定粒子每一步所处的介质。

==== 沿z方向复制Layer

// 来源第35-37页。
```cpp
auto layerS = new G4Box("Layer",
    calorSizeXY/2, calorSizeXY/2, layerThickness/2);
auto layerLV = new G4LogicalVolume(
    layerS, defaultMaterial, "Layer");
new G4PVReplica("Layer", layerLV, calorLV,
    kZAxis, nofLayers, layerThickness);
```
`G4PVReplica`使用一个逻辑体描述许多个有规律排列的副本。上例中的宽度是一个副本沿$z$的*完整厚度*，各副本刚好填满母体，其中心位置可写成
$ z_i=-t_("calor")/2+(i+1/2)t_("layer"), quad i=0,1,dots,N-1 $
复制体在母体中应满足相应填充约束，此类复制应构成该母体唯一的子体系列。

主要参数的声明形式为
```cpp
G4PVReplica(const G4String& name,
            G4LogicalVolume* logical,
            G4LogicalVolume* mother,
            EAxis axis,
            G4int nReplicas,
            G4double width,
            G4double offset = 0.0);
```
复制可以沿`kXAxis`、`kYAxis`、`kZAxis`分片，也可以沿`kRho`形成径向层，或沿`kPhi`形成方位角扇区。规则排列降低重复几何定义的工作量。

#figure(
  image("pic/chap6-lab/replication-layout.png", width: 60%),
  caption: [相同模块的规则堆叠与按位置、朝向变化的排布。径向复制可以形成同心层，方位角复制可以形成扇区。],
)

==== 在每层放置Absorber与Gap

// 来源第38页。
只需在Layer逻辑体中定义一次吸收体和Gap，这个子结构便随Layer的副本一起出现。
```cpp
auto absorberS = new G4Box("Abso",
    calorSizeXY/2, calorSizeXY/2, absoThickness/2);
auto absorberLV = new G4LogicalVolume(
    absorberS, absorberMaterial, "Abso");
auto absorberPV = new G4PVPlacement(
    nullptr, G4ThreeVector(0, 0, -gapThickness/2),
    absorberLV, "Abso", layerLV, false, 0, checkOverlaps);

auto gapS = new G4Box("Gap",
    calorSizeXY/2, calorSizeXY/2, gapThickness/2);
auto gapLV = new G4LogicalVolume(gapS, gapMaterial, "Gap");
auto gapPV = new G4PVPlacement(
    nullptr, G4ThreeVector(0, 0, absoThickness/2),
    gapLV, "Gap", layerLV, false, 0, checkOverlaps);
return worldPV;
```
吸收体中心向负$z$方向偏移$t_g/2$，Gap中心向正$z$方向偏移$t_a/2$。两块材料在同一层中相接，厚度之和正好等于$t_("layer")$。返回的`worldPV`把整个层次结构交给Geant4。

== 变化尺寸的探测器与几何检查

=== 用参数控制多个Chamber

// 来源第39-40页。
B2a展示了一组位置和半径逐渐变化的Chamber。使用副本编号`copyNo`计算尺寸和位置后，可以用循环显式创建各个物理体。

#figure(
  image("pic/chap6-lab/chambers.png", width: 75%),
  caption: [五个Chamber具有不同半径和位置，副本编号用于标识各个探测单元。],
)

```cpp
for (G4int copyNo = 0; copyNo < fNbOfChambers; ++copyNo) {
    G4double zPosition = firstPosition + copyNo*chamberSpacing;
    G4double rmax = rmaxFirst + copyNo*rmaxIncr;
    auto chamberS = new G4Tubs("Chamber_solid",
        0., rmax, halfWidth, 0.*deg, 360.*deg);
    fLogicChamber[copyNo] = new G4LogicalVolume(
        chamberS, chamberMaterial, "Chamber_LV");
    fLogicChamber[copyNo]->SetVisAttributes(chamberVisAtt);
    new G4PVPlacement(nullptr, G4ThreeVector(0, 0, zPosition),
        fLogicChamber[copyNo], "Chamber_PV", trackerLV,
        false, copyNo, checkOverlaps);
}
```
`halfWidth`是Chamber的$z$方向半长，`rmax`是半径。重复使用的名字可以相同，而副本编号和在母体中的位置分别指定。跟踪时可从相应的层次和copy number识别探测单元。

这种循环使用参数公式控制*显式放置*。更一般的Geant4参数化体可以通过`G4VPVParameterisation`描述各副本的变换、尺寸等属性，再交给`G4PVParameterised`创建。

=== 母子包含、材料与重叠

// 来源第41页。
子体所在区域使用子体的材料，其余母体区域使用母体材料。子体应完整包含在母体内部，同级子体应满足几何导航要求并避免重叠。重叠会使所在体、边界和材料的判断出现歧义，进而影响输运或导致异常运行。

构造`G4PVPlacement`时，可以通过最后的检查参数启用重叠检测。变量名如`checkOverlaps`或示例中的`fCheckOverlaps`由用户类自行定义，把它的值传入相应构造函数才会生效。也可以对物理体调用`CheckOverlaps()`进一步检查。

几何检查应同时核对尺寸、材料、母体、平移、旋转和副本编号。显示效果与程序运行表现相互补充，构造复杂几何时宜分层检查。

=== 布尔几何组合

// 来源第42页。
几何体可以进行并集、差集和交集运算，再将结果与其他几何体组合，用于构造复杂形状。

#figure(
  image("pic/chap6-lab/boolean-solids.png", width: 100%),
  caption: [并集、差集与交集在Solid层次构造新的几何形状。],
)

相关类分别为`G4UnionSolid`、`G4SubtractionSolid`和`G4IntersectionSolid`。例如可以从一个盒体中减去一个圆柱孔
```cpp
auto body = new G4Box("Body", 5.*cm, 5.*cm, 2.*cm);
auto hole = new G4Tubs("Hole", 0., 1.*cm, 3.*cm, 0., 360.*deg);
auto pierced = new G4SubtractionSolid("Pierced", body, hole);
```
两个参与体的位置关系由其相对变换确定。组合得到新的Solid以后，还需为其建立逻辑体、赋予材料并放入母体。

=== 通过GDML导入外部模型

// 来源第43页。
CAD或其他建模工具中的几何，经适当导出或转换为GDML后，可以通过`G4GDMLParser`读取。应用可取得文件中定义的世界物理体，再将其作为探测器构造结果。
```cpp
G4GDMLParser parser;
parser.Read("detector.gdml");
auto worldPV = parser.GetWorldVolume();
```
使用时需要相应的头文件及启用GDML支持的Geant4构建。复杂实验装置也可以配合DD4hep等几何描述工具组织模型。advanced示例CaTS展示了与外部几何相关的应用方式。

#figure(image("pic/chap6-lab/gdml-detector.png", width: 80%), caption: [由外部几何描述构造的探测器显示示例。])

== 本章小结与补充复习

=== 从原理到应用程序

// 来源第44页。
+ Geant4以运行管理器协调几何、材料、物理模型、粒子源和用户动作，完成粒子及其次级粒子的输运。
+ 从基本示例出发，可以逐步修改用户应用，并用宏文件设置运行参数。
+ 几何用Solid、LogicalVolume与PhysicalVolume三个层次表达，坐标与朝向按母体层次组合。
+ 分层量能器可以复用单层逻辑体，规则复制、参数公式和显式放置分别适合不同的排布需求。
+ 读懂构造函数参数、检查包含与重叠，是可靠几何模型的基础。

=== 编译目录、安装目录与文件布局

// 来源第45-46页。
CMake在配置阶段识别编译器、系统和依赖，生成所选构建工具使用的文件。编译阶段把用户C++源文件翻译为目标文件，再与Geant4等库链接成程序。安装阶段把可供其他应用使用的头文件、库、脚本及数据等放入指定前缀。

以11.4.3为目录命名示例，可以保留
```text
geant4.11.4.3/           源代码目录
geant4.11.4.3-build/     构建目录
geant4.11.4.3-install/   安装目录
```
独立的构建目录可以分别配置调试、优化、多线程或不同编译器等选项。安装前缀也可以分别指定，使用某一套安装时，使环境和CMake查找路径与之对应。

#figure(three-line-table[
  | 目录 | 典型内容 |
  | --- | --- |
  | 安装前缀中的`bin/` | 环境设置脚本及可执行工具 |
  | `include/` | 应用编译所需的头文件，Geant4头文件常位于其子目录中 |
  | `lib/`或相应平台库目录 | 编译后的库及相关CMake配置 |
  | `share/` | 数据、示例和其他共享资源，具体布局随安装方式而变化 |
  | 源代码中的`source/` | 按功能组织的Geant4内部实现 |
  | 源代码中的`examples/` | 基本、扩展和专门应用示例 |
])

=== 虚函数复习

// 来源第47页，补全main返回类型及对象生命周期。
通过基类指针或引用调用虚函数，可以执行实际派生类重写的行为。下面的输出为`B::foo() called.`
```cpp
#include <iostream>

class A {
public:
    virtual ~A() = default;
    virtual void foo() { std::cout << "A::foo() called.\n"; }
};
class B : public A {
public:
    void foo() override { std::cout << "B::foo() called.\n"; }
};
int main() {
    B object;
    A* ptr = &object;
    ptr->foo();
}
```
`DetectorConstruction::Construct()`、用户动作中的回调等，也利用相同机制把应用提供的实现接入框架。

=== 量能器层次与实验问题

// 来源第48-49页。
沿入射方向，分层量能器交替出现吸收体和Gap。材料选择与厚度共同影响级联发展和可记录的响应。

#figure(
  image("pic/chap6-lab/absorber-gap-layers.png", width: 100%),
  caption: [量能器沿束流方向的层状结构，每层由吸收体与Gap组成。],
)

完整模拟可以用于估计电子及次级粒子的探测效率、能量分辨率，比较材料、尺寸与成本，也可以在加入新物理相互作用以后评估实验灵敏度。这些结果需要结合具体的几何、物理模型、数据记录和重建方法计算。

接口与示例参考可见#link("https://geant4.web.cern.ch/documentation/dev/bfad_html/ForApplicationDevelopers/GettingStarted/mainProgram.html")[主程序与用户初始化]、#link("https://geant4.web.cern.ch/documentation/dev/bfad_html/ForApplicationDevelopers/Detector/Geometry/geomSolids.html")[Solid几何接口]、#link("https://geant4.web.cern.ch/documentation/dev/bfad_html/ForApplicationDevelopers/Detector/Geometry/geomPhysical.html")[物理体、复制与参数化]及#link("https://github.com/Geant4/geant4/tree/v11.4.3/examples/basic")[11.4.3基本示例]。
