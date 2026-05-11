#!/usr/bin/env bash

if pgrep -x "i3lock" > /dev/null; then
    exit 0
fi

# Nord Colors
night0="2e3440"
night3="4c566a"
snow0="d8dee9"
frost0="8fbcbb"
frost2="88c0d0"
aurora0="bf616a" # Red for errors

i3lock \
  --blur 7 \
  --clock \
  --indicator \
  --time-str="%H:%M:%S" \
  --date-str="%A, %d %B" \
  --time-size=90 \
  --date-size=60 \
  --time-pos="ix:iy-20" \
  --date-pos="ix:iy+60" \
  --insidever-color="${frost2}33" \
  --insidewrong-color="${aurora0}33" \
  --inside-color="${night0}ff" \
  --ringver-color="${frost2}ff" \
  --ringwrong-color="${aurora0}ff" \
  --ring-color="${night3}ff" \
  --keyhl-color="${frost0}ff" \
  --bshl-color="${aurora0}ff" \
  --time-color="${snow0}ff" \
  --date-color="${night3}ff" \
  --layout-color="${frost2}ff" \
  --verif-color="${frost2}ff" \
  --wrong-color="${aurora0}ff" \
  --radius 270 \
  --ring-width 20 \
  --screen 1 \
  --force-focus \
  --nofork

