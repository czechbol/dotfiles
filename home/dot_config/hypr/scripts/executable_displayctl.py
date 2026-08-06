#!/usr/bin/env python3
"""displayctl - consolidated Hyprland display management.

Replaces display_ctl.sh, mirror_picker.sh, toggle_display_mode.sh,
mirror_aspect_fix.sh and lid_switch.sh.

Subcommands:
    daemon            watch socket2, fix mirror aspect on hotplug, restore on remove
    apply             one-shot aspect fix for current mirrors
    restore           put the primary output back to its native mode
    toggle            switch external monitors between mirror and extend
    mirror [T [S]]    set T to mirror S (rofi picker when omitted)
    unmirror [T]      remove mirror from T (rofi picker when omitted)
    lid               apply lid state from /proc (bound to the lid switch)
    menu              rofi menu with the operations above
    status            JSON dump of displayctl's view of the world

Nothing here is tied to a particular machine. The mirror source and layout
anchor is whatever `primary()` resolves to: a laptop's built-in panel when
there is one, otherwise the monitor at the origin. Modes are read from what
the output advertises rather than hard-coded, so the same file works on a
desktop, where the lid and touchscreen paths simply find nothing to do.

Aspect fix (works around Hyprland #11708): when a monitor mirrors the source
with a different aspect ratio, the letterbox shows flickering stale buffer
data. We switch the source to the largest sub-rectangle of its native mode
that matches the target's ratio; if the output rejects that custom mode, fall
back to `hyprctl reload`, which clears the bars.
"""

import argparse
import json
import logging
import os
import re
import select
import socket
import subprocess
import sys
import tempfile
import time
from pathlib import Path

# DRM names a built-in laptop panel eDP/LVDS/DSI; a desktop has none of these.
INTERNAL_RE = re.compile(r"^(eDP|LVDS|DSI)-", re.IGNORECASE)
MODE_RE = re.compile(r"^(\d+)x(\d+)(?:@([\d.]+))?")
PANEL_OVERRIDE = os.environ.get("DISPLAYCTL_PANEL")

CACHE_DIR = Path(os.environ.get("XDG_CACHE_HOME", Path.home() / ".cache"))
STATE_FILE = CACHE_DIR / "hypr_display_mode"
BASELINE_FILE = CACHE_DIR / "displayctl_baseline.json"
LOG_DIR = CACHE_DIR / "displayctl"
HYPRPAPER_CONF = Path.home() / ".config/hypr/hyprpaper.conf"
ROFI_THEME = Path.home() / ".config/rofi/applets/type-2/style-2.rasi"
# Absent on machines without a touchscreen; set_device_enabled skips what it
# cannot find, so the default is only a hint for the laptop that has one.
TOUCHSCREEN_DEVICE = os.environ.get("DISPLAYCTL_TOUCHSCREEN", "elan901c:00-04f3:2f18")
LID_STATE_DIR = Path("/proc/acpi/button/lid")
DEBOUNCE_SECONDS = 0.5

log = logging.getLogger("displayctl")


# ── hyprctl plumbing ─────────────────────────────────────────────────────────

def hyprctl(*args: str) -> str:
    res = subprocess.run(["hyprctl", *args], capture_output=True, text=True)
    if res.returncode != 0:
        log.warning("hyprctl %s failed: %s", " ".join(args), res.stderr.strip())
    return res.stdout.strip()


def hyprctl_json(*args: str):
    out = hyprctl("-j", *args)
    return json.loads(out) if out else []


_is_lua: bool | None = None


def config_is_lua() -> bool:
    """Hyprland >= 0.56 ships two config managers. `keyword` only exists on the
    legacy hyprlang one, `eval` only on the Lua one, so we have to ask."""
    global _is_lua
    if _is_lua is None:
        _is_lua = "only supported with the lua" not in hyprctl("eval", "return 1")
        log.info("config manager: %s", "lua" if _is_lua else "hyprlang")
    return _is_lua


def monitor_spec_to_lua(spec: str) -> str:
    """`name, mode, position, scale [, mirror SRC] [, disable]` -> hl.monitor{}"""
    parts = [p.strip() for p in spec.split(",")]
    output, rest = parts[0], parts[1:]
    fields = [f'output = "{output}"']
    positional = ["mode", "position", "scale"]
    disabled = False
    mirror = ""
    i = 0
    while i < len(rest):
        token = rest[i].lower()
        if token in ("disable", "disabled"):
            disabled = True
        elif token == "mirror" and i + 1 < len(rest):
            i += 1
            mirror = rest[i]
        elif token in ("cm", "icc") and i + 1 < len(rest):
            i += 1
            fields.append(f'{token} = "{rest[i]}"')
        elif token in ("bitdepth", "vrr", "transform") and i + 1 < len(rest):
            i += 1
            fields.append(f"{token} = {rest[i]}")
        elif positional:
            fields.append(f'{positional.pop(0)} = "{rest[i]}"')
        else:
            log.warning("monitor spec %r: ignoring token %r", spec, rest[i])
        i += 1
    # hl.monitor merges into the rule already registered for this output, where
    # a legacy `monitor=` keyword replaced it wholesale. Both toggled fields
    # therefore need an explicit reset, or a stale disable/mirror sticks.
    fields.append(f'mirror = "{mirror}"')
    fields.append(f"disabled = {str(disabled).lower()}")
    return "hl.monitor({ " + ", ".join(fields) + " })"


def keyword_monitor(spec: str) -> None:
    log.info("monitor %s", spec)
    if config_is_lua():
        hyprctl("eval", monitor_spec_to_lua(spec))
    else:
        hyprctl("keyword", "monitor", spec)


def set_device_enabled(device: str, enabled: bool) -> None:
    # machines without this input (any desktop, laptops with no touchscreen)
    # would otherwise get a hyprctl error per lid event
    if not device or device not in hyprctl("devices"):
        log.info("device %s not present, skipping", device)
        return
    log.info("device %s enabled=%s", device, enabled)
    if config_is_lua():
        hyprctl("eval", f'hl.device({{ name = "{device}", enabled = {str(enabled).lower()} }})')
    else:
        hyprctl("keyword", f"device[{device}]:enabled", "true" if enabled else "false")


def monitors_all() -> list[dict]:
    return hyprctl_json("monitors", "all")


def monitor(name: str, mons: list[dict] | None = None) -> dict | None:
    for m in mons if mons is not None else monitors_all():
        if m["name"] == name:
            return m
    return None


def mirrors_of(name: str, mons: list[dict] | None = None) -> list[dict]:
    mons = mons if mons is not None else monitors_all()
    src = monitor(name, mons)
    if not src:
        return []
    # mirrorOf is the source monitor id serialized as a string ("0"), but
    # tolerate the name and the bare id in case the format changes
    accepted = {name, src["id"], str(src["id"])}
    return [m for m in mons if m["mirrorOf"] in accepted and not m["disabled"]]


def notify(title: str, body: str) -> None:
    subprocess.run(["notify-send", "-i", "video-display", title, body], check=False)


# ── which output are we anchored on ──────────────────────────────────────────

def internal_panel(mons: list[dict] | None = None) -> str | None:
    """The built-in laptop panel, or None on a machine that has no such thing."""
    mons = mons if mons is not None else monitors_all()
    if PANEL_OVERRIDE:
        return PANEL_OVERRIDE if monitor(PANEL_OVERRIDE, mons) else None
    for m in mons:
        if INTERNAL_RE.match(m["name"]):
            return m["name"]
    return None


def primary(mons: list[dict] | None = None) -> str | None:
    """Mirror source and layout anchor.

    The built-in panel when there is one, so laptop behaviour is unchanged.
    Otherwise the monitor at the origin, and failing that the top-left one --
    a desktop layout need not place anything at 0x0 (mikka's two Philips sit
    at -896x-1080 and 1024x-1080), and picking by geometry keeps the answer
    stable across runs where enumeration order need not be.
    """
    mons = mons if mons is not None else monitors_all()
    panel = internal_panel(mons)
    if panel:
        return panel
    enabled = [m for m in mons if not m["disabled"]]
    if not enabled:
        return None
    for m in enabled:
        if (m["x"], m["y"]) == (0, 0):
            return m["name"]
    return min(enabled, key=lambda m: (m["x"], m["y"]))["name"]


def mirror_source(mons: list[dict] | None = None) -> str | None:
    """The output that others are currently mirroring, if any."""
    mons = mons if mons is not None else monitors_all()
    for m in mons:
        if mirrors_of(m["name"], mons):
            return m["name"]
    return None


def native_mode(name: str, mons: list[dict] | None = None) -> tuple[int, int, float] | None:
    """Highest-resolution mode the output advertises, as (w, h, refresh)."""
    m = monitor(name, mons)
    if not m:
        return None
    best = None
    for spec in m.get("availableModes") or []:
        parsed = MODE_RE.match(spec)
        if not parsed:
            continue
        cand = (int(parsed.group(1)), int(parsed.group(2)), float(parsed.group(3) or 0))
        if best is None or (cand[0] * cand[1], cand[2]) > (best[0] * best[1], best[2]):
            best = cand
    return best


def _load_baselines() -> dict:
    try:
        return json.loads(BASELINE_FILE.read_text())
    except (OSError, ValueError):
        return {}


def baseline(name: str, mons: list[dict] | None = None) -> tuple[str, str, str] | None:
    """(mode, position, scale) for `name` running natively.

    Recorded to disk whenever we see the output in that state, because both
    `restore` and the lid-open path need it at moments when the live values are
    either a mode we set ourselves or nothing at all (a disabled output reports
    no useful geometry).
    """
    mons = mons if mons is not None else monitors_all()
    m = monitor(name, mons)
    nat = native_mode(name, mons)
    if m and not m["disabled"] and nat and (m["width"], m["height"]) == nat[:2]:
        # the live refresh, not the fastest advertised one: monitors.conf pins
        # modes without a rate, and restoring must not silently overclock the
        # output past what it was actually running at
        refresh = m["refreshRate"] or nat[2]
        current = (f"{nat[0]}x{nat[1]}@{refresh:g}", f"{m['x']}x{m['y']}", f"{m['scale']:g}")
        stored = _load_baselines()
        if stored.get(name) != list(current):
            stored[name] = list(current)
            try:
                BASELINE_FILE.write_text(json.dumps(stored, indent=2) + "\n")
            except OSError as e:
                log.warning("could not cache baseline for %s: %s", name, e)
        return current
    cached = _load_baselines().get(name)
    if cached:
        return tuple(cached)
    if nat:
        return (f"{nat[0]}x{nat[1]}@{nat[2]:g}", "0x0", "1")
    return None


# ── state file (imperative mode memory, shared format with the old scripts) ──

def read_mode() -> str:
    try:
        return STATE_FILE.read_text().splitlines()[0]
    except (OSError, IndexError):
        return "mirror"


def write_state(mode: str, monitor_names: list[str]) -> None:
    STATE_FILE.write_text("\n".join([mode, *monitor_names]) + "\n")


def read_state_monitors() -> list[str]:
    try:
        return [l for l in STATE_FILE.read_text().splitlines()[1:] if l]
    except OSError:
        return []


# ── wallpaper ────────────────────────────────────────────────────────────────

def refresh_wallpaper() -> None:
    time.sleep(0.5)
    try:
        conf = HYPRPAPER_CONF.read_text()
    except OSError:
        return
    m = re.search(r"^\s*path\s*=\s*(\S+)", conf, re.MULTILINE)
    if m:
        hyprctl("hyprpaper", "wallpaper", "," + os.path.expanduser(m.group(1)))


# ── aspect fix ───────────────────────────────────────────────────────────────

def even(n: float) -> int:
    return int(round(n / 2) * 2)


def fit_mode(src_w: int, src_h: int, target_w: int, target_h: int) -> tuple[int, int]:
    """Largest WxH inside the source's native bounds matching the target ratio.

    Wider target than the source -> shrink height (16:9 TV -> 2560x1440).
    Narrower target -> shrink width (4:3 projector -> 2132x1600).
    """
    ratio = target_w / target_h
    if ratio >= src_w / src_h:
        return src_w, even(src_w / ratio)
    return even(src_h * ratio), src_h


def restore_native() -> None:
    mons = monitors_all()
    name = primary(mons)
    if not name:
        return
    src = monitor(name, mons)
    # never re-enable an output that was turned off on purpose (lid closed)
    if not src or src["disabled"]:
        return
    nat = native_mode(name, mons)
    if not nat or (src["width"], src["height"]) == nat[:2]:
        return
    base = baseline(name, mons)
    if not base:
        return
    mode, pos, scale = base
    keyword_monitor(f"{name}, {mode}, {pos}, {scale}")
    refresh_wallpaper()


def apply_aspect_fix() -> None:
    mons = monitors_all()
    # prefer whatever is actually being mirrored; a desktop can mirror any pair
    name = mirror_source(mons) or primary(mons)
    if not name:
        return
    targets = mirrors_of(name, mons)
    if not targets:
        restore_native()
        return

    src = monitor(name, mons)
    if not src or src["disabled"]:
        return
    nat = native_mode(name, mons)
    base = baseline(name, mons)
    if not nat or not base:
        return
    _, pos, scale = base
    refresh = base[0].partition("@")[2] or f"{nat[2]:g}"

    t = targets[0]
    want_w, want_h = fit_mode(nat[0], nat[1], t["width"], t["height"])
    if (src["width"], src["height"]) == (want_w, want_h):
        log.info("aspect already matches %s (%dx%d)", t["name"], want_w, want_h)
        return

    keyword_monitor(f"{name}, {want_w}x{want_h}@{refresh}, {pos}, {scale}")
    time.sleep(0.5)
    src = monitor(name)
    if src and (src["width"], src["height"]) == (want_w, want_h):
        log.info("%s accepted custom mode %dx%d", name, want_w, want_h)
        notify("Mirror", f"{name} switched to {want_w}x{want_h} to match {t['name']}")
        refresh_wallpaper()
        return

    # output rejected the custom mode; reload clears the letterbox (#11708)
    log.info("custom mode rejected, falling back to reload")
    keyword_monitor(f"{name}, {base[0]}, {pos}, {scale}")
    hyprctl("reload")
    notify("Mirror", "Reloaded Hyprland to clear letterbox artifacts")
    refresh_wallpaper()


# ── toggle mirror/extend ─────────────────────────────────────────────────────

def logical_width(name: str | None, mons: list[dict]) -> int:
    src = monitor(name, mons) if name else None
    if src and not src["disabled"]:
        return int(src["width"] / src["scale"])
    return 0


def switch_to_extend() -> None:
    mons = monitors_all()
    anchor = primary(mons)
    if not anchor:
        return
    mirrored = sorted(m["name"] for m in mirrors_of(anchor, mons))
    # daemon must see "extend" before the cycles below emit monitoradded events
    write_state("extend", mirrored)

    start_x = logical_width(anchor, mons)
    keyword_monitor(f", preferred, {start_x}x0, 1")

    current_x = start_x
    for name in mirrored:
        m = monitor(name, mons)
        if not m:
            continue
        res = f"{m['width']}x{m['height']}@{int(m['refreshRate'])}"
        # disable/enable cycle: Hyprland doesn't re-announce the wl_output of a
        # monitor that stops mirroring, leaving it invisible to hyprpaper/wayle
        keyword_monitor(f"{name}, disable")
        time.sleep(0.3)
        keyword_monitor(f"{name}, {res}, {current_x}x0, 1")
        current_x += m["width"]
    notify("Display Mode", "Extended")
    restore_native()
    refresh_wallpaper()


def switch_to_mirror() -> None:
    saved = read_state_monitors()
    mons = monitors_all()
    anchor = primary(mons)
    if not anchor:
        return
    keyword_monitor(f", preferred, 0x0, 1, mirror, {anchor}")

    mons = monitors_all()
    for name in saved:
        m = monitor(name, mons)
        if not m:
            continue  # monitor may have been disconnected
        res = f"{m['width']}x{m['height']}@{int(m['refreshRate'])}"
        keyword_monitor(f"{name}, {res}, 0x0, 1, mirror, {anchor}")

    write_state("mirror", [])
    notify("Display Mode", "Mirrored")
    apply_aspect_fix()
    refresh_wallpaper()


def toggle() -> None:
    if read_mode() == "extend":
        switch_to_mirror()
    else:
        switch_to_extend()


# ── mirror set/remove ────────────────────────────────────────────────────────

def set_mirror(target: str, source: str) -> None:
    m = monitor(target)
    if not m:
        sys.exit(f"unknown monitor: {target}")
    info = f"{m['width']}x{m['height']}@{int(m['refreshRate'])},{m['x']}x{m['y']},{m['scale']}"
    keyword_monitor(f"{target},{info},mirror,{source}")
    notify("Mirror Set", f"{target} now mirrors {source}")
    apply_aspect_fix()


def remove_mirror(target: str) -> None:
    # cycle so the wl_output gets re-announced to hyprpaper/wayle
    keyword_monitor(f"{target}, disable")
    time.sleep(0.3)
    keyword_monitor(f"{target},preferred,auto,1")
    notify("Mirror Removed", f"{target} restored")
    restore_native()


# ── lid ──────────────────────────────────────────────────────────────────────

def lid_state() -> str | None:
    """Contents of the ACPI lid state file, or None on a machine without a lid.

    The button is not always LID0 (LID, LID1 and C1AC all occur), so glob it.
    """
    try:
        for path in sorted(LID_STATE_DIR.glob("*/state")):
            return path.read_text()
    except OSError as e:
        log.warning("could not read lid state: %s", e)
    return None


def lid() -> None:
    mons = monitors_all()
    panel = internal_panel(mons)
    state = lid_state()
    if not panel or state is None:
        log.info("no lid to act on (panel=%s, acpi=%s)", panel, state is not None)
        return

    if "open" in state:
        base = baseline(panel, mons)
        if base:
            keyword_monitor(f"{panel}, {base[0]}, {base[1]}, {base[2]}")
        set_device_enabled(TOUCHSCREEN_DEVICE, True)
    else:
        active = [m for m in mons if not m["disabled"]]
        if len(active) > 1:
            # touchscreen off BEFORE its output dies: a touch event landing on a
            # destroyed panel segfaults Hyprland (observed 2026-07-09, v0.55.4)
            set_device_enabled(TOUCHSCREEN_DEVICE, False)
            time.sleep(0.2)
            keyword_monitor(f"{panel}, disable")


# ── rofi UI ──────────────────────────────────────────────────────────────────

THUMB_H = 150
MAX_COLS = 4


def rofi(entries: list[tuple[str, Path | None]], prompt: str, theme_str: list[str]) -> str | None:
    lines = []
    for name, thumb in entries:
        if thumb:
            lines.append(f"{name}\0icon\x1f{thumb}")
        else:
            lines.append(name)
    cmd = ["rofi", "-dmenu", "-p", prompt, "-theme", str(ROFI_THEME), "-format", "s"]
    for t in theme_str:
        cmd += ["-theme-str", t]
    res = subprocess.run(cmd, input="\n".join(lines), capture_output=True, text=True)
    return res.stdout.strip() or None


def make_thumbnails(names: list[str], tmp: Path) -> tuple[dict[str, Path], int]:
    thumbs: dict[str, Path] = {}
    max_w = 267
    for name in names:
        out = tmp / f"{name}.png"
        grim = subprocess.run(["grim", "-o", name, "-t", "png", "-"], capture_output=True)
        if grim.returncode != 0:
            continue
        conv = subprocess.run(
            ["convert", "-", "-resize", f"x{THUMB_H}", str(out)], input=grim.stdout, capture_output=True)
        if conv.returncode != 0 or not out.exists():
            continue
        thumbs[name] = out
        ident = subprocess.run(["identify", "-format", "%w", str(out)], capture_output=True, text=True)
        if ident.returncode == 0 and ident.stdout.isdigit():
            max_w = max(max_w, int(ident.stdout))
    for out in thumbs.values():
        subprocess.run(
            ["convert", str(out), "-background", "none", "-gravity", "Center",
             "-extent", f"{max_w}x{THUMB_H}", str(out)], capture_output=True)
    return thumbs, max_w


def pick_monitor(prompt: str, exclude: str | None = None) -> str | None:
    mons = [m["name"] for m in monitors_all() if not m["disabled"] and m["name"] != exclude]
    if not mons:
        return None
    with tempfile.TemporaryDirectory(prefix="displayctl_thumbs_") as tmpdir:
        tmp = Path(tmpdir)
        thumbs, icon_w = make_thumbnails(mons, tmp)
        n = len(mons)
        cols = min(n, MAX_COLS)
        rows = (n + cols - 1) // cols
        win_w = cols * (icon_w + 20) + (cols - 1) * 10 + 60
        return rofi(
            [(m, thumbs.get(m)) for m in mons], prompt,
            ["configuration { show-icons: true; }",
             f"window {{ width: {win_w}px; }}",
             "mainbox { children: [inputbar, listview]; }",
             f"listview {{ columns: {cols}; lines: {rows}; spacing: 10px; fixed-height: false; }}",
             "element { orientation: vertical; padding: 12px 10px; spacing: 6px; }",
             f"element-icon {{ size: {icon_w}px; background-color: transparent; border-radius: 8px; }}",
             'element-text { horizontal-align: 0.5; font: "JetBrains Mono Nerd Font 10"; }'])


def mirror_interactive() -> None:
    source = pick_monitor("Mirror source")
    if not source:
        return
    target = pick_monitor("Mirror target", exclude=source)
    if not target:
        return
    set_mirror(target, source)


def unmirror_interactive() -> None:
    target = pick_monitor("Remove mirror from")
    if target:
        remove_mirror(target)


def menu() -> None:
    choice = rofi(
        [("  Set mirror", None), ("  Remove mirror", None), ("↔  Toggle extend/mirror", None)],
        "Display",
        ["window { width: 360px; }",
         "listview { columns: 1; lines: 3; fixed-height: false; }",
         "element { padding: 12px 16px; }",
         "mainbox { children: [inputbar, listview]; }"])
    if not choice:
        return
    if "Set mirror" in choice:
        mirror_interactive()
    elif "Remove mirror" in choice:
        unmirror_interactive()
    elif "Toggle" in choice:
        toggle()


# ── daemon ───────────────────────────────────────────────────────────────────

def instance_dir() -> Path | None:
    sig = os.environ.get("HYPRLAND_INSTANCE_SIGNATURE")
    runtime = os.environ.get("XDG_RUNTIME_DIR", f"/run/user/{os.getuid()}")
    return Path(runtime) / "hypr" / sig if sig else None


def handle_events(events: list[str]) -> None:
    added = any(e.startswith("monitoraddedv2") for e in events)
    removed = any(e.startswith("monitorremoved") for e in events)
    if added and read_mode() == "mirror":
        time.sleep(0.5)  # let the modeset settle
        apply_aspect_fix()
    elif removed:
        time.sleep(0.5)
        if not mirror_source():
            restore_native()


def daemon() -> None:
    inst = instance_dir()
    if not inst:
        sys.exit("HYPRLAND_INSTANCE_SIGNATURE not set")
    sock_path = inst / ".socket2.sock"

    while inst.exists():
        try:
            sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
            sock.connect(str(sock_path))
        except OSError as e:
            log.warning("socket2 connect failed (%s), retrying", e)
            time.sleep(2)
            continue

        log.info("connected to %s", sock_path)
        buf = b""
        pending: list[str] = []
        deadline: float | None = None
        try:
            while True:
                timeout = max(0.05, deadline - time.monotonic()) if deadline else None
                ready, _, _ = select.select([sock], [], [], timeout)
                if ready:
                    chunk = sock.recv(4096)
                    if not chunk:
                        break
                    buf += chunk
                    while b"\n" in buf:
                        line, buf = buf.split(b"\n", 1)
                        event = line.decode(errors="replace")
                        if event.startswith(("monitoraddedv2", "monitorremoved")):
                            log.info("event: %s", event)
                            pending.append(event)
                            deadline = time.monotonic() + DEBOUNCE_SECONDS
                if deadline and time.monotonic() >= deadline:
                    # our own keyword calls may emit more events while handling;
                    # clear pending before acting so they queue a fresh batch
                    batch, pending, deadline = pending, [], None
                    handle_events(batch)
        finally:
            sock.close()
        log.info("socket closed, reconnecting")
        time.sleep(1)
    log.info("instance dir gone, exiting")


# ── main ─────────────────────────────────────────────────────────────────────

def status() -> None:
    mons = monitors_all()
    anchor = primary(mons)
    sys.stdout.write(json.dumps({
        "mode": read_mode(),
        "saved_monitors": read_state_monitors(),
        "internal_panel": internal_panel(mons),
        "primary": anchor,
        "baseline": baseline(anchor, mons) if anchor else None,
        "mirror_source": mirror_source(mons),
        "mirrors_of_primary": [m["name"] for m in mirrors_of(anchor, mons)] if anchor else [],
        "monitors": [
            {k: m[k] for k in ("name", "width", "height", "refreshRate", "scale", "mirrorOf", "disabled")}
            for m in mons],
    }, indent=2) + "\n")


def main() -> None:
    parser = argparse.ArgumentParser(prog="displayctl", description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = parser.add_subparsers(dest="cmd", required=True)
    for name in ("daemon", "apply", "restore", "toggle", "lid", "menu", "status"):
        sub.add_parser(name)
    p_mirror = sub.add_parser("mirror")
    p_mirror.add_argument("target", nargs="?")
    # resolved after parsing: the default depends on what is plugged in
    p_mirror.add_argument("source", nargs="?", default=None)
    p_unmirror = sub.add_parser("unmirror")
    p_unmirror.add_argument("target", nargs="?")
    args = parser.parse_args()

    LOG_DIR.mkdir(parents=True, exist_ok=True)
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s %(levelname)s %(message)s",
        handlers=[logging.FileHandler(LOG_DIR / "displayctl.log"), logging.StreamHandler()])

    actions = {
        "daemon": daemon,
        "apply": apply_aspect_fix,
        "restore": restore_native,
        "toggle": toggle,
        "lid": lid,
        "menu": menu,
        "status": status,
    }
    if args.cmd == "mirror":
        if args.target:
            source = args.source or primary()
            if not source:
                sys.exit("no monitors to mirror from")
            set_mirror(args.target, source)
        else:
            mirror_interactive()
    elif args.cmd == "unmirror":
        remove_mirror(args.target) if args.target else unmirror_interactive()
    else:
        actions[args.cmd]()


if __name__ == "__main__":
    main()
