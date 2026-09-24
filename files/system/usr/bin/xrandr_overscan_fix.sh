#!/bin/bash

if [ $# -lt 2 ]; then
    echo "Usage: $0 <output> <mode>"
    echo "Example: $0 HDMI-1 1920x1080"
    exit 1
fi

OUTPUT=$1
MODE=$2

xrandr --output "$OUTPUT" --set audio force-dvi --mode "$MODE"
