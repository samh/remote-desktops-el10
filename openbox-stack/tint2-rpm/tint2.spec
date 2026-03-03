Name:           tint2
Version:        17.0.2
Release:        1%{?dist}
Summary:        A lightweight X11 desktop panel and task manager

License:        GPLv2
URL:            https://gitlab.com/o9000/%{name}
Source0:        %{url}/-/archive/v%{version}/%{name}-v%{version}.tar.bz2

BuildRequires:  gcc
BuildRequires:  gcc-c++
BuildRequires:  cmake
BuildRequires:  ninja-build
BuildRequires:  pkgconfig(gtk+-x11-3.0)
BuildRequires:  pkgconfig(pango)
BuildRequires:  pkgconfig(cairo)
BuildRequires:  pkgconfig(xinerama)
BuildRequires:  pkgconfig(imlib2)
BuildRequires:  pkgconfig(xdamage)
BuildRequires:  pkgconfig(xcomposite)
BuildRequires:  pkgconfig(xrender)
BuildRequires:  pkgconfig(xrandr)
BuildRequires:  pkgconfig(librsvg-2.0)
BuildRequires:  pkgconfig(libstartup-notification-1.0)
BuildRequires:  gettext
BuildRequires:  desktop-file-utils

%description
tint2 is a simple panel/taskbar made for modern X window managers. It was
specifically made for Openbox but also works with other window managers.

%prep
%autosetup -p1 -n %{name}-v%{version}

%build
%cmake -DENABLE_EXAMPLES=ON -GNinja
%cmake_build

%install
%cmake_install

rm -rf %{buildroot}%{_datadir}/doc/

install -p -m 0644 packaging/debian/tint2conf.1 %{buildroot}/%{_mandir}/man1/

desktop-file-install \
  --set-key=NoDisplay --set-value=true \
  --delete-original \
  --dir=%{buildroot}%{_datadir}/applications \
  %{buildroot}/%{_datadir}/applications/tint2.desktop

desktop-file-install \
  --delete-original \
  --dir=%{buildroot}%{_datadir}/applications \
  %{buildroot}/%{_datadir}/applications/tint2conf.desktop

%find_lang tint2conf

%files -f tint2conf.lang
%doc AUTHORS ChangeLog README.md doc/images/
%doc doc/manual.html doc/readme.html doc/tint2.md
%license COPYING
%{_bindir}/tint2
%{_bindir}/tint2conf
%dir %{_sysconfdir}/xdg/tint2/
%config(noreplace) %{_sysconfdir}/xdg/tint2/tint2rc
%{_datadir}/tint2/
%{_datadir}/applications/tint2conf.desktop
%{_datadir}/applications/tint2.desktop
%{_datadir}/icons/hicolor/scalable/apps/tint*
%{_datadir}/mime/packages/tint2conf.xml
%{_mandir}/man1/tint2*

%changelog
* Tue Mar 03 2026 Sam H <samh@example.com> - 17.0.2-1
- Add local tint2 spec for EL10 testing
