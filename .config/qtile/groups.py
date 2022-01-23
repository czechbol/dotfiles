from libqtile.config import Group, Match

groups = [
    Group("DEV", layout="monadtall", matches=[Match(wm_class=["Code"])]),
    Group("CLI", layout="bsp"),
    Group("WWW", layout="monadtall", matches=[Match(wm_class=["vivaldi-stable"])]),
    Group("SYS", layout="monadtall", matches=[Match(wm_class=["Nemo"])]),
    Group("DOC", layout="monadtall", matches=[Match(wm_class=["Zathura", "evince"])]),
    Group("CHAT", layout="monadtall", matches=[Match(wm_class=["discord"])]),
    Group("MUS", layout="monadtall", matches=[Match(wm_class=["spotify", "Spotify"])]),
    Group("VID", layout="monadtall", matches=[Match(wm_class=["vlc"])]),
    Group(
        "GFX", layout="monadtall", matches=[Match(wm_class=["Inkscape", "gimp-2.10"])]
    ),
]
