#!/usr/bin/env sh

#: {{{ General

export PATH="$HOME/bin:$PATH"
export EDITOR="nvim"

#: }}}
#: {{{ Helpers

function should_install() {
  # Takes a cli command as an argument. Returns 0 if the command exists or the
  # user requested to skip installation, 1 otherwise.
  cmd="$1"
  skip_install="$XDG_DATA_HOME/.skip_install"

  if command -v $cmd >/dev/null 2>&1 || ([ -f "$skip_install" ] && grep -o "$cmd" "$skip_install" >/dev/null 2>&1); then
    return 1
  else
    printf "install $cmd (y/N) "
    read -n install
    case "$install" in
      "y"* | "Y"*)
        return 0
        ;;
      *)
        # skip in future
        echo "$cmd" >> "$skip_install"
        return 1
    esac
  fi
}

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
#: {{{ INSTALL DEPS
#: {{{ HOMEBREW

if should_install "brew"; then
  echo "installing homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

install_deps=""
function install() {
  install_deps="$install_deps $@"
}

#: }}}
#: {{{ ZSH

if should_install "zsh"; then
  install zsh
fi

export ZDOTDIR="$XDG_CONFIG_HOME/zsh"

#: }}}
#: {{{ TMUX

if should_install "tmux"; then
  install tmux
fi

export TMUX_PLUGIN_MANAGER_PATH="$XDG_CONFIG_HOME/tmux/plugins"

#: }}}
#: {{{ ASDF

if should_install "asdf"; then
  install asdf
fi

export ASDF_DIR="$XDG_CONFIG_HOME/asdf"
export ASDF_DATA_DIR="$XDG_DATA_HOME/asdf"

#: }}}

if [ -n "$install_deps" ]; then
  if command -v brew &>/dev/null; then
    brew install $install_deps
  elif command -v dnf &>/dev/null; then
    dnf install $install_deps
  else
    echo "Could not detect package manager. Which command should I use?"
    echo "Ex: [command] $install_deps"
    printf "> "
    read -n pkgmgr
    $pkgmgr $install_deps
  fi
fi
#: }}} INSTALL DEPS
#: {{{ Elixir/Mix

if command -v asdf &>/dev/null; then
  plugins=$(asdf plugin list)

  if command -v asdf &>/dev/null && echo "$plugins" | grep -o "elixir" >/dev/null; then
    asdf plugin add elixir https://github.com/asdf-vm/asdf-elixir.git >/dev/null 2>&1
  fi

  if command -v asdf &>/dev/null && echo "$plugins" | grep -o "erlang" >/dev/null; then
    asdf plugin add erlang https://github.com/asdf-vm/asdf-erlang.git >/dev/null 2>&1
  fi
  export HEX_HOME="$XDG_DATA_HOME/hex"
fi

#: }}}
#: {{{ Go

if [ -f "$ASDF_DATA_DIR/plugins/golang/set-env.zsh" ]; then
  source "$ASDF_DATA_DIR/plugins/golang/set-env.zsh"
fi

#: }}}
#: {{{ Node/npm

if command -v asdf &>/dev/null && echo "$plugins" | grep -o "nodejs" >/dev/null; then
  asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git >/dev/null 2>&1
fi

export npm_config_cache="$XDG_DATA_HOME/npm"

#: }}}
#: {{{ Local Overrides
if [ -f "$HOME/.local.env.sh" ]; then
  source ~/.local.env.sh
fi
#: }}}

# vim: ts=2 sw=2 expandtab foldmethod=marker
