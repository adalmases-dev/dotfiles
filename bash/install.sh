#!/usr/bin/env bash

set -e

CURRENT_DIR="$(pwd)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR_ROOT="$(dirname "$SCRIPT_DIR")"

source "$DOTFILES_DIR_ROOT/utils.sh"

# Symlink configurations
mkdir -p "$HOME/.config"

info "Linking bash configurations..."
for dir in "$SCRIPT_DIR"/*; do
  dir_name=$(basename "$dir")
  if [[ -d "$dir" ]]; then
    link_file "$dir" "$HOME/.config/$dir_name"
  else
    if [[ $dir_name == "bashrc" ]]; then # special case: .bashrc
      link_file "$dir" "$HOME/.bashrc"
    fi
  fi
done

cd "$CURRENT_DIR"

success "Terminal and CLI tools installation complete!"
