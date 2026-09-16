#!/usr/bin/env bash
# 练习 3：循环创建目录。运行：bash LAB/1/1.3.sh
# 直接在运行时的当前目录操作；检查成功后清理本次创建的文件和目录。
set -euo pipefail

for ((n = 1; n <= 10; n++)); do
  mkdir -p -- "testDir$n"
  printf 'This is test directory %d\n' "$n" > "testDir$n/README.txt"
  printf '已创建：%s/testDir%d/README.txt\n' "$(pwd -P)" "$n"
done

for ((n = 1; n <= 10; n++)); do
  if [[ ! -d "testDir$n" || ! -f "testDir$n/README.txt" ]] ||
    ! printf 'This is test directory %d\n' "$n" | cmp -s - "testDir$n/README.txt"; then
    printf '检查失败：testDir%d，保留现场以便排查。\n' "$n" >&2
    exit 1
  fi
  printf '\n--- testDir%d/README.txt ---\n' "$n"
  cat -- "testDir$n/README.txt"
done
printf '\n检查通过：10 个目录及 README.txt 的内容均正确。\n'

for ((n = 1; n <= 10; n++)); do
  rm -- "testDir$n/README.txt"
  rmdir -- "testDir$n"
done
printf '已清理本次创建的文件和目录。\n'
