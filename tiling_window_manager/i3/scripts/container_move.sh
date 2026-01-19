#!/usr/bin/env bash

DIRECTION=$1 # direction: next/prev
MONITOR_COUNT=$(i3-msg -t get_outputs | jq 'map(select(.active == true)) | length')

if [[ "$MONITOR_COUNT" -le 1 ]]; then
  exit 0
fi

if [[ "$DIRECTION" == "next" ]]; then
  i3-msg "move container to output right"
else
  i3-msg "move container to output left"
fi
