from libqtile.config import Click, Drag, Key
from libqtile.lazy import lazy

from commands import Commands

mod = "mod4"

NUMBERS = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]

# BSP resizing taken from https://github.com/qtile/qtile/issues/1402
def resize(qtile, direction):
    layout = qtile.current_layout
    child = layout.current
    parent = child.parent

    while parent:
        if child in parent.children:
            layout_all = False

            if (direction == "left" and parent.split_horizontal) or (
                direction == "up" and not parent.split_horizontal
            ):
                parent.split_ratio = max(5, parent.split_ratio - layout.grow_amount)
                layout_all = True
            elif (direction == "right" and parent.split_horizontal) or (
                direction == "down" and not parent.split_horizontal
            ):
                parent.split_ratio = min(95, parent.split_ratio + layout.grow_amount)
                layout_all = True

            if layout_all:
                layout.group.layout_all()
                break

        child = parent
        parent = child.parent


@lazy.function
def resize_left(qtile):
    resize(qtile, "left")


@lazy.function
def resize_right(qtile):
    resize(qtile, "right")


@lazy.function
def resize_up(qtile):
    resize(qtile, "up")


@lazy.function
def resize_down(qtile):
    resize(qtile, "down")


@lazy.function
def float_to_front(qtile):
    for group in qtile.groups:
        for window in group.windows:
            if window.floating:
                window.cmd_bring_to_front()


keys = [
    # Layout change
    Key([mod], "Tab", lazy.next_layout(), desc="Toggle between layouts"),
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
    # Resize window
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
    Key(
        [mod, "control"],
        "Down",
        lazy.layout.grow_down(),
        desc="Grow window downwards",
    ),
    Key([mod, "control"], "Up", lazy.layout.grow_up(), desc="Grow window upwards"),
    # Reset
    Key([mod], "n", lazy.layout.normalize(), desc="Reset all window sizes"),
    # Toggle split
    # Key("M-<space>", lazy.layout.toggle_split()),
    # Programs shortcuts
    Key(
        [mod, "shift"],
        "e",
        lazy.spawn(Commands.powermenu),
        desc="Spawn rofi powermenu",
    ),
    Key(
        [mod],
        "d",
        lazy.spawn(Commands.launcher),
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
        lazy.spawn(Commands.screenshot),
        desc="Spawn a rofi screenshot menu",
    ),
    Key([mod], "Return", lazy.spawn(Commands.terminal), desc="Launch terminal"),
    # Qtile utility shortcuts
    Key([mod, "shift"], "q", lazy.window.kill(), desc="Kill focused window"),
    Key([mod, "shift"], "r", lazy.reload_config(), desc="Reload the config"),
    # Audio controls with amixer
    Key([], "XF86AudioMute", lazy.spawn("amixer sset 'Master' toggle")),
    Key([], "XF86AudioLowerVolume", lazy.spawn("amixer sset 'Master' 5%-")),
    Key([], "XF86AudioRaiseVolume", lazy.spawn("amixer sset 'Master' 5%+")),
    # Screen brightness controls with brightnessctl
    Key([], "XF86MonBrightnessUp", lazy.spawn("brightnessctl -q set +5%")),
    Key([], "XF86MonBrightnessDown", lazy.spawn("brightnessctl -q set 5%-")),
    # Keyboard brightness controls with brightnessctl
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
    # Multi-screen test (not very convincing)
    Key([mod], "Escape", lazy.next_screen()),
]

# Working with groups
for num in NUMBERS:
    keys.append(
        Key(
            [mod],
            num,
            lazy.group[num].toscreen(),
            desc=f"Switch to group {num}",
        )
    )
    keys.append(
        Key(
            [mod, "shift"],
            num,
            lazy.window.togroup(num),
            desc=f"Move window to group {num}",
        )
    )


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
