#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./libdesktop.sh
source "${SCRIPT_DIR}/libdesktop.sh"

OUT_ROOT="${DESKTOP_REPO_DIR}/out"
MOCK_TARGET="epel-10-x86_64"
CONTINUE_ON_ERROR=0
FORCE_REBUILD=0
REFRESH_LOCAL_REPO_ONLY=0
SRPM_ONLY=0
LOCAL_REPO_DIR=""
declare -a requested_packages=()
declare -a requested_srpm_paths=()

log_info() {
  if [[ "${SRPM_ONLY}" -eq 1 ]]; then
    printf '%s\n' "$*" >&2
  else
    printf '%s\n' "$*"
  fi
}

is_requested_package() {
  local needle="$1"
  local package_name
  for package_name in "${requested_packages[@]}"; do
    if [[ "${package_name}" == "${needle}" ]]; then
      return 0
    fi
  done
  return 1
}

usage() {
  cat <<'EOF'
Usage: package-build.sh --package <name> [--package <name> ...] [options]

Options:
  --package <name>       Package to build; may be passed multiple times
  --out-root <path>      Output root (default: repo/out)
  --mock-target <target> Mock target (default: epel-10-x86_64)
  --continue-on-error    Continue with later packages if a build fails
  --force-rebuild        Rebuild packages even if binary RPMs already exist
  --srpm-only           Stop after generating SRPMs
  --refresh-localrepo    Rebuild out/localrepo only
  --local-repo <path>    Local repo path passed to mock via --addrepo
  -h, --help             Show this help
EOF
}

fetch_sources() {
  local package_name="$1"
  local spec_path="$2"
  local distgit_dir
  distgit_dir="$(package_distgit_dir "${package_name}")"
  local fetch_script=""

  fetch_script="$(package_fetch_script "${package_name}" || true)"
  if [[ -n "${fetch_script}" ]]; then
    "${fetch_script}"
    return 0
  fi

  if command -v spectool >/dev/null 2>&1; then
    spectool -g -C "${distgit_dir}" "${spec_path}"
  fi
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --package)
      requested_packages+=("$2")
      shift 2
      ;;
    --out-root)
      OUT_ROOT="$2"
      shift 2
      ;;
    --mock-target)
      MOCK_TARGET="$2"
      shift 2
      ;;
    --continue-on-error)
      CONTINUE_ON_ERROR=1
      shift
      ;;
    --force-rebuild)
      FORCE_REBUILD=1
      shift
      ;;
    --srpm-only)
      SRPM_ONLY=1
      shift
      ;;
    --refresh-localrepo)
      REFRESH_LOCAL_REPO_ONLY=1
      shift
      ;;
    --local-repo)
      LOCAL_REPO_DIR="$2"
      shift 2
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

if [[ -z "${LOCAL_REPO_DIR}" ]]; then
  LOCAL_REPO_DIR="${OUT_ROOT}/localrepo"
fi

mkdir -p "${OUT_ROOT}/packages"

  if [[ "${REFRESH_LOCAL_REPO_ONLY}" -eq 1 ]]; then
  refresh_local_repo "${OUT_ROOT}" "${LOCAL_REPO_DIR}" || true
  log_info "Refreshed ${LOCAL_REPO_DIR}."
  exit 0
fi

if [[ "${#requested_packages[@]}" -eq 0 ]]; then
  echo "At least one --package is required." >&2
  usage >&2
  exit 1
fi

mapfile -t build_order < <(resolve_package_order "${requested_packages[@]}")
mapfile -t mock_sudo < <(mock_prefix)

failures=()
local_repo_ready=0
if refresh_local_repo "${OUT_ROOT}" "${LOCAL_REPO_DIR}"; then
  local_repo_ready=1
fi

for package_name in "${build_order[@]}"; do
  distgit_dir="$(package_distgit_dir "${package_name}")"
  spec_path="$(package_spec_file "${package_name}")"
  pkg_out_root="${OUT_ROOT}/packages/${package_name}"
  pkg_log_dir="${pkg_out_root}/logs"
  pkg_srpm_dir="${pkg_out_root}/srpm-result"
  pkg_result_dir="${pkg_out_root}/mock-result"
  pkg_rpm_dir="${pkg_out_root}/rpms"
  mkdir -p "${pkg_log_dir}" "${pkg_srpm_dir}" "${pkg_result_dir}" "${pkg_rpm_dir}"

  if [[ ! -d "${distgit_dir}" ]]; then
    echo "Missing package tree for ${package_name}: ${distgit_dir}" >&2
    if [[ "${CONTINUE_ON_ERROR}" -eq 1 ]]; then
      failures+=("${package_name}:missing-source")
      continue
    fi
    exit 1
  fi

  if [[ -z "${spec_path}" ]]; then
    echo "No spec file found for ${package_name} under ${distgit_dir}" >&2
    if [[ "${CONTINUE_ON_ERROR}" -eq 1 ]]; then
      failures+=("${package_name}:missing-spec")
      continue
    fi
    exit 1
  fi

  if [[ "${FORCE_REBUILD}" -eq 0 ]]; then
    if [[ "${SRPM_ONLY}" -eq 1 ]]; then
      mapfile -t existing_srpms < <(find "${pkg_srpm_dir}" -maxdepth 1 -type f -name '*.src.rpm' | sort)
      if [[ "${#existing_srpms[@]}" -gt 0 ]]; then
        srpm_path="${existing_srpms[$((${#existing_srpms[@]} - 1))]}"
        if is_requested_package "${package_name}"; then
          requested_srpm_paths+=("${srpm_path}")
        fi
        log_info "==> [${package_name}] SRPM already built, skipping (use --force-rebuild to rebuild)"
        continue
      fi
    else
      mapfile -t existing_pkg_rpms < <(find "${pkg_rpm_dir}" -maxdepth 1 -type f -name '*.rpm' ! -name '*.src.rpm' | sort)
      if [[ "${#existing_pkg_rpms[@]}" -gt 0 ]]; then
        log_info "==> [${package_name}] already built, skipping (use --force-rebuild to rebuild)"
        continue
      fi
    fi
  fi

  log_info "==> [${package_name}] fetch sources"
  if ! fetch_sources "${package_name}" "${spec_path}" >"${pkg_log_dir}/fetch-sources.log" 2>&1; then
    echo "Source fetch failed for ${package_name}. See ${pkg_log_dir}/fetch-sources.log" >&2
    if [[ "${CONTINUE_ON_ERROR}" -eq 1 ]]; then
      failures+=("${package_name}:fetch-sources")
      continue
    fi
    exit 1
  fi

  log_info "==> [${package_name}] mock buildsrpm (${MOCK_TARGET})"
  rm -f "${pkg_srpm_dir}"/*.rpm
  buildsrpm_cmd=("${mock_sudo[@]}" mock --root "${MOCK_TARGET}" --buildsrpm --spec "${spec_path}" --sources "${distgit_dir}" --resultdir "${pkg_srpm_dir}")
  if ! "${buildsrpm_cmd[@]}" >"${pkg_log_dir}/mock-buildsrpm.log" 2>&1; then
    echo "SRPM generation failed for ${package_name}. See ${pkg_log_dir}/mock-buildsrpm.log" >&2
    if [[ "${CONTINUE_ON_ERROR}" -eq 1 ]]; then
      failures+=("${package_name}:srpm")
      continue
    fi
    exit 1
  fi

  srpm_path="$(find "${pkg_srpm_dir}" -maxdepth 1 -type f -name '*.src.rpm' -printf '%T@ %p\n' | sort -nr | head -n1 | cut -d' ' -f2-)"
  if [[ -z "${srpm_path}" ]]; then
    echo "No SRPM found for ${package_name} in ${pkg_srpm_dir}" >&2
    if [[ "${CONTINUE_ON_ERROR}" -eq 1 ]]; then
      failures+=("${package_name}:no-srpm")
      continue
    fi
    exit 1
  fi

  if [[ "${SRPM_ONLY}" -eq 1 ]]; then
    if is_requested_package "${package_name}"; then
      requested_srpm_paths+=("${srpm_path}")
    fi
    log_info "==> [${package_name}] SRPM ready: ${srpm_path}"
    continue
  fi

  log_info "==> [${package_name}] mock rebuild (${MOCK_TARGET})"
  rm -f "${pkg_result_dir}"/*.rpm
  mock_cmd=("${mock_sudo[@]}" mock --root "${MOCK_TARGET}" --rebuild "${srpm_path}" --resultdir "${pkg_result_dir}")
  if [[ "${local_repo_ready}" -eq 1 ]]; then
    mock_cmd+=(--addrepo "file://${LOCAL_REPO_DIR}")
  fi
  if ! "${mock_cmd[@]}" >"${pkg_log_dir}/mock-rebuild.log" 2>&1; then
    echo "mock rebuild failed for ${package_name}. See ${pkg_log_dir}/mock-rebuild.log" >&2
    if [[ "${CONTINUE_ON_ERROR}" -eq 1 ]]; then
      failures+=("${package_name}:mock")
      continue
    fi
    exit 1
  fi

  mapfile -t rpms < <(find "${pkg_result_dir}" -maxdepth 1 -type f -name '*.rpm' | sort)
  if [[ "${#rpms[@]}" -eq 0 ]]; then
    echo "No RPMs produced for ${package_name}. See ${pkg_log_dir}/mock-rebuild.log" >&2
    if [[ "${CONTINUE_ON_ERROR}" -eq 1 ]]; then
      failures+=("${package_name}:no-rpms")
      continue
    fi
    exit 1
  fi

  rm -f "${pkg_rpm_dir}"/*.rpm
  cp -a "${rpms[@]}" "${pkg_rpm_dir}/"

  if refresh_local_repo "${OUT_ROOT}" "${LOCAL_REPO_DIR}"; then
    local_repo_ready=1
  else
    local_repo_ready=0
  fi
done

if [[ "${#failures[@]}" -gt 0 ]]; then
  printf '%s\n' "Build completed with failures:" >&2
  printf '  %s\n' "${failures[@]}" >&2
  exit 1
fi

if [[ "${SRPM_ONLY}" -eq 1 ]]; then
  log_info "SRPM generation completed successfully."
  log_info "SRPM output root: ${OUT_ROOT}/packages"
  if [[ "${#requested_srpm_paths[@]}" -gt 0 ]]; then
    printf '%s\n' "${requested_srpm_paths[@]}"
  fi
else
  log_info "Build completed successfully."
  log_info "Package output root: ${OUT_ROOT}/packages"
fi
