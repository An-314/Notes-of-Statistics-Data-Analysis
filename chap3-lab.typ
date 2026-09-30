#import "@preview/scripst:1.1.2": *

#pagebreak(weak: true)

= C++的参数传递、编译与调试

本讲内容：
- 函数参数
- `const`类型
- C++速成例子2：`VolCuboid`
- 编译并执行C++程序
- GDB调试器

*学习目标*：在可借助资源的情况下，读懂相关C++程序，并能够运用本讲介绍的方法。

== 函数参数

=== 形参与实参

*形参（formal parameter）*是在函数声明或定义中写出的参数，用来说明函数接收的数据类型；*实参（actual argument）*是调用函数时实际传入的表达式或数据。

```cpp
void byRef(int& x) {  // x：形参
    x = 999;
}

int main() {
    int a = 10;
    byRef(a);        // 本次调用中的 a：实参
}
```

这里`x`是`a`的引用，因此函数执行后`a`变为`999`。

选择参数传递方式时，主要关注两点：*函数调用的效率*，以及*实参是否会被函数改变*。

=== 三种传递方式

要把一个包含四动量、质量、电荷等信息的`Particle`对象传给函数，有三种写法：

```cpp
double InvariantMass1(Particle p1, Particle p2);    // 传值
double InvariantMass2(Particle& p1, Particle& p2);  // 引用
double InvariantMass3(Particle* p1, Particle* p2);  // 指针
```

+ *传值*：形参是实参的副本，修改副本不直接改变原对象；对于较大的对象，复制有一定开销。
+ *引用*：形参是实参的“别名”，通过引用操作的就是原对象。有效引用必须绑定对象，不能用空引用表示“没有对象”。
+ *指针*：传入对象的地址，通过指针可访问、修改原对象；指针也可以取`nullptr`，用于表示可选参数。

若一个对象包含100个`double`成员，按每个`double`占8字节估算，一份数据约为800字节；复制100万次约涉及800 MB的数据。对于频繁调用的函数，应考虑避免不必要的大对象复制。

#block(breakable: false)[
  #note(subname: [补充：复制开销与指针参数])[
    800字节是单个对象的粗略估算；若每次复制两个这样的参数，数据量还要相应增加。实际开销与对象的复制行为、内存布局和编译优化有关，不能把数据量直接等同于运行时间。

    指针参数本身仍是按值传递的，只是复制的是地址。修改`*p`可以改变所指对象；仅在函数内给`p`重新赋值，不会改变调用者保存的指针。
  ]
]

=== 复印、位置与书签

// 来源：第5页。
拿“让朋友读我的书”作类比：
- 传值相当于*复印一本书*：涂改复印件不影响原书，但复印需要成本。
- 引用相当于*告诉朋友书的位置*：朋友直接读写原书，高效，但可能改坏它。
- 指针相当于*给一个书签*：它可以指向一本书，也可以指向“空”，适合可选参数。

#figure(
  three-line-table[
    | 方式 | 开销 | 能否通过参数修改原对象 | 常见用途 |
    | --- | --- | --- | --- |
    | 传值 | 复制对象；大对象可能开销较大 | 不直接修改原对象 | `int`、`double`等小对象 |
    | 引用 | 不复制整个对象 | 可以，除非受`const`限制 | 大对象，且需要修改 |
    | 指针 | 复制地址，不复制整个对象 | 可以，除非受`const`限制 | 大对象，允许传`nullptr` |
  ],
)

*选择原则*：大对象优先考虑引用，内置类型通常用传值；“可能没有值”的参数可以用指针。若只需读取大对象，可使用后面介绍的常量引用。

=== 课堂练习：指针调用

// 来源：第6页，单选题1分；页面标示C。
#block(breakable: false)[
  #exercise(subname: [调用方式与返回值])[
    判断下面的调用方式和主程序返回值。
    ```cpp
    #include <iostream>
    using namespace std;

    class Square {
    public:
        int side;
        Square(int s) : side(s) {}
        void modifySide(Square* s) {
            s->side = 10;
        }
    };

    int main() {
        Square sq(5);
        sq.modifySide(&sq);
        return sq.side;
    }
    ```
    - A. 引用调用／10
    - B. 传值调用／5
    - C. 指针调用／10
    - D. 指针调用／5
  ]
]

答案为*C*。传入的是`sq`的地址，`s->side = 10;`修改了原对象，因此`main()`返回`10`。这里问的是返回值，程序并没有把`10`打印到终端。

== const类型

=== 为什么使用const

// 来源：第7页。
引用和指针可以避免复制整个对象，但也可能改变原始数据。如果既希望高效调用，又希望保护数据、防止随意修改，可以使用`const`：

```cpp
void analyze(const Particle& p);  // 通过 p 只读地访问对象
```

也可以使用指向常量对象的指针：

```cpp
void analyze(const Particle* p);
```

`const`是C++类型系统的一部分。编译器在编译时检查相应约束，使一类错误在程序运行前就暴露出来。本讲主要讨论`const`成员变量、`const`成员函数和`const`对象。

#block(breakable: false)[
  #note(subname: [转录说明])[
    第7页的声明把引用、指针符号与注释混排为`const Particle &/* x`；这里分别写成合法的常量引用和常量指针声明。`const Particle* p`限制的是通过`p`修改所指对象，并不禁止让指针变量`p`改指其他对象。
  ]
]

=== const成员变量

// 来源：第8页。
声明形式为`const 类型 成员变量名;`。常量成员必须初始化，之后不能在普通成员函数中重新赋值。下面通过构造函数的*成员初始化列表*初始化`hour`：

```cpp
class Time {
public:
    Time(int h = 0, int m = 0, int s = 0);
private:
    const int hour;
    int minute;
    int second;
};

Time::Time(int h, int m, int s)
    : hour(h), minute(m), second(s) {}
```

`hour(h)`是在初始化成员；若改成在构造函数体内写`hour = h;`，就变成了给常量成员赋值，不能通过编译。

#block(breakable: false)[
  #note(subname: [补充：初始化的位置])[
    成员初始化列表不是唯一写法，C++11起也可以提供类内默认成员初始值，例如`const int hour = 0;`。要区分初始化与赋值；这里的关键是常量成员不能先不初始化，再在构造函数体内赋值。
  ]
]

=== const成员函数

// 来源：第9页。
在成员函数的参数表之后加`const`：

```text
返回类型 函数名(参数表) const;
```

它表示该成员函数通过当前对象的常量视图工作，适合查询对象状态。例如：

```cpp
class Test {
public:
    Test() {}
    Test(int _m) : _cm(_m) {}
    int get_cm() const {
        return _cm;
    }
private:
    int _cm;
};
```

`get_cm()`只读取`_cm`，因此可以声明为`const`。

#block(breakable: false)[
  #note(subname: [补充：默认构造函数])[
    此例保留了`Test() {}`。它没有初始化`_cm`，所以不能在默认构造后直接读取该成员。若需要默认构造后即可读取，可改成`Test() : _cm(0) {}`。后面的`Test t(8);`通过带参构造函数完成了初始化。
  ]
]

// 来源：第10页。
对于`const`成员函数：
+ 不能通过当前对象修改普通的非静态数据成员。
+ 不能通过当前对象调用非`const`成员函数。
+ 例外是使用`mutable`声明的成员，可以修改。
+ `const`对象只能调用对它有效的`const`非静态成员函数；不改变对象逻辑状态的查询函数应尽量声明为`const`。

```cpp
class Test {
public:
    Test(int _m, int _t) : _cm(_m), _ct(_t) {}
    void Kf() const {
        ++_cm;  // 错误：不能修改普通成员
        ++_ct;  // 正确：可以修改 mutable 成员
    }
private:
    int _cm;
    mutable int _ct;
};
```

这个例子有意包含错误语句，不能直接编译；去掉`++_cm;`后，`++_ct;`可以保留。

=== mutable的典型用途：缓存

// 来源：第11页。
若需要缓存计算结果以加速后续调用，可以让缓存成员为`mutable`，而查询接口仍保持`const`：

```cpp
class Polygon {
    mutable double cachedArea;
    mutable bool areaValid;
public:
    double area() const {
        if (!areaValid) {
            cachedArea = computeArea();
            areaValid = true;
        }
        return cachedArea;
    }
};
```

第一次计算后保存面积，再次调用时直接返回缓存。缓存的更新不改变图形的逻辑属性。

#block(breakable: false)[
  #note(subname: [补充：把缓存示意写完整])[
    上面是接口片段。实际使用前必须初始化`areaValid`，例如写成`mutable bool areaValid = false;`，并提供可在`const`函数中调用的`computeArea() const`。图形尺寸改变时还应将缓存标记为失效。

    `mutable`适合缓存等不改变逻辑状态的内部数据，不应仅为绕开`const`检查而滥用。
  ]
]

=== const对象与常量引用

// 来源：第12页。
用`const`声明的对象称为*常量对象*。若`Time`提供非`const`修改接口`setTime()`，下面的调用不允许：

```cpp
const Time t(20, 20, 20);
t.setTime(30, 39, 39);  // 错误：不能对常量对象调用修改接口
```

对前面的`Test`类，函数可以使用常量引用接收对象：

```cpp
void Cmf(const Test& _tt) {
    cout << _tt.get_cm();
}

int main(void) {
    Test t(8);
    Cmf(t);
    return 0;
}
```

常量引用避免复制整个对象，又限制通过参数修改对象。这对类对象作为输入参数尤为常用。`int`、`double`等内置类型在只读输入时通常直接传值；需要修改调用者变量时，仍可以使用引用。

#block(breakable: false)[
  #note(subname: [转录说明])[
    这段代码与前面的`Test`定义组合使用，并包含`<iostream>`和相应命名空间声明，输出`8`。原页中的`system("pause");`用于特定系统下等待按键，整理时省略，以便在Linux终端运行。
  ]
]

=== 没有const保护时的错误

// 来源：第13页。
假设某函数只负责读取粒子信息并计算运动学量：

```cpp
void computeKinematics(Particle& p) {
    double pt = sqrt(p.px() * p.px() + p.py() * p.py());
    // ... 计算 ...
    p.setMass(0);  // 手误或复制粘贴错误，改变了原对象
}
```

编译器不会阻止上面的修改，分析结果可能悄悄变错。若把接口改为常量引用：

```cpp
void computeKinematics(const Particle& p) {
    double pt = sqrt(p.px() * p.px() + p.py() * p.py());
    p.setMass(0);  // 编译错误：不能调用非 const 修改函数
}
```

这时编译器就能发现错误。*`const`的价值，是把一部分可能长期隐藏的运行时错误提前到编译时检查*。第二段保留了故意写错的`setMass()`调用，并修正了原页`sqrt`表达式末尾多余的括号。

=== 回顾Shape：const指针参数与多态

// 来源：第14页。
上一讲的`Shape`例子同时使用了纯虚函数、`const`成员函数和指向常量的基类指针：

```cpp
#include <iostream>
#include <string>
using namespace std;

class Shape {
protected:
    int x, y;
    string color;
public:
    Shape(int x, int y, const string& color)
        : x(x), y(y), color(color) {}
    virtual void draw() const = 0;
    virtual double area() const = 0;
    virtual ~Shape() {}
};
```

```cpp
class Circle : public Shape {
private:
    int radius;
public:
    Circle(int x, int y, const string& color, int radius)
        : Shape(x, y, color), radius(radius) {}
    void draw() const {
        // 实现绘制圆形的代码
    }
    double area() const {
        return 3.14159 * radius * radius;
    }
};

double GetArea(const Shape* sh) {
    return sh->area();
}
```

```cpp
int main() {
    Shape* p1 = new Circle(0, 0, "RED", 3);
    cout << GetArea(p1) << endl;
    delete p1;  // 补充：释放动态创建的对象
    return 0;
}
```

`const Shape*`使`GetArea()`只能通过`sh`调用相应的常量接口；`virtual`仍根据实际对象选择`Circle::area()`。示例补齐了头文件与资源释放语句，面积的默认输出为`28.2743`。

== C++速成例子2：VolCuboid

=== 文件与目录结构

// 来源：第15—16页。
项目将不同用途的文件放在不同目录，便于维护管理：
- `include/`：头文件。
- `src/`：源文件。
- `obj/`：目标文件（object file）。
- `bin/`：可执行文件。

```text
VolCuboid/
├── Makefile
├── Makefile.easy
├── Makefile.not.easy
├── build.sh
├── compile.sh
├── include/
│   └── VolCuboid.h
├── src/
│   ├── VolCuboid.cc
│   └── main.cc
├── obj/
│   ├── VolCuboid.o
│   └── main.o
└── bin/
    └── VolCub
```

可用`tree -C`查看带颜色的目录树。工作目录中还可能有输入参数文件等辅助文件；`obj/`和`bin/`中的文件是编译后的产物。

=== 类定义：头文件

// 来源：第17页；代码由页面截图转录。
文件`include/VolCuboid.h`定义长方体类，声明构造函数、析构函数、计算体积与表面积的成员函数，以及长、宽、高三个成员变量。

```cpp
#ifndef VOLCUBOID_H
#define VOLCUBOID_H

#include <iostream>

class VolCuboid {
public:
    VolCuboid(float x, float y, float z);
    ~VolCuboid();
    float Vol();
    float Area();
private:
    float length, width, height;
};

#endif
```

`#ifndef`、`#define`与`#endif`组成头文件保护，防止同一个头文件在同一翻译单元中被重复展开。`Vol()`返回体积，`Area()`返回表面积，不能把两者混淆。

=== 类实现：源文件

// 来源：第18页；代码由页面截图转录。
文件`src/VolCuboid.cc`给出各成员函数的具体实现：

```cpp
#include "VolCuboid.h"

VolCuboid::VolCuboid(float x, float y, float z) {
    length = x;
    width = y;
    height = z;
}

VolCuboid::~VolCuboid() {
    // 若拥有动态分配的资源，应在这里释放。
    // 本例只有三个 float 成员，无需额外操作。
}

float VolCuboid::Vol() {
    return length * width * height;
}

float VolCuboid::Area() {
    float area;
    area = 2 * length * width + 2 * length * height
         + 2 * width * height;
    return area;
}
```

数学上，若长、宽、高分别为$l,w,h$，则
$
  V = l w h, quad S = 2(l w + l h + w h).
$

#block(breakable: false)[
  #note(subname: [补充：与const成员函数联系])[
    `Vol()`与`Area()`只读取尺寸，可以把声明和定义都改为`const`成员函数，例如`float Vol() const;`及`float VolCuboid::Vol() const { ... }`。这里保持原例子的接口，以便与后面的编译示例对应。
  ]
]

=== 使用类：主函数

// 来源：第19—20页；将两页主函数片段依次转录。
在`src/main.cc`中包含头文件，主函数才能找到类的定义。先生成一个普通对象，通过`.`访问成员：

```cpp
#include <iostream>
#include "VolCuboid.h"
using namespace std;

int main() {
    cout << "Class VolCuboid " << endl;
    float length, width, height;
    length = 2.0;  // cm
    width = 3.0;   // cm
    height = 4.0;  // cm

    VolCuboid myVolCuboid(length, width, height);
    float volume = myVolCuboid.Vol();
    cout << "Volume is " << volume << " cm^3" << endl;
    cout << "Area is " << myVolCuboid.Area() << " cm^2" << endl;
```

接着在同一`main()`中使用指针和动态内存分配创建对象，通过`->`访问成员：

```cpp
    // use pointer
    VolCuboid* pVolCuboid = new VolCuboid(length, width, height);
    volume = pVolCuboid->Vol();
    cout << endl;
    cout << "Operation with pointer" << endl;
    cout << "Volume is " << volume << " cm^3" << endl;
    cout << "Area is " << pVolCuboid->Area() << " cm^2" << endl;

    delete pVolCuboid;  // 补充：释放 new 创建的对象
    return 0;          // 补全主函数结尾
}
```

两种写法计算的体积都为$24 "cm"^3$，表面积都为$52 "cm"^2$。注意`new VolCuboid(...)`返回指针，不能把它直接赋给普通的`VolCuboid`对象。

=== 指针与地址

// 来源：第20页。
内存可以类比有编号的小房间，每个位置有地址。指针中保存的是数据所在的地址，知道地址就可以找到对象。取地址运算符`&`得到地址，解引用运算符`*`访问所指对象：

```cpp
int i = 2;
int* p = &i;
cout << "address: " << p << endl;
cout << "value: " << *p << endl;
```

第二行输出的值为`2`。地址则与具体运行有关，原例中的`0x103d870d0`只是一次运行结果。

#figure(
  three-line-table[
    | 表达式 | 含义 |
    | --- | --- |
    | `i` | 整数对象，值为2 |
    | `&i` | 对象`i`的地址 |
    | `p` | 保存了`i`的地址的指针 |
    | `*p` | 通过指针访问`i`，值为2 |
  ],
)

=== 段错误

// 来源：第21页。
程序代码与数据位于进程的地址空间中，访问受到内存映射和权限限制。错误的指针访问可能引发*段错误（segmentation fault）*，例如：

```cpp
int* p = nullptr;
*p = 100;  // 错误：解引用空指针
```

#block(breakable: false)[
  #note(subname: [补充：错误不一定立即表现为崩溃])[
    空指针解引用、越界访问、使用已经释放的对象等都属于无效内存访问的常见来源。它们可能触发段错误，也可能暂时没有可见异常；不能以“这次没崩溃”作为程序正确的依据。
  ]
]

== 从代码到程序：编译、链接与工程化

// 来源：第22页。
接下来仍使用`VolCuboid`例子，依次介绍直接调用`g++`、使用Makefile和使用CMake三种构建方式。

=== 编译与链接

// 来源：第23页。
从源代码生成程序可以分成两步：
+ *编译（compile）*：把源文件编译成目标文件，常见后缀为`.o`。
+ *链接（link）*：把多个目标文件和需要的库组合成可执行文件。

一次`g++`调用也可以完成这两个阶段。`Lec3/VolCuboid/build.sh`的内容为：

```bash
#!/bin/bash
g++ -o bin/try -Iinclude/ src/*.cc
```

其中`-Iinclude/`指定头文件搜索目录，`src/*.cc`选取源文件，`-o bin/try`指定输出可执行文件。运行后可以执行`./bin/try`。

两步法`compile.sh`写成：

```tcsh
#!/bin/tcsh
g++ -c -I./include/ src/*.cc
g++ -o bin/try *.o
rm -f *.o
```

第一行编译命令使用`-c`，只生成目标文件，不进行链接。第二行将当前目录的`.o`文件链接为`bin/try`，最后清理中间文件。

#block(breakable: false)[
  #note(subname: [补充：运行目录])[
    这些命令应在示例项目根目录运行，并事先准备好`bin/`；后面的Makefile还需要`obj/`。可用`mkdir -p bin obj`创建。脚本中的通配符和清理命令针对这个示例目录，不应在混有其他项目产物的目录中直接照搬。
  ]
]

=== g++常用参数

// 来源：第23—24页。
#figure(
  three-line-table[
    | 参数 | 含义 | 典型用法 |
    | --- | --- | --- |
    | `-o file` | 指定输出文件名 | `g++ -o myprog main.cc` |
    | `-I dir` | 增加头文件搜索路径 | `-I./include` |
    | `-L dir` | 增加链接时的库搜索路径 | `-L/usr/local/lib` |
    | `-l name` | 按名称链接库 | `-lCore` |
    | `-c` | 只编译，不链接 | `-c src/*.cc` |
    | `-g` | 生成调试信息 | `-g -Wall` |
    | `-O2` | 使用2级优化 | `-O2` |
    | `-Wall` | 启用一组常见警告 | `-Wall` |
    | `-std=c++17` | 指定C++语言标准 | `-std=c++17` |
  ],
)

#block(breakable: false)[
  #note(subname: [勘误与补充：编译选项])[
    - `-Wall`并非启用所有可选警告，还可使用`-Wextra`等选项，见#link("https://gcc.gnu.org/onlinedocs/gcc/Warning-Options.html")[GCC警告选项文档]。
    - `-lfoo`按平台和链接选项查找`libfoo.so`或`libfoo.a`等库文件，并不只针对动态库。原表的`-lROOT`只是示意，实际ROOT库参数应由`root-config --libs`获取。
    - `-g`为按源码行号、变量名调试提供信息；没有这些信息也可能调试机器指令，但源码层面的信息会受限。
  ]
]

=== Makefile：自动化编译

// 来源：第25页。
当源文件增多时，Makefile可以定义依赖关系，决定先编译哪些文件、后编译哪些文件，以及哪些目标需要重新生成。

基本语法为：

```text
target: dependencies
<Tab>command
```

命令行开头是实际的制表符（Tab），不是上面显示的`<Tab>`文字。简单的`Makefile.easy`为：

```make
default: hello

hello:
	g++ -o bin/hello -Iinclude/ src/*.cc

clean:
	rm -f obj/*.o bin/*
```

可以在`make`后面选择Makefile和目标：

```bash
make -f Makefile.easy
make clean -f Makefile.easy
make hello -f Makefile.easy
```

未指定目标时，默认从第一个普通目标开始；这里`default`依赖`hello`，因此会执行生成程序的命令。

=== 较完整的Makefile

// 来源：第26—27页。
先设置目录和编译器，并自动发现源文件：

```make
# 路径设置
TOP := $(shell pwd)/
OBJ := $(TOP)obj/
BIN := $(TOP)bin/
SRC := $(TOP)src/
INCLUDE := $(TOP)include/

# 编译器设置
CPP = g++
CPPFLAGS = -O -Wall -fPIC -I$(INCLUDE)

# 源文件与目标文件列表
SOURCES := $(wildcard $(SRC)*.cc)
OBJECTS := $(patsubst $(SRC)%.cc,$(OBJ)%.o,$(SOURCES))

# 默认目标
all: VolCub
```

接着定义链接、编译与清理规则：

```make
# 链接
VolCub: $(OBJECTS)
	$(CPP) $^ $(CPPLIBS) -o $(BIN)$@

# 编译：每个 .cc 对应一个 .o
$(OBJ)%.o: $(SRC)%.cc
	$(CPP) $(CPPFLAGS) -c $< -o $@

# 清理
clean:
	rm -f $(OBJ)*.o $(BIN)*

.PHONY: all clean
```

`-O`使用基本优化，`-fPIC`生成位置无关代码；这两个选项沿用原例。`CPPLIBS`预留给链接库参数，未定义时展开为空。

#block(breakable: false)[
  #note(subname: [补充：目标名称与实际文件])[
    原例的目标名是`VolCub`，实际输出却是`bin/VolCub`，所以再次执行`make`时可能仍然链接。若希望目标与实际文件一致，可把默认依赖和链接规则改成下面的写法。

    原例也没有声明头文件依赖；修改`include/VolCuboid.h`后，应重编译相应目标文件。更完整的工程可以使用`-MMD -MP`生成依赖文件。
  ]
]

```make
# 补充：替换原来的 all 与 VolCub 链接规则
all: $(BIN)VolCub

$(BIN)VolCub: $(OBJECTS)
	$(CPP) $^ $(CPPLIBS) -o $@
```

=== Makefile核心语法与ROOT链接

// 来源：第28页。
#figure(
  three-line-table[
    | 语法 | 含义 |
    | --- | --- |
    | `$(wildcard pattern)` | 返回通配符匹配的文件列表 |
    | `$(patsubst pat,rep,text)` | 对列表进行模式替换 |
    | `$<` | 当前规则的第一个依赖文件 |
    | `$^` | 当前规则的全部普通依赖文件，重复项只保留一次 |
    | `$@` | 当前规则的目标名 |
    | `.PHONY: target` | 声明不对应实际文件的伪目标 |
  ],
)

链接ROOT需要知道其头文件与库文件的位置，可用以下Shell命令获得：

```bash
root-config --cflags
root-config --libs
```

示意输出分别为：

```text
-I/usr/local/root/include
-L/usr/local/root/lib -lCore -lHist ...
```

把查询结果加入Makefile：

```make
ROOTCFLAGS := $(shell root-config --cflags)
ROOTLIBS := $(shell root-config --libs)
CPPFLAGS += $(ROOTCFLAGS)
CPPLIBS += $(ROOTLIBS)
```

实际输出依ROOT的安装位置和构建配置而变，不应直接把示意路径写死。

=== CMake

// 来源：第29页。
CMake用于生成Makefile等构建系统所需的文件。示例位于`Lec3/CMake/VolCuboid`，在项目根目录提供`CMakeLists.txt`。

首先设置项目、编译选项与头文件目录：

```cmake
cmake_minimum_required(VERSION 3.8...3.18)
if(${CMAKE_VERSION} VERSION_LESS 3.12)
    cmake_policy(VERSION ${CMAKE_MAJOR_VERSION}.${CMAKE_MINOR_VERSION})
endif()

project(VolCuboid)
set(DESTINATION ${PROJECT_SOURCE_DIR})
add_compile_options(-g -O -Wall -fPIC)
include_directories(${PROJECT_SOURCE_DIR}/include)
```

接着查找ROOT，并读取源文件与头文件列表：

```cmake
find_package(ROOT CONFIG REQUIRED COMPONENTS
    Core RIO RooFit RooFitCore RooStats Hist Tree Matrix Physics MathCore)
include(${ROOT_USE_FILE})
include_directories(${ROOT_INCLUDE_DIRS})

file(GLOB sources ${PROJECT_SOURCE_DIR}/src/*.cc)
file(GLOB headers ${PROJECT_SOURCE_DIR}/include/*.h)
```

最后添加可执行文件、链接库并指定安装位置：

```cmake
add_executable(VolCub main.cc ${sources} ${headers})
target_link_libraries(VolCub ${ROOT_LIBRARIES})
install(TARGETS VolCub DESTINATION ${PROJECT_SOURCE_DIR}/bin)
```

这个CMake例子将`main.cc`单列为根目录文件，和前面`src/main.cc`的目录结构不同。若沿用前面的结构，`sources`已经包含主函数文件，生成可执行文件时应写成：

```cmake
# 补充：主函数放在 src/main.cc 时的写法
add_executable(VolCub ${sources} ${headers})
```

按原例使用Makefile生成器时，在项目根目录执行：

```bash
mkdir build
cd build
cmake ..
make
make install
```

源文件与构建产物分开保存；`build/`作为本项目专用构建目录可以删除后重新生成。

#block(breakable: false)[
  #note(subname: [补充：CMake命令的含义])[
    `cmake_minimum_required(VERSION 3.8...3.18)`指定最低版本，并给出策略兼容范围，`3.18`不是允许使用的最高CMake版本。见#link("https://cmake.org/cmake/help/latest/command/cmake_minimum_required.html")[CMake文档]。

    `install()`使用的`${PROJECT_SOURCE_DIR}/bin`是绝对路径，安装目标直接指向项目的`bin/`。只计算长方体的程序并不依赖ROOT；这里保留ROOT相关设置，是为了演示需要外部库时如何配置。
  ]
]

== GDB调试器

=== GDB的主要功能

// 来源：第30页。
GDB（the GNU Project Debugger）是功能强大的命令行调试器，可以查看程序运行时的内部状态，以及崩溃时正在执行的操作。

主要功能包括：
+ *断点管理*：设置、启用、禁用和删除断点，在特定行、函数或满足条件时暂停执行。
+ *程序控制*：启动、暂停、单步执行和继续运行程序。
+ *变量检查*：查看或修改变量值、内存内容与寄存器状态。
+ *堆栈分析*：查看函数调用堆栈，了解执行路径和上下文。
+ *内存检查*：检查特定地址的内容，搜索内存区域。
+ *核心转储分析*：分析程序崩溃时生成的core dump。

官方文档入口：#link("https://www.gnu.org/software/gdb/")[GNU GDB]。

=== 编译与启动调试

// 来源：第31页。
为程序生成调试信息：

```bash
g++ main.cc -g -Wall -o main
```

然后选择启动方式：

```bash
gdb main       # 调试可执行文件
gdb -tui main  # 终端中的文本用户界面
gdb -p pid     # 附加到指定 PID 的运行中进程
```

`pid`需替换为实际进程号。`-tui`提供终端内的源码等窗口，并不是另开一个图形桌面界面。附加已有进程还需要相应的调试权限。

在GDB提示符后，可以尝试下面的命令；行号、变量名和栈帧号应按具体程序调整：

```text
(gdb) break 11
(gdb) run
(gdb) step
(gdb) list
(gdb) watch n
(gdb) watch result
(gdb) continue
(gdb) backtrace
(gdb) frame number
```

```text
(gdb) b 8 if i == 10
(gdb) next
(gdb) info breakpoints
(gdb) disable
(gdb) print val
(gdb) next
(gdb) continue
(gdb) quit
```

`b 8 if i == 10`是条件断点。`watch n`在被监视值变化时停止。`frame number`中的`number`是栈帧编号，原页拼写`numbe`在此补全。

=== 常用GDB命令

// 来源：第32页；分组列出原页的全部命令。
#block(sticky: true)[*运行控制*]

#figure(
  three-line-table[
    | 命令 | 常用缩写 | 作用 |
    | --- | --- | --- |
    | `run` | `r` | 启动被调试程序 |
    | `continue` | `c` | 继续执行暂停的程序 |
    | `next` | `n` | 在当前栈帧内按源码行执行，通常跨过函数调用 |
    | `step` | `s` | 按源码行执行，有调试信息时进入被调用函数 |
    | `until` | `u` | 执行到指定位置，或运行越过当前循环位置 |
    | `finish` | `fin` | 运行至当前函数正常返回 |
    | `return` | `return` | 强制当前函数返回，可指定返回值 |
    | `jump` | `j` | 改变接下来执行的位置 |
  ],
)

`finish`会实际执行完函数；`return`则改变调试状态，使其直接返回。`step`和`next`的区别，可通过后面的多态示例观察。参见#link("https://sourceware.org/gdb/current/onlinedocs/gdb.html/Continuing-and-Stepping.html")[GDB单步执行文档]。

#block(sticky: true)[*断点与监视点*]

#figure(
  three-line-table[
    | 命令 | 常用缩写 | 作用 |
    | --- | --- | --- |
    | `break` | `b` | 添加断点 |
    | `tbreak` | `tb` | 添加命中一次后自动删除的临时断点 |
    | `delete` | `d` | 删除指定断点，省略编号时可删除全部 |
    | `enable` | `enable` | 启用断点 |
    | `disable` | `disable` | 禁用断点 |
    | `watch` | `watch` | 监视表达式或内存位置的值是否改变 |
  ],
)

#block(sticky: true)[*检查状态与设置参数*]

#figure(
  three-line-table[
    | 命令 | 常用缩写 | 作用 |
    | --- | --- | --- |
    | `print` | `p` | 显示表达式、变量或寄存器的值 |
    | `backtrace` | `bt` | 查看当前线程的调用堆栈 |
    | `frame` | `f` | 选择指定栈帧 |
    | `thread` | `thread` | 切换到指定线程 |
    | `list` | `l` | 显示源代码 |
    | `info` | `i` | 查看断点、线程、局部变量等信息 |
    | `ptype` | `ptype` | 查看表达式或变量的类型 |
    | `disassemble` | `disas` | 查看汇编代码 |
    | `set args` | `set args` | 设置程序启动时的命令行参数 |
    | `show args` | `show args` | 查看已设置的命令行参数 |
  ],
)

#block(breakable: false)[
  #note(subname: [勘误：缩写应当无歧义])[
    原表将`disassemble`缩写为`dis`，但本机GDB实际把`dis`识别为`disable`，不能用它代替反汇编命令；这里使用`disas`。`finish`采用`fin`。记不清缩写时，直接输入完整命令最清楚。
  ]
]

=== 查看运行流程：多态示例

// 来源：第33页；代码保持原例40行布局，保证断点行号对应。
用`break`、`run`和`step`观察函数调用。下面的`polygen.C`沿用上一讲的多态例子，保留原页的行布局，关键调用位于第35—38行。

```cpp
// virtual members
#include <iostream>
using namespace std;

class Polygon {
  protected:
    int width, height;
  public:
    void set_values (int a, int b)
      { width=a; height=b; }
    virtual int area ()
     { return 0; }
};

class Rectangle: public Polygon {
  public:
    int area ()
      { return width * height; }
};

class Triangle: public Polygon {
  public:
    int area () { return (width * height / 2); }
};
```

```cpp

int main () {
  Rectangle rect;
  Triangle trgl;
  Polygon poly;
  Polygon * ppoly1 = &rect;
  Polygon * ppoly2 = &trgl;
  Polygon * ppoly3 = &poly;
  ppoly1->set_values (4,5);
  ppoly2->set_values (4,5);
  ppoly3->set_values (4,5);
  cout << ppoly1->area() << '\n';
  cout << ppoly2->area() << '\n';
  cout << ppoly3->area() << '\n';
  return 0;
}
```

以上两个代码块直接依次拼接。然后编译并启动：

```bash
g++ polygen.C -g -Wall -o polygen
gdb polygen
```

原例中的调试过程如下，省略机器相关的地址与路径：

```text
(gdb) break 35
Breakpoint 1 ... file polygen.C, line 35.
(gdb) run
Breakpoint 1, main () at polygen.C:35
35  ppoly3->set_values (4,5);
(gdb) step
Polygon::set_values (..., a=4, b=5) at polygen.C:10
10  { width=a; height=b; }
(gdb) next
main () at polygen.C:36
36  cout << ppoly1->area() << '\n';
(gdb) info locals
```

此时可以检查`rect`、`trgl`、`poly`的`width`与`height`，以及三个指针指向的对象。原例的局部变量显示还包含虚函数表相关字段，例如`vtable for Rectangle`，用于观察不同对象的实际类型。

继续执行：

```text
(gdb) step
Rectangle::area (...) at polygen.C:18
18  { return width * height; }
```

虽然`ppoly1`的类型是`Polygon*`，实际进入的仍是`Rectangle::area()`，这正是虚函数的动态绑定。完整运行的输出为`20`、`10`、`0`。

// 来源：第34页。
在终端中也可以先查看示例目录，再以TUI方式调试：

```bash
cd gdb
ls
ls -rtl
gdb -tui polygen
```

这里的`gdb/`是示例目录名；`gdb`命令是调试器。实际运行时根据文件所在位置调整目录。

=== 使用GDB分析core文件

// 来源：第35页。
程序发生段错误等崩溃时，系统可能把当时的内存与执行状态保存为*核心转储（core dump）*。分析core可以定位崩溃现场。

首先查看资源限制，并允许生成较大的core文件：

```bash
ulimit -a
ulimit -c unlimited
```

`ulimit -c`控制当前Shell及其子进程的core大小限制；若受硬限制约束，设置也可能失败。

若当前目录没有出现core，可能是系统将其交给了统一的崩溃收集服务。在使用systemd-coredump的系统中，可以查询并导出：

```bash
coredumpctl list | tail -5
coredumpctl dump 9894 -o core
```

`9894`是示例PID，必须换成列表里所需进程的实际编号。没有core也可能与转储设置、保留策略或访问权限有关，不能只凭当前目录中没有文件就判断没有崩溃记录。

=== 生成一个稍复杂的崩溃例子

// 来源：第36页；test.C代码由页面截图转录，保留第9行为错误语句。
下面的`test.C`有意进行越界访问：

```cpp
#include <vector>
using namespace std;

int main(int argc, char const *argv[])
{
    vector<int> a;
    vector<int> b;

    b.push_back(a[0]);

    return 0;
}
```

`a`刚创建时为空，因此`a[0]`没有对应元素。问题在于向`b.push_back()`提供了无效的访问结果。

原例中执行：

```bash
g++ -g test.C -o test
./test
```

随后出现：

```text
Segmentation fault (core dumped)
```

并产生了名为`core.18983`的文件。具体文件名与保存位置取决于系统配置；越界访问本身是未定义行为，不能保证在所有机器上都以同样方式崩溃。

=== 系统保存core时的提取脚本

// 来源：第37页；保留gencor.sh原例，再单独指出修正。
原页给出的`gencor.sh`尝试从系统服务提取core：

```bash
#!/bin/bash
ulimit -c unlimited

dump_core() {
    local pid=$!
    sleep 1
    coredumpctl dump "$pid" -o "core.$pid" 2>/dev/null ||
        systemd-coredumpctl --user dump "$pid" \
            -o "core.$pid" 2>/dev/null
}

./test & dump_core &
echo "PID=$!"
```

#block(breakable: false)[
  #note(subname: [勘误：保存正确的PID])[
    `./test & dump_core &`连续启动两个后台任务，最后的`$!`对应后台提取任务，不能再用它当作`test`的PID。固定等待1秒也不保证转储已完成；备用命令`systemd-coredumpctl --user`还依赖系统是否提供该接口。

    更清楚的做法是在启动`test`后立即保存它的PID，等待程序退出，再提取该PID对应的记录。下面给出使用`coredumpctl`的补充写法。
  ]
]

```bash
#!/usr/bin/env bash
# 补充写法：在示例目录运行，保存 test 的 PID
ulimit -c unlimited || exit 1
./test &
test_pid=$!
printf 'PID=%s\n' "$test_pid"
wait "$test_pid"

# 崩溃收集服务可能稍后才完成写入，短暂重试
for attempt in 1 2 3 4 5; do
    if coredumpctl dump "$test_pid" -o "core.$test_pid"; then
        exit 0
    fi
    sleep 1
done
printf '未能导出core，请检查coredumpctl记录和权限。\n' >&2
exit 1
```

这里只保存和导出本次示例进程的转储。脚本不保证所有系统都能生成core，使用前应确认崩溃收集服务与权限条件。

=== 从库函数回溯到自己的代码

// 来源：第38页。
用生成core时对应的可执行文件打开转储：

```bash
gdb test core.18983
```

原例的停止信息为`SIGSEGV`，最上层栈帧`#0`落在C++标准库的内存构造函数中：

```text
Program terminated with signal SIGSEGV, Segmentation fault.
#0 ... __gnu_cxx::new_allocator<int>::construct ...
    ... <error reading variable> ...
```

简单程序可能直接显示自己的错误行；经过多层库调用时，当前停住的位置可能在库函数内部。此时先检查自己的调用是否违反接口要求，不应仅因栈顶在库中就判断是库的错误。

// 来源：第39页；保留原截图的栈帧顺序与关键行。
使用`backtrace`（或`where`）列出调用堆栈，再选择自己程序对应的栈帧：

```text
(gdb) bt
#0 ... __gnu_cxx::new_allocator<int>::construct ...
#1 ... std::allocator_traits<...>::construct ...
#2 ... std::vector<int, ...>::_M_insert_aux ...
#3 ... std::vector<int, ...>::push_back ...
#4 ... main (...) at test.C:9
(gdb) frame 4
#4 ... main (...) at test.C:9
9       b.push_back(a[0]);
```

这里便定位到`test.C`第9行。若进一步检查`a`的大小，就能发现它是空容器。

#block(breakable: false)[
  #note(subname: [补充：栈帧编号不是固定值])[
    编译器、标准库版本和优化选项改变后，栈帧数量、函数名与行号都可能不同。应从自己的`bt`输出中找到用户代码，再执行相应的`frame n`；不能机械地总选`frame 4`。

    原例把库函数描述为“基本不可能出错”，这是调试时优先检查自身代码的经验，并非库绝无错误的保证。
  ]
]

第35—39页列出的延伸材料：#link("https://blog.csdn.net/yockie/article/details/51973740")[GDB调试core示例]。

== 本讲小结

// 来源：第40页。
本讲需要掌握：
+ 三种向函数传递参数的方式：传值、引用和指针。
+ `const`成员变量、成员函数和对象，以及`mutable`的用途。
+ 通过`VolCuboid`回顾头文件、源文件、主函数和类的使用。
+ 编译、链接C++程序的三种方式：`g++`命令或脚本、Makefile、CMake。
+ 使用GDB设置断点、查看变量与调用流程，并通过core和调用堆栈定位崩溃。

== 补充材料与课堂练习

=== 传值调用的返回值

// 来源：第41页，单选题1分；页面标示B。
#exercise(subname: [传值调用])[
  下列程序返回什么值？
  ```cpp
  #include <iostream>
  using namespace std;

  class Square {
  public:
      int side;
      Square(int s) : side(s) {}
      void modifySide(Square s) {
          s.side = 10;
      }
  };

  int main() {
      Square sq(5);
      sq.modifySide(sq);
      return sq.side;
  }
  ```
  - A. 0
  - B. 5
  - C. 10
  - D. 不确定
]

答案为*B*。`s`是`sq`的副本，修改`s.side`不会改变`sq.side`，所以返回`5`。

=== 引用调用的返回值

// 来源：第42页，单选题1分；页面标示C。
#exercise(subname: [引用调用])[
  下列程序返回什么值？
  ```cpp
  #include <iostream>
  using namespace std;

  class Square {
  public:
      int side;
      Square(int s) : side(s) {}
      void modifySide(Square& s) {
          s.side = 10;
      }
  };

  int main() {
      Square sq(5);
      sq.modifySide(sq);
      return sq.side;
  }
  ```
  - A. 0
  - B. 5
  - C. 10
  - D. 不确定
]

答案为*C*。`s`是`sq`的别名，所以修改作用于原对象，返回`10`。这与前面的指针例子结果相同，但参数声明和调用语法不同。

=== 再看GDB的用途

// 来源：第43页。
GDB允许查看程序执行时的内部状态，以及程序崩溃时正在进行的操作。可以：
+ 按需要控制程序运行。
+ 在指定位置或满足某个条件时暂停。
+ 在停止时检查程序状态。
+ 在运行过程中修改变量或条件，临时修正一个错误的影响，以便继续检查其他问题。

快速入门示例：#link("https://www.cnblogs.com/davidwang456/p/3450532.html")[GDB入门例子]。在调试器中修改变量只是改变本次运行状态，不会自动修复源代码。

=== Makefile的另一种写法

// 来源：第44页。
这一页把前面的文件列表生成直接放进目标依赖中，并使用`notdir`提取文件名。目录与编译器设置如下：

```make
TOP := $(shell pwd)/
OBJ := $(TOP)obj/
BIN := $(TOP)bin/
SRC := $(TOP)src/
INCLUDE := $(TOP)include/
CPPLIBS =
# INCLUDE += ...

CPP = g++
CPPFLAGS = -O -Wall -fPIC -I$(INCLUDE)
```

构建规则为：

```make
all: VolCub

VolCub: $(patsubst $(SRC)%.cc,$(OBJ)%.o,$(wildcard $(SRC)*.cc))
	$(CPP) $^ $(CPPLIBS) -o $(BIN)$(notdir $@)
	@echo

$(OBJ)%.o: $(SRC)%.cc
	$(CPP) $(CPPFLAGS) -c $(SRC)$(notdir $<) -o $(OBJ)$(notdir $@)
	@echo

.PHONY: clean
clean:
	rm -f $(OBJ)*.o $(BIN)*
```

- `$(notdir ...)`去掉路径中的目录部分，只保留文件名。
- 例如目标名是`/path/obj/main.o`，则`$(notdir $@)`为`main.o`。
- 命令前的`@`使Make不先回显命令本身；`@echo`在这里输出空行。
- 原例清理行多写了一次`rm -f`，此处改为一条清理命令；`@echo`也按Makefile语法放在Tab缩进的配方中。

这一写法与前面的`SOURCES`、`OBJECTS`变量形式功能相近，但变量形式更便于逐项查看。关于目标`VolCub`与实际输出`bin/VolCub`不一致的问题，仍需按前面的补充说明处理。
