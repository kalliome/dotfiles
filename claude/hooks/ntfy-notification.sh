#!/bin/bash

# Enhanced ntfy notification hook for Claude Code
# Sends notifications with context information to ntfy.sh

# Debug log file
DEBUG_LOG="/tmp/claude-ntfy-debug.log"

# Configuration
NTFY_URL="https://ntfy.teppo.dev/claude"
NTFY_USERNAME="teppo"
NTFY_PASSWORD="9GBmkKYEedbRiJv2Ajkv"

# Read JSON input from stdin
input=$(cat)

# Get session ID from environment, default to "unknown" if not set
session_id="${CLAUDE_SESSION_ID:-unknown}"

# Get current timestamp
timestamp=$(date "+%H:%M:%S")

# Debug logging
echo "=== $(date) ===" >> "$DEBUG_LOG"
echo "Session ID: $session_id" >> "$DEBUG_LOG"
echo "Input JSON: $input" >> "$DEBUG_LOG"

# Try to extract message from JSON input if available
message=""
if command -v jq >/dev/null 2>&1; then
    # Try to extract any message or content from the JSON
    message=$(echo "$input" | jq -r '.message // .content // .text // empty' 2>/dev/null)
    echo "Extracted message: $message" >> "$DEBUG_LOG"
else
    echo "jq not available" >> "$DEBUG_LOG"
fi

# Prepare notification content
if [ -n "$message" ] && [ "$message" != "null" ]; then
    notification_text="🤖 Claude Code ($timestamp)
Session: ${session_id##*.}
Message: $message"
else
    notification_text="🤖 Claude Code needs your attention ($timestamp)
Session: ${session_id##*.}"
fi

echo "Notification text: $notification_text" >> "$DEBUG_LOG"

# Send notification via ntfy
echo "Sending to: $NTFY_URL" >> "$DEBUG_LOG"
echo "Username: $NTFY_USERNAME" >> "$DEBUG_LOG"

# Test authentication first
auth_test=$(curl -s -w "%{http_code}" -u "$NTFY_USERNAME:$NTFY_PASSWORD" "$NTFY_URL" -o /dev/null)
echo "Auth test HTTP code: $auth_test" >> "$DEBUG_LOG"

curl_response=$(curl -s -w "HTTP_CODE:%{http_code}" \
    -u "$NTFY_USERNAME:$NTFY_PASSWORD" \
    -H "Title: Claude Code" \
    -H "Priority: default" \
    -H "Tags: robot,code" \
    -d "$notification_text" \
    "$NTFY_URL" 2>&1)

curl_exit_code=$?
echo "Curl exit code: $curl_exit_code" >> "$DEBUG_LOG"
echo "Curl response: $curl_response" >> "$DEBUG_LOG"
echo "---" >> "$DEBUG_LOG"

# Always pass through the original input unchanged
echo "$input"

# Exit successfully
exit 0