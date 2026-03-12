#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./libdesktop.sh
source "${SCRIPT_DIR}/libdesktop.sh"

PROFILE_NAME=""
OUT_ROOT="${DESKTOP_REPO_DIR}/out"
dry_run=0
assume_yes=0

usage() {
  cat <<'EOF'
Usage: profile-install-built.sh --profile <name> [options]

Options:
  --profile <name>   Profile to install from local build outputs
  --out-root <path>  Output root (default: repo/out)
  --dry-run          Print selected RPMs only
  --yes              Pass -y to dnf
  -h, --help         Show this help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --profile)
      PROFILE_NAME="$2"
      shift 2
      ;;
    --out-root)
      OUT_ROOT="$2"
      shift 2
      ;;
    --dry-run)
      dry_run=1
      shift
      ;;
    --yes)
      assume_yes=1
      shift
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
cmd=("${DESKTOP_REPO_DIR}/scripts/package-install-built.sh" --out-root "${OUT_ROOT}")
if [[ "${dry_run}" -eq 1 ]]; then
  cmd+=(--dry-run)
fi
if [[ "${assume_yes}" -eq 1 ]]; then
  cmd+=(--yes)
fi
for package_name in "${packages[@]}"; do
  cmd+=(--package "${package_name}")
done

"${cmd[@]}"

