# Reproducible `sway` RPM Build (AlmaLinux 10)

This directory contains a reproducible workflow to build a local `sway` RPM for
`wayvnc` use on AlmaLinux 10, without ad-hoc install commands.

`sway 1.11` requires `wlroots >= 0.19.0`, so build/install local `wlroots`
RPMs from `../wlroots-rpm` first.

## What Is Pinned

- `sway` version: `1.11`
- Source tarball URL and SHA256: in `versions.env`
- Build dependency package list: in `build-deps.txt`
- RPM recipe: `sway.spec`

## Layout

- `versions.env`: pinned upstream source info
- `build-deps.txt`: package-level build dependencies
- `sway.spec`: RPM spec
- `scripts/install-builddeps.sh`: reproducible dependency install script
- `scripts/fetch-source.sh`: download + checksum verification
- `scripts/build-srpm.sh`: build source RPM
- `scripts/build-rpm.sh`: build binary + source RPM
- `scripts/build-rpm-container.sh`: build RPMs in podman
- `Makefile`: task wrapper

## Usage

1. Review and commit this directory so the build inputs are tracked.
2. Build/install local wlroots:
   - `make -C ../wlroots-rpm deps rpm install-built`
3. Install dependencies:
   - `make deps`
4. Download and verify source:
   - `make source`
5. Build SRPM:
   - `make srpm`
6. Build full RPM set:
   - `make rpm`
7. Or build in a container (no host package installs):
   - `make rpm-container`

Build artifacts will be in:

- `sway-rpm/rpmbuild/SRPMS`
- `sway-rpm/rpmbuild/RPMS`

Container build artifacts are copied to:

- `sway-rpm/out/RPMS`
- `sway-rpm/out/SRPMS`

## Notes

- The scripts use a local RPM topdir under this directory (`sway-rpm/rpmbuild`)
  so the workflow is self-contained.
- The `deps` script disables `TurboVNC*` repos, matching your host issue.
- `sway 1.11` requires `wlroots >= 0.19.0` (`< 0.20.0`).
- If you later want exact repo snapshot reproducibility, pin a mirror/snapshot in
  DNF config and keep that alongside this directory.
