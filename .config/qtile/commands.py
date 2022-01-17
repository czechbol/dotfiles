import os

from libqtile.utils import guess_terminal

config = os.path.expanduser("~/.config/")
rofi = config + "rofi/bin"


class Commands(object):
    """Just a helper object for my macros and widgets."""

    browser = "vivaldi"
    terminal = guess_terminal()
    lock = "betterlockscreen -l base --off 30 --span"
    files = "nemo"
    editor = "code"
    launcher = f"{rofi}/launcher_misc"
    powermenu = f"{rofi}/applet_powermenu"
    network = f"{rofi}/applet_network"
    battery = f"{rofi}/applet_battery"
    backlight = f"{rofi}/applet_backlight"
    volume = f"{rofi}/applet_volume"
    screenshot = f"{rofi}/applet_screenshot"
    time = f"{rofi}/applet_time"
