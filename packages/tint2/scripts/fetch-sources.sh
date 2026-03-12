#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PKG_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
DISTGIT_DIR="${PKG_DIR}/distgit"

if ! command -v spectool >/dev/null 2>&1; then
  echo "Missing required tool: spectool" >&2
  echo "Install rpmdevtools first." >&2
  exit 1
fi

if [[ ! -f "${DISTGIT_DIR}/tint2.spec" ]]; then
  echo "Missing spec file: ${DISTGIT_DIR}/tint2.spec" >&2
  exit 1
fi

cd "${DISTGIT_DIR}"
spectool -g -C "${DISTGIT_DIR}" tint2.spec
