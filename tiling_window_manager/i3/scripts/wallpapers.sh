#!/usr/bin/env bash

WALLPAPER_DIR="$HOME/.config/i3/wallpapers/"
sleep 0.5 # small wait for screents to be ready on first start
feh --bg-fill "$(find "$WALLPAPER_DIR" -type f | shuf -n 1)"
