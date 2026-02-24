#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TOPDIR="${ROOT_DIR}/rpmbuild"
SPEC="${ROOT_DIR}/wlroots.spec"

"${ROOT_DIR}/scripts/fetch-source.sh"

mkdir -p "${TOPDIR}"/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}
cp -f "${SPEC}" "${TOPDIR}/SPECS/"

export LC_ALL=C.UTF-8
export TZ=UTC

if [[ -n "${SOURCE_DATE_EPOCH:-}" ]]; then
  export SOURCE_DATE_EPOCH
fi

rpmbuild \
  --define "_topdir ${TOPDIR}" \
  -bs "${TOPDIR}/SPECS/$(basename "${SPEC}")"

echo "SRPM output:"
ls -1 "${TOPDIR}/SRPMS"
