#!/usr/bin/env bash

set -e

CURRENT_DIR="$(pwd)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR_ROOT="$(dirname "$SCRIPT_DIR")"

source "$DOTFILES_DIR_ROOT/utils.sh"

info "Installing tiling window manager and tools..."
sudo apt-get update -qq
sudo apt-get install -y build-essential pkg-config git cmake meson ninja-build curl jq rofi picom i3lock-fancy flameshot feh

# Check i3 Version for at least 4.22 (gaps support)
LATEST_I3=$(get_latest_github_tag "i3/i3")
CURRENT_I3=$(get_current_version_tag "i3")
if ! has_command "i3" || is_update_required "$LATEST_I3" "$CURRENT_I3"; then
  warn " Installing i3 from source ($LATEST_I3)..."
  sudo apt-get install -y libpcre2-dev libxkbcommon-x11-dev libev-dev libyajl-dev libxcb-cursor-dev libxcb-keysyms1-dev libxcb-icccm4-dev libxcb-xrm-dev libxcb-shape0-dev libstartup-notification0-dev libxcb-randr0-dev libxcb-xinerama0-dev libxcb-util-dev
  TEMP_DIR=$(mktemp -d)
  trap 'rm -rf "$TEMP_DIR"; cd "$CURRENT_DIR"' EXIT

  git clone https://github.com/i3/i3.git --depth 1 "$TEMP_DIR/i3-source"
  cd "$TEMP_DIR/i3-source"
  mkdir build && cd build
  meson setup .. --buildtype=release
  ninja
  sudo ninja install
  sudo cp "$TEMP_DIR/i3-source/share/xsessions/i3.desktop" /usr/share/xsessions/i3.desktop || true
else
  info "i3 is up to date ($LATEST_I3)."
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
