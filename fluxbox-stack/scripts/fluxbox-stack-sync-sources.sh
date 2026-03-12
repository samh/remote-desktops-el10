#!/usr/bin/env bash
set -euo pipefail

STACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO_DIR="$(cd "${STACK_DIR}/.." && pwd)"
PACKAGES_FILE="${STACK_DIR}/packages.yaml"
SOURCES_ROOT="${REPO_DIR}/fedora-rpms"
DEFAULT_BRANCH=""

usage() {
  cat <<'EOF'
Usage: fluxbox-stack-sync-sources.sh [options]

Options:
  --packages <path>     Path to packages.yaml (default: fluxbox-stack/packages.yaml)
  --root <path>         Source checkout root (default: ../fedora-rpms from fluxbox-stack)
  --branch <name>       Override branch for all packages
  -h, --help            Show this help
EOF
}

parse_packages() {
  local file="$1"
  awk '
    function trim(s) {
      sub(/^[[:space:]]+/, "", s)
      sub(/[[:space:]]+$/, "", s)
      gsub(/^["\047]|["\047]$/, "", s)
      return s
    }
    function flush() {
      if (name != "" && url != "") {
        if (branch == "") {
          branch = "f43"
        }
        printf "%s\t%s\t%s\n", name, url, branch
      }
      name = ""
      url = ""
      branch = ""
    }
    /^[[:space:]]*-[[:space:]]*name:[[:space:]]*/ {
      flush()
      line = $0
      sub(/^[^:]*:[[:space:]]*/, "", line)
      name = trim(line)
      next
    }
    /^[[:space:]]*url:[[:space:]]*/ {
      line = $0
      sub(/^[^:]*:[[:space:]]*/, "", line)
      url = trim(line)
      next
    }
    /^[[:space:]]*branch:[[:space:]]*/ {
      line = $0
      sub(/^[^:]*:[[:space:]]*/, "", line)
      branch = trim(line)
      next
    }
    END {
      flush()
    }
  ' "${file}"
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
    --branch)
      DEFAULT_BRANCH="$2"
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

mkdir -p "${SOURCES_ROOT}"
cd "${REPO_DIR}"

mapfile -t entries < <(parse_packages "${PACKAGES_FILE}")
if [[ "${#entries[@]}" -eq 0 ]]; then
  echo "No package entries found in ${PACKAGES_FILE}" >&2
  exit 1
fi

for entry in "${entries[@]}"; do
  IFS=$'\t' read -r name url branch <<< "${entry}"
  if [[ -n "${DEFAULT_BRANCH}" ]]; then
    branch="${DEFAULT_BRANCH}"
  fi

  rel_path="$(realpath --relative-to="${REPO_DIR}" "${SOURCES_ROOT}")/${name}"
  abs_path="${REPO_DIR}/${rel_path}"

  if git ls-files --stage -- "${rel_path}" | awk '$1 == "160000" { found = 1 } END { exit(found ? 0 : 1) }'; then
    current_url="$(git config -f .gitmodules "submodule.${rel_path}.url" || true)"
    if [[ "${current_url}" != "${url}" ]]; then
      git submodule set-url "${rel_path}" "${url}"
    fi
    git config -f .gitmodules "submodule.${rel_path}.branch" "${branch}"
    git submodule update --init --recursive -- "${rel_path}"
  else
    if [[ -e "${abs_path}" ]]; then
      echo "Path exists but is not an indexed submodule: ${rel_path}" >&2
      echo "Move/remove it, or add it as a submodule first." >&2
      exit 1
    fi
    git submodule add -b "${branch}" "${url}" "${rel_path}"
  fi

  git -C "${abs_path}" fetch --all --prune
  git -C "${abs_path}" fetch origin "${branch}"
  git -C "${abs_path}" checkout "${branch}"
  git -C "${abs_path}" merge --ff-only "origin/${branch}"
done

echo "Submodule sync complete."
