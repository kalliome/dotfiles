#!/bin/bash

# XML Task Status Updater Utility
# Updates task status attribute in XML within plan content
# Usage: update-task-status.sh <plan-content> <task-id-or-title> <new-status>

# Enable debug mode if DEBUG env var is set
[[ "$DEBUG" ]] && set -x

# Function to update task status by ID
update_task_status_by_id() {
    local plan_content="$1"
    local task_id="$2"
    local new_status="$3"

    # Use sed to update the status attribute for the specific task ID
    echo "$plan_content" | sed "s/<Task id=\"$task_id\" status=\"[^\"]*\"/<Task id=\"$task_id\" status=\"$new_status\"/g"
}

# Function to update task status by title
update_task_status_by_title() {
    local plan_content="$1"
    local task_title="$2"
    local new_status="$3"

    # This is more complex as we need to find the task with the matching title
    # and update its status attribute
    local temp_file=$(mktemp)
    local in_target_task=false
    local task_depth=0
    local current_task=""
    local updated_content=""

    echo "$plan_content" | while IFS= read -r line; do
        # Check if we're starting a Task element
        if [[ "$line" =~ \<Task[[:space:]] ]]; then
            in_target_task=false
            task_depth=1
            current_task="$line"
        elif [[ "$line" =~ \<\/Task\> ]] && [[ "$task_depth" -gt 0 ]]; then
            task_depth=$((task_depth - 1))
            current_task="$current_task"$'\n'"$line"

            if [[ $task_depth -eq 0 ]]; then
                # Check if this task contains the target title
                if echo "$current_task" | grep -q "<Title>$task_title</Title>"; then
                    # Update the status in this task
                    current_task=$(echo "$current_task" | sed "s/status=\"[^\"]*\"/status=\"$new_status\"/")
                fi
                echo "$current_task"
                current_task=""
            fi
        elif [[ "$task_depth" -gt 0 ]]; then
            # Handle nested tags properly
            if [[ "$line" =~ \<[^/] ]] && [[ ! "$line" =~ /\> ]]; then
                task_depth=$((task_depth + 1))
            elif [[ "$line" =~ \<\/ ]]; then
                task_depth=$((task_depth - 1))
            fi
            current_task="$current_task"$'\n'"$line"
        else
            # Output non-task lines as-is
            echo "$line"
        fi
    done
}

# Function to extract task ID from task title
get_task_id_by_title() {
    local plan_content="$1"
    local task_title="$2"

    # Parse tasks and find ID for the given title
    local tasks_section=$(echo "$plan_content" | sed -n '/<Tasks>/,/<\/Tasks>/p')

    if [[ -z "$tasks_section" ]]; then
        return 1
    fi

    # Extract task elements and find matching title
    local task_elements=()
    local current_task=""
    local in_task=false
    local task_depth=0

    while IFS= read -r line; do
        if [[ "$line" =~ \<Task[[:space:]] ]]; then
            in_task=true
            task_depth=1
            current_task="$line"
        elif [[ "$line" =~ \<\/Task\> ]] && [[ "$in_task" == true ]]; then
            task_depth=$((task_depth - 1))
            current_task="$current_task"$'\n'"$line"
            if [[ $task_depth -eq 0 ]]; then
                # Check if this task has the matching title
                if echo "$current_task" | grep -q "<Title>$task_title</Title>"; then
                    # Extract and return the task ID
                    echo "$current_task" | sed -n 's/.*id="\([^"]*\)".*/\1/p' | head -1
                    return 0
                fi
                current_task=""
                in_task=false
            fi
        elif [[ "$in_task" == true ]]; then
            # Handle nested tags properly
            if [[ "$line" =~ \<[^/] ]] && [[ ! "$line" =~ /\> ]]; then
                task_depth=$((task_depth + 1))
            elif [[ "$line" =~ \<\/ ]]; then
                task_depth=$((task_depth - 1))
            fi
            current_task="$current_task"$'\n'"$line"
        fi
    done <<< "$tasks_section"

    return 1
}

# Main function to update task status
update_task_status() {
    local plan_content="$1"
    local task_identifier="$2"
    local new_status="$3"

    if [[ -z "$plan_content" || -z "$task_identifier" || -z "$new_status" ]]; then
        echo "Error: Missing required parameters" >&2
        echo "Usage: update-task-status.sh <plan-content> <task-id-or-title> <new-status>" >&2
        return 1
    fi

    # Validate status
    case "$new_status" in
        "pending"|"in_progress"|"completed")
            ;;
        *)
            echo "Error: Invalid status '$new_status'. Must be: pending, in_progress, or completed" >&2
            return 1
            ;;
    esac

    # Try to update by ID first (if it looks like an ID)
    if [[ "$task_identifier" =~ ^[0-9]+$ ]]; then
        # Looks like a numeric ID
        update_task_status_by_id "$plan_content" "$task_identifier" "$new_status"
    else
        # Try to find task ID by title first
        local task_id=$(get_task_id_by_title "$plan_content" "$task_identifier")
        if [[ -n "$task_id" ]]; then
            update_task_status_by_id "$plan_content" "$task_id" "$new_status"
        else
            # Fall back to title-based update
            update_task_status_by_title "$plan_content" "$task_identifier" "$new_status"
        fi
    fi
}

# Function to get current task status
get_task_status() {
    local plan_content="$1"
    local task_identifier="$2"

    if [[ "$task_identifier" =~ ^[0-9]+$ ]]; then
        # Extract status by ID
        echo "$plan_content" | sed -n "s/.*<Task id=\"$task_identifier\" status=\"\([^\"]*\)\".*/\1/p"
    else
        # Find by title and extract status
        local task_id=$(get_task_id_by_title "$plan_content" "$task_identifier")
        if [[ -n "$task_id" ]]; then
            echo "$plan_content" | sed -n "s/.*<Task id=\"$task_id\" status=\"\([^\"]*\)\".*/\1/p"
        fi
    fi
}

# Execute if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "$1" in
        "get-status")
            get_task_status "$2" "$3"
            ;;
        *)
            update_task_status "$1" "$2" "$3"
            ;;
    esac
fi