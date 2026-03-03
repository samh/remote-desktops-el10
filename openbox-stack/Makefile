SHELL := /usr/bin/bash

.PHONY: help sync build build-sync install install-dry-run conf-turbovnc tint2-srpm tint2-rpm tint2-install tint2-install-dry-run all

help:
	@echo "Openbox stack targets:"
	@echo "  sync          - sync Fedora RPM source submodules"
	@echo "  build         - build stack packages with fedpkg+mock (no sync)"
	@echo "  build-sync    - sync sources, then build"
	@echo "  install       - install locally built Openbox stack RPMs"
	@echo "  install-dry-run - preview Openbox stack RPM install list"
	@echo "  conf-turbovnc - write ~/.vnc/turbovncserver.conf with wm=openbox"
	@echo "  tint2-srpm    - build local tint2 SRPM from openbox-stack/tint2-rpm/tint2.spec"
	@echo "  tint2-rpm     - build local tint2 RPMs with mock"
	@echo "  tint2-install-dry-run - preview tint2 RPM install list"
	@echo "  tint2-install - install locally built tint2 RPMs"
	@echo "  all           - sync, build, and install"

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

tint2-srpm:
	@./scripts/openbox-stack-build-tint2.sh --srpm-only

tint2-rpm:
	@./scripts/openbox-stack-build-tint2.sh

tint2-install-dry-run:
	@./scripts/openbox-stack-install-built.sh --out ./out/tint2/rpm --dry-run

tint2-install:
	@./scripts/openbox-stack-install-built.sh --out ./out/tint2/rpm

all: build-sync install
