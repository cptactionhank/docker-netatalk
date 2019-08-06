#!/usr/bin/env bash

# Build parameters
IMAGE_OWNER="${IMAGE_OWNER:-dubodubonduponey}"
IMAGE_NAME="${IMAGE_NAME:-netatalk}"
IMAGE_VERSION="${IMAGE_VERSION:-v1}"
PLATFORMS="${PLATFORMS:-linux/amd64,linux/arm64,linux/arm/v7,linux/arm/v6}"

# Behavioral overrides
[ "$NO_PUSH" ] || PUSH=--push
[ ! "$NO_CACHE" ] || CACHE=--no-cache

# Build metadata
GIT_VERSION="$(git describe --match 'v[0-9]*' --dirty='.m' --always)"
GIT_REVISION="$(git rev-parse HEAD)$(if ! git diff --no-ext-diff --quiet --exit-code; then printf ".m\\n"; fi)"
GIT_REPO="$(git remote show -n origin | grep "Fetch URL")"
GIT_REPO="${GIT_REPO#*Fetch URL: }"
LICENSE="$(head -n 1 LICENSE)"
BUILD_DATE="$(date -R)"

# Docker settings
export DOCKER_CONTENT_TRUST=1
export DOCKER_CLI_EXPERIMENTAL=enabled

dv="$(docker version | grep "^ Version")"
dv="${dv#*:}"
dv="${dv##* }"
if [ "${dv%%.*}" != "19" ]; then
  echo "Docker is too old and doesn't support buildx. Failing!"
  exit 1
fi

# Build invocation
docker buildx create --name "$IMAGE_OWNER-$IMAGE_NAME"
docker buildx use "$IMAGE_OWNER-$IMAGE_NAME"
docker buildx build --platform "$PLATFORMS" \
  --label dockerfile.repository="$GIT_REPO" \
  --label dockerfile.license="$LICENSE" \
  --label dockerfile.version="$GIT_VERSION" \
  --label dockerfile.commit="$GIT_REVISION" \
  --label dockerfile.build="$BUILD_DATE" \
  -t "$IMAGE_OWNER/$IMAGE_NAME:$IMAGE_VERSION" $CACHE $PUSH .
