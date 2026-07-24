#!/usr/bin/env bash

SRC=$(realpath $(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd))

IMAGE=docker.io/kenshaw/apt-cacher-ng
VERSION=latest

DOCKER_USER=kenshaw
DOCKER_PASSFILE=$HOME/.config/headless-shell/token

PUSH=0

OPTIND=1
while getopts "p" opt; do
case "$opt" in
  p) PUSH=1 ;;
esac
done

set -e

for TARGET in amd64 arm64; do
  IMG="localhost/$(basename "$IMAGE"):${VERSION}-${TARGET}"
  echo -e "BUILDING ${TAG} ($(date))"
  (set -x;
    buildah build \
      --platform linux/${TARGET} \
      --tag ${IMG} \
      $SRC
  )
done

NAME="localhost/$(basename "$IMAGE"):latest"

# create manifest
echo -e "\n\nCONFIGURING MANIFEST $NAME ($(date))"

if `buildah manifest exists $NAME`; then
  for HASH in $(buildah manifest inspect $NAME|jq -r '.manifests[]|.digest'); do
    (set -x;
      buildah manifest remove $NAME $HASH
    )
  done
else
  (set -x;
    buildah manifest create $NAME
  )
fi

for TARGET in amd64 arm64; do
  IMG="localhost/$(basename "$IMAGE"):${VERSION}-${TARGET}"
  (set -x;
    buildah manifest add $NAME $IMG
  )
done

if [ $PUSH -eq 1 ]; then
  REPO=$(sed -e 's%^docker\.io/%%' <<< "$IMAGE")

  echo -e "\n\nPUSHING MANIFEST $NAME --> ${IMAGE}:${VERSION} ($(date))"

  (set -x;
    buildah login docker.io \
      --username $DOCKER_USER \
      --password-stdin < $DOCKER_PASSFILE
  )

  (set -x;
    buildah manifest push \
      --all \
      $NAME \
      docker://$REPO:$VERSION
  )
fi
