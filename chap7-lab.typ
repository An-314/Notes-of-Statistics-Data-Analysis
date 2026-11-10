#import "@preview/scripst:1.1.2": *

#pagebreak(weak: true)
// #show heading: it => block(sticky: true, it)
// #show figure: set block(breakable: false)
// #show raw.where(block: true): it => block(
//   breakable: it.text.split("\n").len() > 25, it)

= 粒子物理模拟（三）

// 第八讲 lecture_8_Simulation3_v3.pdf，第1—2页。
本章在探测器几何的基础上，继续设置粒子输运所需的材料、场和物理过程，并构造每个事例的初级粒子。

- 用单元素、化学式、质量分数或NIST数据库定义材料。
- 设置全局或局部磁场，理解曲线积分与几何导航的精度。
- 配置物理列表，区分粒子定义、动力学状态和径迹。
- 用粒子枪、通用粒子源或外部事例产生器提供初级粒子。
- 理解预定义衰变以及HEPEvt接口。

#figure(
  image("pic/chap7-lab/framework.png", width: 94%),
  caption: [Geant4模拟中的材料、相互作用模型、初级粒子与运行控制。],
)

== 探测器材料

// 第3—4页。
=== 材料定义的四条路径

粒子与物质的相互作用取决于材料的密度、原子序数、元素和同位素组成等性质。几何体的形状由solid描述，材料则在构造逻辑体时指定。

Geant4用三个层次表示物质组成。

- `G4Isotope`描述给定原子序数和质量数的同位素。
- `G4Element`描述元素，可按同位素及其丰度组成。
- `G4Material`描述具有密度、组分及宏观状态的材料。

常用的材料定义方法有四种。

+ 数据库中已有材料时，调用`FindOrBuildMaterial()`。
+ 单元素材料可直接给出名称、原子序数、摩尔质量和密度。
+ 已知化学式时，以各元素的原子数定义化合物。
+ 已知组分质量分数时，以质量分数定义混合物。

#figure(image("pic/chap7-lab/material-paths.png", width: 96%), caption: [根据已有数据和材料组成选择定义方式。])

=== 单元素材料

// 第5页。
单元素材料的基本构造参数依次为名称、原子序数$Z$、摩尔质量$M$与质量密度$rho$。这些量都需要显式给出，带量纲的参数使用Geant4单位。

```cpp
#include "G4Material.hh"
#include "G4SystemOfUnits.hh"

const G4double density = 1.390 * g/cm3;
const G4double molarMass = 39.95 * g/mole;
const G4double atomicNumber = 18.;

auto liquidArgon = new G4Material(
    "liquidArgon", atomicNumber, molarMass, density,
    kStateLiquid, 87.3 * kelvin, 1. * atmosphere);
```

前四个参数确定单元素材料的基本组成和密度。后面的状态、温度和压强是可选参数，液氩示例显式指定`kStateLiquid`及相应温压。仅把材料命名为`liquidArgon`不会自动设置它的物态。

这里的摩尔质量以`g/mole`为单位，原子序数无量纲。密度参数使用`density`，拼写需要与变量声明一致。

=== 按化学式定义化合物

// 第6页。
水分子中氢、氧原子数之比为$2:1$。先定义元素，再以整数原子数调用`AddElement()`。

```cpp
#include "G4Element.hh"
#include "G4Material.hh"
#include "G4SystemOfUnits.hh"

auto hydrogen = new G4Element(
    "Hydrogen", "H", 1., 1.01 * g/mole);
auto oxygen = new G4Element(
    "Oxygen", "O", 8., 16.00 * g/mole);

auto water = new G4Material("Water", 1.0 * g/cm3, 2);
water->AddElement(hydrogen, 2);
water->AddElement(oxygen, 1);
```

`G4Material`的第三个参数`2`是组分数，即两种元素。`AddElement(hydrogen, 2)`中的整数`2`是化学式中的氢原子数。这两个数具有不同含义。

构造函数按位置传参。`name = "Water"`这类C++表达式表示对已声明变量赋值。

=== 按质量分数定义混合物

// 第7页。
混合物常以各组分的质量分数定义。下面保留一个仅包含氮、氧的简化空气模型。

```cpp
#include "G4Element.hh"
#include "G4Material.hh"
#include "G4SystemOfUnits.hh"

auto nitrogen = new G4Element(
    "Nitrogen", "N", 7., 14.01 * g/mole);
auto oxygen = new G4Element(
    "Oxygen", "O", 8., 16.00 * g/mole);

auto air = new G4Material("AirExample", 1.290 * mg/cm3, 2);
air->AddElement(nitrogen, 70. * perCent);
air->AddElement(oxygen, 30. * perCent);
```

质量分数满足
$ w_i = m_i / sum_j m_j, quad sum_i w_i = 1 $
这里的70%和30%是质量占比。它们与元素原子数占比、气体体积占比需要分别处理。真实空气还含氩等组分，标准空气可直接使用`G4_AIR`。

`AddElement()`根据参数类型区分两种用法。

#figure(three-line-table[
  | 调用形式 | 组成方式 | 例子 |
  | --- | --- | --- |
  | `AddElement(element, G4int)` | 化学式中的原子数 | `water->AddElement(hydrogen, 2)` |
  | `AddElement(element, G4double)` | 元素质量分数 | `air->AddElement(nitrogen, 0.70)` |
])

=== NIST元素与材料数据库

// 第8—9页。
NIST是National Institute of Standards and Technology。Geant4集成的材料数据库提供元素、同位素和预定义材料数据，包括密度、元素组成、同位素组成与平均电离能$I$等。NIST物性参考数据可用于核对材料输入。#link("https://www.nist.gov/pml/productsservices/physical-reference-data")[NIST物性参考数据]

材料数据库包括3000余种同位素数据，并覆盖$Z=1$至108的元素。具有天然同位素组成的元素按相应丰度构建。无天然丰度的人工元素使用数据库指定的同位素信息，具体数据随版本核对。

按元素符号或原子序数查找元素。

```cpp
#include "G4NistManager.hh"

auto nist = G4NistManager::Instance();
auto carbon = nist->FindOrBuildElement("C");
auto silicon = nist->FindOrBuildElement(14);
```

`FindOrBuildElement()`先查找已有对象，必要时构造元素及其同位素，避免重复建立同一个数据库对象。原子序数14对应硅。

按材料名称查找材料。

```cpp
#include "G4Material.hh"
#include "G4NistManager.hh"
#include "G4PhysicalConstants.hh"
#include "G4SystemOfUnits.hh"

void DetectorConstruction::DefineMaterials()
{
    auto nist = G4NistManager::Instance();
    nist->FindOrBuildMaterial("G4_W");
    nist->FindOrBuildMaterial("G4_AIR");
    nist->FindOrBuildMaterial("G4_Si");
    nist->FindOrBuildMaterial("G4_Cu");

    new G4Material(
        "Galactic", 1., 1.01 * g/mole, universe_mean_density,
        kStateGas, 2.73 * kelvin, 3.e-18 * pascal);
}
```

`G4_W`是钨，铅的材料名为`G4_Pb`。`Galactic`用极低的有限密度表示真空区域，并显式给出气态、温度和压强。

材料、元素和同位素会注册到相应的全局表，并由Geant4的材料管理机制统一处理生命周期。通常在探测器材料定义阶段构造一次，后续在逻辑体中复用相同的材料指针。#link("https://geant4.web.cern.ch/documentation/dev/bfad_html/ForApplicationDevelopers/Detector/material.html")[Geant4材料定义]

== 探测器磁场

// 第11—12页。
=== 全局磁场

均匀全局磁场可以使用`G4GlobalMagFieldMessenger`。B2a示例在`ConstructSDandField()`中创建场，并用messenger提供宏命令接口。

下面的代码采用类的静态、线程局部成员。先在`DetectorConstruction`类中声明。

```cpp
// DetectorConstruction.hh 中的类成员
static G4ThreadLocal G4GlobalMagFieldMessenger*
    fMagFieldMessenger;
```

头文件需要声明`G4GlobalMagFieldMessenger`，并包含提供`G4ThreadLocal`的`globals.hh`。实现文件中定义成员并注册线程结束时的清理。

```cpp
#include "G4AutoDelete.hh"
#include "G4GlobalMagFieldMessenger.hh"
#include "G4SystemOfUnits.hh"
#include "G4ThreeVector.hh"

G4ThreadLocal G4GlobalMagFieldMessenger*
    DetectorConstruction::fMagFieldMessenger = nullptr;

void DetectorConstruction::ConstructSDandField()
{
    const G4ThreeVector fieldValue(1. * tesla, 0., 0.);
    fMagFieldMessenger = new G4GlobalMagFieldMessenger(fieldValue);
    fMagFieldMessenger->SetVerboseLevel(1);
    G4AutoDelete::Register(fMagFieldMessenger);
}
```

这里的初始磁场沿$x$轴，大小为1 T。建立messenger后，可以用宏命令设置磁场及输出详细程度。

```text
/globalField/setValue 0 0 1 tesla
/globalField/verbose 1
```

全局场在没有被局部场管理器覆盖的区域生效。多线程应用中，场对象和场管理设置需要遵循示例采用的线程局部初始化方式。

=== 局部磁场

B5示例将磁场限制在一个探测器逻辑体中。核心步骤是构造场、构造场管理器、为场创建弦追踪器，再把管理器关联到逻辑体。

```cpp
// ConstructSDandField() 中的局部场设置片段
fMagneticField = new B5MagneticField();
fFieldMgr = new G4FieldManager();
fFieldMgr->SetDetectorField(fMagneticField);
fFieldMgr->CreateChordFinder(fMagneticField);

const G4bool forceToAllDaughters = true;
fMagneticLogical->SetFieldManager(
    fFieldMgr, forceToAllDaughters);
```

`B5MagneticField`是应用提供的磁场类，`fMagneticLogical`为已构造的逻辑体。第二个参数为`true`时，场管理器也向该逻辑体的所有子体应用。上述成员应按完整B5示例设置为适当的线程局部对象，并在相应线程结束时清理。场管理器保存的场指针需要在输运期间持续有效。

=== 曲线积分、弦与miss distance

// 第13页。
带电粒子在磁场中的运动满足洛伦兹力方程。对于纯磁场，
$ (dif bold(p))/(dif t) = q bold(v) times bold(B) $
Geant4通过数值积分求解运动方程，常用积分方法包括Runge–Kutta方法。几何导航需要查询轨迹与体边界的交点，因此场中的曲线段还会以多条弦进行几何逼近。

*Miss distance*是一个曲线段与其弦之间的最大偏离，也称弓高。它控制导航所用弦对曲线的逼近精度。

#figure(
  image("pic/chap7-lab/field-chords.png", width: 80%),
  caption: [场中曲线以弦进行几何导航。弦与曲线的最大偏离为miss distance。],
)

可通过`G4ChordFinder`设置弓高容差。例如，将容差设为0.25 mm。

```cpp
fieldManager->GetChordFinder()->SetDeltaChord(0.25 * mm);
```

这段代码要求场管理器已经创建了chord finder。弓高容差需要与最小几何结构尺寸及所需位置精度匹配。积分本身的步长误差、边界交点误差还由其他精度参数控制，应分别检查，并用收紧容差后的结果检验数值收敛。#link("https://geant4.web.cern.ch/documentation/dev/bfad_html/ForApplicationDevelopers/Detector/electroMagneticField.html")[Geant4场输运与精度控制]

== 物理过程与物理列表

// 第14—15页。
=== 物理过程的主要类别

不同粒子和材料需要不同的物理过程。按用途可将常见过程分为以下七类。

#figure(three-line-table[
  | 类别 | 主要过程 | 典型用途 |
  | --- | --- | --- |
  | 电磁 electromagnetic | 电离、轫致辐射、多重散射、光电效应、Compton散射、电子对产生 | 径迹探测器、量能器 |
  | 强子 hadronic | 强子与核相互作用、弹性散射、核反应、裂变、中子俘获 | 强子量能器、辐射屏蔽 |
  | 衰变 decay | 按寿命及衰变表产生衰变 | 不稳定粒子输运 |
  | 光／轻子—强子作用 | 光核反应、轻子诱发核反应 | 特定核过程 |
  | 光学 optical | Cherenkov辐射、闪烁、波长位移、Rayleigh散射 | Cherenkov探测器、闪烁体 |
  | 输运 transportation | 粒子在几何和场中的运动 | 所有需要跟踪的粒子 |
  | 参数化 parameterization | 用快速模拟或参数化模型描述响应 | 大规模快速模拟 |
])

这些是便于理解的过程类别。应用需要根据入射粒子、次级粒子及材料选择相应过程。输运过程是粒子在几何中运动的必要组成部分。

=== 在主程序中注册物理列表

// 第16—17页。
以下片段对应B1主程序中的初始化顺序。应用中已经定义`DetectorConstruction`与`ActionInitialization`类。

```cpp
#include "ActionInitialization.hh"
#include "DetectorConstruction.hh"
#include "G4RunManagerFactory.hh"
#include "QBBC.hh"

auto runManager = G4RunManagerFactory::CreateRunManager(
    G4RunManagerType::Default);

runManager->SetUserInitialization(new DetectorConstruction());
runManager->SetUserInitialization(new QBBC());
runManager->SetUserInitialization(new ActionInitialization());
```

同一个run manager注册一个物理列表。Geant4要求用户显式提供物理列表。它负责指定需要构造的粒子、赋予粒子的物理过程，以及次级粒子的产生阈值。

物理列表需要完整覆盖应用关心的过程。缺失粒子定义或相互作用，即使程序正常结束，也可能得到不准确的物理结果。

=== 产生阈值的含义

Geant4常用以长度表示的*range cut*设置次级粒子的产生阈值。它根据材料和粒子种类转换为相应的能量阈值，以控制某些次级粒子的显式产生，并将相应连续能损交给连续过程处理。

这些产生阈值主要作用于有关的电磁次级产生。已经产生并进入跟踪的粒子通常继续输运到停止或被其他物理、用户限制终止。特定过程和用户设置有各自规则，不能用一个生产阈值代替全部跟踪终止条件。#link("https://geant4.web.cern.ch/documentation/dev/bfad_html/ForApplicationDevelopers/TrackingAndPhysics/thresholdVScut.html")[Geant4产生阈值与跟踪截断]

=== 为什么需要不同的物理列表

// 第18—19页。
Geant4面向高能实验、低能核物理、医学、空间辐射和屏蔽等应用。各应用关心的粒子、能区和观测量不同，对精度和计算资源的需求也不同。

- 高能量能器需要描述强子簇射的纵向与横向形状，以及能量分辨率。
- 医学应用可能重点关注低能电子、光子和剂量沉积。
- 空间和屏蔽应用需要考虑离子反应、低能中子及其长期输运。

物理列表允许选用合适的模型组合，并减少无关过程带来的计算开销。精度与速度需要结合具体观测量评估。比较合理的模型或物理列表，可以估计结果对物理建模的敏感性。系统误差的确定还需要数据检验、适用范围与变化方案的依据。

Geant4提供预定义的参考物理列表，例如`FTFP_BERT`、`FTFP_BERT_HP`、`Shielding`、`FTFP_INCLXX`、`QGSP_BERT`与`QGSP_BIC_EMY`。这些列表也可以作为用户定制的基础。

=== 常见模型及参考物理列表

// 第20页。
物理列表名称中的缩写对应不同的强子模型。

- *FTF*为Fritiof弦模型，用于较高能强子与核反应。
- *P*为Precompound，与激发核的预平衡和退激处理相关。
- *BERT*为Bertini核内级联模型，描述较低能入射强子在核内的级联。
- *QGS*为Quark–Gluon String模型，描述更高能的强子反应。
- *BIC*为Binary Cascade，二元级联模型。
- *INCLXX*对应INCL++核内级联模型。
- *HP*表示增加面向低能中子的高精度数据驱动输运处理。

#figure(three-line-table[
  | 名称 | 主要特点 |
  | --- | --- |
  | `FTFP_BERT` | 结合高能FTF与低能Bertini级联，用于通用高能粒子输运 |
  | `FTFP_BERT_HP` | 在相应列表基础上，以高精度模型和核数据处理低于约20 MeV的中子 |
  | `QGSP_BERT` | 保留低能级联和中能FTF，在更高能区引入QGS |
  | `Shielding` | 面向深屏蔽、低能中子及有关核反应的模型组合 |
  | `FTFP_INCLXX` | 使用INCL++级联模型，包含有关强子及轻离子反应的处理 |
  | `QGSP_BIC` | 采用Binary Cascade描述相应低能核内级联 |
  | `QGSP_BIC_EMY` | QGSP_BIC系列配合相应增强电磁配置的变体 |
  | `G4EmStandardPhysics_option4` | 可加入模块化物理列表的电磁物理构造器，覆盖精细的电磁过程配置 |
])

完整参考列表和单个物理构造器的使用层次需要区分。`G4EmStandardPhysics_option4`负责电磁部分，构造完整模拟还需配置所需的其他物理过程。

模型之间常有重叠能区并按能量平滑选择。以Geant4 11.4参考文档为例，FTFP_BERT的Bertini与FTF在约3—6 GeV重叠。QGSP_BERT仍含FTF，FTF与QGS在约12—25 GeV重叠。适用粒子和精确阈值需要按使用版本核对。#link("https://geant4.web.cern.ch/documentation/dev/plg_html/PhysicsListGuide/reference_PL/FTFP_BERT.html")[FTFP_BERT]，#link("https://geant4.web.cern.ch/documentation/dev/plg_html/PhysicsListGuide/reference_PL/QGSP_BERT.html")[QGSP_BERT]

`Shielding`的离子模型配置也具有版本依赖。Geant4 11.4文档给出的低能核—核模型包括Binary Cascade，并向高能FTF过渡，使用时应核对对应版本的模型表。#link("https://geant4.web.cern.ch/documentation/dev/plg_html/PhysicsListGuide/reference_PL/Shielding.html")[Shielding]

=== 按应用场景选择候选列表

// 第21—24页。
通用高能探测器可从FTFP_BERT开始。对低能中子敏感的观测量需要检查相应的高精度输运与核数据库，深屏蔽应用可从Shielding系列开始。最终配置还取决于能区、材料、所需过程及数据验证。

下表整理常见应用与相应候选列表，作为进一步检查模型覆盖范围的入口。

#figure(three-line-table[
  | 应用 | 候选物理列表或关注点 |
  | --- | --- |
  | 高能物理量能器 | `FTFP_BERT`、`QGSP_BERT` |
  | 高能物理径迹探测器 | `FTFP_BERT`、`QGSP_BERT`、`QGSP_BIC` |
  | 典型对撞机探测器 | `FTFP_BERT` |
  | LHC中子通量 | `QGSP_BERT_HP`、`QGSP_BIC_HP` |
  | 直线对撞机中子通量 | `QGSP_BERT_HP`、`QGSP_BIC_HP` |
  | 各能区辐射屏蔽 | `QGSP_BERT_HP`、`QGSP_BIC_HP`、`QGSP_INCLXX`、`Shielding` |
  | 低能剂量学 | `QGSP_BERT_HP`、`QGSP_BIC_HP` |
])

#figure(three-line-table[
  | 应用 | 候选物理列表或关注点 |
  | --- | --- |
  | 医学和工业中子应用 | `QGSP_BERT_HP`、`QGSP_BIC_HP`、`QGSP_INCLXX` |
  | 医学、空间中的低能质子与中子输运 | `QBBC` |
  | 地下物理 | `Shielding` |
  | 大气簇射、中微子束线的强子产生，能量约10 GeV以内 | `FTFP_BERT`、`NuBeam` |
  | 更高能的大气簇射、束线强子产生 | `QGSP_BERT`、`NuBeam`，数十GeV/c束流也可检查`FTFP_BERT` |
])

高能强子簇射需要弦模型与核内级联等组成相互衔接。比较束流测试中的纵向形状、横向形状与分辨率，可检验模型对量能器响应的描述。中子通量应用还需要跟踪降能后直到热能区的中子，因此仅描述高能强子簇射通常不充分。

HP系列需要匹配版本的核数据，例如`G4NDL`。光学光子过程也需要单独确认配置，常见强子参考列表通常需要额外注册`G4OpticalPhysics`才能模拟闪烁、Cherenkov光及光学输运。#link("https://geant4.web.cern.ch/documentation/dev/plg_html/PhysicsListGuide/reference_PL/FTFP_BERT.html")[FTFP_BERT的组件与扩展]

=== 调用与修改参考物理列表

// 第25页。
在主程序中包含所选列表的头文件，构造实例并交给run manager。

```cpp
#include "FTFP_BERT.hh"
#include "G4VModularPhysicsList.hh"

G4VModularPhysicsList* physicsList = new FTFP_BERT();
runManager->SetUserInitialization(physicsList);
```

参考列表的定制可查阅`examples/extended/physicslists`。对低能光核反应等特定过程，需要继续检查模型及截面数据的能区覆盖。`G4LowEGammaNuclearModel`是相关模型之一，反应截面与次级产生可结合`examples/extended/hadronic/Hadr03`研究，并与适当的评价核数据库或实验数据比较。模型的可用范围及默认注册情况应查对应版本的Physics List Guide。#link("https://geant4.web.cern.ch/documentation/pipelines/master/plg_html/PhysicsListGuide/hadronic/gamma-nuclear.html")[Geant4光核反应模型]

== 粒子的定义与访问

// 第26—27页。
=== 描述粒子的三个层次

Geant4用三个相关类逐步给出粒子的物种信息、动力学状态与输运环境。

#figure(three-line-table[
  | 类 | 保存的主要信息 | 含义 |
  | --- | --- | --- |
  | `G4ParticleDefinition` | 名称、质量、电荷、自旋、寿命、衰变表 | 一种粒子共有的静态性质 |
  | `G4DynamicParticle` | 动量、能量、极化等 | 某个具体粒子的动力学状态 |
  | `G4Track` | 动态粒子、位置、时间、当前体等 | 粒子在探测器中的输运状态 |
])

粒子定义本身不含当前粒子的运动方向或能量。相同物种的多个粒子可以共享同一个`G4ParticleDefinition`，同时拥有各自的动力学状态与径迹。

=== 粒子种类与跟踪方式

// 第28—29页。
Geant4提供电子、光子、质子等普通粒子，介子和重子共振态，各类原子核，以及模型内部使用的夸克和胶子定义。预定义粒子有100余种，应用实际构造哪些粒子由物理列表决定，也可以按工具开发接口扩展粒子定义。

从探测器输运的角度，可作如下分类。

+ *通常需要跟踪的粒子*包括光子、电子、质子，以及能够飞行一段距离的μ子和带电π介子等。
+ *相对于探测器尺度极短寿命的粒子*，例如$pi^0$、$eta$及许多激发态，在相应模型中很快衰变，后续主要输运其衰变产物。
+ *中性K介子*涉及混合，传播通常以长、短寿命态$K_L^0$和$K_S^0$描述，具体处理与输入产生器及物理配置有关。
+ *光学光子*使用`opticalphoton`定义，适用于闪烁、Cherenkov光及光学边界等过程。电磁输运中的高能光子通常使用`gamma`定义。
+ *geantino与chargedgeantino*是几何和输运测试用的理想粒子，可用于检查几何及场，不参与通常的物质相互作用。
+ *原子核*包括氘核、氚核、氦3、α粒子等轻核，铀238、碳14等重核或放射性核素，以及反核和超核。具体支持范围与模型及版本有关。
+ *夸克、胶子与极短寿命共振态*通常作为相互作用模型内部的组成，形成可输运的末态粒子后再交给跟踪系统。

“核子”指质子和中子，氘核、氦核及重离子属于原子核。中子在典型探测器飞行时间内寿命很长，但具有β衰变，Geant4中也有相应的非稳定粒子定义。寿命量级、是否属于`short-lived`类别，以及是否需要跟踪，应结合粒子定义和物理过程设置判断。#link("https://geant4.web.cern.ch/documentation/dev/bfad_html/ForApplicationDevelopers/TrackingAndPhysics/particle.html")[Geant4粒子表示与分类]

#figure(
  image("pic/chap7-lab/particle-table.png", width: 96%),
  caption: [粒子属性表与带电π介子定义示例。具体数值随粒子数据和软件版本核对。],
)

=== 通过粒子表查找

// 第30—31页。
`G4ParticleTable`保存已经构造的粒子定义。`FindParticle()`可按名称查找粒子。

```cpp
#include "G4ParticleDefinition.hh"
#include "G4ParticleTable.hh"
#include "G4SystemOfUnits.hh"
#include "G4ios.hh"

auto table = G4ParticleTable::GetParticleTable();
auto proton = table->FindParticle("proton");
if (proton != nullptr) {
    G4cout << proton->GetParticleName() << " mass = "
           << proton->GetPDGMass() / MeV << " MeV" << G4endl;
}
```

查找前，对应粒子需要已经由物理列表或粒子类构造。查找失败时返回空指针。

#figure(three-line-table[
  | 成员函数 | 返回信息 |
  | --- | --- |
  | `GetParticleName()` | 粒子名称，类型为`G4String` |
  | `GetPDGMass()` | 质量，类型为`G4double`，使用内部能量单位 |
  | `GetPDGWidth()` | 衰变宽度，类型为`G4double` |
  | `GetPDGCharge()` | 电荷，类型为`G4double` |
  | `GetPDGSpin()` | 自旋量子数，类型为`G4double` |
  | `GetPDGEncoding()` | PDG粒子编码，类型为`G4int` |
  | `GetDecayTable()` | `G4DecayTable*`，没有相应衰变表时可为空 |
])

输出有量纲的数值时，应按希望显示的单位换算。例如质量用`GetPDGMass()/MeV`输出，电荷可用`GetPDGCharge()/eplus`输出。

=== 通过具体粒子类访问

// 第32页。
每种常见粒子都有相应的类。粒子类的静态方法会返回对应的粒子定义，必要时完成构造。下面列出电磁物理构造器中常见的一组调用。

```cpp
#include "G4AntiProton.hh"
#include "G4Electron.hh"
#include "G4Gamma.hh"
#include "G4KaonMinus.hh"
#include "G4KaonPlus.hh"
#include "G4MuonMinus.hh"
#include "G4MuonPlus.hh"
#include "G4PionMinus.hh"
#include "G4PionPlus.hh"
#include "G4Positron.hh"
#include "G4Proton.hh"

G4Gamma::Gamma();
G4Electron::Electron();
G4Positron::Positron();
G4MuonPlus::MuonPlus();
G4MuonMinus::MuonMinus();
G4PionPlus::PionPlusDefinition();
G4PionMinus::PionMinusDefinition();
G4KaonPlus::KaonPlusDefinition();
G4KaonMinus::KaonMinusDefinition();
G4Proton::Proton();
G4AntiProton::AntiProton();
```

例如，直接取得光子定义。

```cpp
G4ParticleDefinition* particle = G4Gamma::Gamma();
```

构造粒子定义之后，还需要由物理列表为该粒子注册所需的物理过程。

== 初级粒子与初级顶点

// 第33—35页。
=== 事例的输入

应用需要向Geant4提供探测器几何、物理列表及初级粒子来源。Geant4随后模拟这些粒子穿过探测器的输运，产生次级粒子，并形成可由用户记录的探测器响应。

#figure(
  image("pic/chap7-lab/application-interfaces.png", width: 96%),
  caption: [应用提供的必要初始化及可选记录接口。初级粒子产生动作负责提供事例的输入。],
)

*初级粒子*是事例开始时提供给输运系统的粒子，例如$p p$碰撞产生器输出的末态粒子。一个事例包含一个或多个*初级顶点*，每个顶点可以关联一个或多个初级粒子。

- `G4PrimaryVertex`保存顶点的位置和时间。
- `G4PrimaryParticle`保存粒子类型、动量与可选的极化等信息。
- `G4Event`组织一个事例中的初级顶点及后续事例信息。

#figure(
  image("pic/chap7-lab/primary-vertex.png", width: 92%),
  caption: [一个初级顶点可以连接多个初级粒子。位置与时间属于顶点，动量和粒子类型属于粒子。],
)

初级粒子记录给出输运起点，输运阶段再生成相应的动态粒子和径迹。初级粒子与输运过程中产生的次级粒子按来源区分。

=== 注册用户动作

// 第36页。
`ActionInitialization`负责构造并注册初级粒子产生动作，以及所需的run、event、step等用户动作。B1的结构如下。

```cpp
void ActionInitialization::Build() const
{
    SetUserAction(new PrimaryGeneratorAction());

    auto runAction = new RunAction();
    SetUserAction(runAction);

    auto eventAction = new EventAction(runAction);
    SetUserAction(eventAction);

    SetUserAction(new SteppingAction(eventAction));
}
```

这些类由具体应用定义。`PrimaryGeneratorAction`提供事例输入，其他用户动作可负责统计、输出与逐步记录。传给`SetUserAction()`的动作由框架管理生命周期。多线程应用在工作线程中通过`Build()`建立动作，主线程所需的run动作可在`BuildForMaster()`中单独注册。

=== 初级粒子产生动作与产生器

// 第37页。
用户的初级粒子产生动作继承`G4VUserPrimaryGeneratorAction`，实现纯虚函数。

```cpp
virtual void GeneratePrimaries(G4Event* event) = 0;
```

运行时，每个事例调用该方法，用户在其中生成初级顶点和粒子。产生动作可以持有Geant4提供的初级粒子产生器，并调用它的`GeneratePrimaryVertex(event)`。

#figure(three-line-table[
  | 产生器 | 用途 |
  | --- | --- |
  | `G4ParticleGun` | 按当前设置发射给定数目的同类粒子，可由用户逐事例抽样参数 |
  | `G4GeneralParticleSource` | 用宏配置位置、角度和能量等分布 |
  | `G4HEPEvtInterface` | 读取外部产生器按HEPEvt格式输出的ASCII记录 |
])

多初级顶点、Pythia接口等更复杂的用法可参考`examples/extended/eventgenerator`。#link("https://geant4.web.cern.ch/documentation/dev/bfad_html/ForApplicationDevelopers/GettingStarted/eventDef.html")[Geant4事例与初级粒子定义]

=== 粒子枪

// 第38页。
==== 构造与逐事例发射

下面的动作类持有一个粒子枪，默认产生一个能量为100 MeV的光子。发射位置为$(0,0,-50 "cm")$，每个事例重新抽样方向。

```cpp
// PrimaryGeneratorAction.hh
#pragma once

#include "G4VUserPrimaryGeneratorAction.hh"

class G4Event;
class G4ParticleGun;

class PrimaryGeneratorAction : public G4VUserPrimaryGeneratorAction {
public:
    PrimaryGeneratorAction();
    ~PrimaryGeneratorAction() override;
    void GeneratePrimaries(G4Event* event) override;

private:
    G4ParticleGun* fParticleGun = nullptr;
};
```

实现文件如下。通过`G4Gamma`直接取得光子定义。

```cpp
#include "PrimaryGeneratorAction.hh"
#include "G4Event.hh"
#include "G4Gamma.hh"
#include "G4ParticleGun.hh"
#include "G4RandomDirection.hh"
#include "G4SystemOfUnits.hh"
#include "G4ThreeVector.hh"

PrimaryGeneratorAction::PrimaryGeneratorAction()
{
    fParticleGun = new G4ParticleGun(1);
    fParticleGun->SetParticleDefinition(G4Gamma::Gamma());
    fParticleGun->SetParticleMomentumDirection(
        G4ThreeVector(0., 0., 1.));
    fParticleGun->SetParticleEnergy(100. * MeV);
    fParticleGun->SetParticlePosition(
        G4ThreeVector(0., 0., -50. * cm));
}

PrimaryGeneratorAction::~PrimaryGeneratorAction()
{
    delete fParticleGun;
}

void PrimaryGeneratorAction::GeneratePrimaries(G4Event* event)
{
    fParticleGun->SetParticleMomentumDirection(G4RandomDirection());
    fParticleGun->GeneratePrimaryVertex(event);
}
```

构造函数在动作对象建立时执行，`GeneratePrimaries()`则逐事例执行。虽然构造函数给出了沿$+z$的初始方向，逐事例调用`G4RandomDirection()`后，实际发射方向为$4 pi$立体角内各向同性分布。

各向同性意味着方位角均匀、$cos theta$均匀。若自己实现抽样，可取
$ phi = 2 pi U_1, quad cos theta = 2 U_2 - 1 $
其中$U_1,U_2$独立且均匀分布在$[0,1)$。直接对$theta$均匀抽样会得到不同的立体角分布。

源位置需要位于World包含的区域内。这里保留$(0,0,-50 "cm")$的设置，接入前章B4示例时应按源位置相应扩大World。

需要按其他分布逐事例产生能量、位置或方向时，应在调用`GeneratePrimaryVertex()`之前设置本次抽样值。

==== 一次产生多个初级粒子

`G4ParticleGun(n)`允许在一次`GeneratePrimaryVertex()`调用中产生$n$个粒子。它们属于同一初级顶点，并共享这次粒子枪配置的粒子类型、能量、方向与极化。

同一个事例中若需要多组不同设置，可以使用多个粒子枪，也可以复用一个粒子枪，逐次修改设置并再次调用`GeneratePrimaryVertex(event)`。后一种方法每次调用都向事例追加一个初级顶点。需要一个顶点关联多种粒子时，可直接构造相应的`G4PrimaryVertex`与`G4PrimaryParticle`关系。#link("https://geant4.web.cern.ch/documentation/dev/bfad_html/ForApplicationDevelopers/GettingStarted/eventDef.html")[Geant4粒子枪]

=== 通用粒子源

// 第39页。
==== 在产生动作中使用GPS

`G4GeneralParticleSource`简称GPS。应用接入GPS后，可以用宏文件配置粒子类型、空间分布、角分布和能谱，改变这些设置时无需重新编译应用。

下面给出独立的GPS产生动作。其头文件仍继承`G4VUserPrimaryGeneratorAction`，声明构造函数、析构函数和`GeneratePrimaries()`，并持有`G4GeneralParticleSource* fGenerator`成员。

```cpp
#include "GPSPrimaryGeneratorAction.hh"
#include "G4Event.hh"
#include "G4GeneralParticleSource.hh"

GPSPrimaryGeneratorAction::GPSPrimaryGeneratorAction()
    : fGenerator(new G4GeneralParticleSource())
{}

GPSPrimaryGeneratorAction::~GPSPrimaryGeneratorAction()
{
    delete fGenerator;
}

void GPSPrimaryGeneratorAction::GeneratePrimaries(G4Event* event)
{
    fGenerator->GeneratePrimaryVertex(event);
}
```

将该动作注册到`ActionInitialization::Build()`后，使用`/gps/`命令配置源。粒子源对象由产生动作持有并在动作析构时释放。

==== 平面源、余弦角分布与线性能谱

// 第40页。
下面的宏配置一个正方形平面光子源。在已初始化并接入GPS的应用中执行。

```text
# 选择光子
/gps/particle gamma

# 位置在正方形平面源上均匀抽样
/gps/pos/type Plane
/gps/pos/shape Square
/gps/pos/centre 1 2 1 cm
/gps/pos/halfx 2 cm
/gps/pos/halfy 2 cm

# 余弦角分布
/gps/ang/type cos

# 2—10 MeV的线性能谱
/gps/ene/type Lin
/gps/ene/min 2 MeV
/gps/ene/max 10 MeV
/gps/ene/gradient 1
/gps/ene/intercept 1

/run/beamOn 10000
```

这里`halfx`和`halfy`是半长，因而正方形的尺寸为$4 "cm" times 4 "cm"$，中心位于$(1,2,1) "cm"$。默认平面平行于$x y$平面，所生成位置满足
$ x in [-1,3] "cm", quad y in [0,4] "cm", quad z=1 "cm" $

线性能谱在给定区间内满足$dif N / dif E$随能量线性变化。对于上面梯度和截距均取1的宏，以内部MeV数值$u=E/(1 "MeV")$表示能量，可写成归一化分布
$ p(u) = (1+u)/56, quad 2<=u<=10. $
因此高能端的粒子更多。这里用无量纲的$u$表达命令中数值的约定。

余弦角分布是相对于源方向的单位立体角分布。令$theta_s$为动量与源的默认$-z$方向之间的夹角，则在所取半空间中
$ (dif N)/(dif Omega) prop cos theta_s, quad 0<=theta_s<=pi/2. $
计入立体角元$dif Omega=sin theta_s dif theta_s dif phi$，归一化后的极角密度为
$ p(theta_s) = 2 sin theta_s cos theta_s. $
GPS默认角度约定中，零极角指向局部$-z$。下图使用相对源方向的极角$theta_s$，所以$cos theta_s$落在$[0,1]$。若换成相对$+z$的极角$theta_z$，则有$cos theta_z=-cos theta_s$，相应方向余弦落在$[-1,0]$。改变源或角度坐标轴旋转时，应同时检查相应的角度定义。#link("https://geant4.web.cern.ch/documentation/dev/bfad_html/ForApplicationDevelopers/GettingStarted/generalParticleSource.html")[GPS位置、角度与能谱配置]

#figure(
  image("pic/chap7-lab/gps-distributions.png", width: 68%),
  caption: [上述平面源的能谱、位置和角分布示例。角度相对源的默认$-z$方向定义，$cos theta_s$位于$[0,1]$。],
)

`/run/beamOn 10000`要求运行10000个事例。使用默认的单源、每次一个粒子配置时，对应10000个初级光子。改变每个事例的粒子数或多源设置后，事例数与粒子总数需要分别统计。

=== 粒子枪与GPS的使用场景

// 第41页。
#figure(three-line-table[
  | 需求 | 粒子枪 | GPS |
  | --- | --- | --- |
  | 固定种类、能量和方向的测试粒子 | 配置直接 | 同样可以配置 |
  | 逐事例自定义抽样 | 在用户代码中设置 | 内置多种分布，并可用宏配置 |
  | 几何表面或体积分布 | 需要用户实现相应抽样 | 可配置相应源形状与位置分布 |
  | 复杂角分布、能谱或直方图输入 | 需要用户编写抽样 | 提供相应分布与用户直方图接口 |
  | 经常改变源参数 | 结合`/gun/`命令或用户代码 | 可集中在宏文件中设置 |
])

简单测试粒子可以使用粒子枪。需要几何表面发射、复杂位置和角分布，或按直方图设置能谱时，GPS提供现成的配置接口。

== 交互运行与宏命令

// 第42页。
交互模式中，可逐条输入命令并查看输出。批处理模式将命令保存在宏文件中，再由应用执行该文件。应用的界面初始化和命令执行方式可参考B1、B5主程序。

已初始化的粒子枪应用可以执行下面一组演示命令。可视化命令要求Geant4和应用具有相应OpenGL支持。

```text
/vis/open OGL
/vis/drawVolume
/gun/particle mu+
/gun/energy 10 GeV
/run/beamOn 10
```

它将粒子类型设为正μ子，动能设为10 GeV，再运行10个事例。粒子名称必须与粒子表中的定义一致，例如`gamma`、`proton`、`e+`、`neutron`、`pi+`、`pi-`、`pi0`与`opticalphoton`。

`/gun/`命令对应粒子枪，`/gps/`命令对应GPS。若用户代码在每次`GeneratePrimaries()`中重设某个参数，实际发射将使用该次重设的值。例如前面的粒子枪代码逐事例重设方向，运行前通过`/gun/direction`设置的固定方向会被下一次随机抽样覆盖。

== 本章小结

// 第43页。
- 探测器材料由密度、元素与同位素组成及相应宏观状态定义。
- 物理列表负责构造粒子、注册物理过程并设置有关产生阈值。
- 粒子定义、动力学状态与径迹构成三个不同层次的信息。
- 初级粒子和初级顶点给出事例输入，可由粒子枪、GPS或外部产生器提供。
- 磁场可以作用于全局或局部体，场积分和几何导航均需要控制精度。

== 预定义的衰变

// 第44页。
默认情况下，不稳定粒子输运到衰变点时，衰变过程`G4Decay`根据`G4ParticleDefinition`中的衰变表随机选择衰变道，再产生相应末态粒子。

也可以在`G4PrimaryParticle`中预先安排衰变产物及衰变链。对于可被Geant4跟踪并具有相应衰变过程的母粒子，框架保留这些预先指定的产物，在衰变时采用，并按母粒子的运动状态作所需洛伦兹变换。

常见用途有两种。

+ 外部事例产生器负责特殊粒子或复杂衰变链的产生，Geant4接续输运其中可跟踪的粒子。
+ 强制产生某个指定衰变道，例如研究稀有衰变的探测效率。

如果输入母粒子没有对应的`G4ParticleDefinition`，它可以作为外部衰变树中的中间节点。此时Geant4跳过这个母粒子的输运，并在关联初级顶点开始输运其可识别的子粒子。需要母粒子飞行距离的情况，应提供可输运的粒子定义及相应物理过程。#link("https://geant4.web.cern.ch/documentation/dev/bfad_html/ForApplicationDevelopers/Fundamentals/eventGenerator.html")[Geant4外部事例与预定义衰变]

#figure(
  image("pic/chap7-lab/preassigned-decay.png", width: 96%),
  caption: [预先指定的$B^-$衰变链。可输运母粒子先飞行，随后接续生成指定的衰变产物。],
)

强制衰变改变了生成样本中各衰变道的比例。由该样本计算物理产额时，需要保留并使用相应分支比或事例权重。

== 外部产生器与HEPEvt接口

// 第45—46页。
`G4HEPEvtInterface`是`G4VPrimaryGenerator`的一种具体实现。它读取遵循HEPEvt记录格式的ASCII文件，并把外部事例记录转换为Geant4初级顶点和初级粒子。

HEPEvt格式与许多早期Fortran高能物理产生器使用的`/HEPEVT/`公用段对应。外部产生器先完成碰撞或衰变事例的产生，再按接口要求输出记录，Geant4负责后续探测器输运。

- 输入记录需要保留正确的粒子身份、动量和母女关系。
- 空间、时间与能量单位应遵循接口规定并在转换时核对。
- 外部产生器的中间粒子与可输运末态需要正确区分，避免重复衰变或重复输运。

#figure(
  image("pic/chap7-lab/generator-classes.png", width: 96%),
  caption: [内建初级粒子产生器的关系。GPS内部使用`G4SingleParticleSource`描述单个源。],
)

`G4VPrimaryGenerator`统一提供生成初级顶点的接口。粒子枪、GPS和HEPEvt接口都可以在用户的`GeneratePrimaries()`中使用。GPS通过`G4SingleParticleSource`组织一个或多个源，用户动作则负责把本次生成的顶点加入当前事例。#link("https://geant4.web.cern.ch/documentation/dev/bfad_html/ForApplicationDevelopers/Fundamentals/eventGenerator.html")[Geant4事例产生器接口]
