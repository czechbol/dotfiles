-- █░█ █▀ █▀▀ █▀█   █▀█ █▀█ █▀▀ █▀▀ █▀
-- █▄█ ▄█ ██▄ █▀▄   █▀▀ █▀▄ ██▄ █▀░ ▄█

-- toggle Lid Switch on/off
hl.bind("switch:Lid Switch", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.config/hypr/scripts/displayctl.py lid"), { locked = true })
