#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ $# -lt 1 || $# -gt 2 ]]; then
  echo "Usage: $0 {icewm|gnome} [--no-configure]" >&2
  exit 1
fi

profile="$1"
configure_wm=1

if [[ "${2:-}" == "--no-configure" ]]; then
  configure_wm=0
elif [[ -n "${2:-}" ]]; then
  echo "Unknown option: ${2}" >&2
  echo "Usage: $0 {icewm|gnome} [--no-configure]" >&2
  exit 1
fi

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

if [[ "${configure_wm}" -eq 1 ]]; then
  bash "${SCRIPT_DIR}/write-turbovncserver-conf.sh" "${profile}"
fi
