#!/usr/bin/env bash
set -euo pipefail

STACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO_DIR="$(cd "${STACK_DIR}/.." && pwd)"
PACKAGES_FILE="${STACK_DIR}/packages.yaml"
DEFAULT_BRANCH=""

usage() {
  cat <<'EOF'
Usage: fluxbox-stack-sync-sources.sh [options]

Options:
  --packages <path>     Path to packages.yaml (default: fluxbox-stack/packages.yaml)
  --branch <name>       Override branch for all packages
  -h, --help            Show this help
EOF
}

parse_package_names() {
  local file="$1"
  awk '
    function trim(s) {
      sub(/^[[:space:]]+/, "", s)
      sub(/[[:space:]]+$/, "", s)
      gsub(/^["\047]|["\047]$/, "", s)
      return s
    }
    /^[[:space:]]*-[[:space:]]*name:[[:space:]]*/ {
      line = $0
      sub(/^[^:]*:[[:space:]]*/, "", line)
      print trim(line)
    }
  ' "${file}"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --packages)
      PACKAGES_FILE="$2"
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

if [[ ! -f "${PACKAGES_FILE}" ]]; then
  echo "Package manifest not found: ${PACKAGES_FILE}" >&2
  exit 1
fi

mapfile -t packages < <(parse_package_names "${PACKAGES_FILE}")
if [[ "${#packages[@]}" -eq 0 ]]; then
  echo "No package entries found in ${PACKAGES_FILE}" >&2
  exit 1
fi

for pkg in "${packages[@]}"; do
  cmd=("${REPO_DIR}/scripts/update-package-from-fedora.sh" "${pkg}")
  if [[ -n "${DEFAULT_BRANCH}" ]]; then
    cmd+=(--branch "${DEFAULT_BRANCH}")
  fi
  "${cmd[@]}"
done

echo "Package refresh complete."
