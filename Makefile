SHELL := /usr/bin/bash

.PHONY: help wlroots-deps wlroots-source wlroots-rpm wlroots-install sway-deps sway-source sway-rpm install-built apply-sway-config setup-remote-session all all-container openbox-stack-sync openbox-stack-build openbox-stack-build-sync openbox-stack-install openbox-stack-install-dry-run openbox-stack-conf-turbovnc openbox-stack-all

help:
	@echo "Top-level RPM stack targets:"
	@echo "  make wlroots-deps    - install wlroots build dependencies"
	@echo "  make wlroots-source  - fetch/verify wlroots source"
	@echo "  make wlroots-rpm     - build wlroots RPMs"
	@echo "  make wlroots-install - install locally built wlroots RPMs"
	@echo "  make sway-deps       - install sway build dependencies"
	@echo "  make sway-source     - fetch/verify sway source"
	@echo "  make sway-rpm        - build sway RPMs"
	@echo "  make install-built   - install locally built wlroots+sway RPMs"
	@echo "  make apply-sway-config - apply remote-session/sway.config to ~/.config/sway/config and reload sway"
	@echo "  make setup-remote-session - configure headless sway+wayvnc user session (run as root)"
	@echo "  make all             - build/install wlroots, then build sway"
	@echo "  make all-container   - same pipeline inside an AlmaLinux container (no host sudo)"
	@echo "  make openbox-stack-sync - sync Fedora RPM source submodules for minimal Openbox stack"
	@echo "  make openbox-stack-build - build stack packages with fedpkg+mock (no sync)"
	@echo "  make openbox-stack-build-sync - sync sources, then build stack packages"
	@echo "  make openbox-stack-install - install locally built Openbox stack RPMs"
	@echo "  make openbox-stack-install-dry-run - preview Openbox stack RPM install list"
	@echo "  make openbox-stack-conf-turbovnc - write ~/.vnc/turbovncserver.conf with wm=openbox"
	@echo "  make openbox-stack-all - sync, build, and install Openbox stack RPMs"

wlroots-deps:
	@$(MAKE) -C wlroots-rpm deps

wlroots-source:
	@$(MAKE) -C wlroots-rpm source

wlroots-rpm:
	@$(MAKE) -C wlroots-rpm rpm

wlroots-install:
	@$(MAKE) -C wlroots-rpm install-built

sway-deps:
	@$(MAKE) -C sway-rpm deps

sway-source:
	@$(MAKE) -C sway-rpm source

sway-rpm:
	@$(MAKE) -C sway-rpm rpm

install-built:
	@./scripts/install-built-rpms.sh

apply-sway-config:
	@./scripts/apply-sway-config.sh

setup-remote-session:
	@./scripts/setup-remote-wayvnc-user.sh

all: wlroots-deps wlroots-rpm wlroots-install sway-deps sway-rpm

all-container:
	@./scripts/build-stack-container.sh

openbox-stack-sync:
	@./scripts/openbox-stack-sync-sources.sh

openbox-stack-build:
	@./scripts/openbox-stack-build.sh

openbox-stack-build-sync: openbox-stack-sync
	@./scripts/openbox-stack-build.sh

openbox-stack-install:
	@./scripts/openbox-stack-install-built.sh

openbox-stack-install-dry-run:
	@./scripts/openbox-stack-install-built.sh --dry-run

openbox-stack-conf-turbovnc:
	@./scripts/openbox-stack-write-turbovnc-conf.sh

openbox-stack-all: openbox-stack-build-sync openbox-stack-install
