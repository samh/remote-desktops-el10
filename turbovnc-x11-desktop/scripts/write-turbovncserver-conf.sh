#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 || $# -gt 2 ]]; then
  echo "Usage: $0 {icewm|gnome} [output_path]" >&2
  exit 1
fi

profile="$1"
output="${2:-$HOME/.vnc/turbovncserver.conf}"

case "${profile}" in
  icewm) wm="icewm" ;;
  gnome) wm="gnome" ;;
  *)
    echo "Unsupported profile: ${profile}" >&2
    echo "Valid values: icewm, gnome" >&2
    exit 1
    ;;
esac

mkdir -p "$(dirname "${output}")"
tmp="$(mktemp)"

if [[ -f "${output}" ]]; then
  awk '!/^[[:space:]]*\\$wm[[:space:]]*=/' "${output}" > "${tmp}"
else
  : > "${tmp}"
fi

{
  echo ""
  echo "# Managed by turbovnc-x11-desktop/scripts/write-turbovncserver-conf.sh"
  echo "\$wm=\"${wm}\";"
} >> "${tmp}"

mv "${tmp}" "${output}"
chmod 600 "${output}" || true

echo "Wrote ${output} with \$wm=\"${wm}\"."
echo "Important: existing TurboVNC sessions keep their current WM."
echo "To apply, end your current session via your normal SSH/session-manager flow"
echo "and reconnect so it starts a new TurboVNC session."
