#!/usr/bin/env bash

# Get monitors sorted by position (Left to Right)
MONITORS=$(i3-msg -t get_outputs | jq -r 'map(select(.active == true)) | sort_by(.rect.x) | .[].name')
readarray -t mon_array <<<"$MONITORS"

NUM_MONITORS=${#mon_array[@]}
if [[ $NUM_MONITORS -lt 2 ]]; then
  exit 0
fi

# Get visible workspaces
WORKSPACES=$(i3-msg -t get_workspaces | jq -r 'map(select(.visible == true)) | sort_by(.rect.x) | .[].name')
readarray -t ws_array <<<"$WORKSPACES"

# Move workspaces,
CMD=""
for i in "${!mon_array[@]}"; do
  WS="${ws_array[$i]}"
  NEXT_INDEX=$(((i + 1) % NUM_MONITORS))
  TARGET_MONITOR="${mon_array[$NEXT_INDEX]}"

  CMD+="workspace $WS; move workspace to output $TARGET_MONITOR; "
done
i3-msg "$CMD"

# force focus back to the workspace on the primary monitor
PRIMARY_MON_NAME=$(i3-msg -t get_outputs | jq -r '.[] | select(.primary==true) | .name')
PRIMARY_WS=$(i3-msg -t get_workspaces | jq -r ".[] | select(.output==\"$PRIMARY_MON_NAME\" and .visible==true) | .name")
i3-msg "workspace $PRIMARY_WS; forcus output $PRIMARY_MON_NAME"
