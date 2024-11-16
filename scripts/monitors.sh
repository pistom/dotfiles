#!/bin/bash

# Get the list of connected monitors
CONNECTED_MONITORS=$(xrandr --listmonitors | grep '^[[:space:]]*[0-9]:' )

# Define your monitor setups
DELL_HOME_MONITOR="DP-2 3840/880x1600/370"
DELL_WORK_MONITOR="DP-2 2560/597x1440/336"
MSI_HOME_MONITOR="HDMI-0 3840/879x1600/366"

# Use tools like arandr to generate andr output command
if echo "$CONNECTED_MONITORS" | grep -q "$DELL_HOME_MONITOR"; then
    xrandr --output eDP-1 --primary --mode 1680x1050 --pos 0x1243 --rotate normal --output DP-1 --off --output HDMI-1 --off --output DP-2 --mode 3840x1600 --pos 1680x0 --rotate normal --output DP-3 --off --output DP-4 --off --output DP-5 --off
elif echo "$CONNECTED_MONITORS" | grep -q "$DELL_WORK_MONITOR"; then
    xrandr --output eDP-1 --primary --mode 1680x1050 --pos 2560x165 --rotate normal --output DP-1 --off --output HDMI-1 --off --output DP-2 --mode 2560x1440 --pos 0x0 --rotate normal --output DP-3 --off --output DP-4 --off --output DP-5 --off
elif echo "$CONNECTED_MONITORS" | grep -q "$MSI_HOME_MONITOR"; then
    xrandr --output HDMI-0 --primary --mode 3840x1600 --pos 1920x128 --rotate normal --output eDP-1-1 --mode 1920x1080 --pos 0x0 --rotate normal
else
    echo "Unknown monitor setup:"
    echo "$CONNECTED_MONITORS"
fi

