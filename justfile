set shell := ["/usr/bin/bash", "-eu", "-o", "pipefail", "-c"]

default:
    @just --list --unsorted

bootstrap:
    @./scripts/bootstrap-host.sh

apply-sway-config:
    @./scripts/apply-sway-config.sh

setup-remote-session:
    @./scripts/setup-remote-wayvnc-user.sh

package-sync package:
    @./scripts/package-sync.sh --package {{package}}

package-build package:
    @./scripts/package-build.sh --package {{package}}

package-build-many *packages:
    @args=(); for pkg in {{packages}}; do args+=("--package" "$$pkg"); done; ./scripts/package-build.sh "$${args[@]}"

package-install package:
    @./scripts/package-install-built.sh --package {{package}}

package-install-dry-run package:
    @./scripts/package-install-built.sh --package {{package}} --dry-run

package-localrepo:
    @./scripts/package-build.sh --refresh-localrepo

profile-sync profile:
    @./scripts/profile-sync.sh --profile {{profile}}

profile-build profile:
    @./scripts/profile-build.sh --profile {{profile}}

profile-build-sync profile:
    @./scripts/profile-sync.sh --profile {{profile}}
    @./scripts/profile-build.sh --profile {{profile}}

profile-install profile:
    @./scripts/profile-install-built.sh --profile {{profile}}

profile-install-dry-run profile:
    @./scripts/profile-install-built.sh --profile {{profile}} --dry-run

profile-install-config profile:
    @./scripts/profile-install-config.sh --profile {{profile}}

profile-conf-turbovnc profile:
    @./scripts/profile-write-turbovnc-conf.sh --profile {{profile}}

profile-write-xstartup profile:
    @./scripts/profile-write-xstartup.sh --profile {{profile}}
