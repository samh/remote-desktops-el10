#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WLROOTS_RPM_DIR="${ROOT_DIR}/wlroots-rpm/rpmbuild/RPMS"
SWAY_RPM_DIR="${ROOT_DIR}/sway-rpm/rpmbuild/RPMS"

dry_run=0
if [[ "${1:-}" == "--dry-run" ]]; then
  dry_run=1
fi

mapfile -t wlroots_rpms < <(
  find "${WLROOTS_RPM_DIR}" -type f -name "wlroots*.rpm" \
    ! -name "*debuginfo*" \
    ! -name "*debugsource*" \
    ! -name "*-devel-*.rpm" \
    | sort
)

mapfile -t sway_rpms < <(
  find "${SWAY_RPM_DIR}" -type f -name "sway*.rpm" \
    ! -name "*debuginfo*" \
    ! -name "*debugsource*" \
    | sort
)

if [[ "${#wlroots_rpms[@]}" -eq 0 ]]; then
  echo "No non-debug wlroots RPMs found under ${WLROOTS_RPM_DIR}" >&2
  echo "Run: make wlroots-rpm" >&2
  exit 1
fi

if [[ "${#sway_rpms[@]}" -eq 0 ]]; then
  echo "No non-debug sway RPMs found under ${SWAY_RPM_DIR}" >&2
  echo "Run: make sway-rpm" >&2
  exit 1
fi

mapfile -t install_rpms < <(
  printf '%s\n' "${wlroots_rpms[@]}" "${sway_rpms[@]}" | sort
)

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

"${dnf_cmd[@]}" -y install "${install_rpms[@]}"
