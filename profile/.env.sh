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
alias lg="lazygit"

# fuzzy `cd` alternatives
alias sd="cd \$(find \$HOME -type d | fzf)"
alias sf="cd \$(find \$HOME -type f | fzf | xargs dirname)"

# mix aliases
alias hxi="mix hex.info"

#: }}}
#: {{{ XDG Base Directory

[ -z "$XDG_CONFIG_HOME" ] && export XDG_CONFIG_HOME="$HOME/.config"
[ -z "$XDG_DATA_HOME" ] && export XDG_DATA_HOME="$HOME/.local/share"

#: }}}
#: {{{ ZSH

if [ "$(basename $SHELL)" = "zsh" ]; then
  export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
fi

#: }}}
#: {{{ TMUX

export TMUX_PLUGIN_MANAGER_PATH="$XDG_CONFIG_HOME/tmux/plugins"

#: }}}
#: {{{ ASDF

export ASDF_DIR="$XDG_CONFIG_HOME/asdf"
export ASDF_DATA_DIR="$XDG_DATA_HOME/asdf"

#: }}}
#: {{{ Elixir/Mix

export HEX_HOME="$XDG_DATA_HOME/hex"

#: }}}
#: {{{ Go

if [ -f "$ASDF_DATA_DIR/plugins/golang/set-env.zsh" ]; then
  source "$ASDF_DATA_DIR/plugins/golang/set-env.zsh"
fi

#: }}}
#: {{{ Node/npm

export npm_config_cache="$XDG_DATA_HOME/npm"

#: }}}
#: {{{ Local Overrides
if [ -f "$HOME/.local.env.sh" ]; then
  source ~/.local.env.sh
fi
#: }}}

# vim: ts=2 sw=2 expandtab foldmethod=marker
