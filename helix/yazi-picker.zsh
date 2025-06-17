#! /usr/bin/env zsh
echo $1;

# file=$(yazi --chooser-file=/dev/stdout $1 | cat)
# zellij action toggle-floating-panes
# zellij action write 27 # send escape-key
# zellij action write-chars ":open $(command printf '%q' "$file")"
# zellij action write 13 # send enter-key
# zellij action toggle-floating-panes
# zellij action close-pane
