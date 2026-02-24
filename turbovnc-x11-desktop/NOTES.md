# TurboVNC + X11 Desktop Notes

## Goal

Use a desktop/session that works well with TurboVNC, which is X11-based.

## Options From `dnf-list.txt`

### 1) IceWM minimal (recommended default)

Pros:

- lightweight CPU/RAM profile for VNC
- explicit X11 window manager
- packages are present in the current list

Packages observed:

- `turbovnc`
- `icewm`
- `icewm-minimal-session`
- `xorg-x11-xinit`
- `xorg-x11-xauth`
- `dbus-x11`
- `xterm`

### 2) GNOME fallback (heavier)

Pros:

- full desktop environment
- available in the current list

Tradeoffs:

- higher resource usage than IceWM in VNC
- must force/confirm X11 session behavior

Packages observed:

- `turbovnc`
- `gnome-session`
- `gnome-shell`
- `mutter`
- `nautilus`
- `xorg-x11-xinit`
- `xorg-x11-xauth`
- `dbus-x11`
- `xterm`

### 3) Build custom lightweight WM RPMs (fallback if needed)

Use this only if IceWM is too minimal and GNOME is too heavy.

Direction:

- pick an X11 WM stack not present in repos
- package it as RPM(s)
- reuse reproducible RPM workflow patterns from `sway-rpm/` and `wlroots-rpm/`

## Session Startup Contract

For `~/.vnc/xstartup`:

- `exec` exactly one session command
- bootstrap D-Bus session for desktop components
- force X11 environment variables where needed
