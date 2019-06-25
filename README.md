# What

A docker image for [Apple Filing Protocol](https://en.wikipedia.org/wiki/Apple_Filing_Protocol) file sharing, Tracker (search/spotlight integration), and mDNS server for service discovery.

Specifically useful as a Time Machine server.

## Run

```bash
docker run \
    --net=host \
    --volume [host_path]:/media/home \
    --volume [host_path]:/media/share \
    --volume [host_path]:/media/timemachine \
    --env NAME="My AFP Server" \
    --env USERS="$(id -un)" \
    --env PASSWORDS="secret" \
    dubodubonduponey/netatalk:v1
```

## Notes

### Network

 * `bridge` mode will NOT work, since mDNS will not broadcast on your lan subnet
 * `host` (default, easy choice) is only acceptable as long as you DO NOT have any other containers running on the same host using avahi

If you intend on running multiple containers relying on avahi (like a timemachine server for eg), or even two instances
of `shairport-sync`, you may want to consider `macvlan`.

TL;DR:

```bash
docker network create -d macvlan \
  --subnet=192.168.1.0/24 \
  --ip-range=192.168.1.128/25 \
  --gateway=192.168.1.1 \
  -o parent=eth0 hackvlan
  
docker run -d -e NAME=N1 -e USERS="$(id -un)" -e PASSWORDS="secret" --name=N1 --network=hackvlan dubodubonduponey/netatalk:v1
docker run -d -e NAME=N2 -e USERS="$(id -un)" -e PASSWORDS="secret" --name=N2 --network=hackvlan dubodubonduponey/netatalk:v1
```

Need help with macvlan?
[Hit yourself up](https://docs.docker.com/network/macvlan/).


### Configuration

You may specify as many users/passwords as you want (space separated).

Home directories are accessible only by the corresponding user.

`share` is accessible by everyone.

`timemachine` is accessible by everyone as well (hint: backups SHOULD then be encrypted).

Guest access is also enabled for `share` (name `brigitte`) (XXX guest access does not work right now).

If you want to tweak the `afp.conf` file, documentation is [here](http://netatalk.sourceforge.net/3.1/htmldocs/afp.conf.5.html).

### Advanced configuration

Would you need to, you may optionally pass along:
 
 * `--volume [host_path]/afp.conf:/etc/afp.conf` if you want to tweak the afp configuration at runtime
 * `--volume [host_path]/avahi-daemon.conf:/etc/avahi/avahi-daemon.conf` if you need to tweak avahi

Also, any additional arguments when running the image will get fed to the `netatalk` binary.
