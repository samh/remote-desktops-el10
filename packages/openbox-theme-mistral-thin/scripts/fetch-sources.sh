#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PKG_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
DISTGIT_DIR="${PKG_DIR}/distgit"
TMP_DIR="$(mktemp -d)"
RPM_URL="https://archive.fedoraproject.org/pub/archive/fedora/linux/releases/40/Everything/x86_64/os/Packages/o/openbox-theme-mistral-thin-0-16.20170125.fc40.noarch.rpm"
RPM_PATH="${TMP_DIR}/openbox-theme-mistral-thin.noarch.rpm"
TARBALL_PATH="${DISTGIT_DIR}/openbox-theme-mistral-thin-20170125.tar.gz"
SRC_ROOT="${TMP_DIR}/openbox-theme-mistral-thin-20170125"

cleanup() {
  rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

curl -L --fail --silent --show-error -o "${RPM_PATH}" "${RPM_URL}"

mkdir -p "${SRC_ROOT}"
(
  cd "${TMP_DIR}"
  rpm2cpio "${RPM_PATH}" | cpio -idmu --quiet "./usr/share/themes/Mistral-Thin"
)
cp -a "${TMP_DIR}/usr/share/themes/Mistral-Thin" "${SRC_ROOT}/"
tar -C "${TMP_DIR}" -czf "${TARBALL_PATH}" "openbox-theme-mistral-thin-20170125"
