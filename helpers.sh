#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]:-$PWD}")" 2>/dev/null 1>&2 && pwd)"

# Settings defaults
REGISTRY="${REGISTRY:-index.docker.io}"
VENDOR="${VENDOR:-dubodubonduponey}"
IMAGE_NAME="${IMAGE_NAME:-untitled}"
IMAGE_TAG="${IMAGE_TAG:-v1}"
TITLE="${TITLE:-}"
DESCRIPTION="${DESCRIPTION:-}"
PLATFORMS="${PLATFORMS:-linux/amd64,linux/arm64,linux/arm/v7,linux/arm/v6}"
DEBIAN_DATE=${DEBIAN_DATE:-2020-01-01}
DOCKERFILE="$root/${DOCKERFILE:-Dockerfile}"
BUILDER_BASE="${BUILDER_BASE:-dubodubonduponey/base:builder-${DEBIAN_DATE}}"
RUNTIME_BASE="${RUNTIME_BASE:-dubodubonduponey/base:runtime-${DEBIAN_DATE}}"

# Behavioral
PROXY="${PROXY:-}"
PUSH=--push
CACHE=
NO_PUSH="${NO_PUSH:-}"
NO_CACHE="${NO_CACHE:-}"
[ "$NO_PUSH" ]  && PUSH="--output type=docker"
[ ! "$NO_CACHE" ] || CACHE=--no-cache

# Automated metadata
LICENSE="$(head -n 1 "$root/LICENSE")"
# https://tools.ietf.org/html/rfc3339
# XXX it doesn't seem like BSD date can format the timezone appropriately according to RFC3339 - eg: %:z doesn't work and %z misses the colon, so the gymnastic here
DATE="$(date +%Y-%m-%dT%T%z | sed -E 's/([0-9]{2})([0-9]{2})$/\1:\2/')"
VERSION="$(git -C "$root" describe --match 'v[0-9]*' --dirty='.m' --always)"
REVISION="$(git -C "$root" rev-parse HEAD)$(if ! git -C "$root" diff --no-ext-diff --quiet --exit-code; then printf ".m\\n"; fi)"
# XXX this is dirty, resolve ssh aliasing to github by default
URL="$(git -C "$root" remote show -n origin | grep "Fetch URL")"
URL="${URL#*Fetch URL: }"
URL="$(printf "%s" "$URL"| sed -E 's,.git$,,' | sed -E 's,^[a-z-]+:([^/]),https://github.com/\1,')"
DOCUMENTATION="$URL/blob/1/README.md"
SOURCE="$URL/tree/1"

# Docker settings
export DOCKER_CONTENT_TRUST=1
export DOCKER_CLI_EXPERIMENTAL=enabled

dv="$(docker version | grep "^ Version")"
dv="${dv#*:}"
dv="${dv##* }"
if [ "${dv%%.*}" -lt "19" ]; then
  >&2 printf "Docker is too old and doesn't support buildx. Failing!\n"
  exit 1
fi

# Build invocation
#docker buildx create --node "$VENDOR-${IMAGE_NAME}0" --name "$VENDOR-$IMAGE_NAME"
#docker buildx use "$VENDOR-$IMAGE_NAME"
docker buildx create --node "${VENDOR}0" --name "$VENDOR" > /dev/null
docker buildx use "$VENDOR"

# shellcheck disable=SC2086
docker buildx build --pull --platform "$PLATFORMS" --build-arg="FAIL_WHEN_OUTDATED=${FAIL_WHEN_OUTDATED:-}" \
  --build-arg="BUILDER_BASE=$BUILDER_BASE" \
  --build-arg="RUNTIME_BASE=$RUNTIME_BASE" \
  --build-arg="BUILD_CREATED=$DATE" \
  --build-arg="BUILD_URL=$URL" \
  --build-arg="BUILD_DOCUMENTATION=$DOCUMENTATION" \
  --build-arg="BUILD_SOURCE=$SOURCE" \
  --build-arg="BUILD_VERSION=$VERSION" \
  --build-arg="BUILD_REVISION=$REVISION" \
  --build-arg="BUILD_VENDOR=$VENDOR" \
  --build-arg="BUILD_LICENSES=$LICENSE" \
  --build-arg="BUILD_REF_NAME=$REGISTRY/$VENDOR/$IMAGE_NAME:$IMAGE_TAG" \
  --build-arg="BUILD_TITLE=$TITLE" \
  --build-arg="BUILD_DESCRIPTION=$DESCRIPTION" \
  --build-arg="http_proxy=$PROXY" \
  --build-arg="https_proxy=$PROXY" \
  --file "$DOCKERFILE" \
  --tag "$REGISTRY/$VENDOR/$IMAGE_NAME:$IMAGE_TAG" ${CACHE} ${PUSH} "$@" "$root"

build::getsha(){
  local image_name="$1"
  local image_tag="$2"
  local short_name=${image_name##*/}
  local owner=${image_name%/*}
  local token
  local digest

  owner=${owner##*/}
  token=$(curl https://auth.docker.io/token?service=registry.docker.io\&scope=repository%3A"${owner}"%2F"${short_name}"%3Apull  -v -L -s -H 'Authorization: ' 2>/dev/null | grep '^{' | jq -rc .token)
  digest=$(curl https://registry-1.docker.io/v2/"${owner}"/"${short_name}"/manifests/"${image_tag}" -L -s -I -H "Authorization: Bearer ${token}" -H "Accept: application/vnd.docker.distribution.manifest.v2+json"  -H "Accept: application/vnd.docker.distribution.manifest.list.v2+json" | grep Docker-Content-Digest)
  printf "%s\n" "${digest#*: }"
}

if [ "$REGISTRY" == "registry-1.docker.io" ]; then
  build::getsha "$VENDOR/$IMAGE_NAME" "$IMAGE_TAG"
fi
