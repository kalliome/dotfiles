#!/bin/bash
cores=$(sysctl -n hw.ncpu)
ps -A -o %cpu | awk -v cores="$cores" '{s+=$1} END {printf "%.0f%%", s/cores}'
