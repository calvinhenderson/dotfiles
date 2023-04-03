#!/usr/bin/env sh

export DOTFILES_INSTALL_DIR=$(cat "$HOME/.dotfiles_install_dir" 2>& /dev/null)
if [ -z "$DOTFILES_INSTALL_DIR" ]; then
  export DOTFILES_INSTALL_DIR="$HOME"
fi

export PATH="$DOTFILES_INSTALL_DIR/bin:$PATH"
export EDITOR="nvim"

if [ "$(basename $SHELL)" = "zsh" ]; then
  ZSH_THEME="robbyrussell"
  HYPHEN_INSENSITIVE="true"
  plugins=(git brew macos dotenv docker npm zsh-autosuggestions)
fi

LS="/bin/ls"

alias vi="nvim"
alias ls="$LS -1F --color=auto"
alias ll="ls -l"
alias la="ls -hA"
alias lla="ls -lhA"
alias lr="ls -R"
alias lt="du -sh * | sort -h" # Sort by file size
alias cpv="rsync -ah --progress"

# vim: ts=2 sw=2 expandtab
