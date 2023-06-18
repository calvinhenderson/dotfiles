#!/usr/bin/env sh

log() {
  # Only use colors when running an interactive shell
  RED=""; YELLOW=""; GREEN=""; RESET="";
  if test -t 1 && [ `tput colors` -gt 33 ]; then
    RED="\033[31m"
    YELLOW="\033[33m"
    GREEN="\033[32m"
    RESET="\033[0m"
  fi

  LOG_LEVEL="$1"; shift
  # 0: INFO, 1: WARN, 2: ERROR
  case "$LOG_LEVEL" in
    0) echo "$@" ;;
    1) echo "$GREEN$@$RESET" ;;
    2) echo "$YELLOW$@$RESET" ;;
    3) echo "$RED$@$RESET" ;;
  esac
}
log_info() { log 0 $@; }
log_success() { log 1 $@; }
log_warn() { log 2 $@; }
log_error() { log 3 $@; }

usage() {
  cat <<EOF | sed -E 's/^[ ]{4}//'
    usage: $0 [options]

    options:
      -h,--help         Show this message and exit.
      -u,--uninstall    Uninstall existing files. No install is performed.
      --dry-run         Performs a dry-run. No changes will be made.
      --no-interaction  All user prompting is skipped. Use at your own risk.
EOF
  exit 0
}

# Convert input string to all lowercase
to_lower() { echo "$1" | tr '[:upper:]' '[:lower:]'; }

# Executes the command when not a dry-run
maybe_exec() {
  log_info "$@"
  [ $DRY_RUN -eq 0 ] && eval "$@"
}

# Prompts the user to continue.
# Returns yes: 0, otherwise: 1
maybe_continue() {
  [ $NO_INTERACTION -eq 1 ] && return 0

  printf "Continue (y/N)? "
  read -r cont

  case $(to_lower "$cont") in
    "y" | "yes") return 0 ;;
    *) return 1 ;;
  esac
}

local_path() { echo "$1" | sed -E 's|^[^/]*/(.*)$|\1|'; }

uninstall_file() { maybe_exec rm "$2/$(local_path $1)"; }
install_file() {
  dest=`dirname "$2/$(local_path $1)"`
  [ ! -d "$dest" ] && maybe_exec mkdir -p "$dest"
  maybe_exec ln -s "$INSTALL_ROOT/$1" "$dest"
}

list_files() { find "$1" -depth -type f; find "$1" -depth -type l; }


## START
## ===============

# Runtime options defaults
DRY_RUN=0
UNINSTALL=0
NO_INTERACTION=0

# Parse command-line arguments
while [ -n "$1" ]; do
  arg="$1"; shift;
  case "$arg" in
    "-h" | "--help") usage ;;
    "--no-interaction") NO_INTERACTION=1 ;;
    "--dry-run") DRY_RUN=1; ;;
    "-u" | "--uninstall") UNINSTALL=1; ;;
    *) log_error "unknown argument $arg"; usage ;;
  esac
done

# Ensure XDG_CONFIG_HOME is pre-defined
# Otherwise confirm the default location
if [ -z "$XDG_CONFIG_HOME" ]; then
  log_warn "XDG_CONFIG_HOME is empty. Defaulting to $HOME/.config/"
  XDG_CONFIG_HOME="$HOME/.config"
fi

# The current working directory (of this script)
INSTALL_ROOT=$(cd -- "$(dirname -- "$0" )" && pwd -P)

# '|' separated list of files to ignore
IGNORE_FILES=".DS_Store|.swp"

# Configure the installer locations
INSTALL_LOCATIONS=$(cat <<EOF
bin:$HOME/bin
config:$XDG_CONFIG_HOME
profile:$HOME
EOF
)

[ $DRY_RUN -eq 1 ] && log_success "Performing a dry run. No changes will be made"

if [ $UNINSTALL -eq 1 ]; then
  log_error "Uninstalling from $HOME"
else
  log_success "Installing from $INSTALL_ROOT to $HOME"
fi

# Prompt to continue before making any changes.
[ $DRY_RUN -eq 1 ] || maybe_continue || exit 0

# Perform the install/uninstall
for config in $INSTALL_LOCATIONS; do
  [ -z "$config" ] && continue
  SRC=`echo "$config" | tr ':' '\n' | head -n 1`
  DST=`echo "$config" | tr ':' '\n' | tail -n 1`

  for file in `list_files "$SRC"`; do
    [ -n "$(echo basename -- "$file" | grep -oE \"[$IGNORE_FILES]+$\")" ] && continue
    [ `basename -- "$file"` = ".gitignore" ] && continue
    if [ $UNINSTALL -eq 1 ]; then
      uninstall_file "$file" "$DST"
    else
      install_file "$file" "$DST"
    fi
  done
done

if [ $UNINSTALL -eq 1 ]; then
  log_warn "Some folders may be empty and still exist. They will need to be manually deleted."
else
  log_success "Installation complete. You may need to log out and back in for all changes to take affect."
fi

# vim: ts=2 sw=2 et
