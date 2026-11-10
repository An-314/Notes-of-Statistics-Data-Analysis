#!/usr/bin/env bash
set -euo pipefail
if (( $# > 2 )); then
    printf 'Usage: bash %s [output-directory] [toys-per-model]\n' "$0" >&2
    exit 2
fi
project_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
output_dir="${1:-$project_dir/../pic/6}"
toys="${2:-2000000}"
if [[ ! "$toys" =~ ^[1-9][0-9]*$ ]] || (( toys < 2 )); then
    printf 'At least two pseudoexperiments are required.\n' >&2
    exit 2
fi
command -v root >/dev/null
mkdir -p -- "$output_dir"
output_dir="$(cd -- "$output_dir" && pwd -P)"
cd -- "$project_dir"
root_output="${output_dir//\\/\\\\}"
root_output="${root_output//\"/\\\"}"
root -l -b -q "macros/ex4_3.C(\"$root_output\")"
root -l -b -q "macros/ex4_4.C(\"$root_output\",$toys)"
for name in 4-3-results.csv 4-4-results.csv 4-4-data-theory.svg 4-4-pearson-toys.svg; do
    test -s "$output_dir/$name"
done
printf 'Exercises 4.3 and 4.4 finished: %s\n' "$output_dir"
