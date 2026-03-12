#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./libdesktop.sh
source "${SCRIPT_DIR}/libdesktop.sh"

OUT_ROOT="${DESKTOP_REPO_DIR}/out"
dry_run=0
assume_yes=0
declare -a requested_packages=()

usage() {
  cat <<'EOF'
Usage: package-install-built.sh --package <name> [--package <name> ...] [options]

Options:
  --package <name>   Package to install from local build outputs
  --out-root <path>  Output root (default: repo/out)
  --dry-run          Print selected RPMs only
  --yes              Pass -y to dnf
  -h, --help         Show this help
EOF
}

matches_exclude_glob() {
  local rpm_name="$1"
  shift
  local glob
  for glob in "$@"; do
    [[ -z "${glob}" ]] && continue
    if [[ "${rpm_name}" == ${glob} ]]; then
      return 0
    fi
  done
  return 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --package)
      requested_packages+=("$2")
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

if [[ "${#requested_packages[@]}" -eq 0 ]]; then
  echo "At least one --package is required." >&2
  usage >&2
  exit 1
fi

install_rpms=()
for package_name in "${requested_packages[@]}"; do
  mapfile -t candidate_rpms < <(package_binary_rpms "${OUT_ROOT}" "${package_name}")
  if [[ "${#candidate_rpms[@]}" -eq 0 ]]; then
    echo "No built RPMs found for package ${package_name} under ${OUT_ROOT}/packages/${package_name}/rpms" >&2
    exit 1
  fi

  mapfile -t exclude_globs < <(package_install_exclude_globs "${package_name}")
  for rpm_path in "${candidate_rpms[@]}"; do
    rpm_name="$(basename "${rpm_path}")"
    if matches_exclude_glob "${rpm_name}" "${exclude_globs[@]}"; then
      continue
    fi
    install_rpms+=("${rpm_path}")
  done
done

if [[ "${#install_rpms[@]}" -eq 0 ]]; then
  echo "No installable RPMs selected." >&2
  exit 1
fi

mapfile -t install_rpms < <(printf '%s\n' "${install_rpms[@]}" | sort -u)

echo "Local RPMs selected for installation:"
printf '  %s\n' "${install_rpms[@]}"

if [[ "${dry_run}" -eq 1 ]]; then
  echo
  echo "Dry run only; no install performed."
  exit 0
fi

if [[ "${EUID}" -eq 0 ]]; then
  dnf_cmd=(dnf)
else
  dnf_cmd=(sudo dnf)
fi

if [[ "${assume_yes}" -eq 1 ]]; then
  dnf_cmd+=(-y)
fi

"${dnf_cmd[@]}" install "${install_rpms[@]}"

