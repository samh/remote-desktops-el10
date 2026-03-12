#!/usr/bin/env bash
set -euo pipefail

output="${1:-$HOME/.vnc/turbovncserver.conf}"
mkdir -p "$(dirname "${output}")"
tmp="$(mktemp)"

if [[ -f "${output}" ]]; then
  awk '!/^[[:space:]]*\\$wm[[:space:]]*=/' "${output}" > "${tmp}"
else
  : > "${tmp}"
fi

{
  echo ""
  echo "# Managed by fluxbox-stack/scripts/fluxbox-stack-write-turbovnc-conf.sh"
  echo "\$wm=\"fluxbox\";"
} >> "${tmp}"

mv "${tmp}" "${output}"
chmod 600 "${output}" || true

echo "Wrote ${output} with \$wm=\"fluxbox\"."
echo "Important: existing TurboVNC sessions keep their current WM."
