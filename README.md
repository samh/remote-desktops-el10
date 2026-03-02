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

## Minimal Openbox Stack (fedpkg + mock)
This repo now includes a simple Openbox-oriented build flow based on Fedora
RPM sources, `fedpkg srpm`, and `mock --rebuild`.

The initial minimal package set is:

- `openbox`
- `obconf`
- `lxappearance`
- `pcmanfm`
- `jgmenu`
- `dunst`
- `lxpanel`

Manifest:

- `openbox-stack/packages.yaml`

Source checkouts (as submodules):

- `fedora-rpms/<package>`

Build/install helpers:

- `scripts/openbox-stack-sync-sources.sh`
- `scripts/openbox-stack-build.sh`
- `scripts/openbox-stack-install-built.sh`
- `scripts/openbox-stack-write-turbovnc-conf.sh`

Typical flow:

```bash
make openbox-stack-sync
make openbox-stack-build
make openbox-stack-install-dry-run
make openbox-stack-install
make openbox-stack-conf-turbovnc
```

One-step sync + build:

```bash
make openbox-stack-build-sync
```

Build behavior notes:

- `make openbox-stack-build` is incremental and skips packages that already
  have built RPMs under `openbox-stack/out/rpms/<package>/`.
- To force rebuild everything:
  `./scripts/openbox-stack-build.sh --force-rebuild`
- Later package builds can consume earlier locally built RPMs (for example
  `obconf` using `openbox-devel`) via a temporary local mock repo generated
  from `openbox-stack/out/rpms`.

Defaults:

- Fedora branch: `f43` (per-package in `packages.yaml`)
- Mock target: `epel-10-x86_64`

To use a custom fork/branch for any package, edit that package's `url` and
`branch` in `openbox-stack/packages.yaml`, then re-run
`make openbox-stack-sync`.

# To Do
- [x] More complete Sway setup (panel, launcher)
- [ ] Create a personal COPR for any packages I build to make them easier
  to install
- [ ] Try building labwm (if it seems worthwhile to continue trying wayvnc)
- [ ] Investigate tech used by 
  [LSIO Webtop 4.0](https://www.linuxserver.io/blog/webtop-4-0-wayland-is-here-engage-the-reality-engine);
  e.g. can it work without a clumsy browser in the way?
