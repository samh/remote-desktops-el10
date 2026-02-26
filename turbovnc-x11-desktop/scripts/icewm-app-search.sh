#!/usr/bin/env bash
set -euo pipefail

# Build list: "Display Name<TAB>desktop-id"
list_apps() {
  local dir file id name hidden nodisplay
  local IFS=:
  local dirs=("$HOME/.local/share/applications" ${XDG_DATA_DIRS:-/usr/local/share:/usr/share})
  for dir in "${dirs[@]}"; do
    dir="$dir/applications"
    [[ -d "$dir" ]] || continue
    while IFS= read -r -d '' file; do
      id="${file##*/}"
      id="${id%.desktop}"
      hidden="$(grep -m1 '^Hidden=' "$file" | cut -d= -f2- || true)"
      nodisplay="$(grep -m1 '^NoDisplay=' "$file" | cut -d= -f2- || true)"
      [[ "${hidden,,}" == "true" ]] && continue
      [[ "${nodisplay,,}" == "true" ]] && continue
      name="$(grep -m1 '^Name=' "$file" | cut -d= -f2- || true)"
      [[ -z "$name" ]] && name="$id"
      printf '%s\t%s\n' "$name" "$id"
    done < <(find "$dir" -maxdepth 1 -type f -name '*.desktop' -print0 2>/dev/null)
  done
}

choice="$({ list_apps | awk -F '\t' '!seen[$2]++ {print}' | sort -f; } | fzf --height=80% --layout=reverse --border --prompt='App> ' --with-nth=1 --delimiter='\t' || true)"
[[ -z "$choice" ]] && exit 0
id="${choice##*$'\t'}"
exec gtk-launch "$id"
