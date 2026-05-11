#!/usr/bin/env bash

set -e

CURRENT_DIR="$(pwd)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR_ROOT="$(dirname "$SCRIPT_DIR")"

source "$DOTFILES_DIR_ROOT/utils.sh"

info "Installing tiling window manager and tools..."
sudo apt-get update -qq
sudo apt-get install -y -qq build-essential pkg-config git cmake meson ninja-build curl jq rofi picom flameshot feh xss-lock

# Check i3 Version for at least 4.22 (gaps support)
LATEST_I3=$(get_latest_github_tag "i3/i3")
CURRENT_I3=$(get_current_version_tag "i3") 

if ! has_command "i3" || is_update_required "$LATEST_I3" "$CURRENT_I3"; then
  info "Installing i3 from source ($LATEST_I3)..."
  sudo apt-get install -y -qq libpcre2-dev libxkbcommon-x11-dev libev-dev libyajl-dev libxcb-cursor-dev libxcb-keysyms1-dev libxcb-icccm4-dev libxcb-xrm-dev libxcb-shape0-dev libstartup-notification0-dev libxcb-randr0-dev libxcb-xinerama0-dev libxcb-util-dev
  TEMP_DIR=$(mktemp -d)
  trap 'rm -rf "$TEMP_DIR"; cd "$CURRENT_DIR"' EXIT

  git clone https://github.com/i3/i3.git "$TEMP_DIR/i3-source"  -q
  cd "$TEMP_DIR/i3-source"
  mkdir build && cd build
  meson setup .. --buildtype=release --prefix=/usr > /dev/null 2>&1  
  ninja > /dev/null 2>&1
  sudo ninja install > /dev/null 2>&1
  sudo cp "$TEMP_DIR/i3-source/share/xsessions/i3.desktop" /usr/share/xsessions/i3.desktop || true
  success "i3 installed successfully."
else
  info "i3 is up to date ($LATEST_I3)."
fi

# i3lock-color 
# Build and Install i3lock-color
if ! has_command "i3lock" || [[ $(i3lock --version 2>&1) != *"Raymond Li"* ]]; then
    info "Installing i3lock-color ..."

    sudo apt-get install -y -qq \
      autoconf gcc make pkg-config libpam0g-dev libcairo2-dev libfontconfig1-dev \
      libxcb-composite0-dev libev-dev libx11-xcb-dev libxcb-xkb-dev \
      libxcb-xinerama0-dev libxcb-randr0-dev libxcb-image0-dev libxcb-util0-dev \
      libxcb-xrm-dev libxkbcommon-dev libxkbcommon-x11-dev libjpeg-dev

    TEMP_DIR=$(mktemp -d)
    
    git clone https://github.com/Raymo111/i3lock-color.git "$TEMP_DIR/i3lock-color" -q
    cd "$TEMP_DIR/i3lock-color"
    
    ./install-i3lock-color.sh > /dev/null 
    cd "$CURRENT_DIR"
    rm -rf "$TEMP_DIR"
  success "i3lock-color installed successfully."
else
    info "i3lock-color is already installed."
fi

# Symlink configurations
LINK_PLAN=()
for dir in "$SCRIPT_DIR"/*; do
  if [[ -d "$dir" ]]; then
    dir_name=$(basename "$dir")
    LINK_PLAN+=("$dir_name")
  fi
done

if [[ ${#LINK_PLAN[@]} -eq 0 ]]; then
  info "No configuration symlinks required."
else
  info "Linking configurations for: ${LINK_PLAN[*]}"
  for item in "${LINK_PLAN[@]}"; do
    link_file "$SCRIPT_DIR/$item" "$HOME/.config/$item"
  done
fi

success "Tiling window manager installation complete!"
