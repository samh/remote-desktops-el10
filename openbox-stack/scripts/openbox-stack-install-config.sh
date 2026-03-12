#!/usr/bin/env bash
set -euo pipefail

STACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO_DIR="$(cd "${STACK_DIR}/.." && pwd)"
PROFILE_DIR="${REPO_DIR}/profiles/openbox-tint2/config"
TARGET_HOME="${HOME}"
BACKUP_SUFFIX=""
FORCE=0

usage() {
  cat <<'EOF'
Usage: openbox-stack-install-config.sh [options]

Options:
  --home <path>           Target home directory (default: current $HOME)
  --backup-suffix <text>  Explicit suffix for backups
  --force                 Overwrite existing files without backup copies
  -h, --help              Show this help
EOF
}

backup_if_needed() {
  local dest="$1"
  if [[ -e "${dest}" && "${FORCE}" -eq 0 ]]; then
    cp -a "${dest}" "${dest}${BACKUP_SUFFIX}"
    echo "Backed up ${dest} -> ${dest}${BACKUP_SUFFIX}"
  fi
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

if [[ ! -d "${PROFILE_DIR}" ]]; then
  echo "Missing profile config directory: ${PROFILE_DIR}" >&2
  exit 1
fi

if [[ -z "${BACKUP_SUFFIX}" ]]; then
  BACKUP_SUFFIX=".bak.$(date +%Y%m%d%H%M%S)"
fi

openbox_target="${TARGET_HOME}/.config/openbox"
tint2_target="${TARGET_HOME}/.config/tint2"

mkdir -p "${openbox_target}" "${tint2_target}"

for name in autostart menu.xml rc.xml; do
  src="${PROFILE_DIR}/openbox/${name}"
  dest="${openbox_target}/${name}"
  backup_if_needed "${dest}"
  cp -a "${src}" "${dest}"
done

backup_if_needed "${tint2_target}/tint2rc"
cp -a "${PROFILE_DIR}/tint2/tint2rc" "${tint2_target}/tint2rc"

chmod 700 "${openbox_target}/autostart"

echo "Installed Openbox+tint2 profile config to ${TARGET_HOME}/.config"
