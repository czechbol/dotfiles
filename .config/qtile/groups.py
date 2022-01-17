from libqtile.config import Group, EzKey as Key
from libqtile.lazy import lazy

from keys import keys

groups = [
    Group("DEV", layout="monadtall"),
    Group("WWW", layout="monadtall"),
    Group("SYS", layout="monadtall"),
    Group("SYS", layout="monadtall"),
    Group("DOC", layout="monadtall"),
    Group("VBOX", layout="monadtall"),
    Group("CHAT", layout="monadtall"),
    Group("MUS", layout="monadtall"),
    Group("VID", layout="monadtall"),
    Group("GFX", layout="floating"),
]


# Allow MODKEY+[0 through 9] to bind to groups, see https://docs.qtile.org/en/stable/manual/config/groups.html
# MOD4 + index Number : Switch to Group[index]
# MOD4 + shift + index Number : Send active window to another Group
from libqtile.dgroups import simple_key_binder

dgroups_key_binder = simple_key_binder("mod4")
