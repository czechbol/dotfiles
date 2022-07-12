from libqtile.config import Group, Match

groups = [
    Group(
        name="1",
        label="DEV",
        layout="monadtall",
        matches=[Match(wm_class=["code-oss"])],
    ),
    Group(name="2", label="CLI", layout="bsp"),
    Group(
        name="3",
        label="WWW",
        layout="monadtall",
        matches=[Match(wm_class=["vivaldi-stable"])],
    ),
    Group(
        name="4",
        label="SYS",
        layout="monadtall",
        matches=[Match(wm_class=["Nemo", "thunar", "dolphin"])],
    ),
    Group(
        name="5",
        label="DOC",
        layout="monadtall",
        matches=[Match(wm_class=["Zathura", "evince"])],
    ),
    Group(
        name="6",
        label="CHAT",
        layout="monadtall",
        matches=[Match(wm_class=["discord", "slack", "Slack"])],
    ),
    Group(
        name="7",
        label="MUS",
        layout="monadtall",
        matches=[Match(title=["Spotify"], wm_class=["Spotify", "spotify"])],
    ),
    Group(name="8", label="VID", layout="monadtall", matches=[Match(wm_class=["vlc"])]),
    Group(
        name="9",
        label="GFX",
        layout="monadtall",
        matches=[Match(wm_class=["Inkscape", "gimp-2.10"])],
    ),
    Group(
        name="0",
        label="MISC",
        layout="monadtall",
    ),
]
