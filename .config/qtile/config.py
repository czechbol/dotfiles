# Copyright (c) 2010 Aldo Cortesi
# Copyright (c) 2010, 2014 dequis
# Copyright (c) 2012 Randall Ma
# Copyright (c) 2012-2014 Tycho Andersen
# Copyright (c) 2012 Craig Barnes
# Copyright (c) 2013 horsik
# Copyright (c) 2013 Tao Sauvage
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

import os
import subprocess
from typing import List  # noqa: F401

from libqtile import bar, layout, widget, hook
from libqtile.config import Click, Drag, Group, Key, Match, Screen
from libqtile.lazy import lazy
from libqtile.utils import guess_terminal

mod = "mod4"

config = os.path.expanduser("~/.config/")
rofi = config + "rofi/bin/"


class Commands(object):
    browser = "vivaldi"
    terminal = guess_terminal()
    lock = "betterlockscreen -l base --off 30 --span"
    files = "nemo"
    editor = "code"
    launcher = "launcher_misc"
    powermenu = "applet_powermenu"
    network = "applet_network"
    battery = "applet_battery"
    backlight = "applet_backlight"
    volume = "applet_volume"
    screenshot = "applet_screenshot"
    time = "applet_time"

    autostart = [browser, terminal, files]


keys = [
    # A list of available commands that can be bound to keys can be found
    # at https://docs.qtile.org/en/latest/manual/config/lazy.html
    #
    # Toggle between different layouts as defined below
    Key([mod], "Tab", lazy.next_layout(), desc="Toggle between layouts"),
    Key([mod, "shift"], "q", lazy.window.kill(), desc="Kill focused window"),
    Key([mod, "shift"], "r", lazy.reload_config(), desc="Reload the config"),
    Key(
        [mod, "shift"],
        "e",
        lazy.spawn(rofi + Commands.powermenu),
        desc="Spawn rofi powermenu",
    ),
    Key(
        [mod],
        "d",
        lazy.spawn(rofi + Commands.launcher),
        desc="Spawn rofi launcher",
    ),
    Key(
        [mod],
        "f",
        lazy.spawn(Commands.files),
        desc="Spawn files app",
    ),
    Key(
        [mod],
        "b",
        lazy.spawn(Commands.browser),
        desc="Spawn browser app",
    ),
    Key(
        [mod],
        "c",
        lazy.spawn(Commands.editor),
        desc="Spawn editor app",
    ),
    Key(
        [mod],
        "l",
        lazy.spawn(Commands.lock),
        desc="Lock the screen",
    ),
    Key(
        [],
        "Print",
        lazy.spawn(rofi + Commands.screenshot),
        desc="Spawn a rofi screenshot menu",
    ),
    #
    # Toggle between split and unsplit sides of stack.
    # Split = all windows displayed
    # Unsplit = 1 window displayed, like Max layout, but still with
    # multiple stack panes
    Key(
        [mod, "shift"],
        "Return",
        lazy.layout.toggle_split(),
        desc="Toggle between split and unsplit sides of stack",
    ),
    Key([mod], "Return", lazy.spawn(Commands.terminal), desc="Launch terminal"),
    #
    # Switch between windows
    Key([mod], "Left", lazy.layout.left(), desc="Move focus to left"),
    Key([mod], "Right", lazy.layout.right(), desc="Move focus to right"),
    Key([mod], "Down", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "Up", lazy.layout.up(), desc="Move focus up"),
    Key([mod], "space", lazy.layout.next(), desc="Move window focus to other window"),
    # Move windows between left/right columns or move up/down in current stack.
    # Moving out of range in Columns layout will create new column.
    Key(
        [mod, "shift"],
        "Left",
        lazy.layout.shuffle_left(),
        desc="Move window to the left",
    ),
    Key(
        [mod, "shift"],
        "Right",
        lazy.layout.shuffle_right(),
        desc="Move window to the right",
    ),
    Key([mod, "shift"], "Down", lazy.layout.shuffle_down(), desc="Move window down"),
    Key([mod, "shift"], "Up", lazy.layout.shuffle_up(), desc="Move window up"),
    # Grow windows. If current window is on the edge of screen and direction
    # will be to screen edge - window would shrink.
    Key(
        [mod, "control"],
        "Left",
        lazy.layout.grow_left(),
        desc="Grow window to the left",
    ),
    Key(
        [mod, "control"],
        "Right",
        lazy.layout.grow_right(),
        desc="Grow window to the right",
    ),
    Key([mod, "control"], "Down", lazy.layout.grow_down(), desc="Grow window down"),
    Key([mod, "control"], "Up", lazy.layout.grow_up(), desc="Grow window up"),
    Key([mod], "n", lazy.layout.normalize(), desc="Reset all window sizes"),
    # Audio controls with amixer
    Key([], "XF86AudioMute", lazy.spawn("amixer sset 'Master' toggle")),
    Key([], "XF86AudioLowerVolume", lazy.spawn("amixer sset 'Master' 5%-")),
    Key([], "XF86AudioRaiseVolume", lazy.spawn("amixer sset 'Master' 5%+")),
    # Screen brightness controls with brightnessctl
    Key([], "XF86MonBrightnessUp", lazy.spawn("brightnessctl -q set +5%")),
    Key([], "XF86MonBrightnessDown", lazy.spawn("brightnessctl -q set 5%-")),
    # Screen brightness controls with brightnessctl
    Key(
        ["shift"],
        "XF86MonBrightnessUp",
        lazy.spawn("brightnessctl --device='tpacpi::kbd_backlight' -q set +1"),
    ),
    Key(
        ["shift"],
        "XF86MonBrightnessDown",
        lazy.spawn("brightnessctl --device='tpacpi::kbd_backlight' -q set 1-"),
    ),
]

groups = [
    Group("DEV", layout="monadtall"),
    Group("WWW", layout="monadtall"),
    Group("SYS", layout="monadtall"),
    Group("DOC", layout="monadtall"),
    Group("CHAT", layout="monadtall"),
    Group("MUS", layout="monadtall"),
    Group("VID", layout="monadtall"),
    Group("GFX", layout="floating"),
]

layouts = [
    layout.MonadTall(
        margin=10,
        single_margin=0,
        border_focus="e1acff",
        border_normal="1D2330",
    ),
    layout.Max(),
    layout.Bsp(
        margin=10,
        single_margin=0,
        border_focus="e1acff",
        border_normal="1D2330",
    ),
    layout.Stack(
        num_stacks=2,
        margin=10,
        single_margin=0,
        border_focus="e1acff",
        border_normal="1D2330",
    ),
    layout.RatioTile(
        margin=10,
        single_margin=0,
        border_focus="e1acff",
        border_normal="1D2330",
    ),
    layout.Floating(),
    # layout.MonadWide(**layout_theme),
    # layout.Stack(stacks=2, **layout_theme),
    # layout.Columns(**layout_theme),
    # layout.RatioTile(**layout_theme),
    # layout.Tile(shift_windows=True, **layout_theme),
    # layout.VerticalTile(**layout_theme),
    # layout.Matrix(**layout_theme),
    # layout.Zoomy(**layout_theme),
]

widget_defaults = dict(
    font="sans",
    fontsize=12,
    padding=3,
)
extension_defaults = widget_defaults.copy()


def get_bar():
    return bar.Bar(
        [
            widget.Sep(
                linewidth=0, padding=6, foreground="bb9af7", background="1a1b26"
            ),
            widget.GroupBox(
                font="Ubuntu Bold",
                fontsize=9,
                margin_y=3,
                margin_x=0,
                padding_y=5,
                padding_x=3,
                borderwidth=3,
                active="73daca",
                inactive="7aa2f7",
                rounded=False,
                this_current_screen_border="bf616a",
                highlight_method="line",
                highlight_color=["2e3440", "2e3440"],
                this_screen_border="2ac3de",
                other_current_screen_border="9aa5ce",
                other_screen_border="colors",
                foreground="bb9af7",
                background="1a1b26",
            ),
            widget.CurrentLayout(foreground="bb9af7", background="1a1b26"),
            widget.Spacer(),
            widget.TextBox(
                text="",
                font="Ubuntu Mono",
                background="1a1b26",
                foreground="f7768e",
                padding=0,
                fontsize=37,
            ),
            widget.TextBox(
                text="",
                foreground="1a1b26",
                background="f7768e",
                mouse_callbacks={"Button1": lazy.spawn(rofi + Commands.network)},
            ),
            widget.TextBox(
                text="",
                font="Ubuntu Mono",
                background="f7768e",
                foreground="73daca",
                padding=0,
                fontsize=37,
            ),
            widget.TextBox(
                text="",
                foreground="1a1b26",
                background="73daca",
            ),
            widget.Battery(
                foreground="1a1b26",
                background="73daca",
                format="{percent:0.1%}",
                mouse_callbacks={"Button1": lazy.spawn(rofi + Commands.battery)},
            ),
            widget.TextBox(
                text="",
                font="Ubuntu Mono",
                background="73daca",
                foreground="7dcfff",
                padding=0,
                fontsize=37,
            ),
            widget.TextBox(
                text="",
                foreground="1a1b26",
                background="7dcfff",
            ),
            widget.Volume(
                foreground="1a1b26",
                background="7dcfff",
                update_interval=0.2,
                mute_command="amixer sset 'Master' toggle".split(),
                volume_up_command="amixer sset Master 2%+".split(),
                volume_down_command="amixer sset Master 2%-".split(),
                get_volume_command="amixer sget Master".split(),
                mouse_callbacks={"Button1": lazy.spawn(rofi + Commands.volume)},
            ),
            widget.TextBox(
                text="",
                font="Ubuntu Mono",
                background="7dcfff",
                foreground="7aa2f7",
                padding=0,
                fontsize=37,
            ),
            widget.TextBox(
                text="",
                foreground="1a1b26",
                background="7aa2f7",
            ),
            widget.Backlight(
                foreground="1a1b26",
                background="7aa2f7",
                backlight_name="intel_backlight",
                mouse_callbacks={"Button1": lazy.spawn(rofi + Commands.backlight)},
            ),
            widget.TextBox(
                text="",
                font="Ubuntu Mono",
                background="7aa2f7",
                foreground="bb9af7",
                padding=0,
                fontsize=37,
            ),
            widget.TextBox(
                text="",
                foreground="1a1b26",
                background="bb9af7",
            ),
            widget.Clock(
                format="%A, %B %d - %H:%M ",
                foreground="1a1b26",
                background="bb9af7",
                mouse_callbacks={"Button1": lazy.spawn(rofi + Commands.time)},
            ),
        ],
        20,
        background="1a1b26",
    )


screens = [
    Screen(top=get_bar()),
    Screen(top=get_bar()),
    Screen(top=get_bar()),
    Screen(top=get_bar()),
    Screen(top=get_bar()),
    Screen(top=get_bar()),
]

# Drag floating layouts.
mouse = [
    Drag(
        [mod],
        "Button1",
        lazy.window.set_position_floating(),
        start=lazy.window.get_position(),
    ),
    Drag(
        [mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()
    ),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]

dgroups_key_binder = None
dgroups_app_rules = []  # type: List
follow_mouse_focus = True
bring_front_click = False
cursor_warp = False
floating_layout = layout.Floating(
    float_rules=[
        # Run the utility of `xprop` to see the wm class and name of an X client.
        *layout.Floating.default_float_rules,
        Match(wm_class="confirmreset"),  # gitk
        Match(wm_class="makebranch"),  # gitk
        Match(wm_class="maketag"),  # gitk
        Match(wm_class="ssh-askpass"),  # ssh-askpass
        Match(title="branchdialog"),  # gitk
        Match(title="pinentry"),  # GPG key password entry
    ]
)
auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True

# If things like steam games want to auto-minimize themselves when losing
# focus, should we respect this or not?
auto_minimize = True


@hook.subscribe.startup_complete
def start_once():
    home = os.path.expanduser("~")
    subprocess.call([home + "/.config/qtile/autostart.sh"])


# XXX: Gasp! We're lying here. In fact, nobody really uses or cares about this
# string besides java UI toolkits; you can see several discussions on the
# mailing lists, GitHub issues, and other WM documentation that suggest setting
# this string if your java app doesn't work correctly. We may as well just lie
# and say that we're a working one by default.
#
# We choose LG3D to maximize irony: it is a 3D non-reparenting WM written in
# java that happens to be on java's whitelist.
wmname = "LG3D"
