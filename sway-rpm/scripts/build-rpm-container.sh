#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IMAGE_TAG="${IMAGE_TAG:-local/sway-rpm-builder:1.11}"
OUT_DIR="${ROOT_DIR}/out"

podman build -f "${ROOT_DIR}/Containerfile" -t "${IMAGE_TAG}" "${ROOT_DIR}"

cid="$(podman create "${IMAGE_TAG}")"
trap 'podman rm -f "${cid}" >/dev/null 2>&1 || true' EXIT

mkdir -p "${OUT_DIR}"
podman cp "${cid}:/work/rpmbuild/RPMS" "${OUT_DIR}/"
podman cp "${cid}:/work/rpmbuild/SRPMS" "${OUT_DIR}/"

echo "Container build artifacts copied to ${OUT_DIR}"
find "${OUT_DIR}" -type f \( -name '*.rpm' -o -name '*.src.rpm' \) | sort
