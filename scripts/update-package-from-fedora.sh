#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

usage() {
  cat <<'EOF'
Usage: update-package-from-fedora.sh <package> [--branch <name>] [--root <path>] [--include-archives]

Refresh a package's Fedora DistGit packaging snapshot into packages/<package>/.

Options:
  --branch <name>       Override the branch recorded in upstream.yaml
  --root <path>         Override the Fedora source root (default: fedora-rpms)
  --include-archives    Also copy downloaded source archives
  -h, --help            Show this help
EOF
}

trim() {
  local value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s' "${value}"
}

read_yaml_value() {
  local file="$1"
  local key="$2"
  awk -F ':' -v key="${key}" '
    $1 == key {
      sub(/^[^:]*:[[:space:]]*/, "", $0)
      print $0
      exit
    }
  ' "${file}"
}

PACKAGE_NAME="${1:-}"
if [[ -z "${PACKAGE_NAME}" ]]; then
  usage >&2
  exit 1
fi
shift

FEDORA_ROOT="${REPO_DIR}/fedora-rpms"
BRANCH_OVERRIDE=""
INCLUDE_ARCHIVES=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --branch)
      BRANCH_OVERRIDE="$2"
      shift 2
      ;;
    --root)
      FEDORA_ROOT="$2"
      shift 2
      ;;
    --include-archives)
      INCLUDE_ARCHIVES=1
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

PKG_DIR="${REPO_DIR}/packages/${PACKAGE_NAME}"
UPSTREAM_FILE="${PKG_DIR}/upstream.yaml"
if [[ ! -f "${UPSTREAM_FILE}" ]]; then
  echo "Missing upstream metadata: ${UPSTREAM_FILE}" >&2
  exit 1
fi

upstream_type="$(trim "$(read_yaml_value "${UPSTREAM_FILE}" type)")"
upstream_url="$(trim "$(read_yaml_value "${UPSTREAM_FILE}" url)")"
upstream_branch="$(trim "$(read_yaml_value "${UPSTREAM_FILE}" branch)")"
sync_into="$(trim "$(read_yaml_value "${UPSTREAM_FILE}" sync_into)")"

if [[ -n "${BRANCH_OVERRIDE}" ]]; then
  upstream_branch="${BRANCH_OVERRIDE}"
fi

if [[ "${upstream_type}" != "fedora-distgit" ]]; then
  echo "Unsupported upstream type: ${upstream_type}" >&2
  exit 1
fi

SOURCE_DIR="${FEDORA_ROOT}/${PACKAGE_NAME}"
TEMP_DIR=""
if [[ ! -d "${SOURCE_DIR}" ]] || [[ ! -e "${SOURCE_DIR}/.git" ]] || ! git -C "${SOURCE_DIR}" remote get-url origin >/dev/null 2>&1; then
  TEMP_DIR="$(mktemp -d)"
  SOURCE_DIR="${TEMP_DIR}/${PACKAGE_NAME}"
  git clone --depth 1 --branch "${upstream_branch}" "${upstream_url}" "${SOURCE_DIR}" >/dev/null
else
  git -C "${SOURCE_DIR}" fetch origin "${upstream_branch}" >/dev/null
  git -C "${SOURCE_DIR}" checkout "${upstream_branch}" >/dev/null
  git -C "${SOURCE_DIR}" merge --ff-only "origin/${upstream_branch}" >/dev/null
fi

TARGET_DIR="${PKG_DIR}/${sync_into}"
mkdir -p "${TARGET_DIR}"

find "${TARGET_DIR}" -mindepth 1 -maxdepth 1 -type f \
  ! -name '*.tar.*' \
  ! -name '*.src.rpm' \
  -delete

while IFS= read -r -d '' src; do
  base="$(basename "${src}")"
  case "${base}" in
    .git|.gitignore)
      continue
      ;;
    *.tar.*|*.src.rpm)
      if [[ "${INCLUDE_ARCHIVES}" -ne 1 ]]; then
        continue
      fi
      ;;
  esac
  cp -a "${src}" "${TARGET_DIR}/${base}"
done < <(find "${SOURCE_DIR}" -mindepth 1 -maxdepth 1 -type f -print0)

if [[ -n "${TEMP_DIR}" ]]; then
  rm -rf "${TEMP_DIR}"
fi

echo "Refreshed ${PACKAGE_NAME} from Fedora DistGit (${upstream_branch}) into ${TARGET_DIR}"
