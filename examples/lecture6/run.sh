#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")"
root -l -b -q lecture6_demo.C
python3 check_results.py
cp -- competition.png paths.png path-lengths.png ../../pic/chap5-lab/
