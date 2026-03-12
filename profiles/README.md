# Profiles

Profiles describe runnable desktop/session compositions built from one or more
packages plus user-level configuration.

Examples:

- a minimal Fluxbox session
- an Openbox plus tint2 stack
- a TurboVNC IceWM profile

Each profile directory should hold:

- a `profile.yaml` file naming its package set and session metadata
- user config templates
- legacy startup templates if needed
- a short README describing what packages it expects
- install helpers only when the behavior is profile-specific

The goal is to make package ownership independent from runtime composition, so
profiles can reuse subsets of shared packages without owning duplicate RPM
outputs.
