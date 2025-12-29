#!/usr/bin/env bash

set -e

CURRENT_DIR="$(pwd)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR_ROOT="$(dirname "$SCRIPT_DIR")"

source "$DOTFILES_DIR_ROOT/utils.sh"

URL="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz"
LATEST_NVIM=$(get_latest_github_tag "neovim/neovim")
TARBALL=$(basename "$URL")
INSTALL_PARENT="/opt"
INSTALL_DIR="$INSTALL_PARENT/${TARBALL%%.tar.gz}"
BIN_PATH="/usr/local/bin/nvim" # Install will be symlinked here

# Check dependencies for main Neovim plugins (for telescope, build-essential for treesitter, unzip for mason...)
# Handle Ripgrep (rg) recommended dependecy via rust
LATEST_RG=$(get_latest_github_tag "BurntSushi/ripgrep")
if ! has_command "rg" || is_update_required "$(rg --version | head -n1 | awk '{print $2}')" "$LATEST_RG"; then
  ensure_rust
  warn "Installing/Updating ripgrep to $LATEST_RG"
  cargo install ripgrep
fi

DEPENDENCIES=("curl" "gcc" "make" "unzip" "build-essential")
warn "Installing/ensuring apt dependencies: ${MISSING_DEPS[*]}"
sudo apt-get update -qq && sudo apt-get install -y "${MISSING_DEPS[@]}"

# Install Nvim
if ! has_command "nvim" || is_update_required "$(nvim --version | head -n 1 | awk '{print $2}')" $LATEST_NVIM; then
  TEMP_DIR=$(mktemp -d)
  cd "$TEMP_DIR"
  curl -LO "$URL"
  sudo rm -rf "$INSTALL_DIR"
  sudo tar -C "$INSTALL_PARENT" -xzf "$TARBALL"
  rm "$TARBALL"
  sudo rm -f "$BIN_PATH"
  # Link /opt/nvim-linux64/bin/nvim to /usr/local/bin/nvim
  sudo ln -s "$INSTALL_DIR/bin/nvim" "$BIN_PATH"

  if has_command "nvim"; then
    success "Installed $(nvim --version | head -n 1)"
  else
    error "Installation failed. 'nvim' not found in \$PATH"
  fi

  rm -rf "$TEMP_DIR"
fi

# Symlink configuration
mkdir -p "$HOME/.config"

for dir in "$SCRIPT_DIR"/*; do
  if [[ -d "$dir" ]]; then
    dir_name="$(basename "$dir")"
    link_file "$dir" "$HOME/.config/$dir_name"
  fi
done

cd "$CURRENT_DIR"
