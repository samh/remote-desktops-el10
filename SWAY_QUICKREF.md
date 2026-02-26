# Sway Quick Reference (This Setup)

This is a practical reference for your headless Sway + wayvnc session.

## Current Config Files

- Live user config: `~/.config/sway/config`
- Live status script: `~/.config/sway/sway-status.sh`
- wayvnc config: `~/.config/wayvnc/config`
- User service: `~/.config/systemd/user/sway-headless.service`

## Most Useful Keys

These work in your current config:

- `Alt+Return`: Open terminal
- `Alt+d`: Run app launcher (`dmenu-wl_run` if installed)
- `Alt+Shift+r`: Reload Sway config
- `Alt+Shift+e`: Exit Sway session
- `Alt+h/j/k/l`: Focus left/down/up/right
- `Alt+Shift+h/j/k/l`: Move container left/down/up/right
- `Super+r`: Enter resize mode (`h/j/k/l` or arrows, `Enter`/`Esc` to exit)
- `Super+b` / `Super+v`: Horizontal / vertical split
- `Super+s` / `Super+w` / `Super+e`: Stacking / tabbed / split layout
- `Super+f`: Fullscreen toggle
- `Super+Shift+space`: Floating toggle
- `Super+1..0`: Switch workspace 1..10
- `Super+Shift+1..0`: Move current window to workspace 1..10
- `F1`: Focus left container
- `F2`: Focus right container
- `Shift+F1`: Move current container left
- `Shift+F2`: Move current container right
- `F3`: Set horizontal split for next container
- `F4`: Set vertical split for next container
- `F5`: Toggle floating for current window
- `F6`: Toggle fullscreen
- `F8`: Close current window
- `F9`: Open terminal
- `Ctrl+Alt+Return`: Open terminal
- `F10`: Reload Sway config
- `Ctrl+Alt+Shift+r`: Reload Sway config
- `Ctrl+Alt+Shift+e`: Exit Sway session
- `Ctrl+Alt+1`: Set output to `1280x720`
- `Ctrl+Alt+2`: Set output to `1600x900`
- `Ctrl+Alt+3`: Set output to `1920x1080`

Also configured (may require keyboard grab in VNC):

- `Super+Enter`: Open terminal
- `Super+d`: Launcher
- `Super+Shift+r`: Reload config
- `Super+Shift+e`: Exit session

## Common Commands

Reload config without restarting the whole service:

```bash
swaymsg reload
```

Open a terminal from shell (if screen is blank):

```bash
swaymsg exec 'ptyxis --standalone --new-window'
```

Show current outputs:

```bash
swaymsg -t get_outputs
```

Show current tree (all containers/windows):

```bash
swaymsg -t get_tree
```

## Service Control

Check status:

```bash
systemctl --user status sway-headless.service
```

Restart session:

```bash
systemctl --user restart sway-headless.service
```

## wayvnc Login

Show username/password currently configured:

```bash
grep -E '^(username|password)=' ~/.config/wayvnc/config
```

Change password and restart:

```bash
sed -i 's/^password=.*/password=NEW_PASSWORD/' ~/.config/wayvnc/config
systemctl --user restart sway-headless.service
```

## Typical Troubleshooting

Black screen but connection works:

- Press `F9` to launch a terminal.
- Or run: `swaymsg exec 'ptyxis --standalone --new-window'`.

Super key bindings do not work in VNC:

- Use `F9` / `F10` fallback keys.
- Or enable keyboard grab in your VNC viewer.

Panel missing or empty:

- Re-apply template files: `./scripts/apply-sway-config.sh`
- Reload sway: `swaymsg reload`

Launcher says "No menu launcher found":

- Install one: `sudo dnf install -y dmenu-wayland`
- Reload sway: `swaymsg reload`
