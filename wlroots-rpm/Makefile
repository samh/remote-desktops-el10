SHELL := /usr/bin/bash
ROOT_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

.PHONY: help deps source srpm rpm install-built clean

help:
	@echo "Targets:"
	@echo "  make deps         - install build dependencies listed in build-deps.txt"
	@echo "  make source       - download + verify source tarball"
	@echo "  make srpm         - build source RPM under rpmbuild/SRPMS"
	@echo "  make rpm          - build binary RPM(s) under rpmbuild/RPMS"
	@echo "  make install-built - install built local wlroots RPMs"
	@echo "  make clean        - remove rpmbuild workspace"

deps:
	@"$(ROOT_DIR)/scripts/install-builddeps.sh"

source:
	@"$(ROOT_DIR)/scripts/fetch-source.sh"

srpm:
	@"$(ROOT_DIR)/scripts/build-srpm.sh"

rpm:
	@"$(ROOT_DIR)/scripts/build-rpm.sh"

install-built:
	@"$(ROOT_DIR)/scripts/install-built-rpms.sh"

clean:
	rm -rf "$(ROOT_DIR)/rpmbuild"
