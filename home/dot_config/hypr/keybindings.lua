---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER"
local home    = os.getenv("HOME")

-- Assign apps
local term    = "kitty"
local editor  = "code"
local file    = "nemo"
local browser = "vivaldi-stable --password-store=gnome-libsecret --enable-features=UseOzonePlatform --ozone-platform=wayland --ozone-platform-hint=auto --enable-features=WaylandWindowDecorations1"
local manuallock = "playerctl pause & hyprlock --grace 0"

-- Window/Session actions
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(home .. "/.config/hypr/scripts/dontkillsteam.sh")) -- close focused window
hl.bind("ALT + F4", hl.dsp.exec_cmd(home .. "/.config/hypr/scripts/dontkillsteam.sh"))        -- close focused window
hl.bind(mainMod .. " + Delete", hl.dsp.exit())                                                -- kill hyprland session
hl.bind(mainMod .. " + W", hl.dsp.window.float({ action = "toggle" }))                        -- toggle the window between focus and float
hl.bind(mainMod .. " + G", hl.dsp.group.toggle())                                             -- toggle the window between focus and group
hl.bind("ALT + Return", hl.dsp.window.fullscreen())                                           -- toggle the window between focus and fullscreen
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd(manuallock))                                       -- launch lock screen
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.exec_cmd(home .. "/.config/rofi/scripts/powermenu_t2")) -- launch logout menu
hl.bind("CTRL + Escape", hl.dsp.exec_cmd("wayle panel toggle"))                               -- toggle bar

-- Application shortcuts
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(term))    -- launch terminal emulator
hl.bind(mainMod .. " + F", hl.dsp.exec_cmd(file))         -- launch file manager
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd(editor))       -- launch text editor
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser))      -- launch web browser
hl.bind("CTRL + SHIFT + Escape", hl.dsp.exec_cmd(term .. " -e gotop")) -- launch system monitor

-- Rofi menus
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("pkill -x rofi || " .. home .. "/.config/rofi/scripts/launcher_t3")) -- launch application launcher

-- Audio control
hl.bind("XF86AudioMute",    hl.dsp.exec_cmd(home .. "/.config/hypr/scripts/volumecontrol.sh -o m"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd(home .. "/.config/hypr/scripts/volumecontrol.sh -i m"), { locked = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(home .. "/.config/hypr/scripts/volumecontrol.sh -o d"), { locked = true, repeating = true })
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(home .. "/.config/hypr/scripts/volumecontrol.sh -o i"), { locked = true, repeating = true })

-- Media control
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

-- Brightness control
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd(home .. "/.config/hypr/scripts/brightnesscontrol.sh i"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(home .. "/.config/hypr/scripts/brightnesscontrol.sh d"), { locked = true, repeating = true })

-- Screenshot/Screencapture
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd(home .. "/.config/hypr/scripts/screenshot.sh sf"))          -- partial screenshot capture
hl.bind(mainMod .. " + CTRL + P", hl.dsp.exec_cmd(home .. "/.config/hypr/scripts/screenshot.sh s"))    -- partial screenshot capture (frozen screen)
hl.bind(mainMod .. " + ALT + P", hl.dsp.exec_cmd(home .. "/.config/hypr/scripts/screenshot.sh m"))     -- monitor screenshot capture
hl.bind("Print", hl.dsp.exec_cmd(home .. "/.config/hypr/scripts/screenshot.sh p"))                     -- all monitors screenshot capture

-- Custom scripts
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("kitty --class clipse -e 'clipse'"))
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.exec_cmd("pkill -x rofi || " .. home .. "/.config/hypr/scripts/displayctl.py menu")) -- display control menu

-- Move/Change window focus
hl.bind(mainMod .. " + Left",  hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + Right", hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. " + Up",    hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + Down",  hl.dsp.focus({ direction = "d" }))
hl.bind("ALT + Tab",           hl.dsp.focus({ direction = "d" }))

-- Switch workspaces / move focused window to a workspace
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind("ALT + " .. key,           hl.dsp.focus({ workspace = tostring(i) }))
    hl.bind("ALT + SHIFT + " .. key,   hl.dsp.window.move({ workspace = tostring(i) }))
    hl.bind(mainMod .. " + ALT + " .. key, hl.dsp.window.move({ workspace = tostring(i), follow = false })) -- silent
end

-- Switch workspaces to a relative workspace
hl.bind(mainMod .. " + CTRL + Right", hl.dsp.focus({ workspace = "r+1" }))
hl.bind(mainMod .. " + CTRL + Left",  hl.dsp.focus({ workspace = "r-1" }))

-- Move to the first empty workspace
hl.bind(mainMod .. " + CTRL + Down", hl.dsp.focus({ workspace = "empty" }))

-- Resize windows
hl.bind(mainMod .. " + SHIFT + Right", hl.dsp.window.resize({ x = 30,  y = 0,   relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + Left",  hl.dsp.window.resize({ x = -30, y = 0,   relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + Up",    hl.dsp.window.resize({ x = 0,   y = -30, relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + Down",  hl.dsp.window.resize({ x = 0,   y = 30,  relative = true }), { repeating = true })

-- Move focused window to a relative workspace
hl.bind(mainMod .. " + CTRL + ALT + Right", hl.dsp.window.move({ workspace = "r+1" }))
hl.bind(mainMod .. " + CTRL + ALT + Left",  hl.dsp.window.move({ workspace = "r-1" }))

-- Move focused window around the current workspace
hl.bind(mainMod .. " + SHIFT + CTRL + Left",  hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. " + SHIFT + CTRL + Right", hl.dsp.window.move({ direction = "r" }))
hl.bind(mainMod .. " + SHIFT + CTRL + Up",    hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. " + SHIFT + CTRL + Down",  hl.dsp.window.move({ direction = "d" }))

-- Scroll through existing workspaces
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move/Resize focused window
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag())
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize())
hl.bind(mainMod .. " + Z", hl.dsp.window.drag())
hl.bind(mainMod .. " + X", hl.dsp.window.resize())

-- Move/Switch to special workspace (scratchpad)
hl.bind(mainMod .. " + ALT + S", hl.dsp.window.move({ workspace = "special", follow = false }))
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special(""))

-- Toggle focused window split
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))
