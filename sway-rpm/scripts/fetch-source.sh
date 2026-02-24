#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TOPDIR="${ROOT_DIR}/rpmbuild"
VERSIONS_FILE="${ROOT_DIR}/versions.env"

if [[ ! -f "${VERSIONS_FILE}" ]]; then
  echo "Missing ${VERSIONS_FILE}" >&2
  exit 1
fi

# shellcheck disable=SC1090
source "${VERSIONS_FILE}"

if [[ -z "${SWAY_VERSION:-}" || -z "${SWAY_SOURCE_URL:-}" || -z "${SWAY_SOURCE_SHA256:-}" ]]; then
  echo "versions.env must define SWAY_VERSION, SWAY_SOURCE_URL and SWAY_SOURCE_SHA256" >&2
  exit 1
fi

mkdir -p "${TOPDIR}/SOURCES"
tarball="${TOPDIR}/SOURCES/sway-${SWAY_VERSION}.tar.gz"

if [[ -f "${tarball}" ]]; then
  echo "Using existing ${tarball}"
else
  echo "Downloading ${SWAY_SOURCE_URL}"
  curl -fL --retry 3 --retry-delay 2 -o "${tarball}" "${SWAY_SOURCE_URL}"
fi

echo "${SWAY_SOURCE_SHA256}  ${tarball}" | sha256sum -c -
echo "Source verified: ${tarball}"
