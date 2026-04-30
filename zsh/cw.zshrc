# Claude Worktree Tools
# =====================
# Tools for working with Claude Code worktrees.
#
# Commands:
#   wrt <branch>   # Create or jump to a git worktree for the given branch
#   wrt remove <branch> # Remove a git worktree for the given branch
#   cw <branch>    # Launch Claude Code in a worktree for the given branch
#   ocw <branch>   # Launch OpenCode in a worktree for the given branch
#   cls            # Launch Claude Code in a sandbox from the current directory
#   ocs            # Launch OpenCode from the current directory
#   cwp            # Cherry-pick new commits from all worktree branches into current branch
#   cwm            # Move uncommitted changes from main checkout into current worktree
#   cwr            # Reset current branch to origin (undo cwp cherry-picks)
#   cwc            # Clean up worktrees that are fully pushed and have no uncommitted changes
#
# Requirements:
#   - Claude Code CLI (claude)
#   - OpenCode CLI (opencode)
#   - Git
#   - Zellij (optional, for pane naming)
#   - firejail (Linux) or sandbox-exec (macOS) for filesystem sandboxing

# Run claude under a platform-appropriate filesystem sandbox
# ----------------------------------------------------------
# Usage: _claude_sandboxed <repo_root> [claude args...]
#
# Linux  → firejail (whitelist mode)
# Darwin → sandbox-exec (Seatbelt deny-default profile)
# Other  → unsandboxed with warning
_claude_sandbox_profile() {
    local repo_root="$1"
    local git_common_dir="$2"  # optional: resolved git common dir for worktrees
    local brew_prefix
    brew_prefix="$(brew --prefix 2>/dev/null || echo /opt/homebrew)"

    # Allow real paths of symlinked entries in ~/.claude (e.g. CLAUDE.md → dotfiles)
    # sandbox-exec resolves symlinks, so targets outside ~/.claude need explicit rules.
    # Use subpath for directory symlinks (e.g. skills/) and literal for file symlinks.
    local symlink_rules="" _link _rpath
    for _link in "$HOME/.claude/"*(N@); do
        _rpath=$(realpath "$_link" 2>/dev/null)
        if [[ -n "$_rpath" && "$_rpath" != "$HOME/.claude/"* ]]; then
            if [[ -d "$_rpath" ]]; then
                symlink_rules+=$'\n'"(allow file-read* (subpath \"${_rpath}\"))"
            else
                symlink_rules+=$'\n'"(allow file-read* (literal \"${_rpath}\"))"
            fi
        fi
    done

    # Build read rules for intermediate dirs so the sandbox can traverse paths.
    # Without these, repos outside $HOME (e.g. /Volumes/drive/project) are unreachable.
    local traverse_rules=""
    local extra_project_rules=""

    # Helper: add traverse rules from base (/ or $HOME) down to target
    _sb_traverse() {
        local _target="$1" _base="/"
        [[ "$_target" == "$HOME"/* ]] && _base="$HOME"
        local _rel="${_target#$_base}"
        _rel="${_rel#/}"
        local -a _pts=("${(@s:/:)_rel}")
        if (( ${#_pts[@]} > 1 )); then
            local _cur="$_base" _j
            for _j in {1..$((${#_pts[@]} - 1))}; do
                _cur="${_cur%/}/${_pts[$_j]}"
                traverse_rules+=$'\n'"(allow file-read* (literal \"$_cur\"))"
            done
        fi
    }

    _sb_traverse "$repo_root"

    # If realpath differs (symlinks, firmlinks), allow the resolved path too
    local _real_root
    _real_root=$(realpath "$repo_root" 2>/dev/null)
    if [[ -n "$_real_root" && "$_real_root" != "$repo_root" ]]; then
        extra_project_rules+=$'\n'"(allow file-read* file-write* (subpath \"${_real_root}\"))"
        _sb_traverse "$_real_root"
    fi

    # Git common dir — needed when repo_root is itself a worktree whose
    # .git points to a main repo outside repo_root
    if [[ -n "$git_common_dir" && "$git_common_dir" != "$repo_root"/* ]]; then
        extra_project_rules+=$'\n'"(allow file-read* file-write* (subpath \"${git_common_dir}\"))"
        _sb_traverse "$git_common_dir"
    fi

    unset -f _sb_traverse

    cat <<SEATBELT
(version 1)
(deny default)

;; Process management
(allow process-fork process-exec signal)
(allow mach-lookup)
(allow ipc-posix-shm-read-data ipc-posix-shm-read-metadata ipc-posix-shm-write-data ipc-posix-shm-write-create ipc-posix-shm-write-unlink)
(allow sysctl-read)

;; System libraries and tools (read-only)
(allow file-read* (subpath "/System"))
(allow file-read* (subpath "/Library"))
(allow file-read* (subpath "/usr"))
(allow file-read* (subpath "/bin"))
(allow file-read* file-write* file-ioctl (subpath "/dev"))
(allow file-read* (subpath "/private/etc"))
(allow file-read* (subpath "/private/var"))
(allow file-read* (subpath "/var"))
(allow file-read* (literal "/etc"))
(allow file-read* (subpath "/etc"))
(allow file-read* (literal "/"))
(allow file-read* (literal "/private"))
(allow file-read* (literal "/Users"))

;; Temp directories (read+write)
(allow file-read* file-write* (subpath "/private/tmp"))
(allow file-read* file-write* (subpath "/private/var/folders"))
(allow file-read* file-write* (subpath "/tmp"))

;; Homebrew (read-only, /opt literal needed for path traversal)
(allow file-read* (literal "/opt"))
(allow file-read* (subpath "${brew_prefix}"))

;; Home directory listing (needed for bunx cwd resolution)
(allow file-read* (literal "$HOME"))

;; Claude binary (read-only)
(allow file-read* (subpath "$HOME/.local/bin"))

;; Claude config and cache (read+write)
(allow file-read* file-write* (subpath "$HOME/.local/share/claude"))
(allow file-read* file-write* (subpath "$HOME/.claude"))
(allow file-read* file-write* (literal "$HOME/.claude.json"))
${symlink_rules}
(allow file-read* file-write* (subpath "$HOME/.cache/claude-cli-nodejs"))

;; Bun cache (read+write — needed for bunx in status line)
(allow file-read* file-write* (subpath "$HOME/.bun"))

;; npm cache (read+write — needed for npm install)
(allow file-read* file-write* (subpath "$HOME/.npm"))

;; ccstatusline config (read+write)
(allow file-read* file-write* (subpath "$HOME/.config/ccstatusline"))

;; Keychain (read-only — needed for auth tokens)
(allow file-read* (subpath "$HOME/Library/Keychains"))

;; Git and SSH config (read-only — known_hosts for host verification, no private keys)
(allow file-read* (literal "$HOME/.gitconfig"))
(allow file-read* (literal "$HOME/.gitignore_global"))
(allow file-read* (subpath "$HOME/.config/git"))
(allow file-read* file-write* (literal "$HOME/.ssh/known_hosts"))
(allow file-read* (literal "$HOME/.ssh/config"))

;; Project directory (read+write — includes parent dir traversal)
${traverse_rules}
(allow file-read* file-write* (subpath "${repo_root}"))
${extra_project_rules}

;; Network (Claude API)
(allow network-outbound)
(allow network-bind (local ip "*:*"))
(allow system-socket)
SEATBELT
}

_claude_sandboxed() {
    local repo_root="$1"
    shift

    # Detect git common dir (needed when running from inside a worktree,
    # where .git points to a main repo outside the worktree path)
    local common_dir=""
    local _git_common
    _git_common=$(git -C "$repo_root" rev-parse --git-common-dir 2>/dev/null)
    if [[ -n "$_git_common" ]]; then
        if [[ "$_git_common" != /* ]]; then
            common_dir=$(realpath "$repo_root/$_git_common" 2>/dev/null)
        else
            common_dir=$(realpath "$_git_common" 2>/dev/null || echo "$_git_common")
        fi
    fi

    case "$(uname -s)" in
        Linux)
            local -a _wl=(
                --whitelist="$HOME/.local/bin/claude"
                --whitelist="$HOME/.local/share/claude"
                --whitelist="$HOME/.claude"
                --whitelist="$HOME/.claude.json"
                --whitelist="$HOME/.cache/claude-cli-nodejs"
                --whitelist="$HOME/.gitconfig"
                --whitelist="$repo_root"
                --whitelist=/home/linuxbrew
            )
            if [[ -n "$common_dir" && "$common_dir" != "$repo_root"/* ]]; then
                _wl+=(--whitelist="$common_dir")
            fi
            firejail --noprofile "${_wl[@]}" claude "$@"
            ;;
        Darwin)
            local profile
            profile="$(_claude_sandbox_profile "$repo_root" "$common_dir")"
            sandbox-exec -p "$profile" "$HOME/.local/bin/claude" "$@"
            ;;
        *)
            echo "Warning: no sandbox available on $(uname -s), running claude unsandboxed" >&2
            claude "$@"
            ;;
    esac
}

# Run opencode under a platform-appropriate filesystem sandbox
# ----------------------------------------------------------
# Usage: _opencode_sandboxed <repo_root>
_opencode_sandbox_profile() {
    local repo_root="$1"
    local extra_root="$2"
    local opencode_path="$3"
    local brew_prefix
    brew_prefix="$(brew --prefix 2>/dev/null || echo /opt/homebrew)"

    # Allow real paths of symlinked files in ~/.config/opencode, ~/.opencode, or ~/.claude
    local symlink_rules="" _link _rpath
    for _link in "$HOME/.config/opencode/"*(N@) "$HOME/.opencode/"*(N@) "$HOME/.claude/"*(N@); do
        _rpath=$(realpath "$_link" 2>/dev/null)
        if [[ -n "$_rpath" && "$_rpath" != "$HOME/.config/opencode/"* && "$_rpath" != "$HOME/.opencode/"* && "$_rpath" != "$HOME/.claude/"* ]]; then
            symlink_rules+=$'\n'"(allow file-read* (literal \"${_rpath}\"))"
        fi
    done

    local project_rules=""
    _opencode_add_project_rules() {
        local path="$1"
        if [[ -z "$path" ]]; then
            return
        fi

        if [[ "$path" == "$HOME"/* ]]; then
            local rel="${path#$HOME/}"
            local -a parts=("${(@s:/:)rel}")
            if (( ${#parts[@]} > 1 )); then
                local current="$HOME"
                local i
                for i in {1..$((${#parts[@]} - 1))}; do
                    current="$current/${parts[$i]}"
                    project_rules+=$'\n'"(allow file-read* (literal \"$current\"))"
                done
            fi
        fi

        project_rules+=$'\n'"(allow file-read* file-write* (subpath \"${path}\"))"
    }

    _opencode_add_project_rules "$repo_root"
    if [[ -n "$extra_root" && "$extra_root" != "$repo_root" ]]; then
        _opencode_add_project_rules "$extra_root"
    fi

    local opencode_binary_rule=""
    if [[ -n "$opencode_path" ]]; then
        opencode_binary_rule=$'\n'"(allow file-read* (literal \"${opencode_path}\"))"
    fi

    cat <<SEATBELT
(version 1)
(deny default)

;; Process management
(allow process-fork process-exec signal)
(allow mach-lookup)
(allow ipc-posix-shm-read-data ipc-posix-shm-read-metadata ipc-posix-shm-write-data ipc-posix-shm-write-create ipc-posix-shm-write-unlink)
(allow sysctl-read)

;; System libraries and tools (read-only)
(allow file-read* (subpath "/System"))
(allow file-read* (subpath "/Library"))
(allow file-read* (subpath "/usr"))
(allow file-read* (subpath "/bin"))
(allow file-read* file-write* file-ioctl (subpath "/dev"))
(allow file-read* (subpath "/private/etc"))
(allow file-read* (subpath "/private/var"))
(allow file-read* (subpath "/var"))
(allow file-read* (literal "/etc"))
(allow file-read* (subpath "/etc"))
(allow file-read* (literal "/"))
(allow file-read* (literal "/private"))
(allow file-read* (literal "/Users"))

;; Temp directories (read+write)
(allow file-read* file-write* (subpath "/private/tmp"))
(allow file-read* file-write* (subpath "/private/var/folders"))
(allow file-read* file-write* (subpath "/tmp"))

;; Homebrew (read-only, /opt literal needed for path traversal)
(allow file-read* (literal "/opt"))
(allow file-read* (subpath "${brew_prefix}"))

;; Home directory listing
(allow file-read* (literal "$HOME"))

;; OpenCode binary (read-only)
(allow file-read* (subpath "$HOME/.local/bin"))
${opencode_binary_rule}

;; OpenCode config and cache (read+write)
(allow file-read* file-write* (subpath "$HOME/.config/opencode"))
(allow file-read* file-write* (subpath "$HOME/.local/share/opencode"))
(allow file-read* file-write* (subpath "$HOME/.cache/opencode"))
(allow file-read* file-write* (subpath "$HOME/.local/state/opencode"))
(allow file-read* file-write* (subpath "$HOME/.opencode"))
(allow file-read* file-write* (literal "$HOME/.opencode.json"))
${symlink_rules}

;; Claude config (read-only — needed for skills)
(allow file-read* (subpath "$HOME/.claude"))

;; Bun cache (read+write)
(allow file-read* file-write* (subpath "$HOME/.bun"))

;; npm cache (read+write)
(allow file-read* file-write* (subpath "$HOME/.npm"))

;; ccstatusline config (read+write)
(allow file-read* file-write* (subpath "$HOME/.config/ccstatusline"))

;; Keychain (read-only — needed for auth tokens)
(allow file-read* (subpath "$HOME/Library/Keychains"))

;; Git and SSH config (read-only — known_hosts for host verification, no private keys)
(allow file-read* (literal "$HOME/.gitconfig"))
(allow file-read* (literal "$HOME/.gitignore_global"))
(allow file-read* (subpath "$HOME/.config/git"))
(allow file-read* file-write* (literal "$HOME/.ssh/known_hosts"))
(allow file-read* (literal "$HOME/.ssh/config"))

;; Project directory (read+write — includes parent dir traversal)
${project_rules}

;; Network (OpenCode API)
(allow network-outbound)
(allow network-bind (local ip "*:*"))
(allow system-socket)
SEATBELT
}

_opencode_sandboxed() {
    local repo_root="$1"
    shift

    local opencode_path
    opencode_path=$(command -v opencode 2>/dev/null)
    if [[ -z "$opencode_path" ]]; then
        echo "Error: opencode not found in PATH"
        return 1
    fi

    local common_dir
    common_dir=$(git -C "$repo_root" rev-parse --git-common-dir 2>/dev/null)
    if [[ -n "$common_dir" ]]; then
        if [[ "$common_dir" != /* ]]; then
            common_dir=$(realpath "$repo_root/$common_dir" 2>/dev/null)
        else
            common_dir=$(realpath "$common_dir" 2>/dev/null || echo "$common_dir")
        fi
    fi

    mkdir -p "$HOME/.config/opencode" "$HOME/.local/share/opencode" "$HOME/.cache/opencode" "$HOME/.local/state/opencode"

    case "$(uname -s)" in
        Linux)
            local -a whitelists
            whitelists=(--whitelist="$repo_root" --whitelist="$HOME/.config/opencode" --whitelist="$HOME/.local/share/opencode" --whitelist="$HOME/.cache/opencode" --whitelist="$HOME/.local/state/opencode" --whitelist="$HOME/.claude" --whitelist="$HOME/.gitconfig" --whitelist=/home/linuxbrew)
            if [[ -n "$common_dir" ]]; then
                whitelists+=(--whitelist="$common_dir")
            fi
            if [[ -e "$HOME/.opencode" ]]; then
                whitelists+=(--whitelist="$HOME/.opencode")
            fi
            if [[ -e "$HOME/.opencode.json" ]]; then
                whitelists+=(--whitelist="$HOME/.opencode.json")
            fi
            whitelists+=(--whitelist="$opencode_path")

            (cd "$repo_root" && firejail --noprofile \
                "${whitelists[@]}" \
                opencode "$@")
            ;;
        Darwin)
            local profile
            profile="$(_opencode_sandbox_profile "$repo_root" "$common_dir" "$opencode_path")"
            (cd "$repo_root" && sandbox-exec -p "$profile" "$opencode_path" "$@")
            ;;
        *)
            echo "Warning: no sandbox available on $(uname -s), running opencode unsandboxed" >&2
            (cd "$repo_root" && opencode "$@")
            ;;
    esac
}

# Test the macOS sandbox profile
# ---------------------------------------------------------------
# Verifies that the Seatbelt profile correctly blocks access to
# sensitive paths while allowing access to the project directory.
#
# Examples:
#   cls-test          # Run sandbox tests against current repo
cls-test() {
    if [[ "$(uname -s)" != "Darwin" ]]; then
        echo "cls-test only works on macOS (sandbox-exec)"
        return 1
    fi

    local repo_root
    repo_root=$(git rev-parse --show-toplevel 2>/dev/null)
    if [[ -z "$repo_root" ]]; then
        echo "Error: not inside a git repository"
        return 1
    fi

    local profile
    profile="$(_claude_sandbox_profile "$repo_root")"

    local pass=0 fail=0

    _cls_test() {
        local description="$1" expect="$2"
        shift 2
        local output
        output=$(sandbox-exec -p "$profile" "$@" 2>&1)
        local rc=$?

        if [[ "$expect" == "block" && $rc -ne 0 ]]; then
            echo "  ✓ BLOCKED: $description"
            ((pass++))
        elif [[ "$expect" == "allow" && $rc -eq 0 ]]; then
            echo "  ✓ ALLOWED: $description"
            ((pass++))
        elif [[ "$expect" == "block" && $rc -eq 0 ]]; then
            echo "  ✗ NOT BLOCKED: $description"
            ((fail++))
        else
            echo "  ✗ NOT ALLOWED: $description (rc=$rc)"
            ((fail++))
        fi
    }

    echo "Testing sandbox profile for: $repo_root"
    echo ""

    echo "Should BLOCK:"
    _cls_test "read SSH private keys"   block /bin/cat "$HOME/.ssh/id_ed25519"
    _cls_test "list ~/.ssh dir"         block /bin/ls "$HOME/.ssh"
    _cls_test "read ~/.aws"             block /bin/ls "$HOME/.aws"
    _cls_test "read ~/.zshrc"           block /bin/cat "$HOME/.zshrc"
    _cls_test "read ~/Documents"        block /bin/ls "$HOME/Documents"
    _cls_test "read ~/Desktop"          block /bin/ls "$HOME/Desktop"
    _cls_test "write to home"           block /usr/bin/touch "$HOME/sandbox-test-$$"
    _cls_test "write to .gitconfig"     block /bin/sh -c "echo x >> $HOME/.gitconfig"
    echo ""

    echo "Should ALLOW:"
    _cls_test "read project dir"        allow /bin/ls "$repo_root"
    _cls_test "read git config"         allow /bin/cat "$HOME/.gitconfig"
    _cls_test "read /usr/bin"           allow /bin/ls /usr/bin
    _cls_test "read homebrew"           allow /bin/ls "$(brew --prefix 2>/dev/null || echo /opt/homebrew)"
    _cls_test "write to project"        allow /usr/bin/touch "$repo_root/.sandbox-test-$$"
    # Clean up test file
    rm -f "$repo_root/.sandbox-test-$$"
    echo ""

    echo "Results: $pass passed, $fail failed"
    unset -f _cls_test
    return $fail
}

# Git worktree helpers
# --------------------
_wrt_main_repo_root() {
    local line
    while IFS= read -r line; do
        if [[ "$line" == worktree\ * ]]; then
            print -r -- "${line#worktree }"
            return 0
        fi
    done < <(git worktree list --porcelain 2>/dev/null)

    return 1
}

_wrt_folder_name() {
    local branch="$1"
    local folder_name="${branch#teppokallio/}"

    # Keep worktree folders flat even when branch names contain slashes.
    folder_name="${folder_name//\//-}"

    print -r -- "$folder_name"
}

_wrt_existing_path() {
    local target_branch="$1"
    local current_path=""
    local current_branch=""
    local line

    while IFS= read -r line; do
        if [[ "$line" == worktree\ * ]]; then
            current_path="${line#worktree }"
        elif [[ "$line" == branch\ * ]]; then
            current_branch="${line#branch refs/heads/}"
        elif [[ -z "$line" ]]; then
            if [[ "$current_branch" == "$target_branch" ]]; then
                print -r -- "$current_path"
                return 0
            fi

            current_path=""
            current_branch=""
        fi
    done < <(git worktree list --porcelain 2>/dev/null)

    if [[ "$current_branch" == "$target_branch" ]]; then
        print -r -- "$current_path"
        return 0
    fi

    return 1
}

_wrt_base_ref() {
    local candidate

    for candidate in main master; do
        if git show-ref --verify --quiet "refs/heads/$candidate"; then
            print -r -- "$candidate"
            return 0
        fi
    done

    for candidate in main master; do
        if git show-ref --verify --quiet "refs/remotes/origin/$candidate"; then
            print -r -- "origin/$candidate"
            return 0
        fi
    done

    echo "Error: could not find local or origin main/master branch" >&2
    return 1
}

_wrt_list() {
    local repo_root
    repo_root=$(_wrt_main_repo_root) || return 1

    local -A worktree_branches
    local line
    local branch
    local current_path=""
    local current_branch=""
    local -a removable_branches

    while IFS= read -r line; do
        if [[ "$line" == worktree\ * ]]; then
            current_path="${line#worktree }"
        elif [[ "$line" == branch\ * ]]; then
            current_branch="${line#branch refs/heads/}"
        elif [[ -z "$line" ]]; then
            if [[ -n "$current_branch" ]]; then
                worktree_branches[$current_branch]=1
                if [[ -n "$current_path" && "$current_path" != "$repo_root" ]]; then
                    removable_branches+=("$current_branch")
                fi
            fi

            current_path=""
            current_branch=""
        fi
    done < <(git worktree list --porcelain 2>/dev/null)

    if [[ -n "$current_branch" ]]; then
        worktree_branches[$current_branch]=1
        if [[ -n "$current_path" && "$current_path" != "$repo_root" ]]; then
            removable_branches+=("$current_branch")
        fi
    fi

    echo "Worktrees:"
    git worktree list || return 1
    echo ""

    if [[ ${#removable_branches[@]} -gt 0 ]]; then
        echo "Remove worktree commands:"
        for branch in "${removable_branches[@]}"; do
            printf '  wrt remove %s\n' "$branch"
        done
        echo ""
    else
        echo "No removable worktrees."
        echo ""
    fi

    local -a available_branches
    while IFS= read -r branch; do
        [[ -z "$branch" ]] && continue
        [[ "$branch" == "main" || "$branch" == "master" ]] && continue
        [[ -n "${worktree_branches[$branch]}" ]] && continue
        available_branches+=("$branch")
    done < <(git for-each-ref --sort=refname --format='%(refname:short)' refs/heads)

    if [[ ${#available_branches[@]} -eq 0 ]]; then
        echo "No existing local branches available for worktree creation."
        return 0
    fi

    echo "Create worktree commands:"
    for branch in "${available_branches[@]}"; do
        printf '  wrt %s\n' "$branch"
    done
}

_wrt_remove() {
    local repo_root="$1"
    local branch="$2"
    local worktree_path

    worktree_path=$(_wrt_existing_path "$branch")
    if [[ -z "$worktree_path" ]]; then
        echo "Error: no worktree found for branch '$branch'"
        return 1
    fi

    if [[ "$worktree_path" == "$repo_root" ]]; then
        echo "Error: cannot remove the main worktree"
        return 1
    fi

    if [[ -n "$(git -C "$worktree_path" status --porcelain 2>/dev/null)" ]]; then
        echo "Error: worktree '$branch' has uncommitted changes"
        return 1
    fi

    git worktree remove "$worktree_path" || return 1
    echo "Removed worktree: $worktree_path"
}

# Create, jump to, or remove git worktrees from the main checkout
# ---------------------------------------------------------------
# Usage:
#   wrt
#   wrt <branch>
#   wrt remove <branch>
#
# Examples:
#   wrt
#   wrt teppokallio/cle-2358-email-notification-as-trigger-action
#   wrt remove teppokallio/cle-2358-email-notification-as-trigger-action
wrt() {
    if ! git rev-parse --is-inside-work-tree &>/dev/null; then
        echo "Error: not inside a git repository"
        return 1
    fi

    if [[ -z "$1" ]]; then
        _wrt_list
        return $?
    fi

    local repo_root
    repo_root=$(_wrt_main_repo_root)
    if [[ -z "$repo_root" ]]; then
        echo "Error: could not determine the main worktree"
        return 1
    fi

    local current_root
    current_root=$(git rev-parse --show-toplevel 2>/dev/null)
    if [[ "$current_root" != "$repo_root" ]]; then
        echo "Error: run wrt from the main worktree"
        return 1
    fi

    if [[ "$1" == "remove" ]]; then
        if [[ -z "$2" ]]; then
            echo "Usage: wrt remove <branch>"
            return 1
        fi

        _wrt_remove "$repo_root" "$2"
        return $?
    fi

    local branch="$1"
    local existing_path
    existing_path=$(_wrt_existing_path "$branch")
    if [[ -n "$existing_path" ]]; then
        builtin cd -- "$existing_path" || return 1
        return 0
    fi

    local worktrees_root="$repo_root/.worktrees"
    if [[ -e "$worktrees_root" && ! -d "$worktrees_root" ]]; then
        echo "Error: $worktrees_root exists but is not a directory"
        return 1
    fi

    mkdir -p "$worktrees_root" || return 1

    local folder_name
    folder_name=$(_wrt_folder_name "$branch")

    local worktree_path="$worktrees_root/$folder_name"
    if [[ -d "$worktree_path" ]]; then
        if ! git -C "$worktree_path" rev-parse --is-inside-work-tree &>/dev/null; then
            echo "Error: $worktree_path exists but is not a git worktree"
            return 1
        fi

        local existing_branch
        existing_branch=$(git -C "$worktree_path" branch --show-current 2>/dev/null)
        if [[ "$existing_branch" != "$branch" ]]; then
            echo "Error: $worktree_path already exists for branch '$existing_branch'"
            return 1
        fi

        builtin cd -- "$worktree_path" || return 1
        return 0
    elif [[ -e "$worktree_path" ]]; then
        echo "Error: $worktree_path exists but is not a directory"
        return 1
    fi

    if git show-ref --verify --quiet "refs/heads/$branch"; then
        git worktree add "$worktree_path" "$branch" || return 1
    elif git show-ref --verify --quiet "refs/remotes/origin/$branch"; then
        git worktree add --track -b "$branch" "$worktree_path" "origin/$branch" || return 1
    else
        local base_ref
        base_ref=$(_wrt_base_ref) || return 1
        git worktree add -b "$branch" "$worktree_path" "$base_ref" || return 1
    fi

    builtin cd -- "$worktree_path" || return 1
}

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

    _claude_sandboxed "$repo_root" --worktree "$branch" --dangerously-skip-permissions
}

# Launch OpenCode in a worktree with Zellij pane naming
# ---------------------------------------------------------
# Usage: ocw <branch>
#
# Examples:
#   ocw feat/my-feature    # Launch worktree on feat/my-feature
#   ocw fix/login-bug      # Launch worktree on fix/login-bug
unalias ocw 2>/dev/null
ocw() {
    if [[ -z "$1" ]]; then
        echo "Usage: ocw <branch>"
        echo "Launches OpenCode in a worktree for the given branch"
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

    local repo_name="${repo_root:t}"
    local worktrees_root="$repo_root/.claude/worktrees"
    local worktree_path="$worktrees_root/$branch"

    local wt_branch="$branch"
    if [[ "$wt_branch" != worktree-* ]]; then
        wt_branch="worktree-$branch"
    fi

    mkdir -p "${worktree_path:h}"

    if [[ -d "$worktree_path" ]]; then
        if ! git -C "$worktree_path" rev-parse --is-inside-work-tree &>/dev/null; then
            echo "Error: $worktree_path exists but is not a git worktree"
            return 1
        fi
    else
        if git show-ref --verify --quiet "refs/heads/$wt_branch"; then
            echo "Creating worktree for existing branch '$wt_branch'..."
            git worktree add "$worktree_path" "$wt_branch" || return 1
        else
            local remote_branch
            remote_branch=$(git ls-remote --heads origin "$wt_branch" 2>/dev/null)
            if [[ -n "$remote_branch" ]]; then
                echo "Creating worktree for remote branch 'origin/$wt_branch'..."
                git worktree add "$worktree_path" "$wt_branch" || return 1
            else
                echo "Creating worktree with new branch '$wt_branch'..."
                git worktree add -b "$wt_branch" "$worktree_path" || return 1
            fi
        fi
    fi

    _opencode_sandboxed "$worktree_path"
}

# Launch Claude Code in a sandbox from the current directory
# ---------------------------------------------------------
# Like `cw` but without worktree management — runs Claude in a
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

    _claude_sandboxed "$repo_root" --dangerously-skip-permissions
}

# Launch OpenCode from the current directory
# ---------------------------------------------------------
# Like `ocw` but without worktree management — runs OpenCode in a sandbox.
#
# Examples:
#   ocs    # Launch OpenCode in the current repo
ocs() {
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

    _opencode_sandboxed "$repo_root"
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

# Reset current branch to origin (undo cwp cherry-picks)
# -------------------------------------------------------
# Stashes uncommitted changes, resets hard to origin, then restores the stash.
# Useful after `cwp` to get back to a clean state.
#
# Examples:
#   cwr    # Reset current branch to origin
cwr() {
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

    # Stash uncommitted changes
    local stashed=false
    if [[ -n "$(git status --porcelain)" ]]; then
        echo "Stashing uncommitted changes..."
        git stash push -m "cwr: auto-stash before reset" &>/dev/null
        stashed=true
    fi

    echo "Resetting $current_branch to origin/$current_branch..."
    git fetch origin &>/dev/null
    git reset --hard "origin/$current_branch"

    # Restore stashed changes
    if [[ "$stashed" == true ]]; then
        echo "Restoring stashed changes..."
        git stash pop &>/dev/null
    fi

    echo "Done."
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

    # Generate commit message using Pi
    echo "Generating message..."
    local raw=$(pi --print "Generate a git commit message for the staged changes. Conventional commit format. Max 100 chars per line. IMPORTANT: Output the raw commit message only - no preamble, no 'here is', no explanation, no quotes, no markdown. Start directly with the type (feat/fix/etc)." 2>/dev/null)

    local msg=$(echo "$raw" | sed -nE '/^(feat|fix|docs|style|refactor|perf|test|chore|ci|build|revert)[:(]/,$p')

    if [[ -z "$msg" ]]; then
        msg="chore: move uncommitted changes from main"
        echo "Pi unavailable, using fallback message."
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
