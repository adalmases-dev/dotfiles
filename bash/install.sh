#!/usr/bin/env bash

set -e

CURRENT_DIR="$(pwd)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR_ROOT="$(dirname "$SCRIPT_DIR")"

source "$DOTFILES_DIR_ROOT/utils.sh"

# Symlink configurations
mkdir -p "$HOME/.config"

info "Linking configuration for: bash"
link_file "$SCRIPT_DIR/bash" "$HOME/.config/bash"
# special case: .bashrc
link_file "$SCRIPT_DIR/bashrc" "$HOME/.bashrc"

cd "$CURRENT_DIR"

success "Bash installation complete!"
