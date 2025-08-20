#!/bin/bash

# Check if wofi is running
if pgrep -x "wofi" > /dev/null; then
    pkill -x wofi
else
    wofi --show drun &
fi

