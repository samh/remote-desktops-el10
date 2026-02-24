#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
DNF_LIST="${ROOT_DIR}/../dnf-list.txt"

if [[ ! -f "${DNF_LIST}" ]]; then
  echo "Missing package list: ${DNF_LIST}" >&2
  exit 1
fi

check_pkg() {
  local pkg="$1"
  if rg -q "^${pkg}\\." "${DNF_LIST}"; then
    printf "OK   %s\n" "${pkg}"
    return 0
  fi
  printf "MISS %s\n" "${pkg}"
  return 1
}

echo "Checking IceWM profile package availability:"
icewm_pkgs=(
  turbovnc
  icewm
  icewm-minimal-session
  xorg-x11-xinit
  xorg-x11-xauth
  dbus-x11
  xterm
)

icewm_missing=0
for pkg in "${icewm_pkgs[@]}"; do
  check_pkg "${pkg}" || icewm_missing=1
done

echo
echo "Checking GNOME profile package availability:"
gnome_pkgs=(
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

gnome_missing=0
for pkg in "${gnome_pkgs[@]}"; do
  check_pkg "${pkg}" || gnome_missing=1
done

echo
if [[ "${icewm_missing}" -eq 0 ]]; then
  echo "Result: IceWM profile is fully available in dnf-list.txt."
else
  echo "Result: IceWM profile has missing packages."
fi

if [[ "${gnome_missing}" -eq 0 ]]; then
  echo "Result: GNOME profile is fully available in dnf-list.txt."
else
  echo "Result: GNOME profile has missing packages."
fi

if [[ "${icewm_missing}" -ne 0 && "${gnome_missing}" -ne 0 ]]; then
  echo "Both packaged profiles are incomplete; use custom-build fallback." >&2
  exit 2
fi
