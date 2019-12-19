# What

A docker image for [Apple Filing Protocol](https://en.wikipedia.org/wiki/Apple_Filing_Protocol) file sharing, Tracker (search/spotlight integration), and mDNS server for service discovery.

Specifically useful as a Time Machine server.

## Image features

 * multi-architecture:
    * [x] linux/amd64
    * [x] linux/arm64
    * [x] linux/arm/v7
    * [x] linux/arm/v6
 * hardened:
    * [x] image runs read-only
    * [x] image runs with no capabilities
    * [ ] process runs as a non-root user, disabled login, no shell
        * the entrypoint script still runs as root before dropping privileges (due to avahi-daemon)
 * lightweight
    * [x] based on our slim [Debian buster version](https://github.com/dubo-dubon-duponey/docker-debian)
    * [x] simple entrypoint script
    * [ ] multi-stage build with ~~no installed~~ dependencies for the runtime image:
        * dbus
        * avahi-daemon
        * netatalk
 * observable
    * [x] healthcheck
    * [x] log to stdout
    * [ ] ~~prometheus endpoint~~ not applicable

## Run

```bash
docker run -d \
    --net=host \
    --volume [host_path]:/media/home \
    --volume [host_path]:/media/share \
    --volume [host_path]:/media/timemachine \
    --env NAME="My AFP server name" \
    --env USERS="$(id -un) someone" \
    --env PASSWORDS="secret alsosecret" \
    dubodubonduponey/netatalk:v1
```

## Notes

### Network

 * `bridge` mode will NOT work for discovery, since mDNS will not broadcast on your lan subnet (you may still access the server explicitely on port 548)
 * `host` (default, easy choice) is only acceptable as long as you DO NOT have any other containers running on the same ip using avahi

If you intend on running multiple containers relying on avahi, you may want to consider `macvlan`.

TL;DR:

```bash
docker network create -d macvlan \
  --subnet=192.168.1.0/24 \
  --ip-range=192.168.1.128/25 \
  --gateway=192.168.1.1 \
  -o parent=eth0 hackvlan
  
docker run -d --env NAME=N1 --env USERS="$(id -un)" --env PASSWORDS="secret" --name=N1 --network=hackvlan dubodubonduponey/netatalk:v1
docker run -d --env NAME=N2 --env USERS="$(id -un)" --env PASSWORDS="secret" --name=N2 --network=hackvlan dubodubonduponey/netatalk:v1
```

Need help with macvlan?
[Hit yourself up](https://docs.docker.com/network/macvlan/).

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
