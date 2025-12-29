#!/usr/bin/env bash

# Logging

export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[0;33m'
export BLUE='\033[0;34m'
export PURPLE='\033[0;35m'
export CYAN='\033[0;36m'
export NC='\033[0m' # No Color

info() {
  echo -e "${CYAN}[INFO]: $1 ${NC}"
}

# Prints a success message (Green)
success() {
  echo -e "${GREEN}[OK]: $1 ${NC}"
}

# Prints a warning message (Yellow)
warn() {
  echo -e "${YELLOW}[WARN]: $1 ${NC}"
}

# Prints an error message (Red) and redirects to stderr
error() {
  echo -e "${RED}[ERROR]: $1 ${NC}" >&2
}

# Check if a command exists
has_command() {
  command -v "$1" &>/dev/null
}

# link file
link_file() {
  local src=$1
  local dest=$2

  # Check if source actually exists
  if [ ! -e "$src" ]; then
    warn "Source not found: $src (skipping)"
    return
  fi

  # Create destination parent directory if missing
  mkdir -p "$(dirname "$dest")"

  # Case 1: Destination exists
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    # Is it a symlink?
    if [ -L "$dest" ]; then
      local current_target
      current_target=$(readlink -f "$dest")

      if [ "$current_target" == "$src" ]; then
        info "'$(basename "$dest")' configuration is already linked correctly: $dest → $src"
        return
      else
        warn "'$(basename "$dest")' configuration links to $current_target. Updating to $src"
        rm "$dest"
      fi
    # It is a real file or directory
    else
      warn "'$(basename "$dest")' configuration exists but it is not a symlink. Backing up to $(basename "$dest").bak before linking: $dest → $src)"
      mv "$dest" "${dest}.bak"
    fi
  fi

  # Case 2: Create the link
  info "Linking $dest → $src"
  ln -s "$src" "$dest"
}

# Get the latest release tag from GitHub API
# Usage: get_latest_github_tag "owner/repo"
get_latest_github_tag() {
  local repo="$1"
  curl -s "https://api.github.com/repos/$repo/releases/latest" |
    grep '"tag_name":' |
    sed -E 's/.*"([^"]+)".*/\1/'
}

# Compare two installed versions
is_update_required() {
  local current="${1#v}" # remove tipical leading 'v'
  local latest="${2#v}"

  if [[ "$current" == "$latest" ]]; then
    return 1 # False: No update needed
  else
    return 0 # True: Update needed
  fi
}

# Ensure Rust is installed auxiliar
ensure_rust() {
  if ! has_command "cargo"; then
    warn "Rust/Cargo not found. Installing via rustup."
    warn "To use rust within other script ensure that 'source \"$HOME/.cargo/env\"' is added to your bashrc file."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
  fi
}
