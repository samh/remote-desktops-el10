#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STACK_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
TEMPLATE="${STACK_DIR}/templates/xstartup.fluxbox"
output="${1:-$HOME/.vnc/xstartup}"

echo "Note: TurboVNC 3.3+ prefers -wm / ~/.vnc/turbovncserver.conf over xstartup."

if [[ ! -f "${TEMPLATE}" ]]; then
  echo "Missing template: ${TEMPLATE}" >&2
  exit 1
fi

mkdir -p "$(dirname "${output}")"
cp "${TEMPLATE}" "${output}"
chmod 700 "${output}"

echo "Wrote ${output} from Fluxbox compatibility template."
