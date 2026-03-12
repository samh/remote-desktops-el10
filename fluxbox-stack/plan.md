Build the necessary RPMs to run Fluxbox on RHEL10 variants (including this system, which is AlmaLinux 10).

You may look at openbox-stack for ideas, but no need to follow those patterns closely.
Create a `justfile` for common tasks.

You have full sudo access to install required packages.

Requirements:
- Use mock to build RPMs.
- The repo should be structured in a way that makes it easy to build the packages using COPR later.
- All RPMs should be available in a common output folder (hard-linked if possible)
  to make them easy to find.

After building:
- Install the packages.
- Install the configuration.
- Configure TurboVNC to run it (no need to start a session). TurboVNC is already installed.
