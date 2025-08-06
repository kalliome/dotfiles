#!/usr/bin/env zsh
# Git Worktree Helper Functions
# Save this file as: ~/.config/zsh/git-worktree-helpers.zsh
# Or: ~/bin/git-worktree-helpers.sh

# Create a new worktree for a feature branch
# Usage: wt-create <branch-name>
wt-create() {
    if [ -z "$1" ]; then
        echo "Usage: wt-create <branch-name>"
        return 1
    fi

    local branch_name="$1"
    local current_dir=$(pwd)
    local repo_name=${current_dir:t}  # zsh built-in for basename
    local parent_dir=${current_dir:h}  # zsh built-in for dirname
    local worktree_path="${parent_dir}/${repo_name}-${branch_name}"

    # Check if we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "Error: Not in a git repository"
        return 1
    fi

    # Check if branch exists remotely or locally
    if git show-ref --verify --quiet "refs/heads/${branch_name}"; then
        echo "Creating worktree for existing branch '${branch_name}'..."
        git worktree add "$worktree_path" "$branch_name"
    else
        # Check if branch exists on remote
        local remote_branch=$(git ls-remote --heads origin "$branch_name" 2>/dev/null)
        if [[ -n "$remote_branch" ]]; then
            echo "Creating worktree for remote branch 'origin/${branch_name}'..."
            git worktree add "$worktree_path" "$branch_name"
        else
            echo "Creating worktree with new branch '${branch_name}'..."
            git worktree add -b "$branch_name" "$worktree_path"
        fi
    fi

    if [ $? -eq 0 ]; then
        echo "✓ Worktree created at: $worktree_path"
        echo "  You can cd into it with: cd $worktree_path"
    else
        echo "✗ Failed to create worktree"
        return 1
    fi
}

# List all worktrees for the current repository
# Usage: wt-list
wt-list() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "Error: Not in a git repository"
        return 1
    fi

    echo "Git Worktrees:"
    echo "=============="

    # Get the main worktree path for comparison
    local main_path=$(git rev-parse --show-toplevel)

    # Process worktree list without piping to while loop
    local worktree_output=$(git worktree list)

    # Counter for numbering
    local index=0

    # Process each line
    echo "$worktree_output" | while IFS= read -r line; do
        # Skip empty lines
        [[ -z "$line" ]] && continue

        ((index++))

        # Extract path (first word) - don't use local in loop
        wt_path=${line%% *}

        # Extract branch name if present (between brackets)
        branch=""
        if [[ "$line" =~ \[([^\]]+)\] ]]; then
            branch="${match[1]}"
        fi

        # Get basename for cleaner display
        base=${wt_path:t}  # zsh built-in for basename

        # Check worktree type and display accordingly
        if [[ "$line" == *"(bare)"* ]]; then
            echo "  $index) $base [BARE]"
        elif [[ "$wt_path" == "$main_path" ]]; then
            echo "  $index) $base [MAIN] ($branch)"
        else
            echo "  $index) $base ← $branch"
        fi
    done

    echo ""
    echo "Tip: Use 'wts <number>' or 'wts <branch>' to switch"
}

# Remove a worktree
# Usage: wt-remove <branch-name> or wt-remove (interactive)
wt-remove() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "Error: Not in a git repository"
        return 1
    fi

    if [ -z "$1" ]; then
        # Interactive mode - show list and prompt for selection
        echo "Available worktrees to remove:"
        echo "=============================="

        local worktrees=()
        local main_path=$(git rev-parse --show-toplevel)

        # Get all worktrees
        local worktree_output=$(git worktree list)

        # Process each line
        while IFS= read -r line; do
            [[ -z "$line" ]] && continue

            # Extract path (first word) - don't use local in loop
            wt_path=${line%% *}

            # Skip main worktree and bare repos
            if [[ "$wt_path" != "$main_path" ]] && [[ "$line" != *"(bare)"* ]]; then
                # Extract branch name if present
                branch=""
                if [[ "$line" =~ \[([^\]]+)\] ]]; then
                    branch="${match[1]}"
                fi
                worktrees+=("$wt_path|$branch")
            fi
        done <<< "$worktree_output"

        if [ ${#worktrees[@]} -eq 0 ]; then
            echo "No worktrees to remove (only main repository exists)"
            return 0
        fi

        # Display worktrees with numbers
        local i=1
        for wt in "${worktrees[@]}"; do
            wt_path=${wt%%|*}
            branch=${wt#*|}
            base=${wt_path:t}  # zsh built-in for basename
            echo "  $i) $base ← $branch"
            ((i++))
        done

        echo -n "Enter number to remove (or 'q' to quit): "
        read selection

        if [ "$selection" = "q" ]; then
            return 0
        fi

        if ! [[ "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt ${#worktrees[@]} ]; then
            echo "Invalid selection"
            return 1
        fi

        local selected_wt="${worktrees[$((selection-1))]}"
        wt_path=${selected_wt%%|*}
        branch=${selected_wt#*|}
        base=${wt_path:t}

        echo -n "Remove worktree '$base' at $wt_path? [y/N]: "
        read confirm
        if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
            git worktree remove "$wt_path"
            if [ $? -eq 0 ]; then
                echo "✓ Worktree removed: $wt_path"
            else
                echo "✗ Failed to remove worktree"
                echo "  Try: git worktree remove --force $wt_path"
            fi
        else
            echo "Cancelled"
        fi
    else
        # Direct mode - remove by branch name
        local branch_name="$1"
        local current_dir=$(pwd)
        local repo_name=${current_dir:t}  # zsh built-in for basename
        local parent_dir=${current_dir:h}  # zsh built-in for dirname
        local worktree_path="${parent_dir}/${repo_name}-${branch_name}"

        if [ ! -d "$worktree_path" ]; then
            echo "Worktree not found at expected path: $worktree_path"
            echo "Searching for worktree with branch '$branch_name'..."

            # Try to find by branch name
            local found_path=""
            local worktree_output=$(git worktree list)
            while IFS= read -r line; do
                if [[ "$line" =~ \[${branch_name}\] ]]; then
                    found_path=${line%% *}
                    break
                fi
            done <<< "$worktree_output"

            if [ -n "$found_path" ]; then
                worktree_path="$found_path"
                echo "Found at: $worktree_path"
            else
                echo "No worktree found for branch: $branch_name"
                return 1
            fi
        fi

        echo "Removing worktree at: $worktree_path"
        git worktree remove "$worktree_path"
        if [ $? -eq 0 ]; then
            echo "✓ Worktree removed successfully"
        else
            echo "✗ Failed to remove worktree"
            echo "  Try: git worktree remove --force $worktree_path"
        fi
    fi
}

# Quick switch to a worktree
# Usage: wt-switch <branch-name> or wt-switch <number>
wt-switch() {
    if [ -z "$1" ]; then
        echo "Usage: wt-switch <branch-name> or wt-switch <number>"
        echo "Run 'wt-list' to see available worktrees with numbers"
        return 1
    fi

    # Check if we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "Error: Not in a git repository"
        return 1
    fi

    local target="$1"

    # Check if argument is a number
    if [[ "$target" =~ ^[0-9]+$ ]]; then
        # Switch by index
        local worktree_output=$(git worktree list)
        local index=0
        local target_path=""

        # Find the worktree at the specified index
        while IFS= read -r line; do
            [[ -z "$line" ]] && continue
            ((index++))

            if [[ $index -eq $target ]]; then
                target_path=${line%% *}
                break
            fi
        done <<< "$worktree_output"

        if [ -n "$target_path" ] && [ -d "$target_path" ]; then
            cd "$target_path"
            echo "✓ Switched to worktree #$target: $(pwd)"
        else
            echo "Error: No worktree at index $target (found $index worktrees total)"
            echo "Run 'wt-list' to see available worktrees"
            return 1
        fi
    else
        # Switch by branch name (original behavior)
        local current_dir=$(pwd)
        local repo_name=${current_dir:t}  # zsh built-in for basename
        local parent_dir=${current_dir:h}  # zsh built-in for dirname
        local worktree_path="${parent_dir}/${repo_name}-${target}"

        if [ -d "$worktree_path" ]; then
            cd "$worktree_path"
            echo "✓ Switched to worktree: $(pwd)"
        else
            # Try to find by searching through worktrees
            local found_path=""
            local worktree_output=$(git worktree list)

            while IFS= read -r line; do
                if [[ "$line" =~ \[${target}\] ]]; then
                    found_path=${line%% *}
                    break
                fi
            done <<< "$worktree_output"

            if [ -n "$found_path" ] && [ -d "$found_path" ]; then
                cd "$found_path"
                echo "✓ Switched to worktree: $(pwd)"
            else
                echo "Worktree not found for: $target"
                echo "Create it with: wt-create $target"
                echo "Or run 'wt-list' to see available worktrees"
                return 1
            fi
        fi
    fi
}

# Prune worktrees (remove references to deleted directories)
# Usage: wt-prune
wt-prune() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "Error: Not in a git repository"
        return 1
    fi

    echo "Pruning stale worktree references..."
    git worktree prune -v
    echo "✓ Done"
}

# Show help for git worktree commands
# Usage: wt-help
wt-help() {
    cat << 'EOF'
Git Worktree Helper Commands
============================

wt-create <branch>  - Create a new worktree for a branch
                      Creates at: ~/dev/repo-branch

wt-list             - List all worktrees with index numbers

wt-remove <branch>  - Remove worktree by branch name
wt-remove           - Interactive removal with menu

wt-switch <branch>  - Switch to worktree by branch name
wt-switch <number>  - Switch to worktree by index number

wt-prune            - Clean up stale worktree references

wt-help             - Show this help message

Examples:
---------
# Create worktree for feature branch
wt-create feature-login

# List all worktrees (shows index numbers)
wt-list

# Switch by branch name
wt-switch feature-login

# Switch by index (e.g., to worktree #2)
wt-switch 2

# Remove worktree when done
wt-remove feature-login

Short aliases:
--------------
wtc = wt-create
wtl = wt-list
wtr = wt-remove
wts = wt-switch (works with both name and number)
wtp = wt-prune
wth = wt-help
EOF
}

# Optional: Add aliases for shorter commands
alias wtc='wt-create'
alias wtl='wt-list'
alias wtr='wt-remove'
alias wts='wt-switch'
alias wtp='wt-prune'
alias wth='wt-help'
alias wt='wt-help'
