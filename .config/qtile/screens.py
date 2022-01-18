import copy

from libqtile import bar, widget
from libqtile.config import Screen
from libqtile.lazy import lazy
from Xlib import display as xdisplay

from commands import Commands

# Solarized light
theme = dict(
    base03="002b36",
    base02="073642",
    base01="586e75",
    base00="657b83",
    base0="839496",
    base1="93a1a1",
    base2="eee8d5",
    base3="fdf6e3",
    yellow="b58900",
    orange="cb4b16",
    red="dc322f",
    magenta="d33682",
)

separator_defaults = dict(
    font="Victor Mono",
    fontsize=24,
    padding=0,
)


widget_defaults = dict(
    font="sans",
    fontsize=12,
    padding=3,
)
extension_defaults = widget_defaults.copy()


battery_widget_defaults = dict(
    format="{char}[{percent:2.0%}]  ",
    low_percentage=0.2,
    update_interval=5,
    show_short_text=False,
)

widget_list = [
    widget.GroupBox(
        active="73daca",
        background="1a1b26",
        borderwidth=3,
        font="Ubuntu Bold",
        fontsize=9,
        foreground="bb9af7",
        highlight_color=["000000", "2e3440"],
        highlight_method="line",
        inactive="7aa2f7",
        margin_x=0,
        margin_y=3,
        other_current_screen_border="9aa5ce",
        other_screen_border="2ac3de",
        padding_x=3,
        padding_y=5,
        rounded=False,
        this_current_screen_border="bf616a",
        this_screen_border="2ac3de",
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
        mouse_callbacks={"Button1": lazy.spawn(Commands.network)},
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
        mouse_callbacks={"Button1": lazy.spawn(Commands.battery)},
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
        mouse_callbacks={"Button1": lazy.spawn(Commands.volume)},
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
        mouse_callbacks={"Button1": lazy.spawn(Commands.backlight)},
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
        mouse_callbacks={"Button1": lazy.spawn(Commands.time)},
    ),
]

screens = [
    Screen(
        top=bar.Bar(
            widget_list,
            20,
            background="1a1b26",
        ),
    ),
]


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


mon_num = get_num_monitors()
if mon_num > 1:
    for i in range(mon_num - 1):
        screens.append(
            Screen(
                top=bar.Bar(
                    [
                        widget.GroupBox(
                            active="73daca",
                            background="1a1b26",
                            borderwidth=3,
                            font="Ubuntu Bold",
                            fontsize=9,
                            foreground="bb9af7",
                            highlight_color=["000000", "2e3440"],
                            highlight_method="line",
                            inactive="7aa2f7",
                            margin_x=0,
                            margin_y=3,
                            other_current_screen_border="9aa5ce",
                            other_screen_border="2ac3de",
                            padding_x=3,
                            padding_y=5,
                            rounded=False,
                            this_current_screen_border="bf616a",
                            this_screen_border="2ac3de",
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
                            mouse_callbacks={"Button1": lazy.spawn(Commands.network)},
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
                            mouse_callbacks={"Button1": lazy.spawn(Commands.battery)},
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
                            mouse_callbacks={"Button1": lazy.spawn(Commands.volume)},
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
                            mouse_callbacks={"Button1": lazy.spawn(Commands.backlight)},
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
                            mouse_callbacks={"Button1": lazy.spawn(Commands.time)},
                        ),
                    ],
                    20,
                    background="1a1b26",
                ),
            ),
        )
