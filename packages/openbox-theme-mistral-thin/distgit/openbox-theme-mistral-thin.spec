Name:           openbox-theme-mistral-thin
Version:        0
Release:        1.20170125%{?dist}
Summary:        Mistral Thin theme for Openbox

License:        CC-BY-SA
URL:            https://www.box-look.org/p/1169127/
Source0:        %{name}-20170125.tar.gz
BuildArch:      noarch
Requires:       openbox

%description
Mistral Thin theme for the Openbox window manager.

%prep
%autosetup -n %{name}-20170125

%build

%install
mkdir -p %{buildroot}%{_datadir}/themes
cp -a Mistral-Thin %{buildroot}%{_datadir}/themes/

%files
%{_datadir}/themes/Mistral-Thin/

%changelog
* Thu Apr 02 2026 Sam H <samh@example.invalid> - 0-1.20170125
- Add Mistral Thin theme package for LXQt X11 session installs
