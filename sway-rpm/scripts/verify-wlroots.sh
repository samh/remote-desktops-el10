#!/usr/bin/env bash
set -euo pipefail

if rpm -q --quiet 'wlroots-devel >= 0.19.0'; then
  echo "wlroots-devel >= 0.19.0 is installed"
  exit 0
fi

echo "Missing required package: wlroots-devel >= 0.19.0" >&2
echo "Build/install local wlroots first:" >&2
echo "  make -C ../wlroots-rpm deps rpm install-built" >&2
exit 1
