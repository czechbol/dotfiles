from libqtile.config import Group, Match

groups = [
    Group(
        name="1",
        label="CHAT",
        layout="columns",
        matches=[Match(wm_class=["discord", "slack", "Slack"])],
    ),
    Group(
        name="2",
        label="WWW",
        layout="columns",
        matches=[Match(wm_class=["vivaldi-stable"])],
    ),
    Group(
        name="3",
        label="DEV",
        layout="columns",
        matches=[Match(wm_class=["code-oss", "code"])],
    ),
    Group(name="4", label="CLI", layout="bsp"),
    Group(
        name="5",
        label="SYS",
        layout="columns",
        matches=[Match(wm_class=["Nemo", "thunar", "dolphin"])],
    ),
    Group(
        name="6",
        label="DOC",
        layout="columns",
        matches=[
            Match(wm_class=["Zathura", "evince", "okular"]),
            Match(wm_instance_class=["libreoffice"]),
        ],
    ),
    Group(
        name="7",
        label="MUS",
        layout="columns",
        matches=[Match(title=["Spotify"]), Match(wm_class=["Spotify", "spotify"])],
    ),
    Group(name="8", label="VID", layout="columns", matches=[Match(wm_class=["vlc"])]),
    Group(
        name="9",
        label="GFX",
        layout="columns",
        matches=[Match(wm_class=["Inkscape", "gimp-2.10"])],
    ),
    Group(
        name="0",
        label="MISC",
        layout="columns",
    ),
]
