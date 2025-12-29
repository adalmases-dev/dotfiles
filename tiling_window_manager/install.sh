#!/usr/bin/env bash

set -e

CURRENT_DIR="$(pwd)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR_ROOT="$(dirname "$SCRIPT_DIR")"

source "$DOTFILES_DIR_ROOT/utils.sh"

# Define non-interactive frontend once for the whole script
export DEBIAN_FRONTEND=noninteractive

# Update apt
sudo -E apt-get update -qq

# Install build prerequisites:
sudo -E apt-get build-essential pkg-config git cmake meson ninja-build curl wget gettext libtool autoconf automake

# i3 Installation
MIN_I3_VERSION=4.22
APT_VERSION=$(apt-cache policy i3-wm | grep Candidate | awk '{print $2}' | cut -d: -f2 | cut -d- -f1)

if [ "$(printf '%s\n' "$MIN_I3_VERSION" "$APT_VERSION" | sort -V | head -n1)" = "$MIN_I3_VERSION" ]; then
  info "i3 apt version is new enough (>= 4.22). Installing from apt..."
  sudo -E apt-get install -y i3
else
  warn "i3 apt version is old. Building from source..."

  TEMP_DIR=$(mktemp -d)
  trap 'rm -rf "$TEMP_DIR"; cd "$CURRENT_DIR"' EXIT

  sudo -E apt-get build-dep -y i3-wm
  sudo -E apt-get install -y -build libpcre2-dev libxkbcommon-x11-dev \
    libev-dev libyajl-dev libxcb-cursor-dev libxcb-keysyms1-dev \
    libxcb-icccm4-dev libxcb-xrm-dev libxcb-shape0-dev

  git clone https://github.com/i3/i3.git --depth 1 "$TEMP_DIR/i3-source"
  cd "$TEMP_DIR/i3-source"
  mkdir build && cd build
  meson setup .. --buildtype=release
  ninja
  sudo ninja install

  cd "$CURRENT_DIR"
fi

# Other tools
info "Installing additional tools (rofi, picom, i3lock-fancy, fameshot, feh, jq)..."
sudo -E apt-get install -y rofi picom i3lock-fancy flameshot feh jq

# Symlink configurations
mkdir -p "$HOME/.config"

for dir in "$SCRIPT_DIR"/*; do
  if [[ -d "$dir" ]]; then
    dir_name=$(basename "$dir")
    link_file "$dir" "$HOME/.config/$dir_name"
  fi
done

success "Tiling window manager installation complete!"
