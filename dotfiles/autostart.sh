#!/bin/bash

# DWM Autostart Script
# This script is executed automatically when DWM starts

# Start slstatus (status bar) if not already running
pgrep -x slstatus > /dev/null || slstatus &

# Start picom (compositor) if not already running
pgrep -x picom > /dev/null || picom -b --backend glx --vsync &

# Start xfce4-clipman (clipboard manager) if not already running
pgrep -x xfce4-clipman > /dev/null || xfce4-clipman --daemon &

# Set wallpaper using feh
feh --bg-scale ~/dwm-mint/wallpaper/eva-dark.png 2>/dev/null &

# Start Cinnamon settings daemon for X settings
pgrep -x csd-xsettings > /dev/null || /usr/bin/csd-xsettings &

# Start Cinnamon cursor settings daemon
pgrep -x csd-cursor > /dev/null || /usr/bin/csd-cursor &

