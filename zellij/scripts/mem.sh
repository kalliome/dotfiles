#!/bin/bash
memory_pressure 2>/dev/null | awk '/percentage/{printf "%s", $5}'
