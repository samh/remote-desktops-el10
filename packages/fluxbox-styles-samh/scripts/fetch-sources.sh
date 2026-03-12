#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
DISTGIT_DIR="${PACKAGE_DIR}/distgit"
TARBALL="${DISTGIT_DIR}/fluxbox-styles-samh-0.1.0.tar.gz"

mkdir -p "${DISTGIT_DIR}"
tar -C "${PACKAGE_DIR}" -czf "${TARBALL}" \
  --transform 's,^,fluxbox-styles-samh-0.1.0/,' \
  styles

echo "Wrote ${TARBALL}"
