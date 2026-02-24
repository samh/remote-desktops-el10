#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 {icewm|gnome}" >&2
  exit 1
fi

profile="$1"

case "${profile}" in
  icewm)
    pkgs=(
      turbovnc
      icewm
      icewm-minimal-session
      xorg-x11-xinit
      xorg-x11-xauth
      dbus-x11
      xterm
    )
    ;;
  gnome)
    pkgs=(
      turbovnc
      gnome-session
      gnome-shell
      mutter
      nautilus
      xorg-x11-xinit
      xorg-x11-xauth
      dbus-x11
      xterm
    )
    ;;
  *)
    echo "Unsupported profile: ${profile}" >&2
    echo "Valid values: icewm, gnome" >&2
    exit 1
    ;;
esac

echo "Installing TurboVNC ${profile} profile packages:"
printf ' - %s\n' "${pkgs[@]}"
sudo dnf install -y "${pkgs[@]}"
