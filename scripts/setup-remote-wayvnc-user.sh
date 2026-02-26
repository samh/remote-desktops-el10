#!/usr/bin/env bash
set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run as root (or via sudo)." >&2
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATE_DIR="${ROOT_DIR}/remote-session"
SWAY_STATUS_SRC="${TEMPLATE_DIR}/sway-status.sh"

REMOTE_USER="${REMOTE_USER:-remotevnc}"
WAYVNC_BIND_ADDRESS="${WAYVNC_BIND_ADDRESS:-0.0.0.0}"
WAYVNC_PORT="${WAYVNC_PORT:-5900}"
WAYVNC_USERNAME="${WAYVNC_USERNAME:-${REMOTE_USER}}"
WAYVNC_PASSWORD="${WAYVNC_PASSWORD:-}"

for bin in sway wayvnc openssl loginctl systemctl runuser; do
  if ! command -v "${bin}" >/dev/null 2>&1; then
    echo "Missing required command: ${bin}" >&2
    exit 1
  fi
done

if ! command -v dmenu-wl_run >/dev/null 2>&1; then
  echo "Installing dmenu-wayland for app launcher support..."
  if ! dnf -y install dmenu-wayland; then
    echo "Warning: failed to install dmenu-wayland; Alt+d/Super+d launcher may not work." >&2
  fi
fi

if ! id -u "${REMOTE_USER}" >/dev/null 2>&1; then
  useradd --create-home --shell /bin/bash "${REMOTE_USER}"
fi

REMOTE_UID="$(id -u "${REMOTE_USER}")"
REMOTE_GID="$(id -g "${REMOTE_USER}")"
REMOTE_HOME="$(getent passwd "${REMOTE_USER}" | cut -d: -f6)"

if [[ -z "${REMOTE_HOME}" || ! -d "${REMOTE_HOME}" ]]; then
  echo "Could not determine home directory for ${REMOTE_USER}" >&2
  exit 1
fi

loginctl enable-linger "${REMOTE_USER}"
systemctl start "user@${REMOTE_UID}.service"

install -d -m 0700 "${REMOTE_HOME}/.config/sway"
install -d -m 0700 "${REMOTE_HOME}/.config/wayvnc"
install -d -m 0700 "${REMOTE_HOME}/.config/systemd/user"

install -m 0644 "${TEMPLATE_DIR}/sway.config" \
  "${REMOTE_HOME}/.config/sway/config"
if [[ -f "${SWAY_STATUS_SRC}" ]]; then
  install -m 0755 "${SWAY_STATUS_SRC}" \
    "${REMOTE_HOME}/.config/sway/sway-status.sh"
fi
install -m 0644 "${TEMPLATE_DIR}/sway-headless.service" \
  "${REMOTE_HOME}/.config/systemd/user/sway-headless.service"

CREDENTIALS_FILE="${REMOTE_HOME}/.config/wayvnc/credentials"
if [[ -f "${CREDENTIALS_FILE}" ]]; then
  # shellcheck disable=SC1090
  source "${CREDENTIALS_FILE}"
fi

if [[ -z "${WAYVNC_PASSWORD}" ]]; then
  if [[ -n "${password:-}" ]]; then
    WAYVNC_PASSWORD="${password}"
  else
    WAYVNC_PASSWORD="$(openssl rand -base64 24 | tr -d '\n')"
  fi
fi

cat > "${CREDENTIALS_FILE}" <<EOF
username=${WAYVNC_USERNAME}
password=${WAYVNC_PASSWORD}
EOF
chmod 0600 "${CREDENTIALS_FILE}"

if [[ ! -f "${REMOTE_HOME}/.config/wayvnc/tls_key.pem" || \
      ! -f "${REMOTE_HOME}/.config/wayvnc/tls_cert.pem" ]]; then
  openssl req -x509 -newkey rsa:4096 \
    -keyout "${REMOTE_HOME}/.config/wayvnc/tls_key.pem" \
    -out "${REMOTE_HOME}/.config/wayvnc/tls_cert.pem" \
    -sha256 -days 3650 -nodes -subj "/CN=${REMOTE_USER}-wayvnc"
fi

# wayvnc's nettle backend expects a traditional PKCS#1 RSA key here.
openssl genrsa -traditional -out "${REMOTE_HOME}/.config/wayvnc/rsa_key.pem" 2048

chmod 0600 \
  "${REMOTE_HOME}/.config/wayvnc/tls_key.pem" \
  "${REMOTE_HOME}/.config/wayvnc/rsa_key.pem"
chmod 0644 "${REMOTE_HOME}/.config/wayvnc/tls_cert.pem"

cat > "${REMOTE_HOME}/.config/wayvnc/config" <<EOF
use_relative_paths=true
address=${WAYVNC_BIND_ADDRESS}
port=${WAYVNC_PORT}
enable_auth=true
username=${WAYVNC_USERNAME}
password=${WAYVNC_PASSWORD}
rsa_private_key_file=rsa_key.pem
private_key_file=tls_key.pem
certificate_file=tls_cert.pem
EOF
chmod 0600 "${REMOTE_HOME}/.config/wayvnc/config"

chown -R "${REMOTE_UID}:${REMOTE_GID}" "${REMOTE_HOME}/.config"

SYSTEMD_USER_ENV=(
  "XDG_RUNTIME_DIR=/run/user/${REMOTE_UID}"
  "DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/${REMOTE_UID}/bus"
)

runuser -u "${REMOTE_USER}" -- env "${SYSTEMD_USER_ENV[@]}" \
  systemctl --user daemon-reload
runuser -u "${REMOTE_USER}" -- env "${SYSTEMD_USER_ENV[@]}" \
  systemctl --user enable --now sway-headless.service

echo
echo "Remote session configured."
echo "User: ${REMOTE_USER}"
echo "VNC endpoint: ${WAYVNC_BIND_ADDRESS}:${WAYVNC_PORT}"
echo "VNC username: ${WAYVNC_USERNAME}"
echo "VNC password: ${WAYVNC_PASSWORD}"
echo
echo "Service status command:"
echo "  sudo -u ${REMOTE_USER} XDG_RUNTIME_DIR=/run/user/${REMOTE_UID} \\"
echo "    DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/${REMOTE_UID}/bus \\"
echo "    systemctl --user status sway-headless.service"
