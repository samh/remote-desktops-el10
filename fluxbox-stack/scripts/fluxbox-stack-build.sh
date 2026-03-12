#!/usr/bin/env bash
set -euo pipefail

STACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO_DIR="$(cd "${STACK_DIR}/.." && pwd)"
PACKAGES_FILE="${STACK_DIR}/packages.yaml"
SOURCES_ROOT="${REPO_DIR}/fedora-rpms"
OUT_ROOT="${STACK_DIR}/out"
MOCK_TARGET="epel-10-x86_64"
CONTINUE_ON_ERROR=0
FORCE_REBUILD=0
REFRESH_COMMON_OUTPUT=0
LOCAL_REPO_DIR=""

usage() {
  cat <<'EOF'
Usage: fluxbox-stack-build.sh [options]

Options:
  --packages <path>       Path to packages.yaml (default: fluxbox-stack/packages.yaml)
  --root <path>           Source checkout root (default: ../fedora-rpms from fluxbox-stack)
  --out <path>            Build output root (default: fluxbox-stack/out)
  --mock-target <target>  Mock target (default: epel-10-x86_64)
  --continue-on-error     Continue with next package if a build fails
  --force-rebuild         Rebuild packages even if output RPMs already exist
  --refresh-common-output Rebuild out/all-rpms and local repo only
  --local-repo <path>     Local repo path passed to mock via --addrepo
  -h, --help              Show this help
EOF
}

parse_package_names() {
  local file="$1"
  awk '
    function trim(s) {
      sub(/^[[:space:]]+/, "", s)
      sub(/[[:space:]]+$/, "", s)
      gsub(/^["\047]|["\047]$/, "", s)
      return s
    }
    /^[[:space:]]*-[[:space:]]*name:[[:space:]]*/ {
      line = $0
      sub(/^[^:]*:[[:space:]]*/, "", line)
      print trim(line)
    }
  ' "${file}"
}

link_or_copy() {
  local src="$1"
  local dest="$2"

  rm -f "${dest}"
  if ln "${src}" "${dest}" 2>/dev/null; then
    return 0
  fi

  cp -a "${src}" "${dest}"
}

refresh_common_output() {
  local rpm_root="$1"
  local common_dir="$2"

  rm -rf "${common_dir}"
  mkdir -p "${common_dir}"

  mapfile -t all_rpms < <(find "${rpm_root}" -mindepth 2 -maxdepth 2 -type f -name '*.rpm' | sort)
  if [[ "${#all_rpms[@]}" -eq 0 ]]; then
    return 1
  fi

  local src
  for src in "${all_rpms[@]}"; do
    link_or_copy "${src}" "${common_dir}/$(basename "${src}")"
  done
}

refresh_local_repo() {
  local rpm_root="$1"
  local repo_dir="$2"
  local staged_dir="${repo_dir}/rpms"

  rm -rf "${repo_dir}"
  mkdir -p "${staged_dir}"

  mapfile -t binary_rpms < <(
    find "${rpm_root}" -mindepth 2 -maxdepth 2 -type f -name '*.rpm' ! -name '*.src.rpm' | sort
  )

  if [[ "${#binary_rpms[@]}" -eq 0 ]]; then
    return 1
  fi

  local src
  for src in "${binary_rpms[@]}"; do
    link_or_copy "${src}" "${staged_dir}/$(basename "${src}")"
  done

  createrepo_c --quiet "${repo_dir}"
  return 0
}

mock_prefix() {
  if [[ "${EUID}" -eq 0 ]] || id -nG "${USER}" | tr ' ' '\n' | grep -qx mock; then
    return 0
  fi

  printf 'sudo\n'
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --packages)
      PACKAGES_FILE="$2"
      shift 2
      ;;
    --root)
      SOURCES_ROOT="$2"
      shift 2
      ;;
    --out)
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
    --refresh-common-output)
      REFRESH_COMMON_OUTPUT=1
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

if [[ ! -f "${PACKAGES_FILE}" ]]; then
  echo "Package manifest not found: ${PACKAGES_FILE}" >&2
  exit 1
fi

mkdir -p "${OUT_ROOT}/logs" "${OUT_ROOT}/mock-result" "${OUT_ROOT}/rpms"
if [[ -z "${LOCAL_REPO_DIR}" ]]; then
  LOCAL_REPO_DIR="${OUT_ROOT}/localrepo"
fi

if [[ "${REFRESH_COMMON_OUTPUT}" -eq 1 ]]; then
  refresh_common_output "${OUT_ROOT}/rpms" "${OUT_ROOT}/all-rpms" || true
  refresh_local_repo "${OUT_ROOT}/rpms" "${LOCAL_REPO_DIR}" || true
  echo "Refreshed ${OUT_ROOT}/all-rpms and ${LOCAL_REPO_DIR}."
  exit 0
fi

mapfile -t packages < <(parse_package_names "${PACKAGES_FILE}")
if [[ "${#packages[@]}" -eq 0 ]]; then
  echo "No package entries found in ${PACKAGES_FILE}" >&2
  exit 1
fi

failures=()
local_repo_ready=0
if refresh_common_output "${OUT_ROOT}/rpms" "${OUT_ROOT}/all-rpms"; then
  :
fi
if refresh_local_repo "${OUT_ROOT}/rpms" "${LOCAL_REPO_DIR}"; then
  local_repo_ready=1
fi

mapfile -t mock_sudo < <(mock_prefix)

for pkg in "${packages[@]}"; do
  pkg_dir="${SOURCES_ROOT}/${pkg}"
  if [[ ! -d "${pkg_dir}" ]] || ! git -C "${pkg_dir}" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "Missing source repo for ${pkg}: ${pkg_dir}" >&2
    echo "Run: just --justfile fluxbox-stack/justfile sync" >&2
    if [[ "${CONTINUE_ON_ERROR}" -eq 1 ]]; then
      failures+=("${pkg}:missing-source")
      continue
    fi
    exit 1
  fi

  pkg_log_dir="${OUT_ROOT}/logs/${pkg}"
  pkg_result_dir="${OUT_ROOT}/mock-result/${pkg}"
  pkg_rpm_dir="${OUT_ROOT}/rpms/${pkg}"
  mkdir -p "${pkg_log_dir}" "${pkg_result_dir}" "${pkg_rpm_dir}"

  if [[ "${FORCE_REBUILD}" -eq 0 ]]; then
    mapfile -t existing_pkg_rpms < <(find "${pkg_rpm_dir}" -maxdepth 1 -type f -name '*.rpm' ! -name '*.src.rpm' | sort)
    if [[ "${#existing_pkg_rpms[@]}" -gt 0 ]]; then
      echo "==> [${pkg}] already built, skipping (use --force-rebuild to rebuild)"
      continue
    fi
  fi

  echo "==> [${pkg}] fedpkg srpm"
  if ! (
    cd "${pkg_dir}"
    fedpkg srpm
  ) >"${pkg_log_dir}/fedpkg-srpm.log" 2>&1; then
    echo "SRPM generation failed for ${pkg}. See ${pkg_log_dir}/fedpkg-srpm.log" >&2
    if [[ "${CONTINUE_ON_ERROR}" -eq 1 ]]; then
      failures+=("${pkg}:srpm")
      continue
    fi
    exit 1
  fi

  srpm_path="$(find "${pkg_dir}" -maxdepth 1 -type f -name '*.src.rpm' -printf '%T@ %p\n' | sort -nr | head -n1 | cut -d' ' -f2-)"
  if [[ -z "${srpm_path}" ]]; then
    echo "No SRPM found for ${pkg} in ${pkg_dir}" >&2
    if [[ "${CONTINUE_ON_ERROR}" -eq 1 ]]; then
      failures+=("${pkg}:no-srpm")
      continue
    fi
    exit 1
  fi

  echo "==> [${pkg}] mock rebuild (${MOCK_TARGET})"
  mock_cmd=("${mock_sudo[@]}" mock --root "${MOCK_TARGET}" --rebuild "${srpm_path}" --resultdir "${pkg_result_dir}")
  if [[ "${local_repo_ready}" -eq 1 ]]; then
    mock_cmd+=(--addrepo "file://${LOCAL_REPO_DIR}")
  fi
  if ! "${mock_cmd[@]}" >"${pkg_log_dir}/mock-rebuild.log" 2>&1; then
    echo "mock rebuild failed for ${pkg}. See ${pkg_log_dir}/mock-rebuild.log" >&2
    if [[ "${CONTINUE_ON_ERROR}" -eq 1 ]]; then
      failures+=("${pkg}:mock")
      continue
    fi
    exit 1
  fi

  mapfile -t rpms < <(find "${pkg_result_dir}" -maxdepth 1 -type f -name '*.rpm' | sort)
  if [[ "${#rpms[@]}" -eq 0 ]]; then
    echo "No RPMs produced for ${pkg}. See ${pkg_log_dir}/mock-rebuild.log" >&2
    if [[ "${CONTINUE_ON_ERROR}" -eq 1 ]]; then
      failures+=("${pkg}:no-rpms")
      continue
    fi
    exit 1
  fi

  rm -f "${pkg_rpm_dir}"/*.rpm
  for rpm in "${rpms[@]}"; do
    link_or_copy "${rpm}" "${pkg_rpm_dir}/$(basename "${rpm}")"
  done

  refresh_common_output "${OUT_ROOT}/rpms" "${OUT_ROOT}/all-rpms" || true
  if refresh_local_repo "${OUT_ROOT}/rpms" "${LOCAL_REPO_DIR}"; then
    local_repo_ready=1
  else
    local_repo_ready=0
  fi
done

if [[ "${#failures[@]}" -gt 0 ]]; then
  echo "Build completed with failures:" >&2
  printf '  %s\n' "${failures[@]}" >&2
  exit 1
fi

echo "Build completed successfully."
