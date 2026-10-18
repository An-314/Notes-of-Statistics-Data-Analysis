#!/usr/bin/env bash
set -euo pipefail

if (( $# > 2 )); then
    printf 'Usage: bash %s [output-directory] [binary-directory]\n' "$0" >&2
    exit 2
fi

project_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
output_dir="${1:-$project_dir/../pic/4}"
binary_dir="${2:-}"

mkdir -p -- "$output_dir"
output_dir="$(cd -- "$output_dir" && pwd -P)"
if [[ -n "$binary_dir" ]]; then
    binary_dir="$(cd -- "$binary_dir" && pwd -P)"
else
    command -v root >/dev/null
fi

cd -- "$project_dir"
# Quote a C++ string literal for ROOT without evaluating it in the shell.
root_output="${output_dir//\\/\\\\}"
root_output="${root_output//\"/\\\"}"
for number in 1 2 3 4 5 6; do
    if [[ -n "$binary_dir" ]]; then
        "$binary_dir/ex3_$number" "$output_dir"
    else
        root -l -b -q "macros/ex3_$number.C(\"$root_output\")"
    fi
    test -s "$output_dir/3-$number-results.csv"
    test -s "$output_dir/3-$number-run-info.txt"
done

# Only aggregate after all six exercises finish successfully.
head -n 1 "$output_dir/3-1-results.csv" > "$output_dir/results.csv"
: > "$output_dir/run-info.txt"
for number in 1 2 3 4 5 6; do
    tail -n +2 "$output_dir/3-$number-results.csv" >> "$output_dir/results.csv"
    cat "$output_dir/3-$number-run-info.txt" >> "$output_dir/run-info.txt"
done
printf 'All six exercises finished. Results: %s\n' "$output_dir"
