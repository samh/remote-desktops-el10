#!/usr/bin/env bash
set -euo pipefail

STACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO_DIR="$(cd "${STACK_DIR}/.." && pwd)"
CONFIG_DIR="${REPO_DIR}/profiles/fluxbox/config"
TARGET_HOME="${HOME}"
BACKUP_SUFFIX=""
FORCE=0

usage() {
  cat <<'EOF'
Usage: fluxbox-stack-install-config.sh [options]

Options:
  --home <path>           Target home directory (default: current $HOME)
  --backup-suffix <text>  Explicit suffix for backups
  --force                 Overwrite existing files without backup copies
  -h, --help              Show this help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --home)
      TARGET_HOME="$2"
      shift 2
      ;;
    --backup-suffix)
      BACKUP_SUFFIX="$2"
      shift 2
      ;;
    --force)
      FORCE=1
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

if [[ ! -d "${CONFIG_DIR}" ]]; then
  echo "Missing config directory: ${CONFIG_DIR}" >&2
  exit 1
fi

if [[ -z "${BACKUP_SUFFIX}" ]]; then
  BACKUP_SUFFIX=".bak.$(date +%Y%m%d%H%M%S)"
fi

target_dir="${TARGET_HOME}/.fluxbox"
mkdir -p "${target_dir}"

for name in init keys menu startup; do
  src="${CONFIG_DIR}/${name}"
  dest="${target_dir}/${name}"
  if [[ -e "${dest}" && "${FORCE}" -eq 0 ]]; then
    cp -a "${dest}" "${dest}${BACKUP_SUFFIX}"
    echo "Backed up ${dest} -> ${dest}${BACKUP_SUFFIX}"
  fi
  cp -a "${src}" "${dest}"
done

chmod 700 "${target_dir}/startup"

echo "Installed Fluxbox config to ${target_dir}"
