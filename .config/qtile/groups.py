from libqtile.config import Group, Match

groups = [
    Group("DEV", layout="monadtall", matches=[Match(wm_class=["Code"])]),
    Group("CLI", layout="bsp", matches=[Match(wm_class=["kitty"])]),
    Group("WWW", layout="monadtall", matches=[Match(wm_class=["vivaldi-stable"])]),
    Group("SYS", layout="monadtall", matches=[Match(wm_class=["Nemo"])]),
    Group("DOC", layout="monadtall"),
    Group("VBOX", layout="monadtall"),
    Group("CHAT", layout="monadtall", matches=[Match(wm_class=["discord"])]),
    Group("MUS", layout="monadtall", matches=[Match(wm_class=["spotify", "Spotify"])]),
    Group("VID", layout="monadtall"),
    Group("GFX", layout="floating"),
]
