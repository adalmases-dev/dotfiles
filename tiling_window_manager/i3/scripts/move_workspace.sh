#!/usr/bin/env bash

# Useless for single monitor
MONITOR_COUNT=$(i3-msg -t get_outputs | jq 'map(select(.active == true)) | length')
if [[ "$MONITOR_COUNT" -le 1 ]]; then
  exit 0
fi

# Only move workspace if not empty
CURRENT_WS=$(i3-msg -t get_workspaces | jq -r '.[] | select(.focused==true) | .name')
HAS_WINDOWS=$(i3-msg -t get_tree | jq -r "
  .. | select(.type? == \"workspace\" and .name? == \"$CURRENT_WS\") | 
  ((.nodes | length > 0) or (.floating_nodes | length > 0))
")

if [[ "$HAS_WINDOWS" == "true" ]]; then
  PRIMARY_MON_NAME=$(i3-msg -t get_outputs | jq -r '.[] | select(.primary==true) | .name')
  i3-msg "move workspace to output next"
fi
