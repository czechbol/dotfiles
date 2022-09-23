import os
import glob
import random
import subprocess

from libqtile import hook


def get_num_monitors():
    num_monitors = 0
    try:
        display = xdisplay.Display()
        screen = display.screen()
        resources = screen.root.xrandr_get_screen_resources()

        for output in resources.outputs:
            monitor = display.xrandr_get_output_info(output, resources.config_timestamp)
            preferred = False
            if hasattr(monitor, "preferred"):
                preferred = monitor.preferred
            elif hasattr(monitor, "num_preferred"):
                preferred = monitor.num_preferred
            if preferred:
                num_monitors += 1
    except Exception as e:
        # always setup at least one monitor
        return 1
    else:
        return num_monitors


@hook.subscribe.startup_complete
def start_once():
    home = os.path.expanduser("~")
    subprocess.call([home + "/.config/qtile/autostart.sh"])


@hook.subscribe.startup_complete
def screen_change():
    home = os.path.expanduser("~")
    mon_num = get_num_monitors()
    cmd_str = ["betterlockscreen"]
    avogadr_files = glob.glob(
        f"{home}/Pictures/backgrounds/desktop/tokyo-night/*/1920x1080/**/*.png"
    )
    other_files = glob.glob(
        f"{home}/Pictures/backgrounds/desktop/tokyo-night/*/1920x1080/*.png"
    )
    for i in range(mon_num):
        cmd_str.extend(
            ["-u", random.choice(random.choice([avogadr_files, other_files]))]
        )
    subprocess.call(cmd_str)


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
