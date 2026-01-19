#!/usr/bin/env bash

# Get list of connected monitors
mapfile -t MONITORS < <(xrandr | grep " connected" | awk '{print $1}')

declare -A RESOLUTIONS

# Calculate pixels (Resolution area)
for MON in "${MONITORS[@]}"; do
  # Get the preferred resolution (usually the first one listed)
  RES=$(xrandr | grep -A1 "^$MON connected" | tail -n1 | awk '{print $1}')

  # Safety check: ensure we actually got a resolution (e.g., 1920x1080)
  if [[ ! $RES =~ [0-9]+x[0-9]+ ]]; then
    continue
  fi

  WIDTH=$(cut -d'x' -f1 <<<"$RES")
  HEIGHT=$(cut -d'x' -f2 <<<"$RES")
  PIXELS=$((WIDTH * HEIGHT))
  RESOLUTIONS["$MON"]=$PIXELS
done

# Find the Primary (Largest Area)
PRIMARY_MONITOR=$(for MON in "${!RESOLUTIONS[@]}"; do
  echo "${RESOLUTIONS[$MON]} $MON"
done | sort -nr | head -n1 | awk '{print $2}')

# Apply xrandr logic
# First, set the primary
xrandr --output "$PRIMARY_MONITOR" --primary --auto

# Loop through others and place them to the right, sequentially
CURRENT_REF="$PRIMARY_MONITOR"

for MON in "${MONITORS[@]}"; do
  if [ "$MON" != "$PRIMARY_MONITOR" ]; then
    xrandr --output "$MON" --auto --right-of "$CURRENT_REF"
    # Update reference so the next monitor goes to the right of THIS one
    CURRENT_REF="$MON"
  fi
done

# Monitor disconnect scenario: move workspaces to primary if belonged to an inactive output
ACTIVE_MONITORS_PATTERN=$(printf "|%s" "${MONITORS[@]}")
ACTIVE_MONITORS_PATTERN=${ACTIVE_MONITORS_PATTERN:1} # remove leading pipe

i3-msg -t get_workspaces | jq -r ".[] | select(.output | test(\"$ACTIVE_MONITORS_PATTERN\") | not) | .name" | while read -r WS_NAME; do
  if [[ -n "$WS_NAME" ]]; then
    i3-msg "workspace $WS_NAME; move workspace to output $PRIMARY_MONITOR"
  fi
done
