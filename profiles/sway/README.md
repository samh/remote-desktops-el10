# Sway profile

This profile contains the runtime assets for the repo's Wayland remote-desktop
session based on:

- `wlroots`
- `sway`

It provides the Sway config and status script under `config/`, plus the
`sway-headless.service` template used by the remote-session setup helper.
The profile name stays `sway`; the service filename remains specific to the
headless user-session setup flow.
