#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

export DEBIAN_DATE="${DEBIAN_DATE:-2020-06-01}"

# For good info on qemu / multi-arch and buildx:
# https://medium.com/@artur.klauser/building-multi-architecture-docker-images-with-buildx-27d80f7e2408

docker::enable::experimental() {
  export DOCKER_CLI_EXPERIMENTAL=enabled
}

docker::test::buildx::working() {
  docker buildx version >/dev/null 2>&1
}

docker::test::buildx::support() {
  cat <<'EOF' >/tmp/test.hcl
variable "t" {
  default = "test"
}

target "default" {
  args = {
    t = "${t}"
  }
}
EOF

  [ "$(docker buildx bake --print -f /tmp/test.hcl | grep '"t": "')" == '            "t": "test"' ] || return 1
}

docker::install::buildx() {
  DOCKER_BUILDKIT=1 docker build --platform=local -o . git://github.com/docker/buildx
  mkdir -p ~/.docker/cli-plugins
  mv buildx ~/.docker/cli-plugins/docker-buildx
}

docker::install::qemu() {
  docker run --rm --privileged docker/binfmt:a7996909642ee92942dcd6cff44b9b95f08dad64
}

docker::setup::context() {
  docker buildx create --node "local-machine" --name "dubo-dubon-duponey" >/dev/null
}

# Ensure we have a working docker environemnt to start
docker::enable::experimental
>&2 printf " > Enabling docker experimental support.\n"
>&2 printf " > Verifying that docker buildx is working.\n"

docker::test::buildx::working || {
  >&2 printf "    |!| docker buildx is *not* functioning. Your version of docker might simply be too old. You need to manually fix this manually.\n"
  exit 1
}

>&2 printf "    |x| docker buildx is operational.\n"

# Honor commands
case "${1:-}" in
  "install-buildx")
    >&2 printf " > installing buildx. Press enter to continue.\n"
    read -r
    docker::install::buildx || {
      >&2 printf "    |!| failed installing docker buildx!\n"
      exit 1
    }
    >&2 printf "    |x| successfully installed docker buildx plugin from master.\n"
    exit
    ;;
  "enable-multiarch")
    >&2 printf "Installing qemu. Press enter to continue.\n"
    read -r
    docker::install::qemu || {
      >&2 printf "    |!| failed installing qemu. Do you have permission to run privileged containers?\n"
      exit 1
    }
    >&2 printf "    |x| successfully ran docker qemu setup container. Your machine should be able to build multi arch images now.\n"
    exit
    ;;
  "" | "--help")
    >&2 printf "Available commands:\n"
    >&2 printf " * install-buildx: install the latest master version of buildx from git, and copy it into your docker cli plugins folder\n"
    >&2 printf " * enable-multiarch: enable multi-architecture support on this host by installing qemu (the docker way)\n"
    >&2 printf "To build the project, pass any of the following arguments (passed directly to buildx bake):\n"
    >&2 printf " * --push (to publish the build)\n"
    >&2 printf " * --load (to load the result of the build into docker)\n"
    >&2 printf " * --print (to dry-run and dump the build configuration)\n"
    >&2 printf " * --no-cache (to bypass cache)\n"
    >&2 printf "You may also override any of the variables using corresponding ENV variables\n"
    >&2 printf "You may also override any bake value (platform, etc) using build bake syntax: https://github.com/docker/buildx#buildx-bake-options-target\n"
    exit
    ;;
esac

>&2 printf " > Verifying that docker buildx is recent enough.\n"
docker::test::buildx::support || {
  printf >&2 "    |!| Your version of docker buildx does NOT support variable interpolation. It is too old. You need >=0.4. You can use: %s install-buildx to install a more recent version, or fix this manually yourself.\n" "${BASH_SOURCE[0]}"
  exit 1
}
>&2 printf "    |x| buildx is recent enough.\n"

>&2 printf " > Checking docker buildx build env.\n"
[ "${BUILDX:-}" ] || docker::setup::context

>&2 printf " > Using:\n"
>&2 docker buildx use "${BUILDX:-dubo-dubon-duponey}"
>&2 docker buildx inspect

# shellcheck source=/dev/null
root="$(cd "$(dirname "${BASH_SOURCE[0]:-$PWD}")" 2>/dev/null 1>&2 && pwd)"

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
URL="$(printf "%s" "$URL" | sed -E 's,.git$,,' | sed -E 's,^[a-z-]+:([^/]),https://github.com/\1,')"

export LICENSE
export DATE
export VERSION
export REVISION
export URL

PWD="$root" \
  docker buildx bake \
    -f "$root"/docker-bake.hcl \
    -f "$root"/docker-bake.override.hcl \
    "$@"
