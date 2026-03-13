#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./libdesktop.sh
source "${SCRIPT_DIR}/libdesktop.sh"

PROFILE_NAME=""
OUTPUT_PATH="${HOME}/.vnc/turbovncserver.conf"

usage() {
  cat <<'EOF'
Usage: profile-write-turbovnc-conf.sh --profile <name> [--output <path>]

Options:
  --profile <name>  Profile to write config for
  --output <path>   Output path (default: ~/.vnc/turbovncserver.conf)
  -h, --help        Show this help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --profile)
      PROFILE_NAME="$2"
      shift 2
      ;;
    --output)
      OUTPUT_PATH="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [[ -z "${PROFILE_NAME}" ]]; then
  echo "--profile is required." >&2
  usage >&2
  exit 1
fi

wm_name="$(profile_wm "${PROFILE_NAME}")"
if [[ -z "${wm_name}" ]]; then
  echo "Missing wm value for profile ${PROFILE_NAME}" >&2
  exit 1
fi

mkdir -p "$(dirname "${OUTPUT_PATH}")"
tmp="$(mktemp)"

if [[ -f "${OUTPUT_PATH}" ]]; then
  awk '
    !/^[[:space:]]*\$wm[[:space:]]*=/ &&
    !/^[[:space:]]*# Managed by (scripts\/profile-write-turbovnc-conf\.sh|fluxbox-stack\/scripts\/fluxbox-stack-write-turbovnc-conf\.sh)/
  ' "${OUTPUT_PATH}" > "${tmp}"
else
  : > "${tmp}"
fi

{
  echo ""
  echo "# Managed by scripts/profile-write-turbovnc-conf.sh for profile ${PROFILE_NAME}"
  echo "\$wm=\"${wm_name}\";"
} >> "${tmp}"

mv "${tmp}" "${OUTPUT_PATH}"
chmod 600 "${OUTPUT_PATH}" || true

echo "Wrote ${OUTPUT_PATH} with \$wm=\"${wm_name}\"."
echo "Important: existing TurboVNC sessions keep their current WM."
