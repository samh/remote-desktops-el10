SHELL := /usr/bin/bash

.PHONY: help sync build build-sync install install-dry-run conf-turbovnc all

help:
	@echo "Openbox stack targets:"
	@echo "  make -C openbox-stack sync          - sync Fedora RPM source submodules"
	@echo "  make -C openbox-stack build         - build stack packages with fedpkg+mock (no sync)"
	@echo "  make -C openbox-stack build-sync    - sync sources, then build"
	@echo "  make -C openbox-stack install       - install locally built Openbox stack RPMs"
	@echo "  make -C openbox-stack install-dry-run - preview Openbox stack RPM install list"
	@echo "  make -C openbox-stack conf-turbovnc - write ~/.vnc/turbovncserver.conf with wm=openbox"
	@echo "  make -C openbox-stack all           - sync, build, and install"

sync:
	@./scripts/openbox-stack-sync-sources.sh

build:
	@./scripts/openbox-stack-build.sh

build-sync: sync
	@./scripts/openbox-stack-build.sh

install:
	@./scripts/openbox-stack-install-built.sh

install-dry-run:
	@./scripts/openbox-stack-install-built.sh --dry-run

conf-turbovnc:
	@./scripts/openbox-stack-write-turbovnc-conf.sh

all: build-sync install
