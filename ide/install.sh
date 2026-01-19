#!/usr/bin/env bash

set -e

CURRENT_DIR="$(pwd)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR_ROOT="$(dirname "$SCRIPT_DIR")"

source "$DOTFILES_DIR_ROOT/utils.sh"

info "Installing Neovim..."

TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"; cd "$CURRENT_DIR"' EXIT
cd "$TEMP_DIR"

URL="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz"
TARBALL=$(basename "$URL")
INSTALL_PARENT="/opt"
INSTALL_DIR="$INSTALL_PARENT/${TARBALL%%.tar.gz}"
BIN_PATH="/usr/local/bin/nvim" # Install will be symlinked here

# Check dependencies for main Neovim plugins (for telescope, build-essential for treesitter, unzip for mason...)
info "Installing/ensuring basic dependencies..."

# Handle Ripgrep (rg), and tree-sitter recommended dependecy via rust
install_rust_tool "ripgrep" "BurntSushi/ripgrep" "rg"
install_rust_tool "tree-sitter" "tree-sitter/tree-sitter" "tree-sitter"

sudo apt-get update -qq && sudo apt-get install -y curl gcc make unzip build-essential npm

# Install Nvim
LATEST_NVIM=$(get_latest_github_tag "neovim/neovim")
CURRENT_NVIM=$(get_current_version_tag "nvim")
if ! has_command "nvim" || is_update_required "$CURRENT_NVIM" $LATEST_NVIM; then
  info "Installing/Upgrading Neovim ($LATEST_NVIM)..."
  curl -LO "$URL"
  sudo rm -rf "$INSTALL_DIR"
  sudo tar -C "$INSTALL_PARENT" -xzf "$TARBALL"
  rm "$TARBALL"
  sudo rm -f "$BIN_PATH"
  # Link /opt/nvim-linux64/bin/nvim to /usr/local/bin/nvim
  sudo ln -s "$INSTALL_DIR/bin/nvim" "$BIN_PATH"

  rm -rf "$TEMP_DIR"
else
  info "Neovim is up to date ($LATEST_NVIM)."
fi

# Symlink configuration
mkdir -p "$HOME/.config"

info "Linking configuration for: nvim"
link_file "$SCRIPT_DIR/nvim" "$HOME/.config/nvim"

success "Neovim installation complete!"

cd "$CURRENT_DIR"
