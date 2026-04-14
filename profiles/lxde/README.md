# LXDE profile

This profile defines a lightweight LXDE desktop built from shared package
trees, reusing `openbox` and adding the LXDE session, panel, file manager, and
common desktop components.

The profile builds and installs `lxterminal` as its terminal emulator. The
LXDE panel launcher and the default libfm terminal setting both point to it.

## LXTerminal missing symbols (tofu boxes)

If LXTerminal shows empty boxes for prompt or status-line glyphs, install
symbol fonts and use a terminal font that contains those glyphs.

Install common symbol font coverage on EL10:

```bash
sudo dnf install powerline-fonts google-noto-sans-symbols-2-fonts google-noto-emoji-fonts
```

Then in LXTerminal preferences, set the font to a family that includes
Powerline glyphs, for example `DejaVu Sans Mono for Powerline`.

You can test quickly with:

```bash
printf '\ue0a0 \ue0b0 \u26a1 \u2714 \U0001f680\n'
```

If these still render as empty boxes, restart LXTerminal and refresh font cache:

```bash
fc-cache -f
```
