# Hackers zone

## Build from source

### TL;DR

```bash
VENDOR=you
IMAGE_NAME=super_image
IMAGE_TAG=sometag
./build.sh
```

### The what

This image is built using `dubodubonduponey/base:builder-$DEBIAN_DATE` and its runtime uses `dubodubonduponey/base:runtime-$DEBIAN_DATE`.

Both these images are built upon `dubodubonduponey/debian:$DEBIAN_DATE`, a debootstrapped version of Debian Buster, built from a Debian snapshot at `$DEBIAN_DATE`.

At the time of this writing, `DEBIAN_DATE` evaluates to `2019-12-01`, and is updated every 15 days.

You can find out more here:

 * https://github.com/dubo-dubon-duponey/docker-debian for the debootstrapped Debian base
 * https://github.com/dubo-dubon-duponey/docker-base for the builder and runtime images

These images provide very little - they are (mostly) barebone Buster with metadata and some ONBUILD
Docker syntactic sugar (metadata, user creation, entrypoint).

Let me repeat: you have very little reason to go and add anything up there.

### Configuration reference

```bash
# Controls to which registry your image gets pushed (default to Docker Hub if left unspecified)
REGISTRY="registry-1.docker.io"

# "Vendor" name of the image (eg: `REGISTRY/VENDOR/IMAGE`)
VENDOR="dubodubonduponey"

# Image name (as in `REGISTRY/VENDOR/IMAGE`)
IMAGE_NAME="super_image"

# Tag name to publish
IMAGE_TAG="v1"

# Image metadata (applied through labels)
TITLE="My super image title"
DESCRIPTION="My super image description"

# Platforms you want to target (note: certain platforms may be unavailable for the underlying software)
PLATFORMS="linux/amd64,linux/arm64,linux/arm/v7,linux/arm/v6}"

# Base debian image date to use (from our own base images)
DEBIAN_DATE=2019-12-01

# Controls which user-id to assign to the in-container user
BUILD_UID=2000
```

### Behavior control

```bash
# Do NOT push the built image if left empty (useful for debugging) - default to true
PUSH=
# Do NOT use buildkit cache if left empty - default to true
CACHE=

```

## Develop

### TL;DR

Hack away.

Be sure to run `./test.sh` before submitting anything.

### Philosophy

 * keep it simple
    * entrypoint should be kept self-contained
    * minimize runtime dependencies
    * base images should be kept dead simple
    * one process per container (letsencrypt refresh being the only exception)
 * unrelated ops should go elsewhere
    * advanced logging infrastructure does not belong inside a container
    * no init system, failing containers should fail, exit, and be handled from the outside
 * keep it secure
    * no root
    * no write
    * no cap
 * use existing infrastructure
    * runnable artifacts go to:
        * `/boot/bin` (read-only)
    * configuration goes to:
        * `/config` (read-only)
    * certificates go to:
        * `/certs` (read-write)
    * persistent application data goes to:
        * `/data` (read-write)
    * volatile data go to:
        * `/tmp` (read-write)
 * only use chroot if you really REALLY need root first
