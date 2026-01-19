#!/usr/bin/env bash

# Logging
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[0;33m'
export BLUE='\033[0;34m'
export PURPLE='\033[0;35m'
export CYAN='\033[0;36m'
export NC='\033[0m' # No Color

# Logging Helpers
info() { echo -e "${CYAN}[INFO]: $1 ${NC}"; }
success() { echo -e "${GREEN}[OK]: $1 ${NC}"; }
warn() { echo -e "${YELLOW}[WARN]: $1 ${NC}"; }
error() { echo -e "${RED}[ERROR]: $1 ${NC}" >&2; }

has_command() { command -v "$1" &>/dev/null; }

# Symlink file
link_file() {
  local src=$1
  local dest=$2
  local name=$(basename "$dest")

  # Check if source actually exists
  if [ ! -e "$src" ]; then
    warn "Source not found: $src (skipping)"
    return
  fi

  # Create destination parent directory if missing
  mkdir -p "$(dirname "$dest")"

  # Link
  if [ -L "$dest" ]; then
    local current_target
    current_target=$(readlink -f "$dest")

    if [ "$current_target" == "$src" ]; then
      info "Configuration symlink is ok at $dest"
      return
    else
      warn "Configuration at $dest is being remapped from $current_target to $src"
      unlink "$dest"
    fi
  elif [ -e "$dest" ]; then
    warn "Configuration found at $dest. Moving to ${name}.bak before symlinking"
    mv "$dest" "${dest}.bak"
  fi

  # Create the link
  if ln -s "$src" "$dest"; then
    success "Linking configuration $dest → $src"
  else
    error "Something went wrong when linking $name config"
  fi
}

# Get the latest release tag from GitHub API
get_latest_github_tag() {
  local repo="$1"
  local auth_header=()
  [[ -n "$GITHUB_TOKEN" ]] && auth_header=("-H" "Authorization: token $GITHUB_TOKEN")

  # Try Releases first
  local json=$(curl -sL "${auth_header[@]}" "https://api.github.com/repos/$repo/releases/latest")
  local tag=$(echo "$json" | grep '"tag_name":' | sed -E 's/.*"tag_name":\s*"([^"]+)".*/\1/')

  # Fallback to Tags with Filtering
  if [[ -z "$tag" ]] || [[ "$tag" == "null" ]]; then
    # We fetch the tags list and look for the first one that starts with a number or 'v' followed by a number
    # This ignores things like "tree-pr", "deprecated", or "stable"
    json=$(curl -sL "${auth_header[@]}" "https://api.github.com/repos/$repo/tags")
    # Regex: starts with v and a digit, or just a digit
    tag=$(echo "$json" | jq -r '[.[] | select(.name | test("^(v)?[0-9]"))][0].name')
  fi

  echo "$tag"
}

get_current_version_tag() {
  local binary=$1
  if ! has_command "$binary"; then
    echo "0.0.0" # Default for missing tools
    return
  fi

  echo "$("$binary" --version 2>&1 | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -n1)"
}

# Returns 0 (True) if an update IS needed, 1 (False) if it is NOT.
# This follows standard Bash logic: if is_update_required; then ...
is_update_required() {
  local current="${1#v}"
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

# Improved Rust tool installer
install_rust_tool() {
  local tool_name=$1
  local repo=$2
  local binary=$3

  local latest_tag=$(get_latest_github_tag "$repo")
  local current_tag=$(get_current_version_tag "$binary")

  if ! has_command "$binary" || is_update_required "$current_tag" "$latest_tag"; then
    info "Updating/Installing $tool_name ($latest_tag)..."
    ensure_rust
    if cargo install "$tool_name"; then
      success "$tool_name installed successfully!"
    else
      error "Failed to install $tool_name."
    fi
  else
    info "$tool_name is up to date ($latest_tag)."
  fi
}
