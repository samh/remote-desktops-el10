set shell := ["/usr/bin/bash", "-eu", "-o", "pipefail", "-c"]

# Show the available tasks.
default:
    @just --list --unsorted

# Install host tools needed for local builds.
bootstrap:
    @./scripts/bootstrap-host.sh

# Apply the local sway config into the current user account.
apply-sway-config:
    @./scripts/apply-sway-config.sh

# Set up the WayVNC user session helper for the current user.
setup-remote-session:
    @./scripts/setup-remote-wayvnc-user.sh

# Refresh a package tree from its upstream packaging source.
package-sync package:
    @./scripts/package-sync.sh --package {{package}}

# Build a package and stage its RPMs under out/packages/.
package-build package:
    @./scripts/package-build.sh --package {{package}}

# Generate an SRPM for a package and print its path.
package-srpm package:
    @./scripts/package-build.sh --package {{package}} --srpm-only

# Build several packages in one invocation.
package-build-many *packages:
    @args=(); for pkg in {{packages}}; do args+=("--package" "$$pkg"); done; ./scripts/package-build.sh "$${args[@]}"

# Install the built RPMs for a package.
package-install package:
    @./scripts/package-install-built.sh --package {{package}}

# Show which RPMs would be installed for a package.
package-install-dry-run package:
    @./scripts/package-install-built.sh --package {{package}} --dry-run

# Rebuild the shared local repository from staged package outputs.
package-localrepo:
    @./scripts/package-build.sh --refresh-localrepo

# Refresh all package trees required by a profile.
profile-sync profile:
    @./scripts/profile-sync.sh --profile {{profile}}

# Build all packages required by a profile.
profile-build profile:
    @./scripts/profile-build.sh --profile {{profile}}

# Refresh and then build a profile.
profile-build-sync profile:
    @./scripts/profile-sync.sh --profile {{profile}}
    @./scripts/profile-build.sh --profile {{profile}}

# Install the built RPMs required by a profile.
profile-install profile:
    @./scripts/profile-install-built.sh --profile {{profile}}

# Show which RPMs would be installed for a profile.
profile-install-dry-run profile:
    @./scripts/profile-install-built.sh --profile {{profile}} --dry-run

# Install a profile's user config into a target home directory.
profile-install-config profile:
    @./scripts/profile-install-config.sh --profile {{profile}}

# Write TurboVNC window-manager config for a profile.
profile-conf-turbovnc profile:
    @./scripts/profile-write-turbovnc-conf.sh --profile {{profile}}

# Write a legacy xstartup script for a profile.
profile-write-xstartup profile:
    @./scripts/profile-write-xstartup.sh --profile {{profile}}
