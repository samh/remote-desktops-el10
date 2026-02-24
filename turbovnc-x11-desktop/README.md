# TurboVNC X11 Desktop Profiles

This directory implements an X11-first desktop setup for TurboVNC.

It provides:

- profile notes and package mapping from `dnf-list.txt`
- lightweight default profile (`icewm`)
- heavier fallback profile (`gnome`)
- scripts to verify package availability, install packages, and write `~/.vnc/xstartup`

## Files

- `NOTES.md`: option notes and tradeoffs
- `scripts/verify-dnf-list.sh`: checks required packages against `../dnf-list.txt`
- `scripts/install-profile.sh`: installs profile packages with `dnf`
- `scripts/write-xstartup.sh`: writes `~/.vnc/xstartup` for selected profile
- `templates/xstartup.icewm`: TurboVNC startup template for IceWM
- `templates/xstartup.gnome`: TurboVNC startup template for GNOME

## Usage

1. Verify package availability from the captured list:
   - `./scripts/verify-dnf-list.sh`
2. Install the default lightweight profile:
   - `./scripts/install-profile.sh icewm`
3. Write VNC startup script for IceWM:
   - `./scripts/write-xstartup.sh icewm`
4. Start TurboVNC session:
   - `vncserver`

GNOME fallback:

- `./scripts/install-profile.sh gnome`
- `./scripts/write-xstartup.sh gnome`

Custom-build path:

- If a desired lightweight WM is missing from repos, package it as RPMs using
  the same reproducible workflow style used under `sway-rpm/` and `wlroots-rpm/`.
