#!/usr/bin/env bash
set -euo pipefail

if rpm -q wlroots-devel >/dev/null 2>&1; then
  echo "wlroots-devel is installed"
  exit 0
fi

echo "Missing required package: wlroots-devel >= 0.19.0" >&2
echo "Build/install local wlroots first:" >&2
echo "  make -C ../wlroots-rpm deps rpm install-built" >&2
exit 1
