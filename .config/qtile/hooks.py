import glob
import os
import random
import subprocess

from libqtile import hook
from Xlib import display as xdisplay

from funcs import get_num_monitors, get_rand_wallpaper


def lock_update():
    home = os.path.expanduser("~")
    mon_num = get_num_monitors()
    cmd_str = ["betterlockscreen"]
    avogadr_files = glob.glob(
        f"{home}/Pictures/backgrounds/desktop/tokyo-night/**/1920x1080/**/*.png"
    )
    other_files = glob.glob(
        f"{home}/Pictures/backgrounds/desktop/tokyo-night/**/1920x1080/*.png"
    )
    for i in range(mon_num):
        cmd_str.extend(
            ["-u", random.choice(random.choice([avogadr_files, other_files]))]
        )
    subprocess.Popen(cmd_str)


@hook.subscribe.startup_once
def start_once():
    home = os.path.expanduser("~")
    subprocess.call([home + "/.config/qtile/autostart.sh"])
    subprocess.Popen(["/opt/piavpn/bin/pia-client"] + ["%u"] + ["--quiet"])


@hook.subscribe.startup
def on_startup():
    home = os.path.expanduser("~")
    subprocess.Popen(
        [
            "feh",
            "--recursive",
            "--randomize",
            "--bg-center",
            "--image-bg",
            "'#1e1e2e'",
            home + "/Pictures/backgrounds/desktop/catppuccin-wallpapers/",
        ]
    )


@hook.subscribe.screens_reconfigured
def screen_change():
    home = os.path.expanduser("~")
    mon_num = get_num_monitors()
    cmd_str = ["betterlockscreen"]

    for i in range(mon_num):
        cmd_str.extend(["-u", get_rand_wallpaper()])
    subprocess.Popen(cmd_str)
    subprocess.Popen(
        [
            "feh",
            "--recursive",
            "--randomize",
            "--bg-center",
            "--image-bg",
            "#1e1e2e",
            home + "/Pictures/backgrounds/desktop/catppuccin-wallpapers/",
        ]
    )


# Always display launcher in current group
@hook.subscribe.client_new
def albert_open(window):
    if window.name == "rofi":
        window.cmd_togroup()


@hook.subscribe.client_new
def floating_dialogs(window):
    dialog = window.window.get_wm_type() == "dialog"
    transient = window.window.get_wm_transient_for()
    if dialog or transient:
        window.floating = True
