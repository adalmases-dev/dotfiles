#!/usr/bin/env bash

set -e

CURRENT_DIR="$(pwd)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR_ROOT="$(dirname "$SCRIPT_DIR")"

source "$DOTFILES_DIR_ROOT/utils.sh"

info "Installing other software tools..."

# Install Peek - Screen recorder
sudo apt-get update -qq
sudo apt-get install -y peek

# Install Mouseless
MOUSELESS_BIN_PATH="/usr/local/bin/mouseless"
LATEST_MOUSELESS=$(get_latest_github_tag "jbensmann/mouseless")
CURRENT_MOUSELESS=$(get_current_version_tag "mouseless")
GLOBAL_CONFIG_DIR="/opt/mouseless"

if ! has_command "mouseless" || is_update_required "$CURRENT_MOUSELESS" "$LATEST_MOUSELESS"; then
  info "Installing/Updating Mouseless ($LATEST_MOUSELESS)..."

  DOWNLOAD_URL="https://github.com/jbensmann/mouseless/releases/latest/download/mouseless_linux_amd64.tar.gz"
  TEMP_DIR=$(mktemp -d)
  trap 'rm -rf "$TEMP_DIR"; cd "$CURRENT_DIR"' EXIT

  cd "$TEMP_DIR"
  curl -sLO "$DOWNLOAD_URL"
  tar -xf mouseless_linux_amd64.tar.gz
  sudo install -Dm755 "mouseless" "$MOUSELESS_BIN_PATH"

  # Set config as global
  if [ ! -f "$GLOBAL_CONFIG_DIR/config.yaml" ]; then
    sudo install -Dm644 "$SCRIPT_DIR/mouseless/config.yaml" "$GLOBAL_CONFIG_DIR/config.yaml"
  fi

  # Set system service
  sudo tee "/etc/systemd/system/mouseless.service" >/dev/null <<EOF
[Unit]
Description=mouseless (keyboard mouse) for %i

[Service]
  ExecStart=$MOUSELESS_BIN_PATH --config "$GLOBAL_CONFIG_DIR/config.yaml"

[Install]
WantedBy=multi-user.target
EOF

  # Make the system recognise it, and start on boot
  sudo systemctl daemon-reload
  sudo systemctl enable --now "mouseless.service"

  # Add Hot-plug Support (Restarts service when new keyboards connect/wake up)
  sudo tee "/etc/udev/rules.d/99-mouseless.rules" >/dev/null <<EOF
ACTION=="add", SUBSYSTEM=="input", RUN+="/usr/bin/systemctl try-restart mouseless@*.service"
EOF
  sudo udevadm control --reload-rules
  success "Mouseless $LATEST_MOUSELESS installed successfully!"

else
  info "Mouseless is up to date ($LATEST_MOUSELESS). Updating /etc/mouseless/config.yaml just in case."
  sudo install -Dm644 "$SCRIPT_DIR/mouseless/config.yaml" "$GLOBAL_CONFIG_DIR/config.yaml"
  sudo systemctl restart "mouseless.service"
fi

# Symlink configurations (just so mouseless can find user config)
mkdir -p "$HOME/.config"

LINK_PLAN=()
for dir in "$SCRIPT_DIR"/*; do
  if [[ -d "$dir" ]]; then
    dir_name=$(basename "$dir")
    if [[ "$dir_name" == "mouseless" ]]; then continue; fi
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

cd "$CURRENT_DIR"

success "Other software installation complete!"
