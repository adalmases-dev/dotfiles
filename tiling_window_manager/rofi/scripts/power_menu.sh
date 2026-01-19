#!/usr/bin/env bash

# Define icons and labels
lock="   Lock"
logout=" 󰍃  Logout"
suspend=" 󰒲  Suspend"
reboot="   Reboot"
shutdown="   Shutdown"

# Create the list for Rofi
options="$lock\n$suspend\n$logout\n$reboot\n$shutdown"

# Launch Rofi
chosen=$(
  echo -e "$options" | rofi -dmenu \
    -i \
    -p "󰠠  Power Menu" \
    -no-custom \
    -kb-filter-menu "" \
    -kb-row-up "Up,k" \
    -kb-row-down "Down,j" \
    -theme-str '
    @import "~/.config/rofi/color.rasi"
    
    window {
        width: 400px;
        border: 4px;
        border-color: @border;
        border-radius: 15px;
        background-color: @background;
        padding: 0;
    }

    mainbox {
        children: [ "inputbar", "listview" ];
        spacing: 0;
        background-color: @background;
    }

    inputbar {
        children: [ "prompt" ];
        border: 0 0 2 0;
        border-color: @border;
        background-color: @background;
    }

    prompt {
        background-color: transparent;
        text-color: @text;
        font: "Hack Nerd Font Bold 22";
        padding: 10 0 10 20; 
    }

    listview {
        border: 0;
        lines: 5;
        background-color: transparent;
        scrollbar: false;
        padding: 10 0 0 0; 
    }

    element {
        padding: 8 2 8 2;
        margin: 2 10 2 10; 
        background-color: transparent;
        text-color: @text;
        border-radius: 8;
    }
    
    element alternate.normal {
      background-color: transparent;
      text-color:       @text;
    }

    element selected {
        background-color: @background-selected;
        text-color: @text-selected;
        border: 0px 0px 0px 5px;
        border-color: @border; 
    }

    element-text {
        background-color: transparent;
        text-color: @text;
        vertical-align: 0.5;
        font: "Hack Nerd Font 18";
        padding: 0 0 0 0;
    }
  '
)

case $chosen in
$lock) i3lock-fancy ;;
$suspend) systemctl suspend ;;
$logout) i3-msg exit ;;
$reboot) systemctl reboot ;;
$shutdown) systemctl poweroff ;;
esac
