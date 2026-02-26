# TurboVNC X11 Desktop Profiles

This directory implements an X11-first desktop setup for TurboVNC.

It provides:

- profile notes and package mapping from `dnf-list.txt`
- lightweight default profile (`icewm`)
- heavier fallback profile (`gnome`)
- scripts to verify package availability, install packages, and set TurboVNC WM

## Files

- `NOTES.md`: option notes and tradeoffs
- `scripts/verify-dnf-list.sh`: checks required packages against `../dnf-list.txt`
- `scripts/install-profile.sh`: installs profile packages with `dnf` and configures WM
- `scripts/write-turbovncserver-conf.sh`: writes `~/.vnc/turbovncserver.conf` (`$wm=...`)
- `scripts/write-xstartup.sh`: legacy helper (not primary for TurboVNC 3.3+)
- `templates/xstartup.icewm`: legacy startup template for IceWM
- `templates/xstartup.gnome`: legacy startup template for GNOME
- `icewm-profile/`: saved known-good IceWM user config snapshot
- `scripts/icewm-app-search.sh`: fzf-based desktop app search launcher
- `scripts/apply-icewm-profile.sh`: installs saved IceWM profile into your home dir

## Usage

1. Verify package availability from the captured list:
   - `./scripts/verify-dnf-list.sh`
2. Install the default lightweight profile:
   - `./scripts/install-profile.sh icewm`
3. Reconnect through your SSH-launched session manager so it starts a fresh
   TurboVNC session with the configured WM.

If you already have a running session, end it from your normal session manager
workflow, then reconnect.

GNOME fallback:

- `./scripts/install-profile.sh gnome`
- reconnect through your normal SSH/session-manager flow

IceWM background color:

- set a light background: `make bg-icewm-light`
- custom color: `./scripts/set-icewm-background.sh '#f2f4f7'`
- then reconnect through your normal SSH/session-manager flow

Restore saved IceWM profile:

- `./scripts/apply-icewm-profile.sh`
- this writes `~/.icewm/menu`, `~/.icewm/toolbar`, `~/.icewm/prefoverride`
- this installs `~/.local/bin/icewm-app-search`
- existing files are backed up as `*.bak.<timestamp>`

Custom-build path:

- If a desired lightweight WM is missing from repos, package it as RPMs using
  the same reproducible workflow style used under `sway-rpm/` and `wlroots-rpm/`.
