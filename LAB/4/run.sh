#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")"
{
    root -l -b -q exercise.C
    python3 check_results.py
} 2>&1 | tee run-output.txt
