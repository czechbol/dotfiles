#!/usr/bin/env bash
# `hyprctl dispatch` takes hyprlang dispatcher syntax under the legacy config
# manager and a Lua expression under the Lua one (Hyprland >= 0.56), so scripts
# that shell out to it need to know which parser is live. `eval` is Lua-only and
# answers that in one call.
set -euo pipefail

action="${1:-}"

is_legacy() {
    hyprctl eval 'return 1' 2>/dev/null | grep -q 'only supported with the lua'
}

if is_legacy; then
    case "$action" in
        killactive) exec hyprctl dispatch killactive "" ;;
        dpms-on)    exec hyprctl dispatch dpms on ;;
        dpms-off)   exec hyprctl dispatch dpms off ;;
        exit)       exec hyprctl dispatch exit ;;
    esac
else
    case "$action" in
        killactive) exec hyprctl dispatch 'hl.dsp.window.close()' ;;
        dpms-on)    exec hyprctl dispatch 'hl.dsp.dpms({ action = "on" })' ;;
        dpms-off)   exec hyprctl dispatch 'hl.dsp.dpms({ action = "off" })' ;;
        exit)       exec hyprctl dispatch 'hl.dsp.exit()' ;;
    esac
fi

echo "hypr-dispatch: unknown action: ${action}" >&2
exit 1
