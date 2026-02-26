#!/usr/bin/env bash
set -euo pipefail

color="${1:-#e9eef3}"
output="${2:-$HOME/.icewm/prefoverride}"

mkdir -p "$(dirname "${output}")"
tmp="$(mktemp)"

if [[ -f "${output}" ]]; then
  awk '
    !/^[[:space:]]*DesktopBackgroundColor[[:space:]]*=/ &&
    !/^[[:space:]]*DesktopBackgroundImage[[:space:]]*=/ &&
    !/^[[:space:]]*DesktopBackgroundCenter[[:space:]]*=/ &&
    !/^[[:space:]]*DesktopBackgroundScaled[[:space:]]*=/
  ' "${output}" > "${tmp}"
else
  : > "${tmp}"
fi

{
  echo ""
  echo "# Managed by turbovnc-x11-desktop/scripts/set-icewm-background.sh"
  echo "DesktopBackgroundColor=\"${color}\""
  echo "DesktopBackgroundImage=\"\""
  echo "DesktopBackgroundCenter=0"
  echo "DesktopBackgroundScaled=0"
} >> "${tmp}"

mv "${tmp}" "${output}"
chmod 600 "${output}" || true

echo "Wrote ${output} with IceWM background color ${color}."
echo "Reconnect through your normal SSH/session-manager flow to apply."
