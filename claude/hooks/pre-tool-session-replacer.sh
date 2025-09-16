#!/bin/bash

# Pre-tool hook to replace {{sessionId}} placeholders with actual session ID
# This hook intercepts tool calls and replaces any {{sessionId}} placeholder
# with the value from $CLAUDE_SESSION_ID environment variable

# Read the JSON input from stdin
input=$(cat)

# Get session ID from environment variable, default to "default" if not set
session_id="${CLAUDE_SESSION_ID:-default}"

# Replace all occurrences of {{sessionId}} with the actual session ID
# Using sed to replace the placeholder in the JSON string
modified_input=$(echo "$input" | sed "s/{{sessionId}}/$session_id/g")

# Output the modified JSON to stdout
echo "$modified_input"

# Exit with success status
exit 0