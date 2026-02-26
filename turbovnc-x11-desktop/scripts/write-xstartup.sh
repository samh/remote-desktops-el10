#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
TEMPLATE_DIR="${ROOT_DIR}/templates"

if [[ $# -lt 1 || $# -gt 2 ]]; then
  echo "Usage: $0 {icewm|gnome} [output_path]" >&2
  exit 1
fi

profile="$1"
output="${2:-$HOME/.vnc/xstartup}"

echo "Note: TurboVNC 3.3+ prefers -wm / ~/.vnc/turbovncserver.conf over xstartup."

case "${profile}" in
  icewm)
    template="${TEMPLATE_DIR}/xstartup.icewm"
    ;;
  gnome)
    template="${TEMPLATE_DIR}/xstartup.gnome"
    ;;
  *)
    echo "Unsupported profile: ${profile}" >&2
    echo "Valid values: icewm, gnome" >&2
    exit 1
    ;;
esac

if [[ ! -f "${template}" ]]; then
  echo "Missing template: ${template}" >&2
  exit 1
fi

mkdir -p "$(dirname "${output}")"
cp "${template}" "${output}"
chmod 700 "${output}"

echo "Wrote ${output} from ${profile} profile template."
