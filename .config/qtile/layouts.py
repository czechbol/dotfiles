from libqtile import layout

layout_defaults = dict(
    border_focus="e1acff",
    border_normal="1D2330",
    grow_amount=3,
    margin=10,
    single_margin=0,
)


layouts = [
    layout.MonadTall(name="monadtall", **layout_defaults),
    layout.Max(**layout_defaults),
    layout.Floating(),
    layout.RatioTile(name="ratiotile", **layout_defaults),
    layout.Bsp(name="bsp", **layout_defaults),
    # Plasma(**layout_defaults),
    # layout.Stack(num_stacks=2),
    # layout.Columns(),
    # layout.Matrix(),
    # layout.MonadTall(),
    # layout.MonadWide(),
    # layout.RatioTile(),
    # layout.Tile(),
    # layout.TreeTab(),
    # layout.VerticalTile(),
    # layout.Zoomy(),
]
