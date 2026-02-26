#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
PROFILE_DIR="${ROOT_DIR}/icewm-profile"

mkdir -p "$HOME/.icewm" "$HOME/.local/bin"

ts="$(date +%Y%m%d-%H%M%S)"
for f in menu toolbar prefoverride; do
  if [[ -f "$HOME/.icewm/$f" ]]; then
    cp -a "$HOME/.icewm/$f" "$HOME/.icewm/${f}.bak.${ts}"
  fi
done

cp "${PROFILE_DIR}/menu" "$HOME/.icewm/menu"
cp "${PROFILE_DIR}/toolbar" "$HOME/.icewm/toolbar"
cp "${PROFILE_DIR}/prefoverride" "$HOME/.icewm/prefoverride"
cp "${SCRIPT_DIR}/icewm-app-search.sh" "$HOME/.local/bin/icewm-app-search"

chmod 600 "$HOME/.icewm/menu" "$HOME/.icewm/toolbar" "$HOME/.icewm/prefoverride"
chmod 700 "$HOME/.local/bin/icewm-app-search"

echo "Applied IceWM profile and app-search launcher."
echo "Reconnect through your normal SSH/session-manager flow to apply."
