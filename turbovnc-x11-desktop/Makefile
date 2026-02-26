SHELL := /usr/bin/bash
ROOT_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

.PHONY: help verify install-icewm install-gnome conf-icewm conf-gnome bg-icewm-light xstartup-icewm xstartup-gnome

help:
	@echo "Targets:"
	@echo "  make verify         - validate profile package names in ../dnf-list.txt"
	@echo "  make install-icewm  - install lightweight IceWM profile + set TurboVNC wm"
	@echo "  make install-gnome  - install GNOME fallback profile + set TurboVNC wm"
	@echo "  make conf-icewm     - write ~/.vnc/turbovncserver.conf with wm=icewm"
	@echo "  make conf-gnome     - write ~/.vnc/turbovncserver.conf with wm=gnome"
	@echo "  make bg-icewm-light - set IceWM desktop background to a light color"
	@echo "  make xstartup-icewm - legacy write ~/.vnc/xstartup for IceWM"
	@echo "  make xstartup-gnome - legacy write ~/.vnc/xstartup for GNOME"

verify:
	@bash "$(ROOT_DIR)/scripts/verify-dnf-list.sh"

install-icewm:
	@bash "$(ROOT_DIR)/scripts/install-profile.sh" icewm

install-gnome:
	@bash "$(ROOT_DIR)/scripts/install-profile.sh" gnome

conf-icewm:
	@bash "$(ROOT_DIR)/scripts/write-turbovncserver-conf.sh" icewm

conf-gnome:
	@bash "$(ROOT_DIR)/scripts/write-turbovncserver-conf.sh" gnome

bg-icewm-light:
	@bash "$(ROOT_DIR)/scripts/set-icewm-background.sh" "#e9eef3"

xstartup-icewm:
	@bash "$(ROOT_DIR)/scripts/write-xstartup.sh" icewm

xstartup-gnome:
	@bash "$(ROOT_DIR)/scripts/write-xstartup.sh" gnome
