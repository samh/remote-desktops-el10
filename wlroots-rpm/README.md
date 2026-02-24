# Reproducible `wlroots` RPM Build (AlmaLinux 10)

This directory contains a reproducible workflow to build `wlroots` RPMs needed
for `sway 1.11`.

## What Is Pinned

- `wlroots` version: `0.19.2`
- Source URL and SHA256: in `versions.env`
- Build dependencies: in `build-deps.txt`
- RPM recipe: `wlroots.spec`

## Layout

- `versions.env`
- `build-deps.txt`
- `wlroots.spec`
- `scripts/install-builddeps.sh`
- `scripts/fetch-source.sh`
- `scripts/build-srpm.sh`
- `scripts/build-rpm.sh`
- `scripts/install-built-rpms.sh`
- `Makefile`

## Usage

1. Install build dependencies:
   - `make deps`
2. Download and verify source:
   - `make source`
3. Build source RPM:
   - `make srpm`
4. Build binary RPMs:
   - `make rpm`
5. Install the built RPMs to satisfy `sway 1.11`:
   - `make install-built`

Artifacts:

- `wlroots-rpm/rpmbuild/SRPMS`
- `wlroots-rpm/rpmbuild/RPMS`

## Notes

- This uses a local topdir (`wlroots-rpm/rpmbuild`) to keep builds self-contained.
- `deps` disables broken `TurboVNC*` repos on your host.
