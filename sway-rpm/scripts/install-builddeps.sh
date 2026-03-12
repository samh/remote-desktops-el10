#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEPS_FILE="${ROOT_DIR}/build-deps.txt"

if [[ ! -f "${DEPS_FILE}" ]]; then
  echo "Missing ${DEPS_FILE}" >&2
  exit 1
fi

mapfile -t deps < <(grep -Ev '^\s*(#|$)' "${DEPS_FILE}")

if [[ "${#deps[@]}" -eq 0 ]]; then
  echo "No dependencies listed in ${DEPS_FILE}" >&2
  exit 1
fi

echo "Installing ${#deps[@]} build dependencies from ${DEPS_FILE}"
sudo dnf -y install "${deps[@]}"
