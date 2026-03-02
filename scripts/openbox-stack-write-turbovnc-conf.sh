#!/usr/bin/env bash
set -euo pipefail

output="${1:-$HOME/.vnc/turbovncserver.conf}"
mkdir -p "$(dirname "${output}")"

cat > "${output}" <<'EOF'
# Managed by scripts/openbox-stack-write-turbovnc-conf.sh
$wm="openbox";
EOF

chmod 600 "${output}"
echo "Wrote ${output}"
