#!/usr/bin/env zsh
source "$HOME/.env.sh"

OHMYZSH_URL="https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"

# Prompt to continue
# Usage: prompt_continue && { yes } || { no }
prompt_continue() {
  echo "$1"
  printf "Continue? (Y/n)"
  read -r response
  case `echo "$response" | head -c 1` in
    "N"|"n")
      return 1 ;;
    *)
      return 0 ;;
  esac
}

# [[ Install oh-my-zsh ]]
if [ ! -d "$ZDOTDIR/ohmyzsh" ] && [ ! -f "$ZDOTDIR/.skip_oh_my_zsh_install" ]; then
  prompt_continue "Oh-my-zsh is not installed. Install?" \
    && {
      sh -c "$(curl -fsSL $OHMYZSH_URL)" "" --keep-zshrc
    } || {
      echo "Skipping. You will not be prompted again."
      mkdir -p "$ZDOTDIR" && touch "$ZDOTDIR/.skip_oh_my_zsh_install"
    }
fi

# [[ oh-my-zsh Settings ]]
if [ -d "$ZDOTDIR/ohmyzsh" ]; then
  export OHMYZSH_DIR="$ZDOTDIR/ohmyzsh"
  export ZSH_THEME="robbyrussell"
  export HYPHEN_INSENSITIVE="true"

  # [[ ZSH Plugins ]]
  plugins=(git dotenv npm zsh-autosuggestions)

  if [ ! -d "$OHMYZSH_DIR/plugins/zsh-autosuggestions" ]; then
    [[ "${plugins[*]} " =~ "zsh-autosuggestions" ]] && \
      git clone https://github.com/zsh-users/zsh-autosuggestions $ZDOTDIR/ohmyzsh/plugins/zsh-autosuggestions
  fi
else
  # Configure prompt without oh-my-zsh
  autoload -Uz promptinit
  promptinit
  prompt walters
fi

# Force emacs bindings for CLI regardless of $EDITOR
bindkey -e

# [[ macOS Configuration ]]
if echo "$OSTYPE" | grep -e '^.*darwin.*$' > /dev/null; then
  if [ -n $OHMYZSH_DIR ]; then
    plugins+=(brew macos) # Only install macOS-sepcific plugins here.
  fi

  if command -v brew > /dev/null; then
    eval $(brew shellenv)
  fi
fi

# [[ Init oh-my-zsh ]]
if [ -f "$OHMYZSH_DIR/oh-my-zsh.sh" ]; then
  source "$OHMYZSH_DIR/oh-my-zsh.sh"
fi

# [[ Init ASDF ]]
if [ ! -z "$ASDF_DIR" ] \
  && [ ! -f $ASDF_DIR/.skip_asdf_install ] \
  && [ ! -f "$ASDF_DIR/asdf.sh" ]
then
  prompt_continue "ASDF is not installed. Install?" \
    && {
      echo "Installing ASDF."
      git clone https://github.com/asdf-vm/asdf.git $ASDF_DIR
    } || {
      echo "Skipping. You will not be prompted again."
      mkdir -p "$ASDF_DIR" && touch "$ASDF_DIR/.skip_asdf_install"
    }
fi

# Load ASDF completions
if [ -f "$ASDF_DIR/asdf.sh" ]; then
  source "$ASDF_DIR/asdf.sh"
  if [ -d "$ASDF_DIR/completions" ]; then
    fpath=($ASDF_DIR/completions $fpath)
    autoload -Uz compinit && compinit
  fi
fi

# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/calvin_henderson/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions
