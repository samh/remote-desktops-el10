#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC_CONFIG="${ROOT_DIR}/remote-session/sway.config"
SRC_STATUS="${ROOT_DIR}/remote-session/sway-status.sh"
DST_CONFIG="${HOME}/.config/sway/config"
DST_STATUS="${HOME}/.config/sway/sway-status.sh"

if [[ ! -f "${SRC_CONFIG}" ]]; then
  echo "Missing template config: ${SRC_CONFIG}" >&2
  exit 1
fi

if [[ ! -f "${SRC_STATUS}" ]]; then
  echo "Missing status script: ${SRC_STATUS}" >&2
  exit 1
fi

install -d -m 0700 "${HOME}/.config/sway"
install -m 0644 "${SRC_CONFIG}" "${DST_CONFIG}"
install -m 0755 "${SRC_STATUS}" "${DST_STATUS}"
echo "Applied: ${SRC_CONFIG} -> ${DST_CONFIG}"
echo "Applied: ${SRC_STATUS} -> ${DST_STATUS}"

sock="$(ss -xlpn 2>/dev/null | awk -v uid="$(id -u)" '$5 ~ "/run/user/"uid"/sway-ipc\\." { print $5; exit }')"
if [[ -n "${sock:-}" ]]; then
  echo "Reloading sway via ${sock}"
  swaymsg -s "${sock}" reload >/dev/null
  echo "Sway config reloaded."
else
  echo "No active sway IPC socket found; config will apply on next session start."
fi
