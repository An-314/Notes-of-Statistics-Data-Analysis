#import "@preview/scripst:1.1.2": *

#pagebreak(weak: true)

// 代码和较短的提示框保持完整，避免标题或末尾一行单独跨页。
#show raw.where(block: true): it => block(breakable: false, it)
#show heading: it => block(sticky: true, it)

= C++与面向对象程序设计

// 来源：files/lecture_2_C++_v3.pdf，第1—2页。
本章根据张黎明《粒子物理与核物理实验中的数据分析》第二讲“C++”整理。

本讲内容：
- 面向对象的程序设计
- C++的类
- 类的继承与重用
- 类的多态

*学习目标*：在可借助资源的情况下，正确运用C++类，以及继承、多态等类的高级功能。

// 来源：第3页；第33页回到同一道思考题。
#block(breakable: false)[
  #exercise(subname: [编程思考题])[
    已知长方形、圆形和三角形的参数，计算它们的面积。能否写一个函数同时处理所有形状？

    #align(center)[
      #grid(
        columns: (1fr, 1fr, 1fr),
        align: center,
        row-gutter: 0.5em,
        rect(width: 2cm, height: 1.4cm), circle(radius: 0.7cm), polygon((0cm, 1.4cm), (2cm, 1.4cm), (1cm, 0cm)),
        [长方形], [圆形], [三角形],
      )
    ]

    设计一个函数：
    ```cpp
    double getArea(const ??? *shape);
    ```
    - 它既能接收长方形，也能接收圆形、三角形。
    - 无需知道具体类型，就能返回正确面积。
    - 提示：考虑基类、继承、多态。
  ]
]

== 为什么粒子物理学家需要C++

// 来源：第4页。
在粒子物理中，并不是“自由选择”编程语言，选择受制于实验的软件生态。

#figure(
  three-line-table[
    | 实验 | 分析框架 | 主要实现语言 |
    | --- | --- | --- |
    | ATLAS | Athena | C++ |
    | CMS | CMSSW | C++ |
    | LHCb | Gaudi | C++ |
    | BESIII | BOSS | C++ |
  ],
)

通用工具ROOT、Geant4用C++编写。可以用Python调用ROOT（PyROOT），但底层仍然是C++；PyG4的底层也是C++。

=== C++与Python

// 来源：第5页。
- C++用于追求高性能的系统级编程和高性能计算。
- Python用于人工智能、数据科学，语法简洁、库丰富。
- 许多项目用C++实现性能关键的核心，用Python实现上层应用逻辑、快速迭代。

#figure(
  three-line-table[
    | 比较项目 | C++ | Python |
    | --- | --- | --- |
    | 定位 | 性能关键的核心组件 | 上层应用逻辑、快速迭代 |
    | 速度 | 编译执行，接近硬件极限 | 解释执行；典型比较为慢10—100倍 |
    | 内存管理 | 手动管理，如`new/delete` | 自动垃圾回收 |
    | 学习曲线 | 陡峭 | 平缓 |
    | 在粒子物理中的角色 | ROOT、Geant4、重建算法、触发 | 数据分析脚本、绘图、机器学习 |
  ],
)

#block(breakable: false)[
  #note(subname: [比较的适用范围])[
    运行速度的具体差距取决于任务和实现，不能把10—100倍当作固定结论；Python调用C++库时，核心计算仍可由编译后的代码完成。C++也可以通过自动存储期对象、标准容器和智能指针管理资源，并非只能手写`new/delete`。
  ]
]

== 两种编程思维：过程与对象

=== 面向过程编程

// 来源：第6页。
面向过程编程*以事件为中心*：分析步骤，再用函数实现，最后顺序调用。

以棋类游戏为例，首先分析解决问题的步骤：
+ 玩家落子：`placeStone(x, y, player)`。
+ 判断是否合法：`isValid(x, y)`。
+ 更新棋盘：`updateBoard(x, y, player)`。
+ 判断是否获胜：`checkWin(player)`。
+ 轮到对方：`switchPlayer()`。

这种方式直接有效，但在例子中，增加“悔棋”功能需要修改几乎所有步骤。

面向过程的优势在于简单直接，劣势在于需求变化时，修改成本可能较高。它适合小规模、一次性、需求明确的程序，比如一个数据处理脚本。

=== 面向对象编程

// 来源：第7页。
面向对象（object）编程首先找到“角色（对象）”。对象有自己的*属性（数据）*和*行为（函数）*，对象之间通过消息，即方法调用，进行交互。它适合大型系统、需要长期维护的代码。

思考棋类游戏有哪些“角色”：
+ 棋盘（`Board`）：负责存储棋子位置、显示棋盘状态。
+ 玩家（`Player`）：负责决定落子位置。
+ 规则（`Rule`）：负责判断胜负、判定合法位置。

给出的职责划分，增加“悔棋”功能只需给棋盘对象增加`undo()`，玩家和规则不用修改。

=== 优缺点比较

// 来源：第8页。
#figure(
  three-line-table[
    | 比较项目 | 面向过程 | 面向对象 |
    | --- | --- | --- |
    | 优点 | 任务明确，简单直接，效率高 | 结构清晰、模块化，符合人类的思维方式；易扩展，重用率高，可继承；对象间低耦合，易维护 |
    | 缺点 | 代码重用性低、扩展能力较差；增加悔棋功能需改变多个步骤 | 增加设计与接口开销；封装后的数据通常通过读写函数访问 |
    | 适合场景 | 简单任务、脚本、一次性程序 | 大型系统、需要长期维护的代码 |
  ],
)

#block(breakable: false)[
  #note[
    实际的扩展成本取决于模块与接口设计；面向过程并不必然不能重用代码，面向对象也不自动保证低耦合。
  ]
]

== C++速成：HelloWorld

// 来源：第9—11页。
本节课的示例文件位于讲义所列的清华云盘`Lec2/`目录。

首先使用Emacs、vi或VS Code等编辑器，编写文件`HelloWorld.cc`：

```cpp
// A C++ program
#include <iostream>
using namespace std;

int main() {
    cout << "Hello World!" << endl;
    return 0;
}
```

- `#include <iostream>`：包含输入输出所需的头文件。
- `using namespace std;`：命名空间声明。
- `int main()`：程序的主函数。
- `cout`：向标准输出写入内容。
- `endl`：换行并刷新输出流。
- `return 0;`：正常结束程序。

然后编译源文件，形成机器可执行的代码：

```bash
g++ -o HelloWorld HelloWorld.cc
```

其中，`g++`为编译器，`-o HelloWorld`指定输出文件名，`HelloWorld.cc`为源代码文件。最后执行程序：

```bash
./HelloWorld
```

输出为：

```text
Hello World!
```


== 类与对象

=== 类的概括和关键点

// 来源：第12页。
*类的本质*：
- 类是一种数据类型。
- 类是数据和函数的组合。
- 类是用来产生多个对象的蓝图。

学习类需要掌握：
+ 关键字`class`。
+ 构造函数。
+ 析构函数。
+ 成员变量。
+ 成员函数。
+ 成员函数功能的实现。
+ 生成实例（对象），并通过对象使用非静态成员。

=== 类与对象：从蓝图到实例

// 来源：第13页。
*类（class）*是蓝图，定义“有什么属性、能做什么”；*对象（object）*是实例，是根据蓝图创建的具体东西，占用内存、存储实际数据。

类就像饼干模具。模具定义了饼干的形状：圆的、方的、星形的。模具本身不是饼干，不能吃；对象就是用模具做出来的具体饼干。同一个模具可以做出很多块饼干，每块可以有不同的颜色、口味，但它们都是“这个形状”的饼干。

#block(breakable: false)[
  #note[
    “类本身不占内存”是指仅定义类不会创建每个实例的数据存储；并不表示成员函数代码、静态数据成员等不需要存储空间。“类是模板”在这里是蓝图的比喻，不是C++的`template`语法。
  ]
]

=== C++类的例子：Line

// 来源：第14页。
```cpp
#include <iostream>
using namespace std;

class Line {
public:
    Line(double len);             // 构造函数声明
    ~Line();                      // 析构函数声明
    void setLength(double len);   // 成员函数声明
    double getLength(void);       // 成员函数声明
private:
    double length;                // 成员变量
};
```

类定义最后的分号不能省略。`public`部分提供外部接口，`private`部分存放内部数据。

=== 构造函数

// 来源：第15页；代码由页面图像转录。
类的*构造函数*在创建对象时执行：
- 名称与类名完全相同。
- 可以不带参数，也可以带参数。
- 不声明返回类型，连`void`也不写。
- 可用于为成员变量，包括`private`成员，设置初始值。

使用*成员初始化列表*：

```cpp
Line::Line(double len) : length(len) {
    cout << "Object is being created, length = "
         << len << endl;
}
```

也可以在构造函数体内赋值：

```cpp
Line::Line(double len) {
    length = len;
    cout << "Object is being created, length = "
         << len << endl;
}
```

`::`是*作用域解析运算符*（范围解析运算符），`Line::Line`表示在类外定义`Line`的构造函数。上面两种定义选用一种，不能同时定义同一个构造函数。

#block(breakable: false)[
  #note(subname: [初始化与赋值])[
    对这个`double`成员，两种写法最终得到相同的值，但初始化列表直接初始化成员，函数体内的写法则是赋值。引用成员和某些`const`成员等必须在初始化阶段处理。声明了`Line(double)`并不意味着还会自动生成无参构造函数，所以本例要写`Line line(10.0);`。
  ]
]

=== 析构函数

// 来源：第16页；代码由页面图像转录。
类的*析构函数*在对象被销毁时执行：
- 名称与类名相同，前面加波浪号`~`。
- 不声明返回类型，不能带参数。
- 用于对象结束生命周期时释放资源，例如关闭文件、释放内存。

```cpp
Line::~Line(void) {
    cout << "Object is being deleted" << endl;
}
```

局部对象离开作用域也会析构，不必显式使用`delete`。

=== 实现成员函数与生成实例

// 来源：第17页；代码和输出由页面图像转录。
接着实现`Line`的两个成员函数：

```cpp
void Line::setLength(double len) {
    length = len;
}

double Line::getLength(void) {
    return length;
}
```

在主函数中创建实例，并通过访问运算符`.`调用成员函数：

```cpp
int main() {
    Line line(10.0);  // 生成实例（对象）

    // 获取默认设置的长度
    cout << "Length of line : " << line.getLength() << endl;

    // 再次设置长度
    line.setLength(6.0);
    cout << "Length of line : " << line.getLength() << endl;

    return 0;
}
```

把类声明、选定的构造函数定义、析构函数定义、成员函数定义与主函数放在同一源文件中，编译后输出：

```text
Object is being created, length = 10
Length of line : 10
Length of line : 6
Object is being deleted
```

== 数据封装与访问权限

=== 数据封装

// 来源：第18页。
数据封装是面向对象编程的重要特点，用于防止外界的干扰和错误修改。类成员的访问限制通过在类主体内部标记`public`、`private`、`protected`等*访问修饰符*指定。

- `public`：公有成员在类外部可以访问。
- `private`：私有成员不能由普通外部代码直接访问，本类成员与获授权的友元可以访问。`class`默认的成员访问权限为`private`。
- `protected`：保护成员与私有成员类似，但派生类的成员还可以按访问规则使用它们。

=== 为什么不让别人直接碰数据

// 来源：第19页。
不好的设计：直接公开变量。

```cpp
class Line {
public:
    double length;
};

// 使用上述类：
Line myLine;
myLine.length = -5.0;  // 线段长度为负，没有物理意义
```

改进的设计：把数据设为私有，通过setter验证输入。

```cpp
class Line {
private:
    double length;
public:
    void setLength(double len) {
        if (len > 0) {  // 验证：长度必须为正
            length = len;
        } else {
            cout << "错误：长度必须为正数！" << endl;
        }
    }
};
```

完整程序还应通过构造函数给`length`设置合法初值。

*封装的好处*：
+ 数据保护：验证非法值，例如要求质量大于0、概率属于$[0,1]$。
+ 灵活性：改变内部实现时，只要接口不变，外部代码通常无需修改。
+ 可维护：检查异常时可集中查看getter、setter和构造函数。

粒子物理中的例子：若模型中质量不可变，则把`mass`设计为只读，只提供`getMass()`，不提供`setMass()`。

=== 权限总结

// 来源：第20页。
#figure(
  three-line-table[
    | 访问权限 | 类内部 | 派生类内部 | 普通类外代码 | 主要用途 |
    | --- | --- | --- | --- | --- |
    | `public` | 可访问 | 可访问 | 可访问 | 定义类的接口 |
    | `protected` | 可访问 | 可访问 | 不可直接访问 | 在继承体系内共享实现细节 |
    | `private` | 可访问 | 不可直接访问 | 不可直接访问 | 隐藏实现细节 |
  ],
)

此表按公有继承示例理解，未列出友元的特殊访问权限。

=== 课堂练习：访问权限

// 来源：第21页，主观题10分。
#block(breakable: false)[
  #exercise(subname: [类外访问成员])[
    指出下面不正确的语法使用。
    ```cpp
    #include <iostream>
    using namespace std;

    class Sample {
    public:
        int publicVar;
    private:
        int privateVar;
    protected:
        int protectedVar;
    };

    int main() {
        Sample obj;
        obj.publicVar = 10;     // Is this correct?
        obj.privateVar = 20;    // Is this correct?
        obj.protectedVar = 30;  // Is this correct?
        return 0;
    }
    ```
  ]
]

#block(breakable: false)[
  #note(subname: [整理时补充的答案])[
    `obj.publicVar = 10;`正确。后两条赋值违反访问权限：普通类外代码不能直接访问`privateVar`和`protectedVar`。
  ]
]

// 来源：第22页，主观题10分。
#block(breakable: false)[
  #exercise(subname: [派生类访问私有成员])[
    指出下面不正确的语法使用。
    ```cpp
    #include <iostream>
    using namespace std;

    class Base {
    private:
        int x;
    };

    class Derived : public Base {
    public:
        void setX(int val) {
            x = val;  // Is this correct?
        }
    };
    ```
  ]
]

#block(breakable: false)[
  #note(subname: [整理时补充的答案])[
    `x = val;`不正确，因为`x`是基类的私有成员。可以由基类提供可访问的设置函数，派生类再调用这个接口。
  ]
]

== 类的继承与重用

// 来源：第23—24页。
继承（inheritance）是面向对象编程的重要概念之一。类可以被扩展：由已有的类派生出新的类，重用已有成员，并添加新的成员。

- *基类（base class）*：被继承的类。
- *派生类（derived class）*：继承基类成员，并可以添加新成员的类。

```cpp
class CPolygon { /* ... */ };
class CRectangle : public CPolygon { /* ... */ };
class CTriangle : public CPolygon { /* ... */ };
```

这里`CRectangle`与`CTriangle`都派生自`CPolygon`。可以类比电动车继承汽车的方向盘、刹车、油门、车轮，再增加电池和电动机：*复用已有的，扩展新的*。

=== 继承示例

// 来源：第25页。
```cpp
// derived classes
#include <iostream>
using namespace std;

class Polygon {  // base class
protected:
    int width, height;
public:
    void set_values(int a, int b) {
        width = a;
        height = b;
    }
};

class Rectangle : public Polygon {  // derived class
public:
    int area() { return width * height; }
};

class Triangle : public Polygon {  // derived class
public:
    int area() { return width * height / 2; }
};

```

```cpp
int main() {
    Rectangle rect;
    Triangle trgl;
    rect.set_values(4, 5);
    trgl.set_values(4, 5);
    cout << rect.area() << '\n';
    cout << trgl.area() << '\n';
    return 0;
}
```

输出为：

```text
20
10
```

`Polygon`是基类；`Rectangle`和`Triangle`是派生类。派生类内部可以使用基类的`public`和`protected`成员，但不能直接访问基类的`private`成员。

本例使用整数面积；`width * height / 2`执行整数除法，若乘积为奇数会截去小数部分。

=== 继承的要点

// 来源：第26页。
原则上继承基类所有成员，但将以下项目列为例外：
- 构造函数和析构函数。
- 赋值运算符`operator=`。
- 友元（friends）。
- `private`成员。

#block(breakable: false)[
  #note(subname: [继承与访问不是一回事])[
    基类的私有成员仍保留在派生对象的基类子对象中，只是派生类不能直接访问；友元关系不会因为继承而传递。基类构造函数可通过`using Base::Base;`显式继承。赋值运算符也不宜笼统说成“完全不存在”：派生类自己的赋值运算符会隐藏同名基类成员。

    参见#link("https://eel.is/c++draft/class.derived")[C++标准草案：派生类]。
  ]
]

*多重继承*：一个派生类可以继承多个基类，基类之间用逗号分隔。

```cpp
// 假定 Polygon 和 Output 已定义
class Rectangle : public Polygon, public Output { /* ... */ };
class Triangle : public Polygon, public Output { /* ... */ };
```

用分号结束了带基类列表的示意写法；这里补上类体，写成完整类定义的形式。

// 来源：第27页，多选题1分；页面标示B、C、D。
#block(breakable: false)[
  #exercise(subname: [哪些信息无法被继承])[
    基类的哪些信息无法被继承？
    - A. 保护成员
    - B. 构造函数
    - C. 私有成员
    - D. 析构函数
  ]
]

#block(breakable: false)[
  #note(subname: [答案])[
    答案为*B、C、D*。应结合上一条勘误理解：不能把“不能直接访问私有成员”理解为“派生对象里没有这部分数据”；构造函数也存在显式继承的机制。
  ]
]

=== 继承小结

// 来源：第28页。
- 继承让派生类拥有基类部分，并可扩展新成员，实现代码重用。
- 在本讲的公有继承设计中，派生类表示基类的一种具体形式，例如圆形是一种形状。
- 派生类不能直接访问基类的`private`成员。
- 构造、析构及赋值涉及特殊规则，不能像普通成员函数那样简单套用。

== 类的多态

=== 从粒子模拟引入

// 来源：第29页；代码由页面图像转录。
模拟中有很多种粒子，无法在一个函数里穷举全部类型，因此函数的输入不应限于某一种具体粒子。

```cpp
void simulateParticle(const Particle& particle) {
    particle.simulateInteraction();
    double energy = particle.calculateEnergy();
}
```

若`Particle`提供相应的虚函数接口，派生类就可以实现不同的相互作用和能量计算。这里的参数是常量引用，相应的成员函数还需要能对常量对象调用。

=== 同一个接口，不同的实现

// 来源：第30页。
多态（polymorphism）字面意思是“多种形态”：基类与派生类提供相同的成员函数接口，调用时按对象类型执行不同实现。本讲重点是通过虚函数实现的*运行时多态*。

沿用前面的`Polygon`、`Rectangle`、`Triangle`，先在基类中加入一个普通的同名函数：

```cpp
// 加入 Polygon 的 public 部分：
int area() { return 0; }
```

通过基类指针调用：

```cpp
Rectangle rect;
Triangle trgl;
rect.set_values(4, 5);
trgl.set_values(4, 5);

Polygon* ppoly1 = &rect;  // 基类指针指向派生类对象
Polygon* ppoly2 = &trgl;

cout << ppoly1->area() << '\n';
cout << ppoly2->area() << '\n';
```

此时两行都输出`0`。因为基类的`area()`不是虚函数，调用根据指针的静态类型`Polygon*`选择`Polygon::area()`，不会调用派生类版本。

=== virtual与动态绑定

// 来源：第31页。
将基类中的声明改为：

```cpp
virtual int area() { return 0; }
```

同样的指针调用现在得到：

```text
20
10
```

`virtual`使调用在运行时根据指针所指对象的实际类型，选择`Rectangle::area()`或`Triangle::area()`。这称为*动态绑定（dynamic binding）*。

#block(breakable: false)[
  #note[
    仅仅有同名函数还不够，派生类必须真正重写相应虚函数，签名中的参数以及`const`等限定需要匹配。派生类可加`override`，让编译器检查是否正确重写；基类函数一旦是虚函数，派生类重写时即使不再写`virtual`，仍是虚函数。

    参见#link("https://eel.is/c++draft/class.virtual")[C++标准草案：虚函数]。
  ]
]

=== 抽象基类与纯虚函数

// 来源：第32页；类定义由页面图像转录。
*抽象基类（abstract base class）*不能直接实例化，用来为派生类规定接口。*纯虚函数（pure virtual function）*在声明末尾使用`= 0`：

```cpp
// abstract class Polygon
class Polygon {
protected:
    int width, height;
public:
    void set_values(int a, int b) {
        width = a;
        height = b;
    }
    virtual int area() = 0;
};
```

```cpp
Polygon mypolygon;   // 错误：不能创建抽象类对象
Polygon* ppolygon;   // 可以声明指针
```

也可以使用抽象基类的引用。要使派生类能够实例化，必须为尚未实现的纯虚函数提供具体实现。

#block(breakable: false)[
  #note[
    抽象类并不意味着“所有成员都没有实现”，上例的`set_values()`就有函数体。纯虚函数也可以另行提供定义；抽象性取决于是否仍有最终重写为纯虚的函数。
  ]
]

=== 回到面积计算：Shape多态例子

// 来源：第33—34页。
回到本章开头的问题，用抽象基类`Shape`统一描述长方形、圆形和三角形，统一函数就可以接收`const Shape*`。

```cpp
// 派生类和多态的例子
#include <iostream>
#include <string>
using namespace std;

class Shape {
protected:
    int x, y;      // 坐标
    string color;  // 颜色
public:
    Shape(int x, int y, const string& color)
        : x(x), y(y), color(color) {}

    virtual void draw() const = 0;    // 绘制图形
    virtual double area() const = 0;  // 计算面积
    virtual ~Shape() {}              // 虚析构函数
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
    delete p1;  // 整理时补充：释放动态创建的对象
    return 0;
}
```

`Circle`的初始化列表先初始化基类部分`Shape(x, y, color)`，再初始化自身的`radius`。`GetArea()`只需要调用统一的`area()`接口，不必知道具体形状。这里面积为$3.14159 times 3^2 = 28.27431$，默认输出精度下显示`28.2743`。


=== 多态小结

// 来源：第35页。
*多态核心*：
- 同一接口，例如`area()`，可以有不同实现。
- `virtual`实现动态绑定。
- 纯虚函数`= 0`规定接口；抽象基类不能直接实例化。

*注意事项*：
- 在本讲的继承多态用法中，通过基类指针`*`或引用`&`保留派生对象的身份。
- 把派生对象按值复制成基类对象，会发生*对象切割（object slicing）*，新对象不再保有派生类部分。
- 若通过基类指针删除派生对象，通常需要基类具有虚析构函数。

#block(breakable: false)[
  #note(subname: [虚析构函数])[
    非虚析构的后果为“可能内存泄漏”。更严格地说，在本讲普通`delete`的情形下，通过没有虚析构函数的基类指针删除派生对象会导致未定义行为。

    参见#link("https://eel.is/c++draft/expr.delete")[C++标准草案：delete表达式]。
  ]
]

== 本讲小结

// 来源：第36页。
本讲内容包括C++基础、类、继承和多态。复习时特别注意：
+ 成员变量与成员函数的访问权限。
+ 继承关系和访问权限的区别，以及构造、析构等特殊成员的规则。
+ 基类指针或引用、虚函数与动态绑定的配合使用。

== 补充材料与课堂练习

=== C++的历史

// 来源：第37—38页；保留讲义的历史叙述与列举范围。
Bjarne Stroustrup（本贾尼·斯特劳斯特卢普）于1979年在贝尔实验室开始设计开发C++。

- 1979年：借鉴Simula中的“class”概念，研究增强C语言，使其支持面向对象特性。
  - 4月：他与同事负责分析UNIX内核，但缺乏适合分析内核分布所造成的网络流量、将内核模块化的工具，工作进展缓慢。
  - 10月：为C语言增加类似Simula的类机制，开发预处理器Cpre，处理新增元素与C语言之间的对应，由此萌生创建新语言的想法。
- 1980年：早期版本诞生，称为“带类的C”（C with Classes）。
- 1983年：Rick Mascitti建议将“带类的C”命名为C++。

C++在C语言基础上发展，同时参考了其他语言的特性，例如Simula的类概念、Algol 68的运算符重载。1983年以后，使用规模迅速增长，语言标准化成为迫切需求。

截至C++20的六个重要标准：C++98、C++03、C++11、C++14、C++17和C++20（2020）。
- C++03：对C++98的问题进行修订，未修改核心语言。
- C++11：增加多线程支持、通用编程支持等，标准库也有很多变化。
- C++14：对C++11的小范围扩展，主要修复问题并作增量改进。

#block(breakable: false)[
  #note[
    称C++为“C语言的超集”，这是历史定位上的简述；不能据此认为所有合法C程序都能原样作为C++程序编译。
  ]
]

=== 表达式的含义

// 来源：第39页，主观题10分；三条表达式由页面图像转录。
#block(breakable: false)[
  #exercise(subname: [解释C++语法])[
    下面这些表达式是什么意思？
    ```cpp
    int A::b(int c) { }
    a->b
    class A : public B {};
    ```
  ]
]

#block(breakable: false)[
  #note(subname: [答案])[
    + `int A::b(int c) { }`：在类外定义类`A`的成员函数`b`，参数`c`和返回值类型均为`int`。这里用空函数体示意语法；实际执行到此函数末尾而不返回值是不正确的，应补上返回语句。
    + `a->b`：通过指针`a`访问所指对象的成员`b`；对普通对象指针，相当于`(*a).b`。
    + `class A : public B {};`：定义类`A`，它公有继承类`B`，类体中未增加新成员。
  ]
]

=== 非指针基类对象：对象切割

// 来源：第40页。
下面的基类虽然有虚函数，但把派生对象复制为基类对象后会怎样？

```cpp
// virtual members: object slicing
#include <iostream>
using namespace std;

class Polygon {
protected:
    int width, height;
public:
    void set_values(int a, int b) {
        width = a;
        height = b;
    }
    virtual int area() { return 0; }
};

class Rectangle : public Polygon {
public:
    int area() { return width * height; }
};

class Triangle : public Polygon {
public:
    int area() { return width * height / 2; }
};

```

```cpp
int main() {
    Rectangle rect;
    Triangle trgl;
    Polygon poly;
    rect.set_values(4, 5);
    trgl.set_values(4, 5);
    poly.set_values(4, 5);

    Polygon ppoly1 = rect;
    Polygon ppoly2 = trgl;
    Polygon ppoly3 = poly;

    cout << ppoly1.area() << '\n';
    cout << ppoly2.area() << '\n';
    cout << ppoly3.area() << '\n';
    return 0;
}
```

输出为：

```text
0
0
0
```

`ppoly1`和`ppoly2`是新创建的`Polygon`对象，已经发生对象切割；它们不是指向原来派生对象的指针。因此三次调用都执行`Polygon::area()`。

=== ROOT中的继承例子

// 来源：第41页；将原图的继承关系转为表格。
以`TObject`说明ROOT中的继承：大量ROOT类直接或间接继承自`TObject`，由它提供默认行为与协议，例如`Draw()`、输入输出（IO）和`Print()`，使派生类具有一致的接口与行为。

原图中各类的直接继承关系如下：

#figure(
  three-line-table[
    | 派生类 | 图中所示的直接基类 |
    | --- | --- |
    | `TNamed` | `TObject` |
    | `TH1` | `TNamed`、`TAttLine`、`TAttFill`、`TAttMarker` |
    | `TArrayD` | `TArray` |
    | `TH1D` | `TH1`、`TArrayD` |
    | `TProfile` | `TH1D` |
  ],
)

例如，`TProfile`经`TH1D`、`TH1`和`TNamed`间接继承`TObject`；`TH1`和`TH1D`也展示了多重继承。

=== 再看面向对象的程序设计

// 来源：第42页。
Object Oriented Programming（OOP）的出发点是：世界上的事物可以抽象为对象。
- 尽可能模拟人类的思维方式，把实体抽象为问题域中的对象。
- 每个对象具有自己的属性和行为，对象之间通过方法交互。
- 把要解决的问题分解到各个对象，描述每个对象在解决问题过程中的属性和行为。
- 三个主要目标：*重用性、灵活性和扩展性*。
- 核心概念：*对象与类*。

例如，猫可以有颜色、名称、品种和当前行为；粒子可以有类型、寿命、质量、位置和动量等属性。

// 来源：第43页，多选题1分；页面标示B、C。
#block(breakable: false)[
  #exercise(subname: [派生类可以访问什么])[
    派生类可以访问基类的哪些信息？
    - A. 私有成员
    - B. 公有成员
    - C. 保护成员
    - D. 友元类
  ]
]

答案为*B、C*。基类的私有成员不能由派生类直接访问，友元关系也不会自动传给派生类。

=== 指向基类的指针

// 来源：第44页。
若`Mother`为基类，`Daughter`公有继承`Mother`，可以写：

```cpp
Daughter myD;       // 创建派生类对象
Mother* myM = &myD; // 基类指针指向派生类对象
```

// 来源：第45页。
下面是的错误示例。注意基类`Polygon`中还没有声明`area()`：

```cpp
// pointers to base class: intentionally incorrect
#include <iostream>
using namespace std;

class Polygon {
protected:
    int width, height;
public:
    void set_values(int a, int b) {
        width = a;
        height = b;
    }
};

class Rectangle : public Polygon {
public:
    int area() { return width * height; }
};

class Triangle : public Polygon {
public:
    int area() { return width * height / 2; }
};

```

```cpp
int main() {
    Rectangle rect;
    Triangle trgl;
    Polygon* ppoly1 = &rect;
    Polygon* ppoly2 = &trgl;
    ppoly1->set_values(4, 5);
    ppoly2->set_values(4, 5);
    cout << ppoly1->area() << '\n';  // 编译错误
    cout << ppoly2->area() << '\n';  // 编译错误
    return 0;
}
```

- `ppoly1`和`ppoly2`都是`Polygon*`，分别被赋为`rect`与`trgl`的地址。
- 通过这些指针进行成员查找时，接口由基类类型决定，不能直接调用只在派生类中声明的成员。
- 因此，必须先在基类中声明`area()`接口。

=== 如何访问正确的area实现

// 来源：第46页。
仅在`Polygon`中增加普通的`area()`还不够，因为`Rectangle`与`Polygon`的实现不同，需要根据实际对象选择版本。解决办法是*虚成员函数（virtual member）*：
- 在基类中使用`virtual`声明虚函数。
- 派生类重写这个函数。
- 调用时根据对象的实际类型选择实现，称为动态绑定或后期绑定；也称为“动态链接”，这里指函数调用的绑定机制。

=== 虚成员函数的完整示例

// 来源：第47页。
```cpp
// virtual members
#include <iostream>
using namespace std;

class Polygon {
protected:
    int width, height;
public:
    void set_values(int a, int b) {
        width = a;
        height = b;
    }
    virtual int area() { return 0; }
};

class Rectangle : public Polygon {
public:
    int area() { return width * height; }
};

class Triangle : public Polygon {
public:
    int area() { return width * height / 2; }
};

```

```cpp
int main() {
    Rectangle rect;
    Triangle trgl;
    Polygon poly;
    Polygon* ppoly1 = &rect;
    Polygon* ppoly2 = &trgl;
    Polygon* ppoly3 = &poly;
    ppoly1->set_values(4, 5);
    ppoly2->set_values(4, 5);
    ppoly3->set_values(4, 5);
    cout << ppoly1->area() << '\n';
    cout << ppoly2->area() << '\n';
    cout << ppoly3->area() << '\n';
    return 0;
}
```
输出为：

```text
20
10
0
```

`ppoly1`调用长方形的实现，`ppoly2`调用三角形的实现，`ppoly3`指向真正的基类对象，因此调用基类返回`0`的实现。与前面的按值复制比较，关键区别在于这里的指针仍指向原对象，没有产生对象切割。
