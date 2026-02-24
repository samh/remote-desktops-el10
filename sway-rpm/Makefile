SHELL := /usr/bin/bash
ROOT_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

.PHONY: help deps source srpm rpm rpm-container check-wlroots clean

help:
	@echo "Targets:"
	@echo "  make deps    - install build dependencies listed in build-deps.txt"
	@echo "  make source  - download + verify source tarball"
	@echo "  make srpm    - build source RPM under rpmbuild/SRPMS"
	@echo "  make check-wlroots - verify wlroots-devel >= 0.19.0 is installed"
	@echo "  make rpm     - build binary RPM(s) under rpmbuild/RPMS"
	@echo "  make rpm-container - build RPM(s) in a podman container"
	@echo "  make clean   - remove rpmbuild workspace"

deps:
	@"$(ROOT_DIR)/scripts/install-builddeps.sh"

source:
	@"$(ROOT_DIR)/scripts/fetch-source.sh"

srpm:
	@"$(ROOT_DIR)/scripts/build-srpm.sh"

check-wlroots:
	@"$(ROOT_DIR)/scripts/verify-wlroots.sh"

rpm:
	@"$(ROOT_DIR)/scripts/build-rpm.sh"

rpm-container:
	@"$(ROOT_DIR)/scripts/build-rpm-container.sh"

clean:
	rm -rf "$(ROOT_DIR)/rpmbuild"
