Name:           fluxbox-styles-samh
Version:        0.1.0
Release:        1%{?dist}
Summary:        Sam H Fluxbox styles

License:        LicenseRef-samh-personal-styles
BuildArch:      noarch
Source0:        %{name}-%{version}.tar.gz

%description
Curated Fluxbox styles maintained in this repository and installed as system
styles.

%prep
%autosetup -n %{name}-%{version}

%build

%install
install -d %{buildroot}%{_datadir}/fluxbox/styles
cp -a styles/* %{buildroot}%{_datadir}/fluxbox/styles/

%files
%dir %{_datadir}/fluxbox/styles
%{_datadir}/fluxbox/styles/samh-PaperMint
%{_datadir}/fluxbox/styles/samh-Porcelain
%{_datadir}/fluxbox/styles/samh-Sandbar

%changelog
* Thu Mar 12 2026 Sam H <samh@example.com> - 0.1.0-1
- Add personal Fluxbox style pack
