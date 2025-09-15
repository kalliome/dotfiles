#!/usr/bin/env bash

# Debug available variables and environment for slash commands
echo "=== Claude Command Debug Information ==="
echo

echo "Environment Variables:"
echo "CLAUDE_SESSION_ID: ${CLAUDE_SESSION_ID:-'not set'}"
echo "CLAUDE_USER_ID: ${CLAUDE_USER_ID:-'not set'}"
echo "CLAUDE_WORKSPACE_ID: ${CLAUDE_WORKSPACE_ID:-'not set'}"
echo "CLAUDE_PROJECT_ID: ${CLAUDE_PROJECT_ID:-'not set'}"
echo "CLAUDE_CONVERSATION_ID: ${CLAUDE_CONVERSATION_ID:-'not set'}"
echo "PWD: $PWD"
echo "HOME: $HOME"
echo

echo "Available Commands:"
echo "claude-memory session list"
echo "claude-memory session get-active"
if [ -n "$CLAUDE_SESSION_ID" ]; then
    echo "claude-memory session get-active --session-id \"$CLAUDE_SESSION_ID\""
fi
echo

echo "Testing claude-memory commands:"
echo "1. Listing sessions:"
claude-memory session list 2>&1 || echo "Failed to list sessions"
echo

echo "2. Getting active session:"
claude-memory session get-active 2>&1 || echo "Failed to get active session"
echo

if [ -n "$CLAUDE_SESSION_ID" ]; then
    echo "3. Getting session by ID:"
    claude-memory session get-active --session-id "$CLAUDE_SESSION_ID" 2>&1 || echo "Failed to get session by ID"
else
    echo "3. CLAUDE_SESSION_ID not available, skipping session-specific query"
fi
echo

echo "Git Information:"
echo "Current branch: $(git branch --show-current 2>/dev/null || echo 'not in git repo')"
echo "Git status: $(git status --porcelain 2>/dev/null | wc -l || echo '0') files changed"
echo

echo "=== End Debug Information ==="