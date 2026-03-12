# Fluxbox Stack (fedpkg + mock)

This directory contains a minimal EL10 Fluxbox build workflow based on Fedora
RPM packaging (`fedpkg srpm`) and `mock --rebuild`.

## Current Scope

The first cut intentionally builds only:

- `fluxbox`
  - What it is: the window manager itself.
  - Why include: it is actively packaged in Fedora and builds the core
    TurboVNC-compatible session.

Not included in v1:

- `fluxconf`
  - Fedora packaging is retired, and the current `fluxbox` spec already
    obsoletes it.
- `fbdesk`
  - Fedora packaging is retired.

## Commands

Bootstrap host tools and validate the TurboVNC repo:

```bash
cd fluxbox-stack
just bootstrap
```

Sync Fedora RPM sources:

```bash
just sync
```

Build the stack:

```bash
just build
```

Sync and build:

```bash
just build-sync
```

Preview the local RPM install set:

```bash
just install-dry-run
```

Install the built RPMs:

```bash
just install
```

By default, the install helper skips the optional `fluxbox-pulseaudio` subpackage
because EL10 does not provide the `pulseaudio` runtime it requires.

Install the default Fluxbox user config:

```bash
just install-config
```

Write TurboVNC WM config:

```bash
just conf-turbovnc
```

## Output Layout

- `out/logs/<package>/` stores `fedpkg` and `mock` logs.
- `out/mock-result/<package>/` stores raw `mock` output.
- `out/rpms/<package>/` stores package-specific RPM results.
- `out/all-rpms/` contains every RPM in one place, using hard links when
  possible.

## TurboVNC Repo Notes

This stack does not disable the `TurboVNC` repo. Instead, the bootstrap path
uses `sudo dnf makecache --refresh` and `sudo dnf repoinfo TurboVNC` so the
repo is validated through the root-owned DNF cache and trust flow that this
host expects.

## TurboVNC Session Config

The primary configuration path for TurboVNC 3.3+ is:

- `~/.vnc/turbovncserver.conf` with `$wm="fluxbox";`

For older setups, a compatibility `xstartup.fluxbox` template is also provided.
