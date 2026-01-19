#!/usr/bin/env bash

set -e

CURRENT_DIR="$(pwd)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR_ROOT="$(dirname "$SCRIPT_DIR")"

source "$DOTFILES_DIR_ROOT/utils.sh"

info "Installing Nerd Fonts..."

# You could change this to /usr/local/share/fonts if running as sudo
FONT_DIR="$HOME/.local/share/fonts"
FONTS_TO_INSTALL=(
  "Hack"
  "JetBrainsMono"
)

# Append extra fonts if passed as arguments
if [ "$#" -gt 0 ]; then
  FONTS_TO_INSTALL+=("$@")
fi

TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"; cd "$CURRENT_DIR"' EXIT
cd "$TMP_DIR"

for font in "${FONTS_TO_INSTALL[@]}"; do

  # Check if the font family is already registered in the system
  if fc-list :family | grep -qi "$font"; then
    info "$font font is already installed. Skipping..."
    continue
  fi

  # Download and install
  if ! wget -q --show-progress "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$font.zip"; then
    warn "Failed to download $font font."
    continue
  fi

  info "Installing $font font."
  unzip -qq "$font.zip" -d "$font-temp"

  dst="$FONT_DIR/$font"
  mkdir -p "$dst"
  find "$font-temp" -type f \( -iname "*.ttf" -o -iname "*.otf" \) -exec cp {} "$dst/" \;
  rm -rf "$font.zip" "$font-temp"
done

fc-cache -f "$FONT_DIR"

success "Nerd Fonts installation complete!"

cd "$CURRENT_DIR"
