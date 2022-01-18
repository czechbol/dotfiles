import os
import subprocess

from libqtile import hook


@hook.subscribe.startup_complete
def start_once():
    home = os.path.expanduser("~")
    subprocess.call([home + "/.config/qtile/autostart.sh"])


# Always display launcher in current group
# @hook.subscribe.client_new
# def albert_open(window):
#     if window.name == "rofi":
#         window.cmd_togroup()


# @hook.subscribe.client_new
# def floating_dialogs(window):
#     dialog = window.window.get_wm_type() == "dialog"
#     transient = window.window.get_wm_transient_for()
#     if dialog or transient:
#         window.floating = True
