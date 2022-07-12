from libqtile import bar, widget
from libqtile.config import Screen
from libqtile.lazy import lazy
from Xlib import display as xdisplay

from commands import Commands


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
    widget.WindowName(foreground="b4f9f8", background="1a1b26", padding=0),
    widget.Spacer(),
    widget.TextBox(
        background="1a1b26",
        font="Ubuntu Mono",
        fontsize=37,
        foreground="ff9e64",
        padding=-4,
        text="",
    ),
    widget.Systray(background="ff9e64", padding=3),
    widget.TextBox(
        background="ff9e64",
        font="Ubuntu Mono",
        fontsize=37,
        foreground="f7768e",
        padding=-4,
        text="",
    ),
    widget.Net(
        background="f7768e",
        foreground="1a1b26",
        format="↓{down} ↑{up}",
        mouse_callbacks={"Button1": lazy.spawn(Commands.network)},
    ),
    widget.TextBox(
        background="f7768e",
        font="Ubuntu Mono",
        fontsize=37,
        foreground="73daca",
        padding=-4,
        text="",
    ),
    widget.Battery(
        fmt="   {}",
        background="73daca",
        foreground="1a1b26",
        format="{percent:0.1%}",
        mouse_callbacks={"Button1": lazy.spawn(Commands.battery)},
    ),
    widget.TextBox(
        background="73daca",
        font="Ubuntu Mono",
        fontsize=37,
        foreground="7dcfff",
        padding=-4,
        text="",
    ),
    widget.TextBox(
        background="7dcfff",
        fontsize=20,
        foreground="1a1b26",
        text="",
    ),
    widget.Volume(
        fmt="   {}",
        background="7dcfff",
        foreground="1a1b26",
        get_volume_command="amixer sget Master".split(),
        mouse_callbacks={"Button1": lazy.spawn(Commands.volume)},
        mute_command="amixer sset 'Master' toggle".split(),
        update_interval=0.2,
        volume_down_command="amixer sset Master 2%-".split(),
        volume_up_command="amixer sset Master 2%+".split(),
    ),
    widget.TextBox(
        background="7dcfff",
        font="Ubuntu Mono",
        fontsize=37,
        foreground="7aa2f7",
        padding=-4,
        text="",
    ),
    widget.Backlight(
        fmt="   {}",
        background="7aa2f7",
        backlight_name="intel_backlight",
        foreground="1a1b26",
        mouse_callbacks={"Button1": lazy.spawn(Commands.backlight)},
    ),
    widget.TextBox(
        background="7aa2f7",
        font="Ubuntu Mono",
        fontsize=37,
        foreground="bb9af7",
        padding=-4,
        text="",
    ),
    widget.Clock(
        background="bb9af7",
        foreground="1a1b26",
        format="%A, %B %d - %H:%M ",
        mouse_callbacks={"Button1": lazy.spawn(Commands.time)},
    ),
]

screens = [
    Screen(
        top=bar.Bar(
            background="1a1b26",
            size=20,
            widgets=widget_list,
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
                        widget.WindowName(
                            foreground="b4f9f8", background="1a1b26", padding=0
                        ),
                        widget.Spacer(),
                        widget.TextBox(
                            background="1a1b26",
                            font="Ubuntu Mono",
                            fontsize=37,
                            foreground="f7768e",
                            padding=-4,
                            text="",
                        ),
                        widget.Net(
                            background="f7768e",
                            foreground="1a1b26",
                            format="↓{down} ↑{up}",
                            mouse_callbacks={"Button1": lazy.spawn(Commands.network)},
                        ),
                        widget.TextBox(
                            background="f7768e",
                            font="Ubuntu Mono",
                            fontsize=37,
                            foreground="73daca",
                            padding=-4,
                            text="",
                        ),
                        widget.Battery(
                            fmt="   {}",
                            background="73daca",
                            foreground="1a1b26",
                            format="{percent:0.1%}",
                            mouse_callbacks={"Button1": lazy.spawn(Commands.battery)},
                        ),
                        widget.TextBox(
                            background="73daca",
                            font="Ubuntu Mono",
                            fontsize=37,
                            foreground="7dcfff",
                            padding=-4,
                            text="",
                        ),
                        widget.TextBox(
                            background="7dcfff",
                            fontsize=20,
                            foreground="1a1b26",
                            text="",
                        ),
                        widget.Volume(
                            fmt="   {}",
                            background="7dcfff",
                            foreground="1a1b26",
                            get_volume_command="amixer sget Master".split(),
                            mouse_callbacks={"Button1": lazy.spawn(Commands.volume)},
                            mute_command="amixer sset 'Master' toggle".split(),
                            update_interval=0.2,
                            volume_down_command="amixer sset Master 2%-".split(),
                            volume_up_command="amixer sset Master 2%+".split(),
                        ),
                        widget.TextBox(
                            background="7dcfff",
                            font="Ubuntu Mono",
                            fontsize=37,
                            foreground="7aa2f7",
                            padding=-4,
                            text="",
                        ),
                        widget.Backlight(
                            fmt="   {}",
                            background="7aa2f7",
                            backlight_name="intel_backlight",
                            foreground="1a1b26",
                            mouse_callbacks={"Button1": lazy.spawn(Commands.backlight)},
                        ),
                        widget.TextBox(
                            background="7aa2f7",
                            font="Ubuntu Mono",
                            fontsize=37,
                            foreground="bb9af7",
                            padding=-4,
                            text="",
                        ),
                        widget.Clock(
                            background="bb9af7",
                            foreground="1a1b26",
                            format="%A, %B %d - %H:%M ",
                            mouse_callbacks={"Button1": lazy.spawn(Commands.time)},
                        ),
                    ],
                    20,
                    background="1a1b26",
                ),
            ),
        )
