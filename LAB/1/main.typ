#import "@preview/scripst:1.1.2": *

#show: scripst.with(
  title: [统计数据分析第1次实践作业],
  author: "Anzreww",
  time: "2026年9月",
  cb-counter-depth: 1,
  matheq-depth: 1,
  font-size: 13pt,
  par-leading: 0.6em,
  counter-depth: 1,
)

#exercise(subname: [环境检查])[
  检查你的系统环境：
  - 查看当前使用的 Shell：`echo $SHELL`
  - 查看 PATH 环境变量：`echo $PATH`
  - 查看系统发行版信息：`cat /etc/os-release`
  - 查看内核版本：`uname -a`
]

使用Archlinux原生操作系统。将内容保存为 `1.1.sh`：
```sh
#!/usr/bin/env bash
set -euo pipefail # 严格模式，确保脚本在出错时立即退出

printf '当前用户配置的 Shell（SHELL）：%s\n' "${SHELL:-未设置}"
printf '本脚本使用 Bash，版本：%s\n' "$BASH_VERSION"
printf '\nPATH 环境变量：\n%s\n' "$PATH"
printf '\n系统发行版信息：\n'
cat /etc/os-release
printf '\n内核版本：\n'
uname -a
```
运行
```zsh
❯ bash 1.1.sh
```
结果为
```log
当前用户配置的 Shell（SHELL）：/usr/bin/zsh
本脚本使用 Bash，版本：5.3.15(1)-release

PATH 环境变量：
/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/opt/cuda/bin:/usr/bin/site_perl:/usr/bin/vendor_perl:/usr/bin/core_perl:/usr/lib/rustup/bin

系统发行版信息：
NAME="Arch Linux"
PRETTY_NAME="Arch Linux"
ID=arch
BUILD_ID=rolling
ANSI_COLOR="38;2;23;147;209"
HOME_URL="https://archlinux.org/"
DOCUMENTATION_URL="https://wiki.archlinux.org/"
SUPPORT_URL="https://bbs.archlinux.org/"
BUG_REPORT_URL="https://gitlab.archlinux.org/groups/archlinux/-/issues"
PRIVACY_POLICY_URL="https://terms.archlinux.org/docs/privacy-policy/"
LOGO=archlinux-logo

内核版本：
Linux A-Terminal 7.2.6-zen2-1-zen #1 ZEN SMP PREEMPT_DYNAMIC Mon, 14 Sep 2026 22:41:40 +0000 x86_64 GNU/Linux
```

#exercise(subname: [文件操作])[
  打开终端，完成以下操作：
  - 创建目录 `~/workarea`，并进入该目录
  - 在 `workarea` 下创建子目录 `dir1、dir2、dir3`
  - 创建文件 `file1.txt`、`file2.txt`、`index1.htm`、`index2.htm`、`test1.txt`
  - 设置环境变量 `WORKDIR` 为 `workarea` 的绝对路径
  - 修改 `file1.txt` 的权限为 `644`（`rw-r--r--`）
  - 统计 `workarea` 下的目录数和文件数
  - 统计每个子目录的占用空间大小
]

将以下内容保存为 `1.2.sh`：
```sh
#!/usr/bin/env bash

# 使用 ~/workarea，完成后删除整个目录（包括其中原有的内容）。
mkdir -p -- "$HOME/workarea"
cd -- "$HOME/workarea"
export WORKDIR="$(pwd -P)"
printf 'WORKDIR=%s\n' "$WORKDIR"

mkdir -p dir1 dir2 dir3
touch file1.txt file2.txt index1.htm index2.htm test1.txt
chmod 644 file1.txt
printf '\nfile1.txt 的权限：\n'
ls -l file1.txt

# 只统计 workarea 的直接子项，不包含 workarea 自身。
printf '\n目录数：'
find . -mindepth 1 -maxdepth 1 -type d -printf 'x' | wc -c
printf '文件数：'
find . -mindepth 1 -maxdepth 1 -type f -printf 'x' | wc -c
printf '\n每个子目录的占用空间（包含其内部内容）：\n'
find . -mindepth 1 -maxdepth 1 -type d -exec du -sh -- {} +
```
运行
```zsh
❯ bash 1.2.sh
```
```log
WORKDIR=/home/A/workarea

file1.txt 的权限：
-rw-r--r-- 1 A A 0  9月16日 19:28 file1.txt

目录数：3
文件数：5

每个子目录的占用空间（包含其内部内容）：
4.0K    ./dir2
4.0K    ./dir1
4.0K    ./dir3

已删除 ~/workarea。
```

#exercise(subname: [循环脚本])[
  根据你的 Shell 类型（`bash`），编写一个脚本，用循环批量创建 10 个目录 `testDir1` 到 `testDir10`，并在每个目录中创建一个 `README.txt` 文件，内容为 `"This is test directory N"`。
]

将以下内容保存为 `1.3.sh`：
```sh
#!/usr/bin/env bash

for ((n = 1; n <= 10; n++)); do
  mkdir -p -- "testDir$n"
  printf 'This is test directory %d\n' "$n" > "testDir$n/README.txt"
  printf '已创建：%s/testDir%d/README.txt\n' "$(pwd -P)" "$n"
done
```
运行
```zsh
❯ bash 1.3.sh
```
```log
已创建：/home/A/Documents/Notes/1_Mathematics_and_Physics/P11_Data-Analysis_in_Particle_and_Nuclear_Experiments/LAB/1/testDir1/README.txt
已创建：/home/A/Documents/Notes/1_Mathematics_and_Physics/P11_Data-Analysis_in_Particle_and_Nuclear_Experiments/LAB/1/testDir2/README.txt
已创建：/home/A/Documents/Notes/1_Mathematics_and_Physics/P11_Data-Analysis_in_Particle_and_Nuclear_Experiments/LAB/1/testDir3/README.txt
已创建：/home/A/Documents/Notes/1_Mathematics_and_Physics/P11_Data-Analysis_in_Particle_and_Nuclear_Experiments/LAB/1/testDir4/README.txt
已创建：/home/A/Documents/Notes/1_Mathematics_and_Physics/P11_Data-Analysis_in_Particle_and_Nuclear_Experiments/LAB/1/testDir5/README.txt
已创建：/home/A/Documents/Notes/1_Mathematics_and_Physics/P11_Data-Analysis_in_Particle_and_Nuclear_Experiments/LAB/1/testDir6/README.txt
已创建：/home/A/Documents/Notes/1_Mathematics_and_Physics/P11_Data-Analysis_in_Particle_and_Nuclear_Experiments/LAB/1/testDir7/README.txt
已创建：/home/A/Documents/Notes/1_Mathematics_and_Physics/P11_Data-Analysis_in_Particle_and_Nuclear_Experiments/LAB/1/testDir8/README.txt
已创建：/home/A/Documents/Notes/1_Mathematics_and_Physics/P11_Data-Analysis_in_Particle_and_Nuclear_Experiments/LAB/1/testDir9/README.txt
已创建：/home/A/Documents/Notes/1_Mathematics_and_Physics/P11_Data-Analysis_in_Particle_and_Nuclear_Experiments/LAB/1/testDir10/README.txt

--- testDir1/README.txt ---
This is test directory 1

--- testDir2/README.txt ---
This is test directory 2

--- testDir3/README.txt ---
This is test directory 3

--- testDir4/README.txt ---
This is test directory 4

--- testDir5/README.txt ---
This is test directory 5

--- testDir6/README.txt ---
This is test directory 6

--- testDir7/README.txt ---
This is test directory 7

--- testDir8/README.txt ---
This is test directory 8

--- testDir9/README.txt ---
This is test directory 9

--- testDir10/README.txt ---
This is test directory 10

检查通过：10 个目录及 README.txt 的内容均正确。
已清理本次创建的文件和目录。
```
