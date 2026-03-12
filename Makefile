SHELL := /usr/bin/bash

.PHONY: help wlroots-rpm wlroots-install sway-rpm install-built apply-sway-config setup-remote-session all

help:
	@echo "Top-level package/profile targets:"
	@echo "  just profile-build fluxbox         - build the Fluxbox X11 profile"
	@echo "  just profile-build openbox-tint2   - build the Openbox+tint2 X11 profile"
	@echo "  just profile-build sway            - build the Sway Wayland profile"
	@echo "  just profile-install-config fluxbox - install Fluxbox user config"
	@echo "  just profile-conf-turbovnc openbox-tint2 - write TurboVNC WM config"
	@echo "  make wlroots-rpm     - build the wlroots package"
	@echo "  make wlroots-install - install the built wlroots package"
	@echo "  make sway-rpm        - build the sway package"
	@echo "  make install-built   - install the built sway profile packages"
	@echo "  make apply-sway-config - install the sway profile config and reload sway"
	@echo "  make setup-remote-session - configure the remote sway+wayvnc user session (run as root)"
	@echo "  make all             - build the sway profile"

wlroots-rpm:
	@just package-build wlroots

wlroots-install:
	@just package-install wlroots

sway-rpm:
	@just package-build sway

install-built:
	@./scripts/install-built-rpms.sh

apply-sway-config:
	@./scripts/apply-sway-config.sh

setup-remote-session:
	@./scripts/setup-remote-wayvnc-user.sh

all:
	@just profile-build sway
