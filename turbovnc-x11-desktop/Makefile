SHELL := /usr/bin/bash
ROOT_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

.PHONY: help verify install-icewm install-gnome xstartup-icewm xstartup-gnome

help:
	@echo "Targets:"
	@echo "  make verify         - validate profile package names in ../dnf-list.txt"
	@echo "  make install-icewm  - install lightweight IceWM profile packages"
	@echo "  make install-gnome  - install GNOME fallback profile packages"
	@echo "  make xstartup-icewm - write ~/.vnc/xstartup for IceWM"
	@echo "  make xstartup-gnome - write ~/.vnc/xstartup for GNOME"

verify:
	@bash "$(ROOT_DIR)/scripts/verify-dnf-list.sh"

install-icewm:
	@bash "$(ROOT_DIR)/scripts/install-profile.sh" icewm

install-gnome:
	@bash "$(ROOT_DIR)/scripts/install-profile.sh" gnome

xstartup-icewm:
	@bash "$(ROOT_DIR)/scripts/write-xstartup.sh" icewm

xstartup-gnome:
	@bash "$(ROOT_DIR)/scripts/write-xstartup.sh" gnome
