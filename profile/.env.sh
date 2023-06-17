#!/usr/bin/env sh

export DOTFILES_INSTALL_DIR=$(cat "$HOME/.dotfiles_install_dir" 2>& /dev/null)
if [ -z "$DOTFILES_INSTALL_DIR" ]; then
  export DOTFILES_INSTALL_DIR="$HOME"
fi

export PATH="$DOTFILES_INSTALL_DIR/bin:$PATH"
export EDITOR="nvim"

if [ -z "$XDG_CONFIG_HOME" ]; then
  export XDG_CONFIG_HOME="$HOME/.config"
fi

export ASDF_DIR="$XDG_CONFIG_HOME/asdf"

if [ "$(basename $SHELL)" = "zsh" ]; then
  export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
fi

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

# git aliases
alias ga="git add"
alias gc="git commit"

# vim: ts=2 sw=2 expandtab
