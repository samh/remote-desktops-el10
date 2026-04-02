# LXQt profile

This profile defines an LXQt desktop built from the repo's LXQt package trees
plus `openbox` as the X11 window manager.

The session starts via `startlxqt` and currently targets the X11 session path.
It uses `qterminal` as the terminal emulator and `pcmanfm-qt` for desktop and
file manager duties.

Current EL10 limitation: `lxqt-config` is built without touchpad settings.
The missing piece is the Xorg libinput development stack (`xorg-libinput` /
`xorg-x11-server-devel`), which EL10 does not provide. This does not affect
the intended remote-desktop use case.
