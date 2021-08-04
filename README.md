<!> TENTATIVELY DEPRECATED in favor of https://github.com/dubo-dubon-duponey/samba <!>

# What

A docker image for [Apple Filing Protocol](https://en.wikipedia.org/wiki/Apple_Filing_Protocol) file sharing, Tracker (search/spotlight integration), and mDNS server for service discovery.

Specifically useful as a Time Machine server.

Future development will focus on Samba / vfs_fruit instead. https://www.reddit.com/r/homelab/comments/83vkaz/howto_make_time_machine_backups_on_a_samba/

## Image features

* multi-architecture:
  * [x] linux/amd64
  * [x] linux/386
  * [x] linux/arm64
  * [x] linux/arm/v7
  * [x] linux/arm/v6
  * [x] linux/ppc64
  * [ ] linux/s390x
* hardened:
  * [x] image runs read-only
  * [ ] image runs with the following capabilities:
    * NET_BIND_SERVICE
    * CHOWN
    * FOWNER
    * SETUID
    * SETGID
    * DAC_OVERRIDE
  * [ ] process runs as a non-root user, disabled login, no shell
    * the entrypoint script still runs as root before dropping privileges (due to avahi-daemon)
* lightweight
  * [x] based on our slim [Debian bullseye version (2021-08-01)](https://github.com/dubo-dubon-duponey/docker-debian)
  * [x] simple entrypoint script
  * [ ] multi-stage build with ~~no installed~~ dependencies for the runtime image:
    * dbus
    * avahi-daemon
    * netatalk
* observable
  * [ ] ~~healthcheck~~
  * [x] log to stdout
  * [ ] ~~prometheus endpoint~~

## Run

```bash
docker run -d --rm \
    --name "netatalk" \
    --env "NAME=Super Name For Your AFP Server" \
    --env USERS="$(id -un) someone" \
    --env PASSWORDS="secret alsosecret" \
    --volume [host_path]:/media/home \
    --volume [host_path]:/media/share \
    --volume [host_path]:/media/timemachine \
    --net host \
    --cap-drop ALL \
    --cap-add NET_BIND_SERVICE \
    --cap-add CHOWN \
    --cap-add FOWNER \
    --cap-add SETUID \
    --cap-add SETGID \
    --cap-add DAC_OVERRIDE \
    --read-only \
    dubodubonduponey/netatalk
```

## Notes

### Networking

You need to run this in `host` or `mac(or ip)vlan` networking (because of mDNS).

### Configuration

An extra environment variable (`AVAHI_NAME`) allows you to specify a different
name for the avahi workstation. If left unspecified, it will fallback to the value of `NAME`.

You may specify as many users/passwords as you want (space separated).

Home directories are accessible only by the corresponding user.

`share` is accessible by all users.

`timemachine` is accessible by all users as well (hint: backups SHOULD then be encrypted by their respective owners).

Guest access does not work currently, and is disabled.

### Advanced configuration

Would you need to, you may optionally pass along:
 
 * `--volume [host_path]/afp.conf:/etc/afp.conf`
 * `--volume [host_path]/avahi-daemon.conf:/etc/avahi/avahi-daemon.conf`

Also, any additional arguments when running the image will get fed to the `netatalk` binary.

## Moar?

See [DEVELOP.md](DEVELOP.md)
