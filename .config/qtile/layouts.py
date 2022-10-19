from libqtile import layout


layouts = [
    layout.Columns(
        border_focus="e1acff",
        border_focus_stack="e1acff",
        border_normal="1D2330",
        border_normal_stack="1D2330",
        border_on_single=True,
        border_width=2,
        margin=5,
        margin_on_single=0,
        split=False,
    ),
    layout.Max(
        border_focus="e1acff",
        border_normal="1D2330",
        border_width=2,
    ),
    layout.Floating(
        border_focus="e1acff",
        border_normal="1D2330",
        border_width=2,
        max_border_width=0,
    ),
    layout.RatioTile(
        name="ratiotile",
        border_focus="e1acff",
        border_normal="1D2330",
        border_width=2,
        fancy=True,
        margin=5,
    ),
    layout.Bsp(
        name="bsp",
        border_focus="e1acff",
        border_normal="1D2330",
        border_on_single=True,
        border_width=2,
        margin=5,
        margin_on_single=0,
    ),
    layout.Zoomy(
        columnwidth=350,
        margin=5,
    ),
    # layout.Matrix(**layout_defaults),
    # layout.MonadWide(),
    # layout.Stack(num_stacks=2),
    # layout.TreeTab(),
    # layout.VerticalTile(),
    # layout.Zoomy(),
]
