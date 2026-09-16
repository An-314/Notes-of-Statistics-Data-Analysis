#!/usr/bin/env bash
# 练习 1：检查系统环境。
set -euo pipefail

printf '当前用户配置的 Shell（SHELL）：%s\n' "${SHELL:-未设置}"
printf '本脚本使用 Bash，版本：%s\n' "$BASH_VERSION"
printf '\nPATH 环境变量：\n%s\n' "$PATH"
printf '\n系统发行版信息：\n'
cat /etc/os-release
printf '\n内核版本：\n'
uname -a
