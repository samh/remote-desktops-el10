Name:           sway
Version:        1.11
Release:        1%{?dist}
Summary:        i3-compatible Wayland compositor

License:        MIT
URL:            https://github.com/swaywm/sway
Source0:        %{name}-%{version}.tar.gz

BuildRequires:  gcc
BuildRequires:  meson
BuildRequires:  ninja-build
BuildRequires:  pkgconf-pkg-config
BuildRequires:  scdoc
BuildRequires:  cairo-devel
BuildRequires:  gdk-pixbuf2-devel
BuildRequires:  json-c-devel
BuildRequires:  libevdev-devel
BuildRequires:  libinput-devel
BuildRequires:  libxkbcommon-devel
BuildRequires:  pango-devel
BuildRequires:  systemd-devel
BuildRequires:  wayland-devel
BuildRequires:  wayland-protocols-devel
BuildRequires:  wlroots-devel >= 0.19.0
BuildRequires:  xcb-util-devel
BuildRequires:  xcb-util-errors-devel
BuildRequires:  xcb-util-wm-devel
BuildRequires:  xorg-x11-server-Xwayland-devel

Requires:       seatd
Recommends:     xorg-x11-server-Xwayland

%description
Sway is a tiling Wayland compositor and drop-in replacement for i3.

%prep
%autosetup -n sway-%{version}

%build
%meson \
  -Ddefault-wallpaper=false \
  -Dman-pages=enabled \
  -Dsd-bus-provider=libsystemd \
  -Dtray=enabled \
  -Dxwayland=enabled
%meson_build

%install
%meson_install
find %{buildroot} -type f -name '*.la' -delete

%files
%license LICENSE
%doc README.md
%{_bindir}/sway*
%{_bindir}/swaymsg
%{_datadir}/sway
%{_datadir}/wayland-sessions/sway.desktop
%{_libexecdir}/sway
%{_mandir}/man1/sway*.1*
%{_mandir}/man5/sway*.5*
%{_mandir}/man7/sway*.7*

%changelog
* Tue Feb 24 2026 Sam H <samh@example.com> - 1.11-1
- Reproducible local build for AlmaLinux 10
