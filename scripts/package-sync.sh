#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./libdesktop.sh
source "${SCRIPT_DIR}/libdesktop.sh"

DEFAULT_BRANCH=""
declare -a packages=()

usage() {
  cat <<'EOF'
Usage: package-sync.sh --package <name> [--package <name> ...] [--branch <name>]

Options:
  --package <name>  Package to refresh from its upstream metadata
  --branch <name>   Override branch for Fedora-backed packages
  -h, --help        Show this help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --package)
      packages+=("$2")
      shift 2
      ;;
    --branch)
      DEFAULT_BRANCH="$2"
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

if [[ "${#packages[@]}" -eq 0 ]]; then
  echo "At least one --package is required." >&2
  usage >&2
  exit 1
fi

for package_name in "${packages[@]}"; do
  upstream_type="$(package_upstream_type "${package_name}" || true)"
  case "${upstream_type}" in
    fedora-distgit)
      cmd=("${DESKTOP_REPO_DIR}/scripts/update-package-from-fedora.sh" "${package_name}")
      if [[ -n "${DEFAULT_BRANCH}" ]]; then
        cmd+=(--branch "${DEFAULT_BRANCH}")
      fi
      "${cmd[@]}"
      ;;
    "")
      echo "Missing upstream metadata for package: ${package_name}" >&2
      exit 1
      ;;
    *)
      echo "Skipping ${package_name}: upstream type ${upstream_type} does not support sync."
      ;;
  esac
done

