#!/bin/bash

set -x
set -e

REPONAME=lxpanel
GITURL=https://github.com/lxde/${REPONAME}.git

DATE=$(date '+%Y%m%d')
TIME=$(date '+%H%M')

TARNAME=${REPONAME}-${DATE}T${TIME}.tar.gz

PWDDIR=$(pwd)
TMPDIR=$(mktemp -d /var/tmp/libfm-XXXXXX)
pushd $TMPDIR

git clone --mirror $GITURL
tar czf ${TARNAME} ${REPONAME}.git/

pushd ${REPONAME}.git/
git log --format=fuller | head -n 12
popd

cp -p ${TARNAME} $PWDDIR
popd
rm -rf $TMPDIR
