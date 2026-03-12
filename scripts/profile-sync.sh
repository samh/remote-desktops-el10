#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./libdesktop.sh
source "${SCRIPT_DIR}/libdesktop.sh"

PROFILE_NAME=""
BRANCH_OVERRIDE=""

usage() {
  cat <<'EOF'
Usage: profile-sync.sh --profile <name> [--branch <name>]

Options:
  --profile <name>  Profile to refresh
  --branch <name>   Override branch for Fedora-backed packages
  -h, --help        Show this help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --profile)
      PROFILE_NAME="$2"
      shift 2
      ;;
    --branch)
      BRANCH_OVERRIDE="$2"
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

mapfile -t packages < <(profile_packages "${PROFILE_NAME}")
cmd=("${DESKTOP_REPO_DIR}/scripts/package-sync.sh")
for package_name in "${packages[@]}"; do
  cmd+=(--package "${package_name}")
done
if [[ -n "${BRANCH_OVERRIDE}" ]]; then
  cmd+=(--branch "${BRANCH_OVERRIDE}")
fi

"${cmd[@]}"

