# Openbox Stack (fedpkg + mock)

This directory contains a minimal EL10 Openbox build workflow based on Fedora
RPM packaging (`fedpkg srpm`) and `mock --rebuild`.

## Current Minimal Set

Default packages in `packages.yaml`:

- `openbox`
  - What it is: the window manager itself.
  - Why include: required for the Openbox session.
  - Why skip: not applicable; this is the core component.
- `obconf`
  - What it is: GUI editor for Openbox settings.
  - Why include: easier than hand-editing XML for theme/border/focus changes.
  - Why skip: if you prefer fully declarative config files only.
- `dunst`
  - What it is: lightweight notification daemon (`notify-send` popups).
  - Why include: desktop apps can show alerts (copy complete, errors, reminders).
  - Why skip: if you want the absolute smallest stack and do not need popups.
This is intentionally small so the first successful bootstrap is quick and easy
to debug.

## Add-Later Packages

To consider:

- lxpanel - classic LXDE panel/taskbar
  - EL10 build note: current `lxpanel` chain failed in `epel-10-x86_64` due
    missing build deps (`pkgconfig(keybinder)`, `pkgconfig(libwnck-1.0)`) plus
    bootstrap loop (`menu-cache` requires `pkgconfig(libfm-extra)`, and `libfm`
    requires `pkgconfig(libmenu-cache)`).
- xfce4-panel - XFCE panel/taskbar
  - EL10 build note: current Fedora build needs a broader XFCE base
    (`exo-devel`, `garcon-devel`, `libxfce4ui-devel`,
    `libxfce4windowing-devel`, `xfce4-dev-tools`, `xfconf-devel`), so this is
    also a large dependency chain.
- plank - dock; does not replace a classic taskbar/panel
  - EL10 build note: Fedora `plank` spec failed in `epel-10-x86_64` mock
    without extra dependencies: `pkgconfig(granite) >= 5.4.0` and
    `pkgconfig(libbamf3) >= 0.4.0`.
    `granite` is the elementary OS GTK helper/widget library, and `bamf`
    (libbamf3) maps windows to desktop applications.
- polybar - status panel only; doesn't display minimized applications
- jgmenu - "simple, independent and contemporary-looking X11 menu"
- rofi - launcher

### Optional fuller desktop additions

If you want a fuller desktop later (panel/launcher/file manager), add these
packages back in `packages.yaml`:

- `menu-cache`
  - What it is: menu metadata/cache library used by LX components.
  - Why include: required by several LX-style desktop tools.
  - Why skip: unnecessary unless you add packages that depend on it.
- `libfm`
  - What it is: file-management library used by PCManFM/LXPanel plugins.
  - Why include: needed for file-manager/panel integration in LX stack.
  - Why skip: unnecessary for pure Openbox + basic tools.
- `lxpanel`
  - What it is: panel/taskbar for LXDE/Openbox.
  - Why include: gives task list, tray area, launcher integration.
  - Why skip: dependency-heavy on EL10 right now.
- `jgmenu`
  - What it is: application launcher/menu for lightweight WMs.
  - Why include: fast app launcher with simple integration in Openbox/lxpanel.
  - Why skip: if keyboard launchers or static menus are enough.
- `pcmanfm`
  - What it is: lightweight file manager.
  - Why include: practical GUI file browsing and desktop file operations.
  - Why skip: if CLI file management is sufficient on remote systems.
- `lxappearance`
  - What it is: GTK theme/icon/font settings GUI.
  - Why include: convenient visual theme tuning.
  - Why skip: optional; can pull in extra dependency chain and is not required
    for core remote-desktop usability.

Suggested order when re-adding:

1. `menu-cache`
2. `libfm`
3. `lxpanel`
4. `jgmenu`
5. `pcmanfm`
6. `lxappearance` (optional)

`menu-cache` and `libfm` are useful provider packages for the LX stack, and are
often needed before the panel/launcher/file-manager builds resolve in mock.

## Built Panel Option: tint2

`tint2` is now available in this repo via a local RPM spec and is the current
recommended lightweight panel/taskbar option for Openbox on EL10.

Local tint2 packaging in this repo:

- Spec: `openbox-stack/tint2-rpm/tint2.spec` (no submodule)
- Build SRPM: `make -C openbox-stack tint2-srpm`
- Build RPMs: `make -C openbox-stack tint2-rpm`
- Install preview: `make -C openbox-stack tint2-install-dry-run`
- Install: `make -C openbox-stack tint2-install`
- Output: `openbox-stack/out/tint2/`

## Commands

Sync/update package source submodules:

```bash
make -C openbox-stack sync
```

Build package list from `packages.yaml`:

```bash
make -C openbox-stack build
```

Sync + build:

```bash
make -C openbox-stack build-sync
```

Install built RPMs:

```bash
make -C openbox-stack install-dry-run
make -C openbox-stack install
```

Non-interactive install (passes `-y` to `dnf`):

```bash
./openbox-stack/scripts/openbox-stack-install-built.sh --yes
```

Write TurboVNC WM config (`$wm="openbox"`):

```bash
make -C openbox-stack conf-turbovnc
```

## Build Notes

- `make -C openbox-stack build` is incremental and skips packages already built in
  `openbox-stack/out/rpms/<package>/`.
- Use `./openbox-stack/scripts/openbox-stack-build.sh --force-rebuild` to rebuild
  packages.
- The build script creates a temporary local repo from already built RPMs so
  later builds can resolve internal dependencies (for example `obconf` needing
  `openbox-devel`).

## Custom Forks / Branches

Edit `url` and `branch` per package in `packages.yaml`, then run:

```bash
make -C openbox-stack sync
```
