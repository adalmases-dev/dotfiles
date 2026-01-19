#!/usr/bin/env bash

set -e

CURRENT_DIR="$(pwd)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR_ROOT="$(dirname "$SCRIPT_DIR")"

source "$DOTFILES_DIR_ROOT/utils.sh"

info "Installing Terminal Emulator and CLI tools..."

# Ensure rust (defined in utils.sh) here as used
ensure_rust

# Global Temp Directory for the whole script
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"; cd "$CURRENT_DIR"' EXIT
cd "$TEMP_DIR"

# Install build prerequisites, dependencies and tmux:
# Install tmux (Apt-based)
sudo apt-get update -qq
sudo apt-get install -y curl git build-essential tmux cmake g++ pkg-config libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev python3

# Install alacritty
ALACRITTY_BIN_PATH="/usr/local/bin/alacritty" # Install will be placed here
LATEST_ALACRITTY=$(get_latest_github_tag "alacritty/alacritty")
CURRENT_ALACRITTY=$(get_current_version_tag "alacritty")

if ! has_command "alacritty" || is_update_required "$CURRENT_ALACRITTY" "$LATEST_ALACRITTY"; then
  info "Installing/Updating Alacritty ($LATEST_ALACRITTY)..."
  rustup update stable
  git clone --depth 1 --branch "$LATEST_ALACRITTY" https://github.com/alacritty/alacritty.git

  cargo build --release --manifest-path alacritty/Cargo.toml
  sudo install -Dm755 alacritty/target/release/alacritty "$ALACRITTY_BIN_PATH"

  # Set terminfo (for ssh/nvim)
  if ! infocmp alacritty >/dev/null 2>&1; then
    sudo tic -xe alacritty, alacritty-direct alacritty/extra/alacritty.info
  fi

  # bash completions
  sudo install -Dm644 alacritty/extra/completions/alacritty.bash /usr/share/bash_completion/completions/alacritty
else
  info "Alacritty is up to date ($LATEST_ALACRITTY)"
fi

# USER ONLY local terminal setting
mkdir -p "$HOME/.local/bin"
ln -sfn "$ALACRITTY_BIN_PATH" "$HOME/.local/bin/x-terminal-emulator"

# # Global system level setting
# # CURRENT_TERM=$(update-alternatives --display x-terminal-emulator 2>/dev/null | grep "link currently points to" | awk '{print $NF}' || echo "")
# # if [[ "$CURRENT_TERM" != "$BIN_PATH ]]; then
# #   sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator "$BINPATH" 50
# #   sudo update-alternatives --set x-terminal-emulator "$BIN_PATH"
# # fi

# Install starship
LATEST_STARSHIP=$(get_latest_github_tag "starship/starship")
CURRENT_STARSHIP=$(get_current_version_tag "starship")
if ! has_command "starship" || is_update_required "$CURRENT_STARSHIP" "$LATEST_STARSHIP"; then
  info "Installing/Updating starship ($LATEST_STARSHIP)..."
  curl -sS https://starship.rs/install.sh | sh -s -- --yes >/dev/null
else
  info "Starship is up to date ($LATEST_STARSHIP)."
fi

# Install fzf (Go-based)
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

# Install zoxide (Rust-based)
LATEST_ZOXIDE=$(get_latest_github_tag "ajeetdsouza/zoxide")
if ! has_command "zoxide" || is_update_required "$(zoxide --version | awk '{print $2}')" "$LATEST_ZOXIDE"; then
  info "Installing/Updating zoxide ($LATEST_ZOXIDE)..."
  curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh -s -- --bin-dir /usr/local/bin
else
  info "zoxide is up to date ($LATEST_ZOXIDE)."
fi

# Isolated Rust tools: ripgrep, eza, fd-find, bat

install_rust_tool "ripgrep" "BurntSushi/ripgrep" "rg"
install_rust_tool "eza" "eza-community/eza" "eza"
install_rust_tool "fd-find" "sharkdp/fd" "fd"
install_rust_tool "bat" "sharkdp/bat" "bat"
install_rust_tool "du-dust" "bootandy/dust" "dust"

# Symlink configurations
mkdir -p "$HOME/.config"

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
    # special case
    if [[ "$item" == "starship" ]]; then
      link_file "$SCRIPT_DIR/$item/starship.toml" "$HOME/.config/starship.toml"
      continue
    fi
    link_file "$SCRIPT_DIR/$item" "$HOME/.config/$item"
  done
fi

cd "$CURRENT_DIR"

success "Terminal Emulator and CLI tools installation complete!"
