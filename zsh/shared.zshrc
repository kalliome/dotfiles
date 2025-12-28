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
alias do="doctl"
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

# Dev function - cd to ~/dev with optional subdirectory
dev() {
    local dev_dir="$HOME/dev"

    # Create ~/dev if it doesn't exist
    if [[ ! -d "$dev_dir" ]]; then
        mkdir -p "$dev_dir"
    fi

    if [[ $# -eq 0 ]]; then
        # No arguments - just cd to ~/dev
        cd "$dev_dir"
    else
        # Arguments provided - cd to ~/dev/argument
        cd "$dev_dir/$1"
    fi
}

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
