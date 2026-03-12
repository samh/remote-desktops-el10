#!/usr/bin/env bash
set -euo pipefail

STACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_ROOT="${STACK_DIR}/out/all-rpms"
dry_run=0
assume_yes=0

usage() {
  cat <<'EOF'
Usage: fluxbox-stack-install-built.sh [options]

Options:
  --out <path>   RPM output root (default: fluxbox-stack/out/all-rpms)
  --dry-run      Print selected RPMs only
  --yes          Pass -y to dnf (non-interactive install)
  -h, --help     Show this help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --out)
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

if [[ ! -d "${OUT_ROOT}" ]]; then
  echo "RPM output directory not found: ${OUT_ROOT}" >&2
  echo "Run: just --justfile fluxbox-stack/justfile build" >&2
  exit 1
fi

mapfile -t install_rpms < <(
  find "${OUT_ROOT}" -maxdepth 1 -type f -name '*.rpm' \
    ! -name '*.src.rpm' \
    ! -name '*debuginfo*' \
    ! -name '*debugsource*' \
    ! -name '*-devel-*.rpm' \
    ! -name '*-pulseaudio-*.rpm' \
    | sort
)

if [[ "${#install_rpms[@]}" -eq 0 ]]; then
  echo "No installable RPMs found under ${OUT_ROOT}" >&2
  exit 1
fi

echo "Local RPMs selected for installation:"
printf '  %s\n' "${install_rpms[@]}"

if [[ "${dry_run}" -eq 1 ]]; then
  echo
  echo "Dry run only; no install performed."
  exit 0
fi

dnf_cmd=(sudo dnf)
if [[ "${EUID}" -eq 0 ]]; then
  dnf_cmd=(dnf)
fi

if [[ "${assume_yes}" -eq 1 ]]; then
  dnf_cmd+=(-y)
fi

"${dnf_cmd[@]}" install "${install_rpms[@]}"
