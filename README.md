# What

A docker image for [Apple Filing Protocol](https://en.wikipedia.org/wiki/Apple_Filing_Protocol) file sharing, Tracker (search/spotlight integration), and mDNS server for service discovery.

Specifically useful as a Time Machine server.

## Run

```bash
docker run \
    --net=host
    --publish 548:548 \
    --volume [host_path]:/media/share --volume [host_path]:/media/timemachine \
    --env AVAHI=1 \
    --env AFP_USER=$(id -un) \
    --env AFP_PASSWORD=secret \
    --env AFP_UID=$(id -u) \
    --env AFP_GID=$(id -g) \
    dubodubonduponey/system-netatalk:v1
```

## Notes

### Configuration

Documentation for afp configuration `/etc/afp.conf` can be found [here](http://netatalk.sourceforge.net/3.1/htmldocs/afp.conf.5.html).

### Environment

|Variable           |Description|
|---------------|-----------|
|AFP_USER       | create a user in the container and allow it access to /media/share    |
|AFP_PASSWORD   | password
|AFP_UID        | _uid_ of the created user
|AFP_GID        | _gid_ of the created user

