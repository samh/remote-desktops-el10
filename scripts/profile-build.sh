#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./libdesktop.sh
source "${SCRIPT_DIR}/libdesktop.sh"

PROFILE_NAME=""
OUT_ROOT="${DESKTOP_REPO_DIR}/out"
MOCK_TARGET="epel-10-x86_64"
CONTINUE_ON_ERROR=0
FORCE_REBUILD=0

usage() {
  cat <<'EOF'
Usage: profile-build.sh --profile <name> [options]

Options:
  --profile <name>      Profile to build
  --out-root <path>     Output root (default: repo/out)
  --mock-target <name>  Mock target (default: epel-10-x86_64)
  --continue-on-error   Continue with later packages if a build fails
  --force-rebuild       Rebuild packages even if binary RPMs already exist
  -h, --help            Show this help
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
    --mock-target)
      MOCK_TARGET="$2"
      shift 2
      ;;
    --continue-on-error)
      CONTINUE_ON_ERROR=1
      shift
      ;;
    --force-rebuild)
      FORCE_REBUILD=1
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
cmd=("${DESKTOP_REPO_DIR}/scripts/package-build.sh" --out-root "${OUT_ROOT}" --mock-target "${MOCK_TARGET}")
if [[ "${CONTINUE_ON_ERROR}" -eq 1 ]]; then
  cmd+=(--continue-on-error)
fi
if [[ "${FORCE_REBUILD}" -eq 1 ]]; then
  cmd+=(--force-rebuild)
fi
for package_name in "${packages[@]}"; do
  cmd+=(--package "${package_name}")
done

"${cmd[@]}"

