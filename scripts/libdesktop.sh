#!/usr/bin/env bash

set -euo pipefail

DESKTOP_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DESKTOP_REPO_DIR="$(cd "${DESKTOP_LIB_DIR}/.." && pwd)"

trim() {
  local value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  value="${value#\"}"
  value="${value%\"}"
  value="${value#\'}"
  value="${value%\'}"
  printf '%s' "${value}"
}

yaml_scalar() {
  local file="$1"
  local key="$2"
  awk -F ':' -v key="${key}" '
    $1 == key {
      sub(/^[^:]*:[[:space:]]*/, "", $0)
      print $0
      exit
    }
  ' "${file}" | while IFS= read -r line; do
    trim "${line}"
  done
}

yaml_list() {
  local file="$1"
  local key="$2"
  awk -v key="${key}" '
    function trim(s) {
      sub(/^[[:space:]]+/, "", s)
      sub(/[[:space:]]+$/, "", s)
      gsub(/^["\047]|["\047]$/, "", s)
      return s
    }
    $1 == key ":" {
      in_list = 1
      next
    }
    in_list && /^[^[:space:]-]/ {
      exit
    }
    in_list && /^[[:space:]]*-[[:space:]]*/ {
      line = $0
      sub(/^[[:space:]]*-[[:space:]]*/, "", line)
      print trim(line)
      next
    }
    in_list && NF == 0 {
      next
    }
  ' "${file}"
}

package_dir() {
  printf '%s/packages/%s\n' "${DESKTOP_REPO_DIR}" "$1"
}

package_metadata_file() {
  printf '%s/package.yaml\n' "$(package_dir "$1")"
}

package_upstream_file() {
  printf '%s/upstream.yaml\n' "$(package_dir "$1")"
}

profile_dir() {
  printf '%s/profiles/%s\n' "${DESKTOP_REPO_DIR}" "$1"
}

profile_metadata_file() {
  printf '%s/profile.yaml\n' "$(profile_dir "$1")"
}

package_distgit_dir() {
  local pkg_dir
  pkg_dir="$(package_dir "$1")"
  if [[ -d "${pkg_dir}/distgit" ]]; then
    printf '%s/distgit\n' "${pkg_dir}"
  else
    printf '%s\n' "${pkg_dir}"
  fi
}

package_spec_file() {
  local distgit_dir
  distgit_dir="$(package_distgit_dir "$1")"
  find "${distgit_dir}" -maxdepth 1 -type f -name '*.spec' | sort | head -n1
}

package_fetch_script() {
  local package_name="$1"
  local metadata_file
  metadata_file="$(package_metadata_file "${package_name}")"
  local pkg_dir
  pkg_dir="$(package_dir "${package_name}")"
  local rel_path=""

  if [[ -f "${metadata_file}" ]]; then
    rel_path="$(yaml_scalar "${metadata_file}" fetch_script || true)"
  fi

  if [[ -n "${rel_path}" ]]; then
    printf '%s/%s\n' "${pkg_dir}" "${rel_path}"
    return 0
  fi

  if [[ -x "${pkg_dir}/scripts/fetch-sources.sh" ]]; then
    printf '%s/scripts/fetch-sources.sh\n' "${pkg_dir}"
    return 0
  fi

  return 1
}

package_install_exclude_globs() {
  local metadata_file
  metadata_file="$(package_metadata_file "$1")"
  if [[ ! -f "${metadata_file}" ]]; then
    return 0
  fi

  yaml_list "${metadata_file}" install_exclude_globs
}

package_build_after() {
  local metadata_file
  metadata_file="$(package_metadata_file "$1")"
  if [[ ! -f "${metadata_file}" ]]; then
    return 0
  fi

  yaml_list "${metadata_file}" build_after
}

package_upstream_type() {
  local upstream_file
  upstream_file="$(package_upstream_file "$1")"
  if [[ ! -f "${upstream_file}" ]]; then
    return 0
  fi

  yaml_scalar "${upstream_file}" type
}

profile_packages() {
  yaml_list "$(profile_metadata_file "$1")" packages
}

profile_wm() {
  yaml_scalar "$(profile_metadata_file "$1")" wm
}

profile_config_layout() {
  yaml_scalar "$(profile_metadata_file "$1")" config_layout
}

profile_config_source() {
  local value
  value="$(yaml_scalar "$(profile_metadata_file "$1")" config_source || true)"
  if [[ -n "${value}" ]]; then
    printf '%s\n' "${value}"
  else
    printf 'config\n'
  fi
}

profile_config_target_subdir() {
  yaml_scalar "$(profile_metadata_file "$1")" config_target_subdir
}

profile_xstartup_template() {
  yaml_scalar "$(profile_metadata_file "$1")" xstartup_template
}

mock_prefix() {
  if [[ "${EUID}" -eq 0 ]] || id -nG "${USER}" | tr ' ' '\n' | grep -qx mock; then
    return 0
  fi

  printf 'sudo\n'
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

refresh_local_repo() {
  local out_root="$1"
  local repo_dir="$2"
  local staged_dir="${repo_dir}/rpms"

  rm -rf "${repo_dir}"
  mkdir -p "${staged_dir}"

  mapfile -t binary_rpms < <(
    find "${out_root}/packages" -mindepth 3 -maxdepth 3 -type f -name '*.rpm' ! -name '*.src.rpm' | sort
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

package_binary_rpms() {
  local out_root="$1"
  local package_name="$2"
  find "${out_root}/packages/${package_name}/rpms" -maxdepth 1 -type f -name '*.rpm' \
    ! -name '*.src.rpm' \
    ! -name '*debuginfo*' \
    ! -name '*debugsource*' \
    ! -name '*-devel-*.rpm' \
    | sort
}

resolve_package_order() {
  local requested=("$@")
  declare -gA __desktop_seen=()
  declare -gA __desktop_visiting=()
  declare -ga __desktop_order=()

  __desktop_visit() {
    local package_name="$1"
    local metadata_file
    metadata_file="$(package_metadata_file "${package_name}")"

    if [[ ! -f "${metadata_file}" ]]; then
      echo "Missing package metadata: ${metadata_file}" >&2
      return 1
    fi

    if [[ -n "${__desktop_seen[${package_name}]:-}" ]]; then
      return 0
    fi

    if [[ -n "${__desktop_visiting[${package_name}]:-}" ]]; then
      echo "Dependency cycle detected at package: ${package_name}" >&2
      return 1
    fi

    __desktop_visiting["${package_name}"]=1

    local dep
    while IFS= read -r dep; do
      [[ -z "${dep}" ]] && continue
      __desktop_visit "${dep}"
    done < <(package_build_after "${package_name}")

    unset "__desktop_visiting[${package_name}]"
    __desktop_seen["${package_name}"]=1
    __desktop_order+=("${package_name}")
  }

  local package_name
  for package_name in "${requested[@]}"; do
    __desktop_visit "${package_name}"
  done

  printf '%s\n' "${__desktop_order[@]}"

  unset -f __desktop_visit
  unset __desktop_seen __desktop_visiting __desktop_order
}

