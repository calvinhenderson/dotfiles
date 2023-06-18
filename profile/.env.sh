#!/usr/bin/env sh

#: {{{ General

export PATH="$HOME/bin:$PATH"
export EDITOR="nvim"

#: }}}
#: {{{ Aliases

# `ls` aliases
LS="/bin/ls"
alias ls="$LS -1F --color=auto"
alias ll="ls -l"
alias la="ls -hA"
alias lla="ls -lhA"
alias lr="ls -R"
alias lt="du -sh * | sort -h" # Sort by file size

# `cp` alternative
alias cpv="rsync -ah --progress"

# vim and tmux aliases
alias vi="nvim"
alias tn="tmux new-session -s"
alias ta="tmux attach-session -t"
alias tl="tmux list-sessions"
alias ts="tmux-session"

# git aliases
alias ga="git add"
alias gc="git commit"

#: }}}
#: {{{ XDG Base Directory

[ -z "$XDG_CONFIG_HOME" ] && export XDG_CONFIG_HOME="$HOME/.config"
[ -z "$XDG_DATA_HOME" ] && export XDG_DATA_HOME="$HOME/.local/share"

#: }}}
#: {{{ TMUX

export TMUX_PLUGIN_MANAGER_PATH="$XDG_CONFIG_HOME/tmux/plugins"

#: }}}
#: {{{ ASDF

export ASDF_DIR="$XDG_CONFIG_HOME/asdf"
export ASDF_DATA_DIR="$XDG_DATA_HOME/asdf"

#: }}}
#: {{{ ZSH

if [ "$(basename $SHELL)" = "zsh" ]; then
  export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
fi

#: }}}

# vim: ts=2 sw=2 expandtab foldmethod=marker
