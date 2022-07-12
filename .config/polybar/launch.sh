#!/bin/bash
while getopts b: flag
do
  case "${flag}" in
    b) bar="$OPTARG" ;;
  esac
done

# Terminate already running bar instances
killall -q polybar
# If all your bars have ipc enabled, you can also use
# polybar-msg cmd quit

# Launch Polybar, using default config location ~/.config/polybar/config.ini
for m in $(polybar --list-monitors | cut -d":" -f1); do
  MONITOR=$m polybar --reload $bar &
done

echo "Polybar launched..."