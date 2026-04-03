Name:           lxqt-themes
Version:        2.3.0
Release:        1%{?dist}
Summary:        Themes, graphics, and wallpapers for LXQt

License:        LGPL-2.1-or-later AND CC-BY-SA-3.0
URL:            https://lxqt-project.org/
Source0:        https://github.com/lxqt/%{name}/releases/download/%{version}/%{name}-%{version}.tar.xz

BuildArch:      noarch

BuildRequires:  cmake
BuildRequires:  gcc-c++
BuildRequires:  lxqt-build-tools
BuildRequires:  perl

%description
Themes, palettes, graphics, wallpapers, and related assets for the LXQt desktop.

%prep
%autosetup -n %{name}-%{version}

%build
%cmake
%cmake_build

%install
%cmake_install

%files
%license COPYING
%doc AUTHORS CHANGELOG README.md
%{_datadir}/icons/hicolor/scalable/apps/lxqt.svg
%{_datadir}/icons/hicolor/scalable/places/start-here-lxqt.svg
%{_datadir}/lxqt/graphics/
%{_datadir}/lxqt/palettes/
%{_datadir}/lxqt/themes/
%{_datadir}/lxqt/wallpapers/

%changelog
* Fri Apr 03 2026 Sam H <samh@example.invalid> - 2.3.0-1
- Package lxqt-themes for EL10 LXQt sessions