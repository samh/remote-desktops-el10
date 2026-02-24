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
