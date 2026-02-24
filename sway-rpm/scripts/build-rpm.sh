#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TOPDIR="${ROOT_DIR}/rpmbuild"
SPEC="${ROOT_DIR}/sway.spec"

"${ROOT_DIR}/scripts/verify-wlroots.sh"
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
  -ba "${TOPDIR}/SPECS/$(basename "${SPEC}")"

echo "RPM output:"
find "${TOPDIR}/RPMS" -type f -name '*.rpm' | sort
echo "SRPM output:"
ls -1 "${TOPDIR}/SRPMS"
