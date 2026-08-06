hl.monitor({ output = "eDP-1",   mode = "2560x1600@120", position = "0x0",      scale = "1.25" })
hl.monitor({ output = "HDMI-A-1", mode = "1920x1080",    position = "-1920x200", scale = "1" })

hl.monitor({ output = "desc:Philips Consumer Electronics Company PHL 242E2F UHB2117004313", mode = "1920x1080", position = "-896x-1080",  scale = "1" })
hl.monitor({ output = "desc:Philips Consumer Electronics Company PHL 242E2F UHB2117004497", mode = "1920x1080", position = "1024x-1080",  scale = "1" })
hl.monitor({ output = "desc:Dell Inc. DELL P2421DC JW9PR63",  mode = "2560x1440", position = "-2560x-1440", scale = "1" })
hl.monitor({ output = "desc:Dell Inc. DELL P2421DC GYFPR63",  mode = "2560x1440", position = "0x-1440",     scale = "1" })
hl.monitor({ output = "desc:Dell Inc. DELL P2723DE 1L0HH14",  mode = "2560x1440", position = "-2560x-1440", scale = "1" })
hl.monitor({ output = "desc:Dell Inc. DELL P2723DE 2L0HH14",  mode = "2560x1440", position = "0x-1440",     scale = "1" })
hl.monitor({ output = "desc:HP Inc. HP E24 G4 CN41391K4T",    mode = "1920x1080", position = "0x-1080",     scale = "1" })

-- fallback: mirror the laptop panel on any unknown output
hl.monitor({ output = "", mode = "preferred", position = "0x0", scale = "1", mirror = "eDP-1" })
