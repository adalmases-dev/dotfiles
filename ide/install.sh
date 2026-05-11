#!/usr/bin/env bash

set -e

CURRENT_DIR="$(pwd)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR_ROOT="$(dirname "$SCRIPT_DIR")"

# Load helpers
source "$DOTFILES_DIR_ROOT/utils.sh"

info "Installing dependencies..."
sudo apt-get update -qq
sudo apt-get install -y -qq curl unzip build-essential npm

# Some dependencies (latest version, instead of apt)
LATEST_FZF=$(get_latest_github_tag "junegunn/fzf")
CURRENT_FZF=$(get_current_version_tag "fzf")
if ! has_command "fzf" || is_update_required "$CURRENT_FZF" "$LATEST_FZF"; then
  info "Installing/Updating fzf ($LATEST_FZF)..."
  rm -rf "$HOME/.fzf"
  git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
  "$HOME/.fzf/install" --all --no-bash --no-zsh
  sudo ln -sf "$HOME/.fzf/bin/fzf" /usr/local/bin/fzf
else
  info "fzf is up to date ($LATEST_FZF)."
fi

install_rust_tool "ripgrep" "BurntSushi/ripgrep" "rg"
install_rust_tool "fd-find" "sharkdp/fd" "fd"
install_rust_tool "tree-sitter-cli" "tree-sitter/tree-sitter" "tree-sitter"

# Neovim Logic
LATEST_NVIM=$(get_latest_github_tag "neovim/neovim")
CURRENT_NVIM=$(get_current_version_tag "nvim")

if ! has_command "nvim" || is_update_required "$CURRENT_NVIM" "$LATEST_NVIM"; then
    info "Installing Neovim ($LATEST_NVIM)..."
    
    TEMP_DIR=$(mktemp -d)
    trap 'rm -rf "$TEMP_DIR"' EXIT
    {
      cd "$TEMP_DIR" || exit 1

      # Using the specific tag ensures consistency
      URL="https://github.com/neovim/neovim/releases/download/${LATEST_NVIM}/nvim-linux-x86_64.tar.gz"
      
      curl -LO "$URL"
      sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
      
      # Create symlink to the binary
      sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
      
      info "Neovim installed successfully."
    }
else
    info "Neovim is up to date ($LATEST_NVIM)."
fi

# Symlink configuration
mkdir -p "$HOME/.config"
info "Linking configuration for: nvim"
link_file "$SCRIPT_DIR/nvim" "$HOME/.config/nvim"

success "Neovim installation complete!"

cd "$CURRENT_DIR"
