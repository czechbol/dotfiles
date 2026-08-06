-- See https://wiki.hypr.land/Configuring/Start/

------------------
---- MONITORS ----
------------------

hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})


-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")

    hl.exec_cmd("gnome-keyring-daemon --start --components=secrets,ssh,pkcs11")
    hl.exec_cmd("systemctl --user start hyprpolkitagent") -- authentication dialogue for GUI apps
    hl.exec_cmd("blueman-applet")                         -- systray app for Bluetooth
    hl.exec_cmd("udiskie --no-automount --smart-tray")    -- front-end that allows to manage removable media
    hl.exec_cmd("nm-applet --indicator")                  -- systray app for Network/Wifi
    hl.exec_cmd("clipse -clear")                          -- clear clipboard history on startup
    hl.exec_cmd("clipse -listen")                         -- store clipboard history
    hl.exec_cmd(os.getenv("HOME") .. "/.config/hypr/scripts/displayctl.py lid")
    hl.exec_cmd(os.getenv("HOME") .. "/.config/hypr/scripts/displayctl.py daemon")
    hl.exec_cmd("wayle panel start")

    hl.exec_cmd("pika-backup")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("hyprsunset")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("/opt/piavpn/bin/pia-client %u --quiet")
    hl.exec_cmd(os.getenv("HOME") .. "/.config/hypr/scripts/sunsetd.py -c Brno -t 2500 -d")
end)


-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
hl.env("XCURSOR_SIZE", "24")
hl.env("GDK_SCALE", "1")
hl.env("HYPRCURSOR_THEME", "MyCursor")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("GRIMBLAST_HIDE_CURSOR", "0")


-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
    general = {
        gaps_in  = 5,
        gaps_out = 10,

        border_size = 2,

        col = {
            active_border   = { colors = { "rgba(94e2d5ee)", "rgba(cba6f7ee)" }, angle = 45 },
            inactive_border = "rgba(6c7086ff)",
        },

        resize_on_border = false,

        allow_tearing = false,

        layout = "dwindle",
    },

    decoration = {
        rounding       = 10,
        rounding_power = 2,

        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = 0xee1a1a1a,
        },

        blur = {
            enabled  = true,
            size     = 3,
            passes   = 1,
            vibrancy = 0.1696,
        },
    },

    xwayland = {
        force_zero_scaling = true,
    },

    animations = {
        enabled = true,
    },

    dwindle = {
        preserve_split = true,
    },

    master = {
        new_status = "master",
    },

    misc = {
        background_color           = 0x000000,
        vrr                        = 2,
        disable_hyprland_logo      = true,
        disable_splash_rendering   = true,
        force_default_wallpaper    = 0,
        mouse_move_enables_dpms    = true,
        mouse_move_focuses_monitor = true,
        key_press_enables_dpms     = true,
        focus_on_activate          = true,
        initial_workspace_tracking = 2,
        allow_session_lock_restore = true,
    },

    input = {
        kb_layout         = "cz",
        kb_variant        = "coder",
        kb_model          = "",
        kb_options        = "",
        kb_rules          = "",
        numlock_by_default = true,

        follow_mouse = 1,

        sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.

        touchpad = {
            natural_scroll = true,
        },
    },

    debug = {
        disable_logs = false,
        disable_time = false,
        vfr          = true,
    },
})

hl.curve("easeOutQuint",   { type = "bezier", points = { { 0.23, 1 },   { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear",         { type = "bezier", points = { { 0, 0 },      { 1, 1 } } })
hl.curve("almostLinear",   { type = "bezier", points = { { 0.5, 0.5 },  { 0.75, 1.0 } } })
hl.curve("quick",          { type = "bezier", points = { { 0.15, 0 },   { 0.1, 1 } } })

hl.animation({ leaf = "global",        enabled = true, speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 4.1,  bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 1.49, bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })


---------------
---- INPUT ----
---------------

hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})

hl.device({
    name        = "epic-mouse-v1",
    sensitivity = -0.5,
})


----------------
---- SOURCE ----
----------------

require("keybindings")
require("monitors")
require("userprefs")
require("windowrules")
