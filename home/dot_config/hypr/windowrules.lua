-- █░█░█ █ █▄░█ █▀▄ █▀█ █░█░█   █▀█ █░█ █░░ █▀▀ █▀
-- ▀▄▀▄▀ █ █░▀█ █▄▀ █▄█ ▀▄▀▄▀   █▀▄ █▄█ █▄▄ ██▄ ▄█

----------------
--- DEFAULTS ---
----------------

-- Ignore maximize requests from apps. You'll probably like this.
hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

-- Fix some dragging issues with XWayland
hl.window_rule({
    name  = "fix-xwayland-drags",
    match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
    no_initial_focus = true,
})

local float = {
    "^(vlc)$",
    "^(kvantummanager)$",
    "^(qt5ct)$",
    "^(qt6ct)$",
    "^(nwg-look)$",
    "^(org.kde.ark)$",
    "^(Signal)$",                                 -- Signal-Gtk
    "^(com.github.rafostar.Clapper)$",            -- Clapper-Gtk
    "^(app.drey.Warp)$",                          -- Warp-Gtk
    "^(net.davidotek.pupgui2)$",                  -- ProtonUp-Qt
    "^(yad)$",                                    -- Protontricks-Gtk
    "^(eog)$",                                    -- Imageviewer-Gtk
    "^(io.github.alainm23.planify)$",             -- planify-Gtk
    "^(io.gitlab.theevilskeleton.Upscaler)$",     -- Upscaler-Gtk
    "^(com.github.unrud.VideoDownloader)$",       -- VideoDownloader-Gtk
    "^(pavucontrol)$",
    "^(blueman-manager)$",
    "^(nm-applet)$",
    "^(nm-connection-editor)$",
    "^(org.kde.polkit-kde-authentication-agent-1)$",
    "^(Perimeter81)$",
    "^(Harmony SASE)$",
    "(clipse)",
}

for _, class in ipairs(float) do
    hl.window_rule({ match = { class = class }, float = true })
end

hl.window_rule({ match = { class = "^(org.kde.dolphin)$", title = "^(Progress Dialog — Dolphin)$" }, float = true })
hl.window_rule({ match = { class = "^(org.kde.dolphin)$", title = "^(Copying — Dolphin)$" },         float = true })
hl.window_rule({ match = { title = "^(Picture-in-Picture)$" },                                       float = true })
hl.window_rule({ match = { class = "^(firefox)$", title = "^(Library)$" },                           float = true })
hl.window_rule({ match = { title = "(satty)" },                                                      float = true })

hl.window_rule({ match = { class = "^(Perimeter81)$",  float = true }, center = true })
hl.window_rule({ match = { class = "^(Harmony SASE)$", float = true }, center = true })
hl.window_rule({ match = { class = "^(Codium)$",       float = true }, center = true })
hl.window_rule({ match = { title = "(satty)",          float = true }, center = true })

hl.window_rule({ match = { class = "^(org.freedesktop.impl.portal.desktop.gtk)$" },      opacity = "0.90 0.90" })
hl.window_rule({ match = { class = "^(org.freedesktop.impl.portal.desktop.hyprland)$" }, opacity = "0.90 0.90" })

hl.window_rule({ match = { class = "^(Vivaldi-stable)$" }, tile = true })
hl.window_rule({ match = { class = "^(winbox.exe)$" },     tile = true })

hl.window_rule({ match = { class = "(clipse)" }, size = "622 652" })
hl.window_rule({ match = { title = "(satty)" },  size = "75% 75%" })

-- Smart gaps / no gaps when only
hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
hl.workspace_rule({ workspace = "f[1]",   gaps_out = 0, gaps_in = 0 })

hl.window_rule({ match = { float = false, workspace = "w[tv1]" }, rounding = 0 })
hl.window_rule({ match = { float = false, workspace = "w[tv1]" }, border_size = 0 })
hl.window_rule({ match = { float = false, workspace = "f[1]" },   border_size = 0 })
hl.window_rule({ match = { float = false, workspace = "f[1]" },   rounding = 0 })


-- █░░ ▄▀█ █▄█ █▀▀ █▀█   █▀█ █░█ █░░ █▀▀ █▀
-- █▄▄ █▀█ ░█░ ██▄ █▀▄   █▀▄ █▄█ █▄▄ ██▄ ▄█

for _, ns in ipairs({ "rofi", "notifications", "swaync-notification-window", "swaync-control-center", "logout_dialog" }) do
    hl.layer_rule({ match = { namespace = ns }, blur = true })
end
