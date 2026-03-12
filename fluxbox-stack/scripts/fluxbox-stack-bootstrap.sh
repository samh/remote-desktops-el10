#!/usr/bin/env bash
set -euo pipefail

pkgs=(
  createrepo_c
  dnf-plugins-core
  fedpkg
  git
  just
  mock
  rpmdevtools
)

echo "Installing Fluxbox stack prerequisites:"
printf ' - %s\n' "${pkgs[@]}"
sudo dnf install -y "${pkgs[@]}"

echo
echo "Refreshing root-owned DNF metadata, including TurboVNC..."
sudo dnf makecache --refresh

echo
echo "Checking TurboVNC repo details..."
sudo dnf repoinfo TurboVNC

echo
echo "Bootstrap complete."
