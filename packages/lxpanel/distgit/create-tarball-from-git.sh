#!/bin/sh

set -e
set -x

CURRENTDIR=$(pwd)
PKGNAME=lxpanel

TMPDIR=$(mktemp -d /var/tmp/$PKGNAME-XXXXXX)
pushd $TMPDIR

GITSCM=http://git.lxde.org/git/lxde/$PKGNAME.git

git clone $GITSCM
pushd $PKGNAME

COMMIT=$(git log | head -n 1 | sed -e 's|^.*[ \t]||')
SHORTCOMMIT=$(echo $COMMIT | cut -c-8)
DATE=$(git show --format=%ci $COMMIT | head -n 1 | sed -e 's|[ \t].*$||')
SHORTDATE=$(echo $DATE | sed -e 's|-||g')
VERSION=$(cat configure.ac | grep AC_INIT | sed -n -e 's|^.*,[ \t]*\([0-9\.][0-9\.]*\)[ \t]*,.*$|\1|p')

echo "VERSION=$VERSION"
echo "COMMIT=$COMMIT"
echo "DATE=$DATE"

echo
popd

TARDIR=$PKGNAME-${VERSION}-D${SHORTDATE}git${SHORTCOMMIT}
ln -sf $PKGNAME $TARDIR
tar cjf ${TARDIR}.tar.bz2 ${TARDIR}/./ 

mv ${TARDIR}.tar.bz2 ${CURRENTDIR}/
popd

rm -rf $TMPDIR

