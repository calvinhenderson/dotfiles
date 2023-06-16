#!/usr/bin/env zsh
source "$HOME/.env.sh"

# [[ Install oh-my-zsh ]]
if [ ! -d "$ZDOTDIR/ohmyzsh" ] && [ ! -f "$DOTFILES_INSTALL_DIR/.install_oh_my_zsh" ]; then
  echo "oh-my-zsh is not installed."

  printf "Install oh-my-zsh? (y/N): "  >&2
  read -r prompt

  # Maybe run the install script?
  case `echo "$prompt" | tr '[:upper:]' '[:lower:]'` in
    "y" | "yes")
      sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --keep-zshrc
      ;;
    *)
      # Don't prompt again
      touch "$DOTFILES_INSTALL_DIR/.skip_oh_my_zsh_install"
      ;;
  esac
fi

# [[ oh-my-zsh Settings ]]
if [ -d "$ZDOTDIR/ohmyzsh" ]; then
  export OHMYZSH_DIR="$ZDOTDIR/ohmyzsh"
  export ZSH_THEME="robbyrussell"
  export HYPHEN_INSENSITIVE="true"

  # [[ ZSH Plugins ]]
  plugins=(git dotenv docker npm zsh-autosuggestions)

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

# [[ macOS Configuration ]]
if echo "$OSTYPE" | grep -e '^.*darwin.*$' > /dev/null; then
  if [ -n $OHMYZSH_DIR ]; then
    plugins+=(brew macos) # Only install macOS-sepcific plugins here.
  fi

  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# [[ Init oh-my-zsh ]]
if [ -f "$OHMYZSH_DIR/oh-my-zsh.sh" ]; then
  source "$OHMYZSH_DIR/oh-my-zsh.sh"
fi
