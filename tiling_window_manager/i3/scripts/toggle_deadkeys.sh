#!/usr/bin/env bash

CURRENT_VARIANT=$(setxkbmap -query | grep variant | awk '{print $2}')

if setxkbmap -query | grep -q "nodeadkeys"; then
  # Currently "nodeadkeys" -> Switch to Standard Spanish
  setxkbmap -layout es
  notify-send "Keyboard Deadkeys active" -t 2000
else
  # Currently Standard -> Switch to No Deadkeys
  setxkbmap -layout es -variant nodeadkeys
  notify-send "Keyboard Deadkeys inactive" -t 2000
fi
