#import "@preview/scripst:1.1.2": *

#show: scripst.with(
  title: [统计数据分析第2次实践作业],
  author: "Anzreww",
  time: "2026年9月",
  cb-counter-depth: 1,
  matheq-depth: 1,
  font-size: 13pt,
  par-leading: 0.6em,
  counter-depth: 1,
)

#exercise(subname: [基础类设计])[
  编写一个 `Particle` 类，包含成员变量：`px`、`py`、`pz`（动量分量）、`mass`（质量）、`charge`（电荷）。实现成员函数：
  + `energy()`：计算能量 $E = sqrt(p^2 + m^2)$，其中 $p^2 = p_x^2 + p_y^2 + p_z^2$。
  + `pt()`：计算横动量 $p_T = sqrt(p_x^2 + p_y^2)$。
  + `eta()`：计算赝快度
    $
      eta = -ln(tan(theta/2)) \
      theta = arccos(p_z/abs(vb(p))) quad abs(vb(p)) = sqrt(p_x^2 + p_y^2 + p_z^2)
    $<->
    其中 $theta$ 为相对于 $z$ 轴的极角。
]

采用自然单位制 $c = 1$，程序中的质量、动量和能量均用 MeV 表示，电荷取元电荷 $e$ 为单位。类中用后缀下划线区分成员变量与访问函数，例如 `mass_` 保存质量，`mass()` 读取质量；将成员设为 `private`，通过构造函数初始化。

#block(sticky: true)[将以下内容保存为 `include/Particle.h`：]
#raw(read("include/Particle.h"), lang: "cpp", block: true)

`energy()`、`pt()` 和 `eta()` 不改变对象，均声明为 `const`。`name()` 和虚析构函数提前为后两题的继承、多态提供接口。

#block(sticky: true)[将成员函数的实现保存为 `src/Particle.cc`：]
#raw(read("src/Particle.cc"), lang: "cpp", block: true)

这里用 `std::hypot` 计算平方和的平方根。对于 $p_T > 0$，由半角公式可得
$
  tan(theta/2) = p_T/(abs(vb(p)) + p_z)
$
因此
$
  eta = ln((abs(vb(p)) + p_z)/p_T) = op("asinh")(p_z/p_T)
$
程序使用等价形式 `std::asinh(pz_ / transverse)`，避免先求极角、再取半角正切。

#block(breakable: false)[
  #note(subname: [边界情况])[
    当 $p_T = 0$ 且 $p_z > 0$ 时，$eta = +infinity$；当 $p_z < 0$ 时，$eta = -infinity$。若三个动量分量均为零，方向未定义，程序返回 `NaN`。
  ]
]

#exercise(subname: [继承])[
  基于第1题的 `Particle` 类，使用继承创建 `Muon` 和 `Electron` 派生类。每个派生类应设置正确的质量和电荷，并添加独特的属性：
  - `Muon`：$m_mu = 105.66 "MeV"$，电荷 $q = -1$；属性 `isTight`（`bool`），表示是否通过紧选择（tight selection）。
  - `Electron`：$m_e = 0.511 "MeV"$，电荷 $q = -1$；属性 `hasConversionVeto`（`bool`），表示是否通过转换（photon conversion）排除。
]

#block(sticky: true)[将以下内容保存为 `include/Muon.h`：]
#raw(read("include/Muon.h"), lang: "cpp", block: true)

#block(sticky: true)[将以下内容保存为 `include/Electron.h`：]
#raw(read("include/Electron.h"), lang: "cpp", block: true)

两个派生类均采用 `public` 继承，在成员初始化列表中调用基类构造函数，固定各自的质量和电荷，再初始化独有的Bool属性。它们继承基类的动量、能量、横动量和赝快度计算方法，并用 `override` 明确重写 `name()`。

#exercise(subname: [多态])[
  编写一个函数 `void PrintParticleInfo(const Particle* p)`，通过多态打印不同粒子的信息（名称、质量、电荷、$p_T$、$eta$）。

  要求验证：当传入 `Muon*` 和 `Electron*` 时，程序能正确调用各自版本的函数。

  提示：需要在基类 `Particle` 中将相关函数声明为 `virtual`（如取得粒子名称的 `name()`），并为其提供 `virtual` 析构函数。
]

#block(sticky: true)[将函数声明保存为 `include/ParticleInfo.h`：]
#raw(read("include/ParticleInfo.h"), lang: "cpp", block: true)

#block(sticky: true)[将函数实现保存为 `src/ParticleInfo.cc`：]
#raw(read("src/ParticleInfo.cc"), lang: "cpp", block: true)

参数 `p` 的静态类型是 `const Particle*`，但 `p->name()` 会根据它实际指向的对象调用 `Muon::name()` 或 `Electron::name()`。质量、电荷和运动学量则由继承的访问函数读取和计算。输出额外列出能量，便于同时检查第1题的实现。

#exercise(subname: [项目工程化])[
  编写主程序文件 `main.cc`，调用 `PrintParticleInfo` 函数，并按照下面要求编译运行：
  + 创建标准目录结构（`include/`、`src/`、`obj/`、`bin/`）。
  + 分别编写 `Makefile` 和 `CMakeLists.txt` 两种编译方式，并验证两者都能成功编译。
  + 运行程序，验证输出结果是否正确。
]

#block(sticky: true)[项目放在 `LAB/2`，目录结构为：]
```text
LAB/2/
├── main.typ
├── main.cc
├── Makefile
├── CMakeLists.txt
├── run-output.txt
├── include/
│   ├── Particle.h
│   ├── Muon.h
│   ├── Electron.h
│   └── ParticleInfo.h
├── src/
│   ├── Particle.cc
│   └── ParticleInfo.cc
├── obj/                  # Make 生成的目标文件和依赖文件
├── bin/                  # Make 生成的可执行文件
└── build/                # CMake 构建时生成
```

#block(sticky: true)[*主程序*]

#block(sticky: true)[将以下内容保存为 `main.cc`：]
#raw(read("main.cc"), lang: "cpp", block: true)

两个对象均在栈上创建，基类指针仅用于访问；离开作用域时对象自动析构，不需要手动 `delete`。把两种派生类指针都交给同一个 `PrintParticleInfo` 函数，便能检查动态绑定是否生效。

#block(sticky: true)[*使用 Makefile 编译*]

#block(sticky: true)[将以下内容保存为 `Makefile`。命令行开头使用 Tab 缩进：]
#raw(read("Makefile"), lang: "make", block: true)

`-Iinclude` 指定头文件目录，`-std=c++17` 指定语言标准，`-O2` 启用优化，`-Wall -Wextra -Wpedantic` 启用常用警告。`-MMD -MP` 自动生成头文件依赖文件，修改头文件后再次运行 `make`，会重新编译受影响的源文件。

在 `LAB/2` 目录运行：
```sh
make
./bin/particles
```

#block(sticky: true)[*使用 CMake 编译*]

#block(sticky: true)[将以下内容保存为 `CMakeLists.txt`：]
#raw(read("CMakeLists.txt"), lang: "cmake", block: true)

仍在 `LAB/2` 目录运行：
```sh
cmake -S . -B build
cmake --build build
./build/bin/particles
```

#block(
  sticky: true,
)[两套构建分别把程序放在 `bin/particles` 和 `build/bin/particles`，可以分别运行并比较输出。本次两种方式均已实际编译、运行，输出完全一致：]
#raw(read("run-output.txt"), lang: "text", block: true)

#block(sticky: true)[*结果核对*]

主程序中，$mu^-$ 的动量为 $(300, 400, 500)$，$e^-$ 的动量为 $(600, 800, -1000)$。代入第1题的公式：
$
  p_(T,mu) = sqrt(300^2 + 400^2) = 500, quad p_(T,e) = sqrt(600^2 + 800^2) = 1000
$
$
  E_mu = sqrt(300^2 + 400^2 + 500^2 + 105.66^2) approx 714.957366\
  E_e = sqrt(600^2 + 800^2 + (-1000)^2 + 0.511^2) approx 1414.213655
$
两者的 $p_z/p_T$ 分别为 $+1$、$-1$，因此
$
  eta_mu = ln(1 + sqrt(2)) approx 0.881374, quad eta_e = -ln(1 + sqrt(2)) approx -0.881374
$

运行结果与上述计算一致。通过基类指针分别输出 `Muon`、`Electron`，且质量、电荷与两种布尔属性均符合构造时的设定，说明继承和多态按预期工作。
