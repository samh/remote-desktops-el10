# Reproducible Remote Desktop RPM Stack

This repository now has a two-stage local RPM workflow:

1. Build and install `wlroots 0.19.2`
2. Build `sway 1.11` against that wlroots version

This matches `sway 1.11`'s requirement of `wlroots >= 0.19.0`.

## Quick Start

From `/home/samh/src/remotedesktop`:

```bash
make all
```

Equivalent explicit sequence:

```bash
make wlroots-deps
make wlroots-rpm
make wlroots-install
make sway-deps
make sway-rpm
```

Containerized alternative (no host package install):

```bash
make all-container
```

Install the built non-debug RPMs from this directory onto the host:

```bash
make install-built
```

Preview what would be installed (no changes):

```bash
./scripts/install-built-rpms.sh --dry-run
```

## Configure Dedicated Remote Session

Configure a dedicated headless Sway + wayvnc user session:

```bash
sudo make setup-remote-session
```

Optional environment overrides:

```bash
sudo REMOTE_USER=remotevnc \
  WAYVNC_BIND_ADDRESS=0.0.0.0 \
  WAYVNC_PORT=5900 \
  WAYVNC_USERNAME=remotevnc \
  WAYVNC_PASSWORD='strong-password' \
  make setup-remote-session
```

The setup script installs:

- `~/.config/sway/config` from `remote-session/sway.config`
- `~/.config/wayvnc/config` with TLS + auth enabled
- `~/.config/systemd/user/sway-headless.service`

and enables `sway-headless.service` in the remote user's systemd user manager.

## Outputs

- wlroots RPMs: `wlroots-rpm/rpmbuild/RPMS`
- sway RPMs: `sway-rpm/rpmbuild/RPMS`

## Pinned Inputs

- `wlroots-rpm/versions.env` (version, source URL, checksum)
- `sway-rpm/versions.env` (version, source URL, checksum)
- `wlroots-rpm/build-deps.txt`
- `sway-rpm/build-deps.txt`
- `wlroots-rpm/wlroots.spec`
- `sway-rpm/sway.spec`
