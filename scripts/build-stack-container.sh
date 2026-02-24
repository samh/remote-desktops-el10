#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IMAGE="${CONTAINER_IMAGE:-almalinux:10.1}"

cd "${ROOT_DIR}"

echo "Using container image: ${IMAGE}"
podman pull "${IMAGE}" >/dev/null

podman run --rm \
  -v "${ROOT_DIR}:/work:Z" \
  -w /work \
  "${IMAGE}" \
  /bin/bash -lc '
    set -euo pipefail

    dnf -y install epel-release

    mapfile -t deps < <(
      awk "!/^[[:space:]]*($|#)/ {print}" wlroots-rpm/build-deps.txt sway-rpm/build-deps.txt \
      | sort -u
    )
    dnf -y install "${deps[@]}"

    cd /work/wlroots-rpm
    ./scripts/build-rpm.sh

    dnf -y install /work/wlroots-rpm/rpmbuild/RPMS/*/wlroots*.rpm

    cd /work/sway-rpm
    ./scripts/build-rpm.sh
  '

echo "Build complete."
echo "wlroots RPMs:"
find "${ROOT_DIR}/wlroots-rpm/rpmbuild/RPMS" -type f -name "*.rpm" | sort || true
echo "sway RPMs:"
find "${ROOT_DIR}/sway-rpm/rpmbuild/RPMS" -type f -name "*.rpm" | sort || true
