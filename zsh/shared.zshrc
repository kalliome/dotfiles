# Shared ZSH configuration - portable across different systems
#
# INSTALLATION INSTRUCTIONS:
# ==========================
#
# This file contains aliases, functions, and environment variables that work
# across different operating systems (macOS, Linux, WSL2).
#
# To use this shared configuration:
#
# 1. Make sure this file is accessible from your target system
#    (e.g., sync via Git, symlink, or copy to a shared location)
#
# 2. Add this line to your machine-specific ~/.zshrc:
#    source ~/dotfiles/zsh/shared.zshrc
#
# 3. In your main ~/.zshrc, add machine-specific configurations AFTER sourcing
#    this file. Examples of machine-specific configs:
#    - Platform-specific commands (lsof on Mac vs Linux)
#    - Absolute paths that differ between machines
#    - API keys and credentials
#    - Local tool installations
#
# Example ~/.zshrc structure:
#
#   # Oh My Zsh or other framework initialization
#   export ZSH="$HOME/.oh-my-zsh"
#   source $ZSH/oh-my-zsh.sh
#
#   # Source shared configuration
#   source ~/dotfiles/zsh/shared.zshrc
#
#   # Machine-specific aliases and functions
#   alias myproject="cd ~/projects/myproject"
#
#   # Machine-specific environment variables
#   export PATH="/usr/local/custom/bin:$PATH"
#
# NOTES:
# - Port management commands (port, killport) should be added per-machine
#   as they use different tools on Mac (lsof) vs Linux (ss, netstat)
# - Clipboard commands (pbcopy/pbpaste on Mac, xclip on Linux) are machine-specific
# - Any paths with your username should go in the machine-specific config
#
# ==========================

# General aliases
alias g="lazygit"
alias sshpub="cat ~/.ssh/id_rsa.pub"
alias myip="curl -s https://api.ipify.org"
alias sail='sh $([ -f sail ] && echo sail || echo vendor/bin/sail)'
alias doct="doctl"
alias zz="zed ."
alias c.="cursor ."

# Nextjs dev with turbopack
alias turb="npm run dev -- --turbopack"

# Docker and Git tools
alias lzd='lazydocker'
alias lzg='lazygit'

# AI tools
alias ai=aichat
alias ae='aichat -e'

# Tmux
alias t='tmux a'

# Better CLI tools
alias ls='lsd'
alias l='ls -la'
alias la='ls -a'
alias lt='ls -la --tree'
alias cat='bat'
alias dig='doggo'
alias vim='nvim'

# Zellij
alias zn='zellij'
alias z='zellij attach -c main'
alias zl='zellij list-sessions'

# Config management
alias edit-config='hx ~/.zshrc'
alias ec='edit-config'
alias dotfiles='cd ~/dotfiles'
alias dot='cd ~/dotfiles'

# Editor shortcuts
alias v='nvim .'

# Git tools
alias tower='gittower'
alias tw='gittower .'

# Claude
alias cl='claude'
alias cly='claude --dangerously-skip-permissions'

# Claude Code commit helper - interactive with confirmation
commit() {
  # Stage all changes
  git add -A

  # Check if there are staged changes
  if git diff --staged --quiet; then
    echo "No changes to commit."
    return 0
  fi

  # Show summary of changes
  echo "Changes:"
  git --no-pager diff --staged --stat | sed 's/^/  /'
  echo ""

  # Generate commit message using Claude
  echo "Generating message..."
  local raw=$(claude --print -p "Generate a git commit message for the staged changes. Conventional commit format. Max 100 chars per line. IMPORTANT: Output the raw commit message only - no preamble, no 'here is', no explanation, no quotes, no markdown. Start directly with the type (feat/fix/etc)." 2>/dev/null)

  # Strip any preamble before the conventional commit type
  local msg=$(echo "$raw" | sed -n '/^\(feat\|fix\|docs\|style\|refactor\|perf\|test\|chore\|ci\|build\|revert\)[:(]/,$p')

  if [[ -z "$msg" ]]; then
    echo "Failed to generate commit message."
    return 1
  fi

  echo "Message:"
  echo "$msg" | sed 's/^/  /'
  echo ""

  # Ask for confirmation
  read "confirm?Commit? [y/N] "
  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    git commit -m "$msg"
  else
    echo "Commit cancelled."
    git reset HEAD >/dev/null 2>&1
  fi
}

# Claude Code PR helper - interactive with confirmation
create-pr() {
  # Get current branch
  local branch=$(git branch --show-current)
  local base=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
  base=${base:-main}

  # Check we're not on base branch
  if [[ "$branch" == "$base" || "$branch" == "main" || "$branch" == "master" ]]; then
    echo "Cannot create PR from $branch branch."
    return 1
  fi

  # Push branch if needed
  if ! git rev-parse --abbrev-ref --symbolic-full-name @{u} >/dev/null 2>&1; then
    echo "Pushing branch..."
    git push -u origin "$branch" || return 1
    echo ""
  fi

  # Show commits in this PR
  echo "Commits:"
  git --no-pager log --oneline "$base".."$branch" | sed 's/^/  /'
  echo ""

  # Show file changes
  echo "Files changed:"
  git --no-pager diff --stat "$base".."$branch" | sed 's/^/  /'
  echo ""

  # Generate PR title and body with Claude
  echo "Generating PR description..."
  local pr_content=$(claude --print -p "Generate a GitHub PR title and body for the commits on this branch. Format:
TITLE: <short descriptive title>
BODY:
<markdown body with summary and key changes>

Output ONLY in this exact format. No preamble, no explanation." 2>/dev/null)

  # Parse title and body
  local title=$(echo "$pr_content" | sed -n 's/^TITLE: //p' | head -1)
  local body=$(echo "$pr_content" | sed -n '/^BODY:/,$p' | tail -n +2)

  if [[ -z "$title" ]]; then
    echo "Failed to generate PR description."
    return 1
  fi

  echo "Title:"
  echo "  $title"
  echo ""
  echo "Body:"
  echo "$body" | sed 's/^/  /'
  echo ""

  # Ask for confirmation
  read "confirm?Create PR? [y/N] "
  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    gh pr create --title "$title" --body "$body" --base "$base"
  else
    echo "PR cancelled."
  fi
}

# Task Master
alias tm='task-master'
alias taskmaster='task-master'

# Config reload function
function load-config() {
    source ~/.zshrc
    if [[ $? -eq 0 ]]; then
        echo ".zshrc config reloaded!"
    else
        echo "Error reloading .zshrc!"
    fi
}
alias lc='load-config'


# Autocomplete function for dev command
_dev_complete() {
    local dev_dir="$HOME/dev"

    # Only provide completions if ~/dev exists
    if [[ -d "$dev_dir" ]]; then
        # Get directories in ~/dev, remove the full path prefix
        local dirs=($(find "$dev_dir" -maxdepth 1 -type d -not -path "$dev_dir" -exec basename {} \;))
        _describe 'directories' dirs
    fi
}

# Register the completion function
compdef _dev_complete dev

# Yazi cd wrapper
function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    yazi "$@" --cwd-file="$tmp"
    IFS= read -r -d '' cwd < "$tmp"
    [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
    rm -f -- "$tmp"
}

# Source additional configurations
source ~/dotfiles/zsh/aws.zshrc
source ~/dotfiles/zsh/port.zshrc
source ~/dotfiles/zsh/cw.zshrc

# Environment variables
export NODE_NO_WARNINGS=1
export NODE_ENV=development
export EDITOR='hx'

# Key bindings
bindkey '\e[H'    beginning-of-line
bindkey '\e[F'    end-of-line

# Add common binary paths
export PATH="${HOME}/.local/bin":${PATH}
export PATH="$HOME/bin:$PATH"
