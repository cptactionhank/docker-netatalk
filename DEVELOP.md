# Hackers zone

## Build from source

### TL;DR

```bash
./hack/cue-bake image --inject tags=registry/you/image
```

### The what

This image is built using: `dubodubonduponey/base:builder-$DEBOOTSTRAP_SUITE-$DEBOOTSTRAP_DATE` 

The runtime part is based on: `dubodubonduponey/base:runtime-$DEBOOTSTRAP_SUITE-$DEBOOTSTRAP_DATE`

Both these images are built upon: `dubodubonduponey/debian:$DEBOOTSTRAP_SUITE-$DEBOOTSTRAP_DATE`, a debootstrapped version of Debian ("buster" at this time), built from a snapshot at `$DEBOOTSTRAP_DATE`.

At the time of this writing, `DEBOOTSTRAP_DATE` evaluates to `2020-09-01`, and is updated every 15 days.

You can find out more here:

 * https://github.com/dubo-dubon-duponey/docker-debian for the debootstrapped Debian base
 * https://github.com/dubo-dubon-duponey/docker-base for the builder and runtime images

These images provide very little - they are (mostly) barebone Buster with some ONBUILD
Docker syntactic sugar (metadata, user creation, entrypoint).

Let me repeat: you have very little reason to go and add anything up there.

### Configuration reference

```bash
# Have a look at the bake_tool.cue file if you want to modify hard-wired values (image title and description for example)

# The following flags are currently supported:

# Override default platform choice (not all images allow that):
./hack/cue-bake image --inject platforms="linux/amd64,linux/arm/v7"

# Specify a collection of tags to push to
./hack/cue-bake image --inject tags="registry1/name/image,registry2/name/image:tag"

# Bust cache
./hack/cue-bake image --inject no_cache=true

# Environment variables you may tweak

# Space-separated options to be passed to apt-get
export APT_OPTIONS=""
# If you want to use entirely different sources.list
export APT_SOURCES
# If you need to trust additional GPG keys
export APT_TRUSTED

# Self-explanatory
export http_proxy
export https_proxy

# Which base date you want to use (eg: 2020-09-01)
export DEBOOTSTRAP_DATE
# Which base suite you want to use (only buster exist for now)
export DEBOOTSTRAP_SUITE

# Allows you to pass a goproxy
export GOPROXY
```

## Develop

### TL;DR

Hack away.

Be sure to run `./test.sh` before submitting anything.

### About branches

`master` is the currently stable version that published images are based on.

`work` is a development branch, with possibly unstable / dramatic changes.

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
