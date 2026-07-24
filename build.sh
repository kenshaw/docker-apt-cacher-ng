#!/usr/bin/env bash

IMAGE=docker.io/kenshaw/apt-cacher-ng
VERSION=latest

DOCKER_USER=kenshaw
DOCKER_PASSFILE=$HOME/.config/headless-shell/token

for TARGET in amd64 arm64; do
  IMG="localhost/$(basename "$IMAGE"):${VERSION}-${TARGET}"
  echo -e "BUILDING ${TAG} ($(date))"
  (set -x;
    buildah build \
      --platform linux/${TARGET} \
      --tag ${IMG} .
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
