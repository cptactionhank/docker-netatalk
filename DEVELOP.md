# Hackers zone

## Build from source

### TL;DR

```bash
./hack/build.sh image --inject tags=registry/you/image
```

### The what

This image is built using: `ghcr.io/dubo-dubon-duponey/base:builder-bullseye-2021-08-01` 

The runtime part is based on: `ghcr.io/dubo-dubon-duponey/base:runtime-bullseye-2021-08-01`

Both these images are built upon: `ghcr.io/dubo-dubon-duponey/debian:bullseye-2021-08-01`, a debootstrapped version of Debian ("bullseye" at this time), built from a snapshot at 2021-08-01.

You can find out more here:

 * https://github.com/dubo-dubon-duponey/docker-debian for the debootstrapped Debian base
 * https://github.com/dubo-dubon-duponey/docker-base for the builder and runtime images

These images provide very little - they are (mostly) barebone bullseye with some ONBUILD
Docker syntactic sugar (metadata, user creation, entrypoint).

Let me repeat: you have very little reason to go and add anything up there.

### Configuration reference

```bash
# Have a look at the hack/recipe.cue file if you want to modify hard-wired values

# The following flags are currently supported:

# Override default platform choice (not all images allow that):
./hack/build.sh image --inject platforms="linux/amd64,linux/arm/v7"

# Specify a collection of tags to push to
./hack/build.sh image --inject tags="registry1/name/image,registry2/name/image:tag"

# Bust cache
./hack/build.sh image --inject no_cache=true
```

## Develop

### TL;DR

Hack away.

Be sure to run `./hack/lint.sh` and `./hack/test.sh` before submitting anything.

### About branches

`master` is usually outdated, but stable

`work` is a development branch, with possibly unstable / dramatic changes

### Philosophy

 * keep it simple
    * entrypoint should be kept self-contained
    * minimize runtime dependencies
    * base images should be kept dead simple
    * one process per container (mdns broadcasting and letsencrypt refresh being one of a few exceptions)
 * unrelated ops should go elsewhere
    * advanced logging infrastructure does not belong inside a container
    * no init system: failing containers should fail, exit, and be handled from the outside
 * keep it secure
    * no root
    * no write
    * no cap
 * use the provided infrastructure
    * runnable artifacts go to:
        * `/boot/bin` (read-only)
    * configuration should be read from:
        * `/config` (read-only)
    * certificates should go to:
        * `/certs` (either read-only or read-write)
    * persistent application data should use:
        * `/data` (usually read-write)
    * volatile data should use:
        * `/tmp` (usually read-write)
 * only use chroot to downgrade if you really REALLY need to start your entrypoint with "root"
