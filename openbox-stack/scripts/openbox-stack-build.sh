#!/usr/bin/env bash
set -euo pipefail

STACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO_DIR="$(cd "${STACK_DIR}/.." && pwd)"
PACKAGES_FILE="${STACK_DIR}/packages.yaml"
SOURCES_ROOT="${REPO_DIR}/packages"
OUT_ROOT="${STACK_DIR}/out"
MOCK_TARGET="epel-10-x86_64"
CONTINUE_ON_ERROR=0
FORCE_REBUILD=0
LOCAL_REPO_DIR=""

usage() {
  cat <<'EOF'
Usage: openbox-stack-build.sh [options]

Options:
  --packages <path>       Path to packages.yaml (default: openbox-stack/packages.yaml)
  --root <path>           Package source root (default: ../packages from openbox-stack)
  --out <path>            Build output root (default: openbox-stack/out)
  --mock-target <target>  Mock target (default: epel-10-x86_64)
  --continue-on-error     Continue with next package if a build fails
  --force-rebuild         Rebuild packages even if output RPMs already exist
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

refresh_local_repo() {
  local rpm_root="$1"
  local repo_dir="$2"
  local staged_dir="${repo_dir}/rpms"

  rm -rf "${repo_dir}"
  mkdir -p "${staged_dir}"

  mapfile -t binary_rpms < <(
    find "${rpm_root}" -type f -name '*.rpm' ! -name '*.src.rpm' | sort
  )

  if [[ "${#binary_rpms[@]}" -eq 0 ]]; then
    return 1
  fi

  cp -a "${binary_rpms[@]}" "${staged_dir}/"
  createrepo_c --quiet "${repo_dir}"
  return 0
}

mock_prefix() {
  if [[ "${EUID}" -eq 0 ]] || id -nG "${USER}" | tr ' ' '\n' | grep -qx mock; then
    return 0
  fi

  printf 'sudo\n'
}

find_spec_file() {
  local dir="$1"
  find "${dir}" -maxdepth 1 -type f -name '*.spec' | sort | head -n1
}

fetch_sources() {
  local pkg_dir="$1"
  local distgit_dir="$2"
  local spec_path="$3"

  if [[ -x "${pkg_dir}/scripts/fetch-sources.sh" ]]; then
    "${pkg_dir}/scripts/fetch-sources.sh"
    return 0
  fi

  if command -v spectool >/dev/null 2>&1; then
    spectool -g -C "${distgit_dir}" "${spec_path}"
  fi
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

mkdir -p "${OUT_ROOT}/logs" "${OUT_ROOT}/srpm-result" "${OUT_ROOT}/mock-result" "${OUT_ROOT}/rpms"
if [[ -z "${LOCAL_REPO_DIR}" ]]; then
  LOCAL_REPO_DIR="${OUT_ROOT}/localrepo"
fi

mapfile -t packages < <(parse_package_names "${PACKAGES_FILE}")
if [[ "${#packages[@]}" -eq 0 ]]; then
  echo "No package entries found in ${PACKAGES_FILE}" >&2
  exit 1
fi

failures=()
local_repo_ready=0
if refresh_local_repo "${OUT_ROOT}/rpms" "${LOCAL_REPO_DIR}"; then
  local_repo_ready=1
fi

mapfile -t mock_sudo < <(mock_prefix)

for pkg in "${packages[@]}"; do
  pkg_dir="${SOURCES_ROOT}/${pkg}"
  distgit_dir="${pkg_dir}/distgit"
  if [[ ! -d "${distgit_dir}" ]]; then
    distgit_dir="${pkg_dir}"
  fi

  if [[ ! -d "${distgit_dir}" ]]; then
    echo "Missing package tree for ${pkg}: ${distgit_dir}" >&2
    echo "Run: make -C openbox-stack sync" >&2
    if [[ "${CONTINUE_ON_ERROR}" -eq 1 ]]; then
      failures+=("${pkg}:missing-source")
      continue
    fi
    exit 1
  fi

  spec_path="$(find_spec_file "${distgit_dir}")"
  if [[ -z "${spec_path}" ]]; then
    echo "No spec file found for ${pkg} under ${distgit_dir}" >&2
    if [[ "${CONTINUE_ON_ERROR}" -eq 1 ]]; then
      failures+=("${pkg}:missing-spec")
      continue
    fi
    exit 1
  fi

  pkg_log_dir="${OUT_ROOT}/logs/${pkg}"
  pkg_srpm_dir="${OUT_ROOT}/srpm-result/${pkg}"
  pkg_result_dir="${OUT_ROOT}/mock-result/${pkg}"
  pkg_rpm_dir="${OUT_ROOT}/rpms/${pkg}"
  mkdir -p "${pkg_log_dir}" "${pkg_srpm_dir}" "${pkg_result_dir}" "${pkg_rpm_dir}"

  if [[ "${FORCE_REBUILD}" -eq 0 ]]; then
    mapfile -t existing_pkg_rpms < <(find "${pkg_rpm_dir}" -maxdepth 1 -type f -name '*.rpm' ! -name '*.src.rpm' | sort)
    if [[ "${#existing_pkg_rpms[@]}" -gt 0 ]]; then
      echo "==> [${pkg}] already built, skipping (use --force-rebuild to rebuild)"
      continue
    fi
  fi

  echo "==> [${pkg}] fetch sources"
  if ! fetch_sources "${pkg_dir}" "${distgit_dir}" "${spec_path}" >"${pkg_log_dir}/fetch-sources.log" 2>&1; then
    echo "Source fetch failed for ${pkg}. See ${pkg_log_dir}/fetch-sources.log" >&2
    if [[ "${CONTINUE_ON_ERROR}" -eq 1 ]]; then
      failures+=("${pkg}:fetch-sources")
      continue
    fi
    exit 1
  fi

  echo "==> [${pkg}] mock buildsrpm (${MOCK_TARGET})"
  buildsrpm_cmd=("${mock_sudo[@]}" mock --root "${MOCK_TARGET}" --buildsrpm --spec "${spec_path}" --sources "${distgit_dir}" --resultdir "${pkg_srpm_dir}")
  if ! "${buildsrpm_cmd[@]}" >"${pkg_log_dir}/mock-buildsrpm.log" 2>&1; then
    echo "SRPM generation failed for ${pkg}. See ${pkg_log_dir}/mock-buildsrpm.log" >&2
    if [[ "${CONTINUE_ON_ERROR}" -eq 1 ]]; then
      failures+=("${pkg}:srpm")
      continue
    fi
    exit 1
  fi

  srpm_path="$(find "${pkg_srpm_dir}" -maxdepth 1 -type f -name '*.src.rpm' -printf '%T@ %p\n' | sort -nr | head -n1 | cut -d' ' -f2-)"
  if [[ -z "${srpm_path}" ]]; then
    echo "No SRPM found for ${pkg} in ${pkg_srpm_dir}" >&2
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
  cp -a "${rpms[@]}" "${pkg_rpm_dir}/"

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
echo "RPM output: ${OUT_ROOT}/rpms"
