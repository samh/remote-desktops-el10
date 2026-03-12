# Packages

This directory is the long-term home for self-contained RPM source trees used
by local `mock` builds and future COPR builds.

Each package directory should contain:

- a buildable RPM packaging tree
- a `package.yaml` file describing local build ordering and install filters
- an `upstream.yaml` file describing where the packaging currently comes from
- any local patches or release-suffix changes needed for EL builds and COPR
- small helper scripts for refreshing or fetching sources

The intent is that `packages/<name>/` becomes the canonical packaging location,
while Fedora DistGit is treated as an upstream packaging source that can be
refreshed into this repo when needed. Local build outputs now live under
`out/packages/<name>/`.
