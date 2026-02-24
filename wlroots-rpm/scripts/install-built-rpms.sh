#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RPM_DIR="${ROOT_DIR}/rpmbuild/RPMS"

mapfile -t rpms < <(find "${RPM_DIR}" -type f -name 'wlroots*.rpm' | sort)

if [[ "${#rpms[@]}" -eq 0 ]]; then
  echo "No built wlroots RPMs found under ${RPM_DIR}" >&2
  echo "Run: make rpm" >&2
  exit 1
fi

echo "Installing local wlroots RPMs:"
printf '  %s\n' "${rpms[@]}"
sudo dnf -y --disablerepo='TurboVNC*' install "${rpms[@]}"
