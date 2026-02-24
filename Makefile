SHELL := /usr/bin/bash

.PHONY: help wlroots-deps wlroots-source wlroots-rpm wlroots-install sway-deps sway-source sway-rpm all

help:
	@echo "Top-level RPM stack targets:"
	@echo "  make wlroots-deps    - install wlroots build dependencies"
	@echo "  make wlroots-source  - fetch/verify wlroots source"
	@echo "  make wlroots-rpm     - build wlroots RPMs"
	@echo "  make wlroots-install - install locally built wlroots RPMs"
	@echo "  make sway-deps       - install sway build dependencies"
	@echo "  make sway-source     - fetch/verify sway source"
	@echo "  make sway-rpm        - build sway RPMs"
	@echo "  make all             - build/install wlroots, then build sway"

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

all: wlroots-deps wlroots-rpm wlroots-install sway-deps sway-rpm
