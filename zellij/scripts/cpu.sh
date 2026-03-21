#!/bin/bash
top -l1 -n0 2>/dev/null | awk '/CPU usage/{printf "%.0f%%", $3}'
