import glob
import os
import random

from libqtile import bar, widget
from libqtile.config import Screen
from libqtile.lazy import lazy
from Xlib import display as xdisplay

from commands import Commands
from funcs import get_num_monitors


separator_defaults = dict(
    font="Victor Mono",
    fontsize=12,
    padding=0,
)


widget_defaults = dict(
    font="sans",
    fontsize=36,
    padding=3,
)
extension_defaults = widget_defaults.copy()


battery_widget_defaults = dict(
    format="{char}[{percent:0.1%}]  ",
    low_percentage=0.2,
    show_short_text=False,
    update_interval=5,
)

widget_list = [
    widget.GroupBox(
        active="#94e2d5",
        background="#181825",
        borderwidth=3,
        font="Ubuntu Bold",
        fontsize=9,
        foreground="#cba6f7",
        highlight_method="line",
        inactive="#b4befe",
        margin_x=0,
        margin_y=3,
        other_screen_border="#89b4fa",
        padding_x=3,
        padding_y=5,
        rounded=False,
        this_current_screen_border="#f38ba8",
        this_screen_border="#89b4fa",
    ),
    widget.CurrentLayout(foreground="#cba6f7", background="#181825"),
    widget.Spacer(),
    widget.WindowName(foreground="#94e2d5", background="#181825", padding=0),
    widget.Spacer(),
    widget.TextBox(
        background="#181825",
        font="Ubuntu Mono",
        fontsize=37,
        foreground="#fab387",
        padding=-4,
        text="",
    ),
    widget.Systray(background="#fab387", padding=3),
    widget.TextBox(
        background="#fab387",
        font="Ubuntu Mono",
        fontsize=37,
        foreground="#f38ba8",
        padding=-4,
        text="",
    ),
    widget.Net(
        background="#f38ba8",
        foreground="#181825",
        format="↓{down} ↑{up}",
        mouse_callbacks={"Button1": lazy.spawn(Commands.network)},
    ),
    widget.TextBox(
        background="#f38ba8",
        font="Ubuntu Mono",
        fontsize=37,
        foreground="#a6e3a1",
        padding=-4,
        text="",
    ),
    widget.Battery(
        fmt="   {}",
        background="#a6e3a1",
        foreground="#181825",
        format="{percent:0.1%}",
        mouse_callbacks={"Button1": lazy.spawn(Commands.battery)},
    ),
    widget.TextBox(
        background="#a6e3a1",
        font="Ubuntu Mono",
        fontsize=37,
        foreground="#74c7ec",
        padding=-4,
        text="",
    ),
    widget.TextBox(
        background="#74c7ec",
        fontsize=20,
        foreground="#181825",
        text="",
    ),
    widget.Volume(
        fmt="   {}",
        background="#74c7ec",
        foreground="#181825",
        get_volume_command="amixer sget Master".split(),
        mouse_callbacks={"Button1": lazy.spawn(Commands.volume)},
        mute_command="amixer sset 'Master' toggle".split(),
        update_interval=0.2,
        volume_down_command="amixer sset Master 2%-".split(),
        volume_up_command="amixer sset Master 2%+".split(),
    ),
    widget.TextBox(
        background="#74c7ec",
        font="Ubuntu Mono",
        fontsize=37,
        foreground="#89b4fa",
        padding=-4,
        text="",
    ),
    widget.Backlight(
        fmt="   {}",
        background="#89b4fa",
        backlight_name="intel_backlight",
        foreground="#181825",
        mouse_callbacks={"Button1": lazy.spawn(Commands.backlight)},
    ),
    widget.TextBox(
        background="#89b4fa",
        font="Ubuntu Mono",
        fontsize=37,
        foreground="#b4befe",
        padding=-4,
        text="",
    ),
    widget.Clock(
        background="#b4befe",
        foreground="#181825",
        format="%A, %B %d - %H:%M ",
        mouse_callbacks={"Button1": lazy.spawn(Commands.time)},
    ),
]


screens = [
    Screen(
        top=bar.Bar(
            background="#181825",
            size=20,
            widgets=widget_list,
        ),
    ),
]


mon_num = get_num_monitors()
if mon_num > 1:
    for i in range(mon_num - 1):
        screens.append(
            Screen(
                top=bar.Bar(
                    [
                        widget.GroupBox(
                            active="#94e2d5",
                            background="#181825",
                            borderwidth=3,
                            font="Ubuntu Bold",
                            fontsize=9,
                            foreground="#cba6f7",
                            highlight_method="line",
                            inactive="#b4befe",
                            margin_x=0,
                            margin_y=3,
                            other_screen_border="#89b4fa",
                            padding_x=3,
                            padding_y=5,
                            rounded=False,
                            this_current_screen_border="#f38ba8",
                            this_screen_border="#89b4fa",
                        ),
                        widget.CurrentLayout(
                            foreground="#cba6f7", background="#181825"
                        ),
                        widget.Spacer(),
                        widget.WindowName(
                            foreground="#94e2d5", background="#181825", padding=0
                        ),
                        widget.Spacer(),
                        widget.TextBox(
                            background="#181825",
                            font="Ubuntu Mono",
                            fontsize=37,
                            foreground="#f38ba8",
                            padding=-4,
                            text="",
                        ),
                        widget.Net(
                            background="#f38ba8",
                            foreground="#181825",
                            format="↓{down} ↑{up}",
                            mouse_callbacks={"Button1": lazy.spawn(Commands.network)},
                        ),
                        widget.TextBox(
                            background="#f38ba8",
                            font="Ubuntu Mono",
                            fontsize=37,
                            foreground="#a6e3a1",
                            padding=-4,
                            text="",
                        ),
                        widget.Battery(
                            fmt="   {}",
                            background="#a6e3a1",
                            foreground="#181825",
                            format="{percent:0.1%}",
                            mouse_callbacks={"Button1": lazy.spawn(Commands.battery)},
                        ),
                        widget.TextBox(
                            background="#a6e3a1",
                            font="Ubuntu Mono",
                            fontsize=37,
                            foreground="#74c7ec",
                            padding=-4,
                            text="",
                        ),
                        widget.TextBox(
                            background="#74c7ec",
                            fontsize=20,
                            foreground="#181825",
                            text="",
                        ),
                        widget.Volume(
                            fmt="   {}",
                            background="#74c7ec",
                            foreground="#181825",
                            get_volume_command="amixer sget Master".split(),
                            mouse_callbacks={"Button1": lazy.spawn(Commands.volume)},
                            mute_command="amixer sset 'Master' toggle".split(),
                            update_interval=0.2,
                            volume_down_command="amixer sset Master 2%-".split(),
                            volume_up_command="amixer sset Master 2%+".split(),
                        ),
                        widget.TextBox(
                            background="#74c7ec",
                            font="Ubuntu Mono",
                            fontsize=37,
                            foreground="#89b4fa",
                            padding=-4,
                            text="",
                        ),
                        widget.Backlight(
                            fmt="   {}",
                            background="#89b4fa",
                            backlight_name="intel_backlight",
                            foreground="#181825",
                            mouse_callbacks={"Button1": lazy.spawn(Commands.backlight)},
                        ),
                        widget.TextBox(
                            background="#89b4fa",
                            font="Ubuntu Mono",
                            fontsize=37,
                            foreground="#b4befe",
                            padding=-4,
                            text="",
                        ),
                        widget.Clock(
                            background="#b4befe",
                            foreground="#181825",
                            format="%A, %B %d - %H:%M ",
                            mouse_callbacks={"Button1": lazy.spawn(Commands.time)},
                        ),
                    ],
                    20,
                    background="#181825",
                )
            ),
        )
