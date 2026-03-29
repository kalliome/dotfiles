#!/bin/bash
total=$(sysctl -n hw.memsize)
vm_stat 2>/dev/null | awk -v total="$total" '
  /page size/    { ps = $8 }
  /Pages active/ { active = $3+0 }
  /Pages wired/  { wired = $4+0 }
  /Pages speculative/ { spec = $3+0 }
  /Pages compressed/  { comp = $3+0 }
  END { used = (active + wired + spec + comp) * ps; printf "%.0f%%", used / total * 100 }'
