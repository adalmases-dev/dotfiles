#!/usr/bin/env bash

set -e 
CURRENT_DIR="$(pwd)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR_ROOT="$(dirname "$SCRIPT_DIR")"
source "$DOTFILES_DIR_ROOT/utils.sh"
  
info "Removing current Neovim configuration and data..."
if [ -d "$HOME/.config/nvim" ]; then
    # Generate a timestamp to avoid overwriting previous backups
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    BACKUP_DIR="$HOME/.config/nvim.bak_$TIMESTAMP"
    
    info "Backing up ~/.config/nvim to $BACKUP_DIR"
    cp -r ~/.config/nvim "$BACKUP_DIR"
    rm -rf ~/.config/nvim
else
    warn "No ~/.config/nvim found, skipping backup."
fi
rm -rf ~/.local/share/nvim
rm -rf ~/.local/state/nvim
rm -rf ~/.cache/nvim
