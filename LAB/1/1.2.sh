#!/usr/bin/env bash
# 练习 2：文件操作。
# 使用 ~/workarea，完成后删除整个目录（包括其中原有的内容）。
# WORKDIR 的导出仅影响本脚本及其子进程。
set -euo pipefail

if (( $# > 0 )); then
  printf '本脚本仅操作 ~/workarea，不接受其他目录参数。\n' >&2
  exit 1
fi
if [[ -L "$HOME/workarea" ]]; then
  printf '拒绝操作：~/workarea 是符号链接。\n' >&2
  exit 1
fi

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

# 离开工作目录后再删除；清理目标固定为 ~/workarea。
cd -- "$HOME"
rm -rf -- "$HOME/workarea"
printf '\n已删除 ~/workarea。\n'
