# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LC_CTYPE=en_US.utf-8
export PYTHONIOENCODING=utf-8

export EDITOR=vim

HIST_STAMPS="dd.mm.yyyy"
ZSH_THEME="avit"

source $ZSH/oh-my-zsh.sh

ex () {
    if [ -f $1 ] ; then
      case $1 in
        *.tar.bz2)   tar xjf $1     ;;
        *.tar.gz)    tar xzf $1     ;;
        *.bz2)       bunzip2 $1     ;;
        *.rar)       unrar e $1     ;;
        *.gz)        gunzip $1      ;;
        *.tar)       tar xf $1      ;;
        *.tbz2)      tar xjf $1     ;;
        *.tgz)       tar xzf $1     ;;
        *.zip)       unzip $1       ;;
        *.Z)         uncompress $1  ;;
        *.7z)        7z x $1        ;;
        *)     echo "'$1' cannot be extracted via extract()" ;;
         esac
     else
         echo "'$1' is not a valid file"
     fi
}

tr () { tar zcvf `basename $1`.tar.gz $@; }
nr () { npm run $@; }

PROMPT_TITLE='echo -ne "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/~}\007"'
export PROMPT_COMMAND="${PROMPT_COMMAND} ${PROMPT_TITLE}; "

bindkey "^[^[[D" backward-word
bindkey "^[^[[C" forward-word
bindkey "^[^[[A" beginning-of-line
bindkey "^[^[[B" end-of-line

# Load local zshrc
if [ -f $HOME/.zshrc.local ]; then
  source $HOME/.zshrc.local
fi