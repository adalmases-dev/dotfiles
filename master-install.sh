#!/usr/bin/env bash

set -e

CURRENT_DIR="$(pwd)"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for dir in "$ROOT_DIR"/*; do
  if [[ -d $dir && -f "$dir/install.sh" ]]; then
    bash "$dir/install.sh"
  fi
done

cd "$CURRENT_DIR"
