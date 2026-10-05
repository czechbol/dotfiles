#!/usr/bin/env bash
# Claude Code hook: mirrors agent state into the tmux window name (● waiting, ✓ done, … working).
[ -n "$TMUX_PANE" ] || exit 0

event=$(jq -r '.hook_event_name // empty')

case "$event" in
  UserPromptSubmit|PostToolUse) state="…" ;;
  Notification|PermissionRequest) state="●" ;;
  Stop) state="✓" ;;
  SessionEnd) tmux set -w -t "$TMUX_PANE" -u @agent; exit 0 ;;
  *) exit 0 ;;
esac

tmux set -w -t "$TMUX_PANE" @agent "$state"
