#!/bin/bash

# Task Status Update Hook
# Updates task status in cc-plan and sends notifications
# Triggered when agents complete tasks

# Debug log file
DEBUG_LOG="/tmp/claude-task-status-debug.log"

# Enable debug mode if DEBUG env var is set
[[ "$DEBUG" ]] && set -x

# Read JSON input from stdin
input=$(cat)

# Get session ID from environment
session_id="${CLAUDE_SESSION_ID:-unknown}"

# Get current timestamp
timestamp=$(date "+%H:%M:%S")

# Debug logging
echo "=== $(date) ===" >> "$DEBUG_LOG"
echo "Session ID: $session_id" >> "$DEBUG_LOG"
echo "Input JSON: $input" >> "$DEBUG_LOG"

# Function to extract task information from agent messages
extract_task_info() {
    local message="$1"

    # Look for task completion patterns in the message
    local task_id=""
    local task_title=""
    local new_status=""

    # Pattern 1: "✅ Task Implementation Complete" from plan-task-executor
    if echo "$message" | grep -q "Task Implementation Complete"; then
        task_title=$(echo "$message" | sed -n 's/.*Task: \([^$]*\).*/\1/p' | head -1)
        new_status="completed"
    fi

    # Pattern 2: "📋 Task Analysis" from plan-task-executor starting
    if echo "$message" | grep -q "Task Analysis"; then
        task_title=$(echo "$message" | sed -n 's/.*Task: \([^$]*\).*/\1/p' | head -1)
        new_status="in_progress"
    fi

    # Pattern 3: "**VERDICT: OK**" from plan-task-reviewer
    if echo "$message" | grep -q "VERDICT: OK"; then
        task_title=$(echo "$message" | sed -n 's/.*Task: \([^$]*\).*/\1/p' | head -1)
        new_status="completed"
    fi

    # Pattern 4: "**VERDICT: NEEDS IMPROVEMENT**" from plan-task-reviewer
    if echo "$message" | grep -q "VERDICT: NEEDS IMPROVEMENT"; then
        task_title=$(echo "$message" | sed -n 's/.*Task: \([^$]*\).*/\1/p' | head -1)
        new_status="in_progress"  # Keep as in_progress for revision
    fi

    # Pattern 5: Explicit task ID in message
    if echo "$message" | grep -q "Task ID:"; then
        task_id=$(echo "$message" | sed -n 's/.*Task ID: \([^$]*\).*/\1/p' | head -1)
    fi

    echo "Extracted - ID: '$task_id', Title: '$task_title', Status: '$new_status'" >> "$DEBUG_LOG"

    # Return extracted info as JSON
    if [[ -n "$task_id" || -n "$task_title" ]] && [[ -n "$new_status" ]]; then
        cat << EOF
{
  "taskId": "$task_id",
  "taskTitle": "$task_title",
  "newStatus": "$new_status",
  "timestamp": "$timestamp"
}
EOF
    else
        echo "null"
    fi
}

# Function to update task status in cc-plan
update_task_status() {
    local task_info="$1"

    if [[ "$task_info" == "null" ]]; then
        echo "No task information to update" >> "$DEBUG_LOG"
        return 0
    fi

    local task_id=$(echo "$task_info" | jq -r '.taskId // empty')
    local task_title=$(echo "$task_info" | jq -r '.taskTitle // empty')
    local new_status=$(echo "$task_info" | jq -r '.newStatus // empty')

    echo "Updating task - ID: '$task_id', Title: '$task_title', Status: '$new_status'" >> "$DEBUG_LOG"

    # Determine task identifier (prefer ID, fall back to title)
    local task_identifier=""
    if [[ -n "$task_id" ]]; then
        task_identifier="$task_id"
    elif [[ -n "$task_title" ]]; then
        task_identifier="$task_title"
    else
        echo "No task identifier available for update" >> "$DEBUG_LOG"
        return 1
    fi

    local update_success=false

    if [[ "$session_id" != "unknown" ]]; then
        # Get current plan content
        local plan_content=$(cc-plan plan get --session-id "$session_id" 2>>"$DEBUG_LOG")

        if [[ $? -eq 0 && -n "$plan_content" ]]; then
            echo "Retrieved plan content for status update" >> "$DEBUG_LOG"

            # Update task status in the XML using our utility
            local updated_plan_content=$($(dirname "${BASH_SOURCE[0]}")/../utils/update-task-status.sh "$plan_content" "$task_identifier" "$new_status" 2>>"$DEBUG_LOG")

            if [[ $? -eq 0 && -n "$updated_plan_content" ]]; then
                # Update the plan with the modified content
                if echo "$updated_plan_content" | cc-plan plan update --session-id "$session_id" --content "$(cat)" >> "$DEBUG_LOG" 2>&1; then
                    update_success=true
                    echo "Successfully updated task '$task_identifier' to $new_status in plan" >> "$DEBUG_LOG"
                else
                    echo "Failed to update plan with new task status" >> "$DEBUG_LOG"
                fi
            else
                echo "Failed to update task status in XML content" >> "$DEBUG_LOG"
            fi
        else
            echo "Failed to retrieve plan content for session $session_id" >> "$DEBUG_LOG"
        fi
    else
        echo "Session ID unknown, cannot update task status" >> "$DEBUG_LOG"
    fi

    # Send notification if update was successful
    if [[ "$update_success" == true ]]; then
        send_task_notification "$task_info"
    fi

    return 0
}

# Function to send task completion notification
send_task_notification() {
    local task_info="$1"

    local task_title=$(echo "$task_info" | jq -r '.taskTitle // .taskId')
    local new_status=$(echo "$task_info" | jq -r '.newStatus')

    # Determine notification message based on status
    local notification_text=""
    local emoji=""

    case "$new_status" in
        "completed")
            emoji="✅"
            notification_text="$emoji Task Completed ($timestamp)
Session: ${session_id##*.}
Task: $task_title"
            ;;
        "in_progress")
            emoji="🔄"
            notification_text="$emoji Task Started ($timestamp)
Session: ${session_id##*.}
Task: $task_title"
            ;;
        *)
            emoji="📋"
            notification_text="$emoji Task Status Update ($timestamp)
Session: ${session_id##*.}
Task: $task_title
Status: $new_status"
            ;;
    esac

    echo "Sending notification: $notification_text" >> "$DEBUG_LOG"

    # Try to send notification using ntfy (same config as ntfy-notification.sh)
    local ntfy_url="https://ntfy.teppo.dev/claude"
    local ntfy_username="teppo"
    local ntfy_password="9GBmkKYEedbRiJv2Ajkv"

    curl -s \
        -u "$ntfy_username:$ntfy_password" \
        -H "Title: Claude Code - Task Update" \
        -H "Priority: default" \
        -H "Tags: robot,task,$new_status" \
        -d "$notification_text" \
        "$ntfy_url" >> "$DEBUG_LOG" 2>&1

    echo "Notification sent" >> "$DEBUG_LOG"
}

# Main processing
process_input() {
    local input="$1"

    # Try to extract message from JSON input if available
    local message=""
    if command -v jq >/dev/null 2>&1; then
        message=$(echo "$input" | jq -r '.message // .content // .text // empty' 2>/dev/null)
        echo "Extracted message: $message" >> "$DEBUG_LOG"
    else
        echo "jq not available, using raw input" >> "$DEBUG_LOG"
        message="$input"
    fi

    # Extract task information from the message
    if [[ -n "$message" && "$message" != "null" ]]; then
        local task_info=$(extract_task_info "$message")
        update_task_status "$task_info"
    fi
}

# Execute main processing
process_input "$input"

# Always pass through the original input unchanged
echo "$input"

# Exit successfully
exit 0