# Remote Desktops for el10
This repo contains experiments (mostly using Codex CLI) on setting up remote
desktop sessions on RHEL10, CentOS Stream 10, AlmaLinux 10, or other variants
(currently testing on AlmaLinux 10).

I was unsatisfied with the GNOME Remote Desktop (RDP) that is officially
supported (requires two usernames/passwords to log in, does not auto-resize),
so I wanted to see what else was possible.

For reference, I am connecting from client software running on Windows 11.

## wayvnc
I've been wanting to try wayvnc for a while to see how well it works.
Confusingly, although wayvnc is in EPEL, there don't appear to be any
compositors that work with it available, so I had to build one from
source.

## TurboVNC
This has been my go-to viewer for several years, but it is X11 and
understandably doesn't work well with GNOME.

A quick note on why it's my go-to viewer:

- Works through SSH, doesn't require setting up sessions in advance
- Auto-resizing & clipboard sharing just work
- It's fast

Will it work well with icewm from EPEL?
*It works, but I'm not really satisfied with icewm.*

Should we try to build another WM/desktop from source?
Openbox?
(also need some kind of panel, launcher)

## Profiles
The desktop workflows now build from package trees in `packages/` and are
composed by profiles in `profiles/`.

Common entrypoints:

- `just profile-build fluxbox`
- `just profile-build openbox-tint2`
- `just profile-build sway`
- `just profile-install-config fluxbox`
- `just profile-install-config sway`
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
- `packages/openbox/`
- `packages/obconf/`
- `packages/dunst/`
- `packages/tint2/`
- `packages/wlroots/`
- `packages/sway/`
- `profiles/fluxbox/`
- `profiles/openbox-tint2/`
- `profiles/sway/`

# To Do
- [x] More complete Sway setup (panel, launcher)
- [x] Try openbox
  - [ ] Find a good panel to work with it
    - [x] tint2
  - [ ] jgmenu
  - [ ] Launcher such as rofi
- [ ] Create a personal COPR for any packages I build to make them easier
  to install
- [ ] Try building labwm
- [ ] Try building Enlightenment
- [ ] Try building Xfce
  - They are developing Wayland support, but based on Smithay, which as far
    as I can tell has no remote desktop solution so far.
  - May also be possible to use components on top of labwc
- [ ] Try building LXDE
- [ ] Investigate tech used by 
  [LSIO Webtop 4.0](https://www.linuxserver.io/blog/webtop-4-0-wayland-is-here-engage-the-reality-engine);
  e.g. can it work without a clumsy browser in the way?
