#!/bin/bash

# XML Task Parser Utility
# Parses <Tasks> XML format from cc-plan plans and converts to JSON
# Usage: parse-tasks.sh <plan-content> [task-id]

# Enable debug mode if DEBUG env var is set
[[ "$DEBUG" ]] && set -x

# Function to extract XML content between tags
extract_xml_content() {
    local tag="$1"
    local content="$2"
    echo "$content" | sed -n "/<$tag>/,/<\/$tag>/p" | sed "1d;\$d"
}

# Function to extract CDATA content
extract_cdata() {
    local content="$1"
    echo "$content" | sed -n 's/.*<!\[CDATA\[\(.*\)\]\]>.*/\1/p'
}

# Function to extract attribute value
extract_attribute() {
    local attr="$1"
    local element="$2"
    echo "$element" | sed -n "s/.*$attr=\"\([^\"]*\)\".*/\1/p"
}

# Function to parse a single task element
parse_task() {
    local task_element="$1"

    # Extract attributes
    local id=$(extract_attribute "id" "$task_element")
    local status=$(extract_attribute "status" "$task_element")

    # Set default status if not provided
    [[ -z "$status" ]] && status="pending"

    # Extract content fields
    local title=$(extract_xml_content "Title" "$task_element")
    local what=$(extract_xml_content "What" "$task_element")
    local why=$(extract_xml_content "Why" "$task_element")
    local file=$(extract_xml_content "File" "$task_element")
    local command=$(extract_xml_content "Command" "$task_element")
    local type=$(extract_xml_content "Type" "$task_element")
    local dependencies=$(extract_xml_content "Dependencies" "$task_element")
    local impacts=$(extract_xml_content "Impacts" "$task_element")
    local test_strategy=$(extract_xml_content "TestStrategy" "$task_element")

    # Extract diff content (handle CDATA)
    local diff_section=$(extract_xml_content "Diff" "$task_element")
    local diff=""
    if [[ -n "$diff_section" ]]; then
        diff=$(extract_cdata "$diff_section")
        [[ -z "$diff" ]] && diff="$diff_section"
    fi

    # Convert dependencies to array format
    local deps_array=""
    if [[ -n "$dependencies" && "$dependencies" != "null" ]]; then
        # Split comma-separated dependencies and create JSON array
        IFS=',' read -ra DEPS <<< "$dependencies"
        local dep_items=""
        for dep in "${DEPS[@]}"; do
            dep=$(echo "$dep" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')  # trim
            [[ -n "$dep" ]] && dep_items="$dep_items\"$dep\","
        done
        [[ -n "$dep_items" ]] && deps_array="[${dep_items%,}]"
    fi
    [[ -z "$deps_array" ]] && deps_array="[]"

    # Generate JSON output
    cat << EOF
{
  "id": "$id",
  "status": "$status",
  "title": "$title",
  "what": "$what",
  "why": "$why",
  "file": "$file",
  "command": "$command",
  "type": "$type",
  "dependencies": $deps_array,
  "impacts": "$impacts",
  "testStrategy": "$test_strategy",
  "diff": "$diff"
}
EOF
}

# Function to parse all tasks
parse_all_tasks() {
    local plan_content="$1"
    local specific_task_id="$2"

    # Extract the entire Tasks section
    local tasks_section=$(echo "$plan_content" | sed -n '/<Tasks>/,/<\/Tasks>/p')

    if [[ -z "$tasks_section" ]]; then
        echo '{"error": "No <Tasks> section found in plan", "tasks": []}'
        return 1
    fi

    # Extract individual Task elements
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
                task_elements+=("$current_task")
                current_task=""
                in_task=false
            fi
        elif [[ "$in_task" == true ]]; then
            # Handle nested tags properly
            if [[ "$line" =~ \<[^/] ]]; then
                task_depth=$((task_depth + 1))
            elif [[ "$line" =~ \<\/ ]]; then
                task_depth=$((task_depth - 1))
            fi
            current_task="$current_task"$'\n'"$line"
        fi
    done <<< "$tasks_section"

    # Parse tasks and generate JSON
    local json_tasks=""
    local found_task=false

    for task_element in "${task_elements[@]}"; do
        local task_id=$(extract_attribute "id" "$task_element")

        # If specific task ID requested, only return that task
        if [[ -n "$specific_task_id" ]] && [[ "$task_id" != "$specific_task_id" ]]; then
            continue
        fi

        found_task=true
        local task_json=$(parse_task "$task_element")
        json_tasks="$json_tasks$task_json,"
    done

    # If specific task requested but not found
    if [[ -n "$specific_task_id" ]] && [[ "$found_task" == false ]]; then
        echo "{\"error\": \"Task with ID '$specific_task_id' not found\", \"tasks\": []}"
        return 1
    fi

    # Remove trailing comma and wrap in array
    [[ -n "$json_tasks" ]] && json_tasks="${json_tasks%,}"

    if [[ -n "$specific_task_id" ]]; then
        # Return single task object
        echo "$json_tasks"
    else
        # Return tasks array with metadata
        local total_tasks=$(echo "$json_tasks" | grep -c '"id":' || echo "0")
        echo "{\"totalTasks\": $total_tasks, \"tasks\": [$json_tasks]}"
    fi
}

# Function to build dependency graph
build_dependency_graph() {
    local plan_content="$1"

    # Get all tasks
    local all_tasks=$(parse_all_tasks "$plan_content")

    # Extract task dependencies and build graph
    echo "$all_tasks" | jq -r '
        .tasks[] |
        {
            id: .id,
            title: .title,
            dependencies: .dependencies,
            dependents: []
        }
    ' | jq -s '
        # Build dependents list
        map(. as $task |
            .dependents = [
                .. |
                select(type == "object" and has("dependencies")) |
                select(.dependencies[] == $task.id) |
                .id
            ]
        ) |
        {
            nodes: .,
            edges: [
                .[] |
                .dependencies[] as $dep |
                {from: $dep, to: .id}
            ]
        }
    '
}

# Function to update task status in plan content
update_task_status_in_plan() {
    local plan_content="$1"
    local task_identifier="$2"
    local new_status="$3"

    # Use the dedicated update-task-status utility
    local script_dir="$(dirname "${BASH_SOURCE[0]}")"
    "$script_dir/update-task-status.sh" "$plan_content" "$task_identifier" "$new_status"
}

# Main execution
main() {
    local plan_content="$1"
    local task_id="$2"
    local command="$3"
    local new_status="$4"

    if [[ -z "$plan_content" ]]; then
        echo '{"error": "No plan content provided", "usage": "parse-tasks.sh <plan-content> [task-id] [command] [new-status]"}'
        exit 1
    fi

    case "$command" in
        "graph")
            build_dependency_graph "$plan_content"
            ;;
        "update-status")
            if [[ -z "$task_id" || -z "$new_status" ]]; then
                echo '{"error": "Missing task identifier or status", "usage": "parse-tasks.sh <plan-content> <task-id> update-status <new-status>"}'
                exit 1
            fi
            update_task_status_in_plan "$plan_content" "$task_id" "$new_status"
            ;;
        *)
            parse_all_tasks "$plan_content" "$task_id"
            ;;
    esac
}

# Execute if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi