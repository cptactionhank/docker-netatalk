#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

export BIN_LOCATION="${BIN_LOCATION:-$HOME/Dubo/bin}"
export SUITE=bullseye
export DATE=2021-08-01

export PATH="$BIN_LOCATION:$PATH"
readonly IMAGE_TOOLS="${IMAGE_TOOLS:-ghcr.io/dubo-dubon-duponey/tools:$(uname | grep -q Darwin && printf "macos" || printf "linux")-$SUITE-$DATE}"
readonly IMAGE_BLDKT="${IMAGE_BLDKT:-ghcr.io/dubo-dubon-duponey/buildkit:$SUITE-$DATE}"

setup::tools(){
  local location="$1"
  if  command -v "$location/cue" > /dev/null &&
      command -v "$location/buildctl" > /dev/null &&
      command -v docker > /dev/null; then
    return
  fi

  mkdir -p "$location"
  docker rm -f dubo-tools 2>/dev/null || true
  docker run --pull always --name dubo-tools "$IMAGE_TOOLS" /boot/bin/cue >/dev/null 2>&1 || true
  docker cp dubo-tools:/boot/bin/cue "$location"
  docker cp dubo-tools:/boot/bin/buildctl "$location"
  docker cp dubo-tools:/boot/bin/docker "$location"
  docker rm -f dubo-tools 2>/dev/null || true
}

# XXX add hado & shellcheck to the images
command -v hadolint >/dev/null || {
  printf >&2 "You need to install hadolint"
  exit 1
}

command -v shellcheck >/dev/null || {
  printf >&2 "You need to install shellcheck"
  exit 1
}

setup::buildkit(){
  docker inspect dbdbdp-buildkit 1>/dev/null 2>&1 || \
    docker run --pull always --rm -d \
      -p 4242:4242 \
      --network host \
      --name dbdbdp-buildkit \
      --env MDNS_ENABLED=true \
      --env MDNS_HOST=buildkit-machina \
      --env MDNS_NAME="Dubo Buildkit on la machina" \
      --entrypoint buildkitd \
      --user root \
      --privileged \
      "$IMAGE_BLDKT"
}

setup::tools "$BIN_LOCATION"

# XXX deprecating for now since we moved to addr and injects
# [ "${BUILDKIT_HOST:-}" != "docker-container://dbdbdp-buildkit" ] || setup::buildkit
