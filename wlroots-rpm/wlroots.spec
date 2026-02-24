%global abi_ver 0.19
%global liftoff_ver 0.4.0

Name:           wlroots
Version:        0.19.2
Release:        1%{?dist}
Summary:        A modular Wayland compositor library

License:        MIT
URL:            https://gitlab.freedesktop.org/wlroots/wlroots
Source0:        %{url}/-/releases/%{version}/downloads/%{name}-%{version}.tar.gz

BuildRequires:  gcc
BuildRequires:  meson >= 1.3
BuildRequires:  pkgconf-pkg-config
BuildRequires:  pkgconfig(egl)
BuildRequires:  pkgconfig(gbm) >= 17.1.0
BuildRequires:  pkgconfig(glesv2)
BuildRequires:  pkgconfig(hwdata)
BuildRequires:  pkgconfig(libdisplay-info) >= 0.2.0
BuildRequires:  pkgconfig(libdrm) >= 2.4.122
BuildRequires:  pkgconfig(libinput) >= 1.19.0
BuildRequires:  pkgconfig(libliftoff) >= %{liftoff_ver}
BuildRequires:  pkgconfig(libseat)
BuildRequires:  pkgconfig(libudev)
BuildRequires:  pkgconfig(pixman-1) >= 0.43.0
BuildRequires:  pkgconfig(wayland-protocols) >= 1.41
BuildRequires:  pkgconfig(wayland-scanner)
BuildRequires:  pkgconfig(wayland-server) >= 1.23.1
BuildRequires:  pkgconfig(xcb)
BuildRequires:  pkgconfig(xcb-composite)
BuildRequires:  pkgconfig(xcb-errors)
BuildRequires:  pkgconfig(xcb-ewmh)
BuildRequires:  pkgconfig(xcb-icccm)
BuildRequires:  pkgconfig(xcb-render)
BuildRequires:  pkgconfig(xcb-res)
BuildRequires:  pkgconfig(xcb-xfixes)
BuildRequires:  pkgconfig(xkbcommon)
BuildRequires:  pkgconfig(xwayland)

Requires:       libliftoff%{?_isa} >= %{liftoff_ver}

%description
wlroots is a modular Wayland compositor library.

%package devel
Summary:        Development files for wlroots
Requires:       %{name}%{?_isa} = %{version}-%{release}

%description devel
Development headers and pkg-config data for wlroots.

%prep
%autosetup -n %{name}-%{version}

%build
%meson \
  -Dexamples=false \
  -Dbackends=drm,libinput \
  -Drenderers=gles2 \
  -Dallocators=gbm \
  -Dsession=enabled \
  -Dxwayland=enabled \
  -Dxcb-errors=enabled \
  -Dlibliftoff=enabled \
  -Dcolor-management=disabled
%meson_build

%install
%meson_install
find %{buildroot} -type f -name '*.la' -delete

%post -p /sbin/ldconfig
%postun -p /sbin/ldconfig

%files
%license LICENSE
%doc README.md
%{_libdir}/libwlroots-%{abi_ver}.so

%files devel
%{_includedir}/wlroots-%{abi_ver}/wlr
%{_libdir}/pkgconfig/wlroots-%{abi_ver}.pc

%changelog
* Tue Feb 24 2026 Sam H <samh@example.com> - 0.19.2-1
- Reproducible local build for AlmaLinux 10
