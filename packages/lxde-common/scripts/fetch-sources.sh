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
url="https://src.fedoraproject.org/repo/pkgs/rpms/lxde-common/${filename}/sha512/${checksum}/${filename}"

curl -L --fail --output "${DISTGIT_DIR}/${filename}" "${url}"
echo "${checksum}  ${DISTGIT_DIR}/${filename}" | sha512sum -c -
