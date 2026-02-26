#!/usr/bin/env bash
set -euo pipefail

cpu_prev_total=0
cpu_prev_idle=0

read_cpu() {
  # shellcheck disable=SC2034
  read -r _ user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat
  local total=$((user + nice + system + idle + iowait + irq + softirq + steal))
  local idle_all=$((idle + iowait))
  echo "${total} ${idle_all}"
}

cpu_usage() {
  local now_total now_idle
  read -r now_total now_idle < <(read_cpu)
  if [[ "${cpu_prev_total}" -eq 0 ]]; then
    cpu_prev_total="${now_total}"
    cpu_prev_idle="${now_idle}"
    echo "0"
    return
  fi
  local dt=$((now_total - cpu_prev_total))
  local di=$((now_idle - cpu_prev_idle))
  cpu_prev_total="${now_total}"
  cpu_prev_idle="${now_idle}"
  if [[ "${dt}" -le 0 ]]; then
    echo "0"
    return
  fi
  echo $((100 * (dt - di) / dt))
}

mem_usage() {
  awk '
    /^MemTotal:/ {t=$2}
    /^MemAvailable:/ {a=$2}
    END {
      if (t == 0) { print "0%"; exit }
      u=t-a
      printf("%d%%", (u*100)/t)
    }' /proc/meminfo
}

echo '{"version":1}'
echo '['
echo '[],'

while :; do
  cpu="$(cpu_usage)%"
  mem="$(mem_usage)"
  now="$(date '+%Y-%m-%d %H:%M:%S')"
  printf '[{"name":"cpu","full_text":"CPU %s"},{"name":"mem","full_text":"MEM %s"},{"name":"clock","full_text":"%s"}],\n' \
    "${cpu}" "${mem}" "${now}"
  sleep 1
done
