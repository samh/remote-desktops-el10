#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STACK_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
REPO_DIR="$(cd "${STACK_DIR}/.." && pwd)"
template="${REPO_DIR}/profiles/openbox-tint2/templates/turbovncserver.conf"
output="${1:-$HOME/.vnc/turbovncserver.conf}"
mkdir -p "$(dirname "${output}")"

if [[ ! -f "${template}" ]]; then
  echo "Missing template: ${template}" >&2
  exit 1
fi

cp "${template}" "${output}"

chmod 600 "${output}"
echo "Wrote ${output}"
