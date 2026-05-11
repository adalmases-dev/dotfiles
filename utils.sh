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
      warn "Configuration at $dest is being remapped from its current link to $current_target"
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

  # Use jq for both to keep it consistent and clean
  local json=$(curl -sL "${auth_header[@]}" "https://api.github.com/repos/$repo/releases/latest")
  local tag=$(echo "$json" | jq -r '.tag_name // empty')

  if [[ -z "$tag" || "$tag" == "null" ]]; then
    json=$(curl -sL "${auth_header[@]}" "https://api.github.com/repos/$repo/tags")
    tag=$(echo "$json" | jq -r '[.[] | select(.name | test("^(v)?[0-9]"))][0].name // empty')
  fi

  echo "$tag"
}

get_current_version_tag() {
    local binary=$1
    if ! command -v "$binary" &> /dev/null; then
        echo "0.0.0"
        return
    fi

    local version=$("$binary" --version 2>&1 | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -n1)

    if [[ -z "$version" ]]; then
        version=$("$binary" --version 2>&1 | awk '{print $3}')
    fi

    echo "$version"
}
is_update_required() {
    local latest="${1#v}"
    local current="${2#v}"

    latest=$(echo "$latest" | cut -d'-' -f1)
    current=$(echo "$current" | cut -d'-' -f1)

    # Count dots to determine "granularity" 
    # (e.g., 4.25 has 1 dot, 4.25.1 has 2 dots)
    local dots_latest=$(echo "$latest" | tr -cd '.' | wc -c)
    local dots_current=$(echo "$current" | tr -cd '.' | wc -c)

    if [[ $dots_latest -ne $dots_current ]]; then
        # Different granularity: Compare only Major.Minor
        local latest_mm=$(echo "$latest" | cut -d'.' -f1,2)
        local current_mm=$(echo "$current" | cut -d'.' -f1,2)
        
        if [[ "$latest_mm" == "$current_mm" ]]; then
            return 1 # False: Major.Minor matches, ignore missing patch
        fi
    fi

    [[ "$latest" == "$current" ]] && return 1

    local newest=$(printf '%s\n%s' "$latest" "$current" | sort -V | tail -n1)
    if [[ "$newest" == "$latest" && "$latest" != "$current" ]]; then
        return 0 # True: An actual update is available
    fi

    return 1 # False: Already up to date or current is newer
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
