#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./libdesktop.sh
source "${SCRIPT_DIR}/libdesktop.sh"

PROFILE_NAME=""
OUTPUT_PATH="${HOME}/.vnc/xstartup"

usage() {
  cat <<'EOF'
Usage: profile-write-xstartup.sh --profile <name> [--output <path>]

Options:
  --profile <name>  Profile to write compatibility xstartup for
  --output <path>   Output path (default: ~/.vnc/xstartup)
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

template_rel="$(profile_xstartup_template "${PROFILE_NAME}")"
if [[ -z "${template_rel}" ]]; then
  echo "Profile ${PROFILE_NAME} does not define an xstartup template." >&2
  exit 1
fi

template_path="$(profile_dir "${PROFILE_NAME}")/${template_rel}"
if [[ ! -f "${template_path}" ]]; then
  echo "Missing template: ${template_path}" >&2
  exit 1
fi

mkdir -p "$(dirname "${OUTPUT_PATH}")"
cp "${template_path}" "${OUTPUT_PATH}"
chmod 700 "${OUTPUT_PATH}"

echo "Wrote ${OUTPUT_PATH} from ${PROFILE_NAME} compatibility template."
