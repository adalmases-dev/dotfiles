#!/usr/bin/env bash

set -e

CURRENT_DIR="$(pwd)"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$ROOT_DIR/utils.sh"

for dir in "$ROOT_DIR"/*; do
  if [[ -d $dir && -f "$dir/install.sh" ]]; then
    dir_name=$(basename "$dir")
    PROMPT=$(echo -e "${YELLOW}Install '$dir_name' configuration [y/N]: ${NC}")
    read -r -p "$PROMPT" response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
      bash "$dir/install.sh"
    else
      info "Skipping '$dir_name' configuration."
    fi
    echo ""
  fi
done

cd "$CURRENT_DIR"
