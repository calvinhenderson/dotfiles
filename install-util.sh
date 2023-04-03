#!/usr/bin/env sh

# Configure the installation paths here
# syntax: local_path:install_path:[dir|files]
DOTFILES_INSTALL_DIRS=$(cat <<EOF
nvim:.config/nvim:dir
scripts:bin:files
shell:.:files
EOF
)

usage() {
  echo "$1 [-i|--install][-u|--uninstall] [installation_root]"
}

export DOTFILES_INSTALL=0
export DOTFILES_UNINSTALL=0

case "$1" in
  "-i"|"--install")
    export DOTFILES_INSTALL=1
    break;;
  "-u"|"--uninstall")
    export DOTFILES_UNINSTALL=1
    break;;
  *)
    usage;;
esac

if [ -d "$2" ]; then
  echo "using installation root: $2"
  export DOTFILES_ROOT="$2"
elif [ ! -z "$2" ]; then
  echo "path does not exist or is not a directory: $2"
fi

if [ -z "$DOTFILES_ROOT" ]; then
  echo "installation path not provided or not set."
  echo "default installation path: $HOME"
  export DOTFILES_ROOT="$HOME"
fi

dirname=$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)

if [ "$DOTFILES_INSTALL" -eq 1 ]; then
  echo "installing to $DOTFILES_ROOT"
elif [ "$DOTFILES_UNINSTALL" -eq 1 ]; then
  echo "uninstalling from $DOTFILES_ROOT"
fi

read -p "continue (y/N)? " choice
case $choice in
  "y"|"Y"|"yes"|"YES")
    break;;
  *)
    exit 0;;
esac

echo "$DOTFILES_ROOT" > ~/.dotfiles_root

for config in $DOTFILES_INSTALL_DIRS; do
  if [ -z "$config" ]; then continue; fi
  echo "$config" | tr ':' '\n' | xargs sh -c '
    if [ "$1" = "." ]; then
      export DOTFILES_INSTALL_LOC="$DOTFILES_ROOT"
    else
      export DOTFILES_INSTALL_LOC="$DOTFILES_ROOT/$1"
    fi

    if [ "$2" == "dir" ]; then
      if [ "$DOTFILES_INSTALL" -eq 1 ]; then
        echo "ln -s $0 $DOTFILES_INSTALL_LOC"
        ln -s "$0" "$DOTFILES_INSTALL_LOC"
      elif [ "$DOTFILES_UNINSTALL" -eq 1 ]; then
        echo "rm -r $DOTFILES_INSTALL_LOC"
        rm -r "$DOTFILES_INSTALL_LOC" 2>/dev/null
      fi
    else
      for file in $(ls -1A "$0"); do
        if [ "$DOTFILES_INSTALL" -eq 1 ]; then
          echo "ln -s $0/$file $DOTFILES_INSTALL_LOC/$file"
          ln -s "$0/$file" "$DOTFILES_INSTALL_LOC/$file"
        elif [ "$DOTFILES_UNINSTALL" -eq 1 ]; then
          echo "rm -r $DOTFILES_INSTALL_LOC/$file"
          rm -r "$DOTFILES_INSTALL_LOC/$file" 2>/dev/null
        fi
      done
    fi
  '
done

export DOTFILES_INSTALL=
export DOTFILES_UNINSTALL=

# vim: ts=2 sw=2 expandtab
