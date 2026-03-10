# Claude Worktree Tools
# =====================
# Tools for working with Claude Code worktrees.
#
# Commands:
#   cw <branch>    # Launch Claude Code in a worktree for the given branch
#   cls            # Launch Claude Code in a sandbox from the current directory
#   cwp            # Cherry-pick new commits from all worktree branches into current branch
#   cwm            # Move uncommitted changes from main checkout into current worktree
#   cwc            # Clean up worktrees that are fully pushed and have no uncommitted changes
#
# Requirements:
#   - Claude Code CLI (claude)
#   - Git
#   - Zellij (optional, for pane naming)

# Launch Claude Code in a worktree with Zellij pane naming
# ---------------------------------------------------------
# Usage: cw <branch>
#
# Examples:
#   cw feat/my-feature    # Launch worktree on feat/my-feature
#   cw fix/login-bug      # Launch worktree on fix/login-bug
cw() {
    if [[ -z "$1" ]]; then
        echo "Usage: cw <branch>"
        echo "Launches Claude Code in a worktree for the given branch"
        return 1
    fi

    local branch="$1"

    # Set Zellij pane name to the branch (only if running inside Zellij)
    if [[ -n "$ZELLIJ" ]]; then
        zellij action rename-pane "$branch"
    fi

    local repo_root
    repo_root=$(git rev-parse --show-toplevel 2>/dev/null)
    if [[ -z "$repo_root" ]]; then
        echo "Error: not inside a git repository"
        return 1
    fi

    firejail --noprofile \
        --whitelist="$HOME/.local/bin/claude" \
        --whitelist="$HOME/.local/share/claude" \
        --whitelist="$HOME/.claude" \
        --whitelist="$HOME/.claude.json" \
        --whitelist="$HOME/.cache/claude-cli-nodejs" \
        --whitelist="$HOME/.gitconfig" \
        --whitelist="$repo_root" \
        --whitelist=/home/linuxbrew \
        claude --worktree "$branch" --dangerously-skip-permissions
}

# Launch Claude Code in a sandbox from the current directory
# ---------------------------------------------------------
# Like `cw` but without worktree management — runs Claude in a firejail
# sandbox using the current repo, with permission bypass enabled.
#
# Examples:
#   cls    # Launch sandboxed Claude in the current repo
cls() {
    local repo_root
    repo_root=$(git rev-parse --show-toplevel 2>/dev/null)
    if [[ -z "$repo_root" ]]; then
        echo "Error: not inside a git repository"
        return 1
    fi

    # Set Zellij pane name to the repo directory name
    if [[ -n "$ZELLIJ" ]]; then
        zellij action rename-pane "${repo_root:t}"
    fi

    firejail --noprofile \
        --whitelist="$HOME/.local/bin/claude" \
        --whitelist="$HOME/.local/share/claude" \
        --whitelist="$HOME/.claude" \
        --whitelist="$HOME/.claude.json" \
        --whitelist="$HOME/.cache/claude-cli-nodejs" \
        --whitelist="$HOME/.gitconfig" \
        --whitelist="$repo_root" \
        --whitelist=/home/linuxbrew \
        claude --dangerously-skip-permissions
}

# Cherry-pick new commits from all worktree branches into current branch
# -----------------------------------------------------------------------
# Finds all worktree-* branches, identifies commits not yet on the current
# branch, and cherry-picks them. Useful for building a preview branch that
# combines work from multiple worktrees.
#
# Stashes uncommitted changes, resets to origin, cherry-picks, then restores.
#
# Workflow:
#   1. Work on features in separate worktrees via `cw`
#   2. Run `cwp` on your branch to cherry-pick all worktree commits for preview
#   3. Test the combined result in browser
#   4. When happy, reset the branch and merge worktree branches properly
#
# Examples:
#   cwp                  # Cherry-pick all new worktree commits
#   cwp --dry-run        # Show what would be cherry-picked without doing it
cwp() {
    local dry_run=false
    if [[ "$1" == "--dry-run" ]]; then
        dry_run=true
    fi

    # Ensure we're in a git repo
    if ! git rev-parse --is-inside-work-tree &>/dev/null; then
        echo "Error: not inside a git repository"
        return 1
    fi

    local current_branch
    current_branch=$(git branch --show-current)
    if [[ -z "$current_branch" ]]; then
        echo "Error: HEAD is detached, checkout a branch first"
        return 1
    fi

    # Stash any uncommitted changes
    local stashed=false
    if [[ -n "$(git status --porcelain)" ]]; then
        echo "Stashing uncommitted changes..."
        git stash push -m "cwp: auto-stash before cherry-pick" &>/dev/null
        stashed=true
    fi

    # Reset to origin for a clean slate
    echo "Resetting $current_branch to origin/$current_branch..."
    git fetch origin &>/dev/null
    git reset --hard "origin/$current_branch" &>/dev/null
    echo ""

    # Find all worktree-* branches
    local branches=()
    while IFS= read -r ref; do
        branches+=("$ref")
    done < <(git branch --list 'worktree-*' --format='%(refname:short)')

    if [[ ${#branches[@]} -eq 0 ]]; then
        echo "No worktree-* branches found"
        return 0
    fi

    echo "Current branch: $current_branch"
    echo "Found ${#branches[@]} worktree branch(es):"
    echo ""

    local total_commits=0
    local has_commits=false

    for branch in "${branches[@]}"; do
        # Get commits in this branch that are NOT in current branch
        local commits=()
        while IFS= read -r line; do
            [[ -n "$line" ]] && commits+=("$line")
        done < <(git log --oneline "$current_branch..$branch" 2>/dev/null)

        if [[ ${#commits[@]} -eq 0 ]]; then
            echo "  $branch: (no new commits)"
            continue
        fi

        has_commits=true
        echo "  $branch: ${#commits[@]} new commit(s)"
        for commit in "${commits[@]}"; do
            echo "    $commit"
        done
        total_commits=$((total_commits + ${#commits[@]}))
    done

    echo ""

    if [[ "$has_commits" == false ]]; then
        echo "Nothing to cherry-pick — all worktree branches are up to date."
        return 0
    fi

    if [[ "$dry_run" == true ]]; then
        echo "Dry run: would cherry-pick $total_commits commit(s) onto $current_branch"
        return 0
    fi

    echo "Cherry-picking $total_commits commit(s) onto $current_branch..."
    echo ""

    for branch in "${branches[@]}"; do
        local shas=()
        while IFS= read -r sha; do
            [[ -n "$sha" ]] && shas+=("$sha")
        done < <(git log --reverse --format='%H' "$current_branch..$branch" 2>/dev/null)

        if [[ ${#shas[@]} -eq 0 ]]; then
            continue
        fi

        echo "Cherry-picking from $branch..."
        for sha in "${shas[@]}"; do
            if ! git cherry-pick "$sha" &>/dev/null; then
                # Check if it's an empty cherry-pick (changes already applied)
                if [[ -z "$(git diff --staged)" ]]; then
                    git cherry-pick --skip &>/dev/null
                    echo "  Skipped (already applied): $(git log --oneline -1 "$sha")"
                else
                    # Auto-resolve conflicts by keeping both sides (union merge)
                    local conflicted_files=()
                    while IFS= read -r f; do
                        [[ -n "$f" ]] && conflicted_files+=("$f")
                    done < <(git diff --name-only --diff-filter=U)

                    local resolved=true
                    for f in "${conflicted_files[@]}"; do
                        # Remove conflict markers, keeping both sides
                        sed -i '/^<<<<<<< HEAD$/d; /^=======$/d; /^>>>>>>> .*$/d' "$f"
                        git add "$f"
                    done

                    if [[ -z "$(git diff --staged)" ]]; then
                        git cherry-pick --skip &>/dev/null
                        echo "  Skipped (empty after resolve): $(git log --oneline -1 "$sha")"
                    else
                        git -c core.editor=true cherry-pick --continue &>/dev/null
                        echo "  Auto-resolved: $(git log --oneline -1 "$sha")"
                    fi
                fi
            else
                echo "  Applied: $(git log --oneline -1 "$sha")"
            fi
        done
    done

    echo ""
    echo "Done. Cherry-picked $total_commits commit(s) onto $current_branch."

    # Restore stashed changes
    if [[ "$stashed" == true ]]; then
        echo "Restoring stashed changes..."
        git stash pop &>/dev/null
    fi
}

# Move uncommitted changes from main checkout into current worktree
# ---------------------------------------------------------------------
# When previewing worktree branches, style tweaks are sometimes made in
# the main/root checkout. Run this from inside a worktree to pull those
# changes over, commit them here, and discard them from main.
#
# Examples:
#   cwm              # Move changes from main into this worktree
#   cwm --dry-run    # Preview what would be moved
cwm() {
    local dry_run=false
    if [[ "$1" == "--dry-run" ]]; then
        dry_run=true
    fi

    # Must be in a git repo
    if ! git rev-parse --is-inside-work-tree &>/dev/null; then
        echo "Error: not inside a git repository"
        return 1
    fi

    # Find main worktree path (first entry in porcelain output)
    local main_path=""
    while IFS= read -r line; do
        if [[ "$line" == worktree\ * ]]; then
            main_path="${line#worktree }"
            break
        fi
    done < <(git worktree list --porcelain)

    if [[ -z "$main_path" ]]; then
        echo "Error: could not determine main worktree path"
        return 1
    fi

    # Must be in a worktree, not the main checkout
    local current_toplevel
    current_toplevel=$(git rev-parse --show-toplevel)
    if [[ "$current_toplevel" == "$main_path" ]]; then
        echo "Error: run this from inside a worktree, not the main checkout"
        return 1
    fi

    # Check for uncommitted changes in main
    if [[ -z "$(git -C "$main_path" status --porcelain)" ]]; then
        echo "No uncommitted changes in main worktree."
        return 0
    fi

    # Track untracked files with intent-to-add so they appear in diff
    local untracked_files=()
    while IFS= read -r f; do
        [[ -n "$f" ]] && untracked_files+=("$f")
    done < <(git -C "$main_path" ls-files --others --exclude-standard)

    if [[ ${#untracked_files[@]} -gt 0 ]]; then
        git -C "$main_path" add -N "${untracked_files[@]}"
    fi

    # Capture the patch
    local patch
    patch=$(git -C "$main_path" diff HEAD)

    # Undo intent-to-add on untracked files
    if [[ ${#untracked_files[@]} -gt 0 ]]; then
        git -C "$main_path" reset HEAD -- "${untracked_files[@]}" &>/dev/null
    fi

    if [[ -z "$patch" ]]; then
        echo "Patch is empty, nothing to move."
        return 0
    fi

    # Show what would be moved
    echo "Changes in main worktree:"
    echo "$patch" | git apply --stat | sed 's/^/  /'
    echo ""

    if [[ "$dry_run" == true ]]; then
        echo "Dry run: would move these changes into $(git branch --show-current)."
        return 0
    fi

    # Apply patch in current worktree
    if ! echo "$patch" | git apply --3way; then
        echo ""
        echo "Error: patch failed to apply. Main worktree left untouched."
        return 1
    fi

    # Stage all changes
    git add -A

    # Show summary
    echo ""
    echo "Changes staged:"
    git --no-pager diff --staged --stat | sed 's/^/  /'
    echo ""

    # Generate commit message using Claude
    echo "Generating message..."
    local raw=$(claude --print -p "Generate a git commit message for the staged changes. Conventional commit format. Max 100 chars per line. IMPORTANT: Output the raw commit message only - no preamble, no 'here is', no explanation, no quotes, no markdown. Start directly with the type (feat/fix/etc)." 2>/dev/null)

    local msg=$(echo "$raw" | sed -n '/^\(feat\|fix\|docs\|style\|refactor\|perf\|test\|chore\|ci\|build\|revert\)[:(]/,$p')

    if [[ -z "$msg" ]]; then
        msg="chore: move uncommitted changes from main"
        echo "Claude unavailable, using fallback message."
    fi

    echo "Message:"
    echo "$msg" | sed 's/^/  /'
    echo ""

    # Ask for confirmation
    read "confirm?Commit? [y/N] "
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo "Commit cancelled. Undoing applied changes..."
        git checkout -- . &>/dev/null
        git clean -fd &>/dev/null
        return 0
    fi

    # Commit
    if ! git commit -m "$msg"; then
        echo "Error: commit failed. Main worktree left untouched."
        return 1
    fi

    # Discard changes from main
    git -C "$main_path" checkout -- . &>/dev/null
    git -C "$main_path" clean -fd &>/dev/null

    echo ""
    local commit_hash=$(git rev-parse --short HEAD)
    echo "Done. Changes moved to $(git branch --show-current) ($commit_hash)."
    echo "Main worktree is now clean."
}

# Clean up worktrees that are fully pushed with no uncommitted changes
# ---------------------------------------------------------------------
# For each worktree-* branch, checks:
#   1. No unstaged/uncommitted changes in the worktree directory
#   2. Branch is fully pushed to origin (not ahead)
# If both conditions are met, removes the worktree and deletes the branch.
#
# Examples:
#   cwc              # Clean up all safe-to-remove worktrees
#   cwc --dry-run    # Show what would be cleaned without doing it
cwc() {
    local dry_run=false
    if [[ "$1" == "--dry-run" ]]; then
        dry_run=true
    fi

    if ! git rev-parse --is-inside-work-tree &>/dev/null; then
        echo "Error: not inside a git repository"
        return 1
    fi

    local repo_root
    repo_root=$(git rev-parse --show-toplevel)

    # Parse worktree list to map branches to paths
    local -A worktree_paths
    local current_path="" current_branch=""
    while IFS= read -r line; do
        if [[ "$line" == worktree\ * ]]; then
            current_path="${line#worktree }"
        elif [[ "$line" == branch\ * ]]; then
            current_branch="${line#branch refs/heads/}"
            if [[ "$current_branch" == worktree-* ]]; then
                worktree_paths[$current_branch]="$current_path"
            fi
        elif [[ -z "$line" ]]; then
            current_path=""
            current_branch=""
        fi
    done < <(git worktree list --porcelain)

    if [[ ${#worktree_paths[@]} -eq 0 ]]; then
        echo "No worktree-* worktrees found"
        return 0
    fi

    echo "Checking ${#worktree_paths[@]} worktree(s)..."
    echo ""

    local removed=0
    local skipped=0

    for branch wt_path in "${(@kv)worktree_paths}"; do
        echo "  $branch"
        local skip=false

        # Check for uncommitted changes in the worktree
        if [[ -n "$(git -C "$wt_path" status --porcelain 2>/dev/null)" ]]; then
            echo "    SKIP: has uncommitted changes"
            skip=true
        fi

        # Check if branch is pushed to origin
        if [[ "$skip" == false ]]; then
            local track_status
            track_status=$(git for-each-ref --format='%(upstream:track)' "refs/heads/$branch")
            if [[ "$track_status" == *ahead* ]]; then
                echo "    SKIP: not fully pushed to origin"
                skip=true
            elif [[ -z "$(git for-each-ref --format='%(upstream:short)' "refs/heads/$branch")" ]]; then
                echo "    SKIP: no upstream tracking branch"
                skip=true
            fi
        fi

        if [[ "$skip" == true ]]; then
            skipped=$((skipped + 1))
            continue
        fi

        if [[ "$dry_run" == true ]]; then
            echo "    Would remove worktree and delete branch"
            removed=$((removed + 1))
            continue
        fi

        # Remove the worktree
        if ! git worktree remove "$wt_path" 2>/dev/null; then
            echo "    SKIP: failed to remove worktree"
            skipped=$((skipped + 1))
            continue
        fi

        # Delete the local branch
        git branch -D "$branch" &>/dev/null
        echo "    Removed"
        removed=$((removed + 1))
    done

    echo ""
    if [[ "$dry_run" == true ]]; then
        echo "Dry run: would remove $removed worktree(s), $skipped skipped."
    else
        echo "Removed $removed worktree(s), $skipped skipped."
    fi
}
