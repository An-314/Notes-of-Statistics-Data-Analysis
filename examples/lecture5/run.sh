#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")"
root -l -b -q tree1w.C
root -l -b -q tree1r.C
cp -- tree1.root tree1-cpp.root
python3 tree1w.py
python3 tree1r.py
python3 lecture5_demo.py
cp -- tree-distributions.png rdf-comparison.png ../../pic/chap4-lab/
