#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
DISTGIT_DIR="${PACKAGE_DIR}/distgit"
SOURCES_FILE="${DISTGIT_DIR}/sources"

line="$(head -n1 "${SOURCES_FILE}")"
filename="${line#*(}"
filename="${filename%%)*}"
checksum="${line##*= }"
version="${filename#lxqt-themes-}"
version="${version%.tar.xz}"
url="https://github.com/lxqt/lxqt-themes/releases/download/${version}/${filename}"

curl -L --fail --output "${DISTGIT_DIR}/${filename}" "${url}"
echo "${checksum}  ${DISTGIT_DIR}/${filename}" | sha256sum -c -