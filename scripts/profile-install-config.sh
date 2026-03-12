#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./libdesktop.sh
source "${SCRIPT_DIR}/libdesktop.sh"

PROFILE_NAME=""
TARGET_HOME="${HOME}"
BACKUP_SUFFIX=""
FORCE=0

usage() {
  cat <<'EOF'
Usage: profile-install-config.sh --profile <name> [options]

Options:
  --profile <name>       Profile whose config should be installed
  --home <path>          Target home directory (default: current $HOME)
  --backup-suffix <txt>  Explicit suffix for backups
  --force                Overwrite existing files without backup copies
  -h, --help             Show this help
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
    --profile)
      PROFILE_NAME="$2"
      shift 2
      ;;
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

if [[ -z "${PROFILE_NAME}" ]]; then
  echo "--profile is required." >&2
  usage >&2
  exit 1
fi

layout="$(profile_config_layout "${PROFILE_NAME}")"
config_source_rel="$(profile_config_source "${PROFILE_NAME}")"
config_source_dir="$(profile_dir "${PROFILE_NAME}")/${config_source_rel}"

if [[ ! -d "${config_source_dir}" ]]; then
  echo "Missing config directory: ${config_source_dir}" >&2
  exit 1
fi

if [[ -z "${BACKUP_SUFFIX}" ]]; then
  BACKUP_SUFFIX=".bak.$(date +%Y%m%d%H%M%S)"
fi

case "${layout}" in
  home-subdir)
    target_subdir="$(profile_config_target_subdir "${PROFILE_NAME}")"
    if [[ -z "${target_subdir}" ]]; then
      echo "Missing config_target_subdir for profile ${PROFILE_NAME}" >&2
      exit 1
    fi

    target_dir="${TARGET_HOME}/${target_subdir}"
    mkdir -p "${target_dir}"

    while IFS= read -r src; do
      dest="${target_dir}/$(basename "${src}")"
      backup_if_needed "${dest}"
      cp -a "${src}" "${dest}"
      if [[ -x "${src}" ]]; then
        chmod 700 "${dest}"
      fi
    done < <(find "${config_source_dir}" -maxdepth 1 -type f | sort)
    ;;
  xdg-tree)
    target_dir="${TARGET_HOME}/.config"
    mkdir -p "${target_dir}"

    while IFS= read -r src; do
      rel="${src#${config_source_dir}/}"
      dest="${target_dir}/${rel}"
      mkdir -p "$(dirname "${dest}")"
      backup_if_needed "${dest}"
      cp -a "${src}" "${dest}"
      if [[ -x "${src}" ]]; then
        chmod 700 "${dest}"
      fi
    done < <(find "${config_source_dir}" -type f | sort)
    ;;
  *)
    echo "Unsupported config_layout for profile ${PROFILE_NAME}: ${layout}" >&2
    exit 1
    ;;
esac

echo "Installed ${PROFILE_NAME} config to ${TARGET_HOME}"
