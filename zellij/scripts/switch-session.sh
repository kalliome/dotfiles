#!/bin/bash
# Switch to a named zellij session if it exists
# Usage: switch-session.sh <session-name>
session="$1"
log="/tmp/zellij-switch-session.log"

echo "$(date '+%H:%M:%S') --- switch-session.sh called with: '$session'" >> "$log"

sessions=$(zellij list-sessions --short 2>&1)

if echo "$sessions" | grep -qx "$session"; then
    echo "  Found session '$session', switching..." >> "$log"
    output=$(zellij pipe --plugin "file:$HOME/dotfiles/zellij/plugins/zellij-switch.wasm" -- "--session $session" 2>&1)
    echo "  pipe exit=$? output='$output'" >> "$log"
else
    echo "  Session '$session' not found" >> "$log"
fi
