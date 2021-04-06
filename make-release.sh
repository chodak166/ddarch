#!/bin/bash

set -e
#set -x

PACKAGE=ddarch
VERSION=$(./ddarch --version | grep -Eo '[0-9.]+')
PREFIX=${PACKAGE}_${VERSION}
TMP_DIR=/tmp/${PACKAGE}_package
OUT_DIR=./package
PACKAGE_BRANCH=debian-package

SRC_BRANCH=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p')

if [[ "$SRC_BRANCH" != "master" ]]; then
  echo -e "\nCurrent branch is not master branch, continue? [y/N]"
  read c
  if [[ "$c" != "y" ]]; then
    exit 0
  fi
fi

backToOriginBranch()
{
  git checkout $SRC_BRANCH
}

trap backToOriginBranch EXIT

toRemove=$(git clean --dry-run -fdx)

if [ ! -z "$toRemove" ]; then
  echo "$toRemove"
  echo -e "\nContinue? [y/N]"
  read c
  if [[ "$c" != "y" ]]; then
    exit 0
  fi
fi

git clean -fdx

help2man --no-info \
  --name "archive & restore utility for dd disk images" \
  ./ddarch -o man/ddarch.1

CHANGED=$(git diff --name-only)

if [ ! -z "$CHANGED" ]; then
  echo "Please commit the changes and try again:"
  echo "$CHANGED"
  exit 1
fi

mkdir $TMP_DIR || rm -r $TMP_DIR/*
git archive --format=tar --prefix=$PREFIX/ HEAD | gzip -c > $TMP_DIR/$PREFIX.orig.tar.gz

git checkout $PACKAGE_BRANCH
gbp import-orig $TMP_DIR/${PACKAGE}_${VERSION}.orig.tar.gz
gbp buildpackage -us -uc \
  --git-ignore-new \
  --git-arch='all' \
  --git-builder='debuild -i -I -S' \
  --git-export-dir=$TMP_DIR
  
mv $TMP_DIR $OUT_DIR

echo "${OUT_DIR}: "
ls -1 "${OUT_DIR}"
echo "You can now sign the package with 'debsign -k <key> <package>.changes'"
