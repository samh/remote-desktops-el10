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
- `just profile-build openbox-tint2`
- `just profile-build sway`
- `just profile-install-config fluxbox`
- `just profile-install-config lxde`
- `just profile-install-config sway`
- `just profile-conf-turbovnc lxde`
- `just profile-conf-turbovnc openbox-tint2`
- `just apply-sway-config`

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
- `packages/libfm/`
- `packages/libwnck/`
- `packages/lxappearance/`
- `packages/lxde-common/`
- `packages/lxmenu-data/`
- `packages/lxpanel/`
- `packages/lxsession/`
- `packages/lxterminal/`
- `packages/menu-cache/`
- `packages/openbox/`
- `packages/obconf/`
- `packages/pcmanfm/`
- `packages/dunst/`
- `packages/tint2/`
- `packages/wlroots/`
- `packages/sway/`
- `profiles/fluxbox/`
- `profiles/lxde/`
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
- [ ] Try building LXQt
- [ ] Try building labwc
- [ ] Try building Enlightenment
- [ ] Try building Xfce
  - They are developing Wayland support, but based on Smithay, which as far
    as I can tell has no remote desktop solution so far.
  - May also be possible to use components on top of labwc
- [ ] Investigate tech used by 
  [LSIO Webtop 4.0](https://www.linuxserver.io/blog/webtop-4-0-wayland-is-here-engage-the-reality-engine);
  e.g. can it work without a clumsy browser in the way?
