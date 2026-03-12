#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
"${ROOT_DIR}/scripts/profile-install-config.sh" --profile sway --home "${HOME}"

sock="$(ss -xlpn 2>/dev/null | awk -v uid="$(id -u)" '$5 ~ "/run/user/"uid"/sway-ipc\\." { print $5; exit }')"
if [[ -n "${sock:-}" ]]; then
  echo "Reloading sway via ${sock}"
  swaymsg -s "${sock}" reload >/dev/null
  echo "Sway config reloaded."
else
  echo "No active sway IPC socket found; config will apply on next session start."
fi
