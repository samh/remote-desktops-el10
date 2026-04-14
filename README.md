# Lightweight Desktops for el10
This repo contains packages for various lightweight desktops / window managers
and related components for RHEL10, CentOS Stream 10, AlmaLinux 10, or other
variants (currently testing on AlmaLinux 10).

I was unsatisfied with the GNOME Remote Desktop (RDP) that is officially
supported (requires two usernames/passwords to log in, does not auto-resize),
so I wanted to see what else was possible.

For reference, I am connecting from client software running on Windows 11.

## Installation (COPR)

These instructions are for end users installing prebuilt RPMs from COPR on
RHEL 10, CentOS Stream 10, AlmaLinux 10, or similar EL10 systems.

*As an alternative to using the COPR, you can clone this repo and build*
*everything locally.*

*For instructions on uploading packages to build, see [COPR Builds](#copr-builds).*

First, enable the COPR repository [samuelh/lightweight-desktops](https://copr.fedorainfracloud.org/coprs/samuelh/lightweight-desktops/):

```bash
sudo dnf copr enable samuelh/lightweight-desktops
```

Then install one or more of the currently available desktop options.

### Fluxbox

Install the packages:

```bash
sudo dnf install fluxbox
```

Some optional light styles:
```bash
sudo dnf install fluxbox-styles-samh
```

To use with TurboVNC, set in `turbovncserver.conf`:
```perl
$wm = "fluxbox";
```

### Openbox

Install the packages:

```bash
sudo dnf install openbox obconf dunst
```

Install the `tint2` panel if desired:
```bash
sudo dnf install tint2
```

To use with TurboVNC, set in `turbovncserver.conf`:
```perl
$wm = "openbox";
```

### LXDE

Install the packages:

```bash
sudo dnf install lxde-common lxsession lxpanel lxappearance pcmanfm lxterminal
```

To use with TurboVNC, set in `turbovncserver.conf`:
```perl
$wm = "startlxde";
```

### Utilities

Install `xdotool`:

```bash
sudo dnf install xdotool
```

## Remote Desktop Options
### wayvnc
I've been wanting to try wayvnc for a while to see how well it works.
Confusingly, although wayvnc is in EPEL, there don't appear to be any
compositors that work with it available, so I had to build one from
source.

Current options in this repo:

- sway

### TurboVNC
This has been my go-to viewer for several years, but it is X11-only.
It *does* appear to work with the RHEL10 version of GNOME, but it
is sluggish, and the TurboVNC documentation reports many issues with
GNOME 3+.

A quick note on why it's my go-to viewer:

- Works through SSH, doesn't require setting up sessions in advance
- Auto-resizing & clipboard sharing just work
- It's fast

As of 2026-02, the other options in EPEL10 are:

- KDE Plasma: Plasma is great but moving toward Wayland-only;
  it likely works in this version, but I got dependency errors
  last time I tried to install it
- icewm: works fine, but I'm not really satisfied with it personally

## Profiles
The desktop workflows now build from package trees in `packages/` and are
composed by profiles in `profiles/`.

Common entrypoints:

- `just profile-build fluxbox`
- `just profile-build lxde`
- `just profile-build lxqt`
- `just profile-build openbox-tint2`
- `just profile-build sway`
- `just profile-install-config fluxbox`
- `just profile-install-config lxde`
- `just profile-install-config lxqt`
- `just profile-install-config sway`
- `just profile-conf-turbovnc lxde`
- `just profile-conf-turbovnc lxqt`
- `just profile-conf-turbovnc openbox-tint2`
- `just apply-sway-config`

Build target note:

- The local build scripts originally defaulted to `epel-10-x86_64`, which on
  this system maps to CentOS Stream 10 + EPEL in `mock`.
- That can drift ahead of stable EL10 variants such as AlmaLinux 10 and Rocky
  10. In practice, this caused local LXQt builds to link against Qt 6.10 while
  the current AlmaLinux 10 repositories still provide Qt 6.9.
- For local builds intended to be installed on AlmaLinux or similar stable
  EL10 systems, prefer the `alma+epel-10-x86_64` mock target.
- For COPR, prefer the stable `rhel+epel-10-x86_64` chroot rather than the
  CentOS Stream `epel-10-x86_64` chroot when the goal is compatibility with
  RHEL 10 and downstream stable EL10 rebuilds.
- COPR chroots publish separate output repositories, so enabling both a stable
  chroot and the CentOS Stream chroot is possible when both are intentionally
  supported.

Current LXQt note:

- `lxqt-config` is built without touchpad settings on EL10 because the Xorg
  libinput development stack is not available there. This does not affect the
  intended remote desktop use case.
- EL10 repos in use here do not provide `lxqt-themes`, so this repo packages
  it directly and `lxqt-session` depends on it. That supplies the LXQt panel
  and appearance themes that would otherwise be missing from fresh installs.
- LXQt is configured to use `gnome-icon-theme` for icons and
  `adwaita-cursor-theme` for cursors because that combination is more complete
  on this EL10 base than Adwaita icons alone.

## Monorepo Layout

The repo now uses:

- `packages/` for self-contained RPM source trees intended for local `mock`
  builds and future COPR builds.
- `profiles/` for desktop/session compositions and user-level config that can
  reuse subsets of packages.

Current packages/profiles include:

- `packages/fluxbox/`
- `packages/fluxbox-styles-samh/`
- `packages/keybinder/`
- `packages/libdbusmenu-lxqt/`
- `packages/libfm/`
- `packages/libfm-qt/`
- `packages/liblxqt/`
- `packages/libqtxdg/`
- `packages/libstatgrab/`
- `packages/libsysstat/`
- `packages/libwnck/`
- `packages/lxappearance/`
- `packages/lxde-common/`
- `packages/lximage-qt/`
- `packages/lxmenu-data/`
- `packages/lxpanel/`
- `packages/lxsession/`
- `packages/lxterminal/`
- `packages/lxqt-build-tools/`
- `packages/lxqt-config/`
- `packages/lxqt-globalkeys/`
- `packages/lxqt-menu-data/`
- `packages/lxqt-panel/`
- `packages/lxqt-qtplugin/`
- `packages/lxqt-session/`
- `packages/lxqt-sudo/`
- `packages/lxqt-themes/`
- `packages/lxqt-wayland-session/`
- `packages/menu-cache/`
- `packages/openbox/`
- `packages/obconf/`
- `packages/pcmanfm/`
- `packages/pcmanfm-qt/`
- `packages/dunst/`
- `packages/qterminal/`
- `packages/qtermwidget/`
- `packages/qtxdg-tools/`
- `packages/tint2/`
- `packages/wlroots/`
- `packages/xdotool/`
- `packages/sway/`
- `profiles/fluxbox/`
- `profiles/lxde/`
- `profiles/lxqt/`
- `profiles/openbox-tint2/`
- `profiles/sway/`

## COPR Builds
COPR project: <https://copr.fedorainfracloud.org/coprs/samuelh/lightweight-desktops/>

Package trees under `packages/` are the units that map cleanly to COPR builds.
The usual flow is:

1. Generate the SRPM locally, for example `just package-srpm sway`.
2. Submit the generated SRPM from `out/packages/<name>/srpm-result/`, for
   example:
   `copr-cli build samuelh/lightweight-desktops out/packages/sway/srpm-result/sway-1.11-1.el10.src.rpm`

`just package-srpm <name>` prints the requested SRPM path on stdout, so this
also works:
`copr-cli build samuelh/lightweight-desktops "$(just package-srpm sway)"`

Useful reference:

- COPR user documentation: <https://docs.pagure.org/copr.copr/user_documentation.html>

# To Do
- [x] More complete Sway setup (panel, launcher)
- [x] Try openbox
  - [ ] Find a good panel to work with it
    - [x] tint2
  - [ ] jgmenu
  - [ ] Launcher such as rofi
- [x] Create a personal COPR for any packages I build to make them easier
  to install
- [x] Try building LXDE
- [x] Try building LXQt
- [ ] Try building labwc
- [ ] Wayland session for LXQt, e.g. using labwc
- [ ] Try building Enlightenment
- [ ] Try building Xfce
  - They are developing Wayland support, but based on Smithay, which as far
    as I can tell has no remote desktop solution so far.
  - May also be possible to use components on top of labwc
- [ ] Investigate tech used by 
  [LSIO Webtop 4.0](https://www.linuxserver.io/blog/webtop-4-0-wayland-is-here-engage-the-reality-engine);
  e.g. can it work without a clumsy browser in the way?
