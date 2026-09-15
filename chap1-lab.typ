#import "@preview/scripst:1.1.2": *

= Linux环境及shell编程

Linux安装：
- Windows下安装Linux子系统（WSL）
- MacOS原生支持部分Unix命令
- Linux发行版安装（Ubuntu、Debian、Arch Linux等）

== Linux简介

GNU/Linux是一个自由软件操作系统，最初由Linus Torvalds在1991年开发。Linux内核是操作系统的核心部分，负责管理硬件资源和提供系统服务。Linux操作系统通常与GNU工具链结合使用，因此常被称为GNU/Linux。

Linux 的特点包括开源、稳定性高、安全性强、可定制性强以及广泛的社区支持。它支持多用户、多任务和多线程操作，适用于服务器、桌面和嵌入式系统等多种应用场景。

Linux 本身只是"内核"——操作系统的核心部分。一个完整的操作系统还需要命令行工具、图形界面、库文件、应用程序等。不同组织把Linux 内核和这些组件打包在一起，形成了不同的*"发行版"（distribution）*。

#figure(
  three-line-table[
    | 发行版 | 说明 | 适用场景 |
    | --- | --- | --- |
    | Ubuntu | 基于Debian的发行版，用户友好，社区活跃 | 桌面、服务器 |
    | Fedora | 由Red Hat赞助，注重最新技术和开源软件 | 桌面、开发 |
    | Debian | 稳定、安全，拥有庞大的软件仓库 | 服务器、桌面 |
    | CentOS | 基于Red Hat Enterprise Linux，稳定性高 | 服务器 |
    | Arch Linux | 滚动更新，用户可高度自定义 | 高级用户、开发 |
    |  openSUSE | 稳定、易用，适合企业和开发者 |  服务器、桌面 |
    | Gentoo | 源码发行版，用户可自行编译和优化 | 高级用户、开发 |
  ],
)

不同发行版最重要的区别是包管理系统和默认软件包。包管理系统负责安装、更新和删除软件包，常见的有APT（Debian/Ubuntu）、YUM/DNF（Red Hat/CentOS/Fedora）、Pacman（Arch Linux）等。

== Linux系统结构

一个操作系统通常由内核、系统库、系统工具和应用程序组成。Linux系统结构如下：
- 内核（Kernel）：负责管理硬件资源、进程调度、内存管理、文件系统等核心功能。
- 系统库（System Libraries）：提供应用程序与内核交互的接口，如C标准库（glibc）。
- 系统工具（System Utilities）：提供基本的系统管理和操作功能，如文件操作、进程管理等。
- 应用程序（Applications）：用户使用的各种软件，如文本编辑器、浏览器、办公软件等。

#note(subname: [系统调用])[
  系统调用是操作系统内核为用户程序提供的接口，允许程序请求内核执行特定的操作，如文件操作、进程管理、网络通信等。

  函数调用是程序内部的调用，而系统调用是用户程序与操作系统内核之间的接口。系统调用通常通过中断或陷阱机制实现，用户程序通过特定的指令触发系统调用，内核接收到请求后执行相应的操作，并将结果返回给用户程序。
]

#newpara()

Shell是Linux系统中最常用的命令行解释器，它提供了用户与操作系统交互的接口。常见的Shell有Bash、Zsh、Fish等。Shell不仅可以执行命令，还支持脚本编程，允许用户编写自动化任务和复杂的操作流程。

== Linux文件系统

*操作系统认为所有操作对象都是文件*，包括硬件设备、目录、普通文件等。Linux文件系统采用层次化的目录结构，所有文件和目录都位于根目录（`/`）下，形成一棵树状结构。

Linux对文件与目录的管理，整体呈树状结构：
```
/
├── bin
├── boot
├── dev
├── etc
├── home
|    ├── ~ (当前用户的主目录)
|    └── OtherUser (其他用户的主目录)
├── lib
├── media
├── mnt
├── opt
├── proc
├── root
├── run
├── sbin
├── srv
├── sys
├── tmp
├── usr
└── var
```
其中：
- `/`：根目录，所有文件和目录的起点。
- `/bin`：存放基本命令的二进制文件。
- `/boot`：存放启动加载器和内核文件。
- `/dev`：存放设备文件。
- `/etc`：存放系统配置文件。
- `/home`：存放用户的主目录，`~`表示当前用户的主目录。
- `/lib`：存放共享库文件。
- `/media`：挂载可移动媒体设备的目录。
- `/mnt`：临时挂载文件系统的目录。
- `/opt`：存放可选的应用软件包。
- `/proc`：虚拟文件系统，提供内核和进程信息。
- `/root`：超级用户（root）的主目录。
- `/run`：存放运行时数据。
- `/sbin`：存放系统管理命令的二进制文件。
- `/srv`：存放服务数据。
- `/sys`：虚拟文件系统，提供内核和设备信息。
- `/tmp`：存放临时文件。
- `/usr`：存放用户程序和数据，类似Windows的Program Files。
- `/var`：存放可变数据，如日志文件、邮件等。

*相对路径和绝对路径*：
- 绝对路径：从根目录开始的完整路径，例如 `/home/user/documents/file.txt`。
- 相对路径：相对于当前工作目录的路径，例如 `documents/file.txt`。
  - `.` 表示当前目录，`..` 表示上级目录
  - `~` 表示当前用户的主目录

*文件所有者、权限和组*：
- 每个文件和目录都有一个所有者（user）和一个所属组（group）。
  - 每个用户都有一个唯一的用户名和用户ID（UID），每个组都有一个唯一的组名和组ID（GID）。
  - 用户可以被分配到一个或多个组中，组用于管理一组用户的权限。
- 文件权限分为三类：所有者权限、组权限和其他用户权限，每类权限包括读（r）、写（w）和执行（x）。
- 使用 `ls -l` 命令可以查看文件的详细信息，包括权限、所有者和组。

== Linux常用命令

Linux终端的常用命令
- `pwd`：显示当前工作目录的绝对路径。
- `ls [-lahrt]`：列出当前目录下的文件和目录，常用选项：
  - `-l`：以长格式显示详细信息。
  - `-a`：显示所有文件，包括隐藏文件。
  - `-h`：以人类可读的格式显示文件大小。
  - `-r`：反向排序。
  - `-t`：按修改时间排序。
- `cd [dir]`：切换当前工作目录。
- `mkdir [dir]`：创建新目录。
- `rm [-rf] [file/dir]`：删除文件或目录，常用选项：
  - `-r`：递归删除目录及其内容。
  - `-f`：强制删除，不提示确认。
- `cp [-r] [source] [destination]`：复制文件或目录，常用选项：
  - `-r`：递归复制目录及其内容。
- `mv [source] [destination]`：移动或重命名文件或目录
- `rsync [-avz] [source] [destination]`：更现代的用法，同步文件或目录，常用选项：
  - `-a`：归档模式，保留文件属性。
  - `-v`：显示详细信息。
  - `-z`：传输时压缩数据。
- `ln [-s] [target] [link_name]`：创建硬链接或符号链接，常用选项：
  - `-s`：创建符号链接。
- `touch [file]`：创建空文件或更新文件的访问和修改时间
- `cat [file]`：显示文件内容。
- `man [command]`：查看命令的使用手册。
- `du [-sh] [file/dir]`：显示文件或目录的磁盘使用情况，常用选项：
  - `-s`：仅显示总计。
  - `-h`：以人类可读的格式显示大小。
- `alias [name]='[command]'`：创建命令别名。
- `more [file]`：分页显示文件内容。
- `less [file]`：分页显示文件内容，支持向前和向后翻页。
- `head [-n] [file]`：显示文件的前n行，默认显示前10行。
- `tail [-n] [file]`：显示文件的后n行，默认显示后10行。
- `grep [pattern] [file]`：在文件中搜索指定模式的行。
- `find [path] -name [pattern]`：在指定路径下查找匹配模式的文件。
- `chmod [permissions] [file/dir]`：修改文件或目录的权限。
- `chown [user:group] [file/dir]`：修改文件或目录的所有者和所属组。
- `ps [-aux]`：显示当前运行的进程，常用选项：
  - `-a`：显示所有用户的进程。
  - `-u`：显示进程的用户信息。
  - `-x`：显示没有控制终端的进程。
- `kill [pid]`：终止指定进程，`pid`为进程ID。
- `top`：实时显示系统的进程和资源使用情况。

#note(subname: [文件搜索和处理])[
  - grep
    - `grep` 是一个强大的文本搜索工具，用于在文件中查找匹配指定模式的行。它支持正则表达式，可以结合其他命令使用，如 `ps aux | grep process_name` 查找特定进程。
    - `grep [-args] [pattern] [file]`：在文件中搜索指定模式的行，常用选项：
      - `-i`：忽略大小写。
      - `-n`：显示行号。
      - `-r`：递归搜索目录。
  - `find`
    - `find` 是一个用于在文件系统中查找文件和目录的命令。它可以根据名称、类型、大小、修改时间等条件进行搜索。
    - `find [path] -name [pattern]`：在指定路径下查找匹配模式的文件。
      - `-name`：按名称查找文件。
      - `-type`：按类型查找文件（如 `f` 表示普通文件，`d` 表示目录）。
      - `-size`：按大小查找文件。
  - `sed`
    - `sed` 是一个流编辑器，用于对文本进行处理和转换。它可以执行替换、删除、插入等操作。
    - `sed [options] 'command' [file]`：对文件进行文本处理，常用选项：
      - `-i`：直接修改文件。
      - `-e`：允许使用多个编辑命令。
      - `s/pattern/replacement/`：替换匹配的模式为指定的内容。
  - `tar`
    - `tar` 是一个用于打包和压缩文件的命令。它可以将多个文件和目录打包成一个归档文件，并支持多种压缩格式。
    - `tar [options] [archive_file] [file/dir]`：创建或解压归档文件，常用选项：
      - `-c`：创建新的归档文件。
      - `-x`：解压归档文件。
      - `-v`：显示详细信息。
      - `-f`：指定归档文件名。
      - `-z`：使用gzip压缩或解压。
      - `-j`：使用bzip2压缩或解压。
]

#newpara()
- `>`： 将命令的输出重定向到文件，覆盖原有内容。
- `>>`： 将命令的输出追加到文件末尾。
- `|`： 管道，将一个命令的输出作为另一个命令的输入。

#note(subname: [管道与重定向])[
  ```bash
  # 将命令的输出重定向到文件
  ls -l > output.txt
  # 将命令的输出追加到文件末尾
  echo "New line" >> output.txt
  # 使用管道将一个命令的输出作为另一个命令的输入
  ps aux | grep process_name
  # 将命令的输出重定向到文件
  ps aux | grep process_name > output.txt
  ```
]

== Shell脚本

*Shell环境变量*是Shell 存储配置信息的“全局变量”，程序通过它了解运行环境，为系统和用户程序服务。环境变量一般用大写字母定义(有些类似于C语言的宏定义)，比如`PATH`，`PWD`，`USER`，`GROUP`等都是系统环境变量。
- `PATH`：可执行程序的搜索路径集合
  ```zsh
  ❯ echo $PATH
  /usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/opt/cuda/bin:/usr/bin/site_perl:/usr/bin/vendor_perl:/usr/bin/core_perl:/usr/lib/rustup/bin
  ```
- `PWD`：当前工作目录
- `USER`：当前用户
- `GROUP`：当前用户所属组
对于环境变量的设置和修改，可以通过`export`命令来实现。例如：
```bash
export PATH=$PATH:/new/path
export MY_VAR="Hello, World!"
```

#newpara()
*Shell脚本*是由一系列Shell命令组成的文本文件，用于自动化执行任务。Shell脚本可以包含变量、条件语句、循环、函数等编程结构，使得用户能够编写复杂的操作流程。
- Shell脚本的基本结构：
  ```bash
  #!/bin/bash
  # 这是一个简单的Shell脚本示例

  # 定义变量
  NAME="World"

  # 条件语句
  if [ "$NAME" == "World" ]; then
      echo "Hello, $NAME!"
  else
      echo "Hello, Stranger!"
  fi

  # 循环语句
  for i in {1..5}; do
      echo "Iteration $i"
  done
  ```
- Shell脚本的执行权限：
  - 在Linux中，文件的执行权限决定了是否可以直接运行该文件。要使Shell脚本可执行，需要使用`chmod`命令修改文件权限。例如：
    ```bash
    chmod +x script.sh
    ```
  - 然后可以通过以下方式运行脚本：
    ```bash
    ./script.sh
    ```

== Python脚本

Python是一种高级编程语言，具有简洁的语法和强大的功能。Python脚本可以用于数据分析、自动化任务、Web开发等多种应用场景。Python脚本通常以`.py`为文件扩展名。

Python是简单且易于学习的编程语言，具有丰富的标准库和第三方库，支持多种编程范式，包括面向对象、函数式和过程式编程。Python脚本可以在Linux环境下直接运行，通常使用命令`python script.py`或`python3 script.py`来执行。

== 常见Linux应用程序简介

*SSH*（Secure Shell）是一种用于安全远程登录和其他网络服务的协议。它通过加密通信来保护数据传输的安全性，常用于远程管理服务器和执行命令。
- ssh用来连接远程服务器，常用命令格式：
  ```bash
  ssh username@hostname
  ```
  - `username`：远程服务器的用户名。
  - `hostname`：远程服务器的IP地址或域名。
  - `-p port`：指定连接的端口号，默认是22。
  - `-i identity_file`：指定用于身份验证的私钥文件。
  - `-Y`：启用X11转发，用于运行图形界面应用程序。
- 连接成功后，可以在远程服务器上执行命令，就像在本地终端一样。
- 可以用过编辑`~/.ssh/config`文件来配置SSH连接的别名和参数，简化连接命令。例如：
  ```
  Host myserver
      HostName example.com
      User myusername
      Port 2222
      IdentityFile ~/.ssh/id_rsa
  ```
  然后可以使用`ssh myserver`来连接远程服务器。

#note(subname: [非对称加密])[
  SSH使用非对称加密技术来确保通信的安全性。非对称加密使用一对密钥：公钥和私钥。公钥用于加密数据，而私钥用于解密数据。只有拥有私钥的用户才能解密由公钥加密的数据，从而保证了数据传输的安全性。

  在SSH连接过程中，客户端和服务器会交换公钥，并使用这些公钥来建立一个安全的通信通道。客户端使用服务器的公钥加密数据，服务器使用其私钥解密数据，反之亦然。这种机制确保了即使数据在传输过程中被截获，也无法被解密和读取。
]
在本地生成SSH密钥对的命令如下：
```bash
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```
这条命令会生成一个RSA类型的密钥对，密钥长度为4096位，并使用指定的电子邮件地址作为注释。生成的密钥对包括一个私钥（通常保存在`~/.ssh/id_rsa`）和一个公钥（通常保存在`~/.ssh/id_rsa.pub`）。public key必须事先通过可靠通道传递到服务器上，验证登录时，服务器会使用公钥来验证客户端的身份，而客户端使用私钥来进行身份验证。

*SCP*（Secure Copy）是一种用于在本地和远程主机之间安全传输文件的协议。它基于SSH协议，确保数据传输的安全性。SCP命令的基本格式如下：
```bash
scp [options] source_file username@hostname:destination_path
```
- `source_file`：要传输的本地文件路径。
- `username`：远程主机的用户名。
- `hostname`：远程主机的IP地址或域名。
- `destination_path`：远程主机上的目标路径。
- 常用选项：
  - `-r`：递归复制整个目录。
  - `-P port`：指定远程主机的端口号，默认是22。
  - `-i identity_file`：指定用于身份验证的私钥文件。
当然现在更现代的做法是使用rsync (remote synchronize)来同步文件和目录，`rsync`具有增量传输、压缩传输和断点续传等功能，适用于大文件和目录的传输。基本用法如下：
```bash
rsync [options] source_path username@hostname:destination_path
```
- 既可以用于本地和远程主机之间的文件同步，也可以用于本地目录之间的同步。
- 常用选项：
  - `-a`：归档模式，保留文件属性。
  - `-v`：显示详细信息。
  - `-z`：传输时压缩数据。
  - `--progress`：显示传输进度。
