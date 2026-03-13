#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
DISTGIT_DIR="${PACKAGE_DIR}/distgit"
SOURCES_FILE="${DISTGIT_DIR}/sources"

read -r checksum filename < "${SOURCES_FILE}"
url="https://src.fedoraproject.org/repo/pkgs/rpms/libwnck/${filename}/md5/${checksum}/${filename}"

curl -L --fail --output "${DISTGIT_DIR}/${filename}" "${url}"
echo "${checksum}  ${DISTGIT_DIR}/${filename}" | md5sum -c -
