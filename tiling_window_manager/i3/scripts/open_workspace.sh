#!/usr/bin/env bash

TARGET_WS=$1
if [[ -z "$TARGET_WS" ]]; then
  exit 1
fi

# Check if the workspace actually exists in the current list
WS_DATA=$(i3-msg -t get_workspaces | jq -e ".[] | select(.num == $TARGET_WS)")
WS_EXISTS=$? # 0 if found, 1 if not

# Check if the workspace has windows
HAS_WINDOWS=$(i3-msg -t get_tree | jq -r "
  .. | select(.type? == \"workspace\" and .num? == $TARGET_WS) | 
  ((.nodes | length > 0) or (.floating_nodes | length > 0))
")

if [[ $WS_EXISTS -eq 0 && "$HAS_WINDOWS" == "true" ]]; then
  i3-msg "workspace $TARGET_WS"
elif [[ $WS_EXISTS -eq 0 && "$HAS_WINDOWS" == "false" ]]; then
  i3-msg "workspace $TARGET_WS; move workspace to output primary"
else
  # Workspace does not exist yet: Open it on primary
  i3-msg "focus output primary; workspace $TARGET_WS"
fi
