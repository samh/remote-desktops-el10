#!/bin/bash

set -x
set -e

REPONAME=lxterminal
GITBASEURL=${REPONAME}.git
GITURL=https://github.com/lxde/${GITBASEURL}

DATE=$(date '+%Y%m%d')
TIME=$(date '+%H%M')

PWDDIR=$(pwd)
TMPDIR=$(mktemp -d /var/tmp/${REPONAME}-XXXXXX)
pushd $TMPDIR

mkdir MIRROR
cd MIRROR
git clone --mirror $GITURL
cd ..
mkdir MASTER
cd MASTER
git clone ../MIRROR/${GITBASEURL}
cd ${REPONAME}
VERSION=$(cat configure.ac | sed -n -e '\@AC_INIT@s|^.*,[ \t]*\([0-9][0-9\.]*\),.*$|\1|p')
cd ../..

TARNAME=${REPONAME}-${VERSION}-${DATE}T${TIME}.tar.gz

cd MIRROR

pushd ${REPONAME}.git/
git log --format=fuller | head -n 12
popd


tar czf ${TARNAME} ${REPONAME}.git/
cp -p ${TARNAME} $PWDDIR

popd
rm -rf $TMPDIR
