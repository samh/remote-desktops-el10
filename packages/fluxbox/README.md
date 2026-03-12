# Fluxbox package

This directory is the start of a local, COPR-friendly packaging home for
`fluxbox`.

Current state:

- `distgit/` is a snapshot of the Fedora packaging files currently used by the
  working EL10 Fluxbox build flow.
- `upstream.yaml` records the Fedora DistGit origin used for refreshes.
- The active local build flow now reads directly from this directory via the
  shared package builder.

Near-term intent:

1. Refresh packaging from Fedora into `distgit/` with the helper script.
2. Add repo-local EL and COPR deltas here rather than only in Fedora-derived
   submodules.
3. Keep repo-local EL and COPR deltas here and refresh from Fedora only when
   desired.
