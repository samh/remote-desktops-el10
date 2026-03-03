#!/usr/bin/env bash
set -euo pipefail

STACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SPEC_FILE="${STACK_DIR}/tint2-rpm/tint2.spec"
OUT_ROOT="${STACK_DIR}/out/tint2"
SOURCES_DIR="${OUT_ROOT}/sources"
SRPM_DIR="${OUT_ROOT}/srpm"
RPM_DIR="${OUT_ROOT}/rpm"
MOCK_TARGET="epel-10-x86_64"
SRPM_ONLY=0

usage() {
  cat <<'EOF'
Usage: openbox-stack-build-tint2.sh [options]

Options:
  --mock-target <target>  Mock target (default: epel-10-x86_64)
  --out <path>            Output root (default: openbox-stack/out/tint2)
  --srpm-only             Build SRPM only (skip mock --rebuild)
  -h, --help              Show this help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --mock-target)
      MOCK_TARGET="$2"
      shift 2
      ;;
    --out)
      OUT_ROOT="$2"
      SOURCES_DIR="${OUT_ROOT}/sources"
      SRPM_DIR="${OUT_ROOT}/srpm"
      RPM_DIR="${OUT_ROOT}/rpm"
      shift 2
      ;;
    --srpm-only)
      SRPM_ONLY=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [[ ! -f "${SPEC_FILE}" ]]; then
  echo "Missing spec file: ${SPEC_FILE}" >&2
  exit 1
fi

mkdir -p "${SOURCES_DIR}" "${SRPM_DIR}" "${RPM_DIR}"

source_url="$(rpmspec -P "${SPEC_FILE}" | awk '
  /^Source0:[[:space:]]*/ && url == "" { url = $2 }
  END { if (url != "") print url }
')"
if [[ -z "${source_url}" ]]; then
  echo "Unable to resolve Source0 from ${SPEC_FILE}" >&2
  exit 1
fi

source_file="${SOURCES_DIR}/$(basename "${source_url}")"
if [[ ! -f "${source_file}" ]]; then
  echo "Downloading source: ${source_url}"
  curl -fL --retry 3 --retry-delay 2 -o "${source_file}" "${source_url}"
else
  echo "Using cached source: ${source_file}"
fi

echo "Building tint2 SRPM (${MOCK_TARGET})"
mock --root "${MOCK_TARGET}" --buildsrpm \
  --spec "${SPEC_FILE}" \
  --sources "${SOURCES_DIR}" \
  --resultdir "${SRPM_DIR}"

srpm_path="$(find "${SRPM_DIR}" -maxdepth 1 -type f -name '*.src.rpm' -printf '%T@ %p\n' | sort -nr | head -n1 | cut -d' ' -f2-)"
if [[ -z "${srpm_path}" ]]; then
  echo "No SRPM produced in ${SRPM_DIR}" >&2
  exit 1
fi

echo "SRPM: ${srpm_path}"
if [[ "${SRPM_ONLY}" -eq 1 ]]; then
  exit 0
fi

echo "Building tint2 RPMs (${MOCK_TARGET})"
mock --root "${MOCK_TARGET}" --rebuild "${srpm_path}" --resultdir "${RPM_DIR}"

echo "RPM output:"
find "${RPM_DIR}" -maxdepth 1 -type f -name '*.rpm' | sort
