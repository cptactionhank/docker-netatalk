# Netatalk in a Docker container

An environment running AFP filesharing, Tracker (search/spotlight integration), and mDNS server for service discovery.

## I'm in the fast lane! Get me started

To quickly get started with running an Confluence instance, first run the following command:
```bash
docker run --detach --publish 548:548 cptactionhank/netatalk:latest
```

Important: This does not announce the AFP service on the network; connecting to the server should be by Finder's Go -> Connect Server (CMD+K) and then typing `afp://servername`

Default configuration of Netatalk has one share called _share_ and shares to containers `/share` directory. So host mounting a volume to this path will be the quickest way to start sharing files from your host.

```bash
docker run --detach --volume hostpath:/share --publish 548:548 cptactionhank/netatalk:latest
```

## The slower road

With the slower roads documentation some knowledge in administering Docker is implicitly assumed.

### Configuring shares

There are two ways of configuring the Netatalk which is either by mounting a configuration file or editing the file from the container itself. Documentation of the configuration file `/etc/afp.conf` can be found [here](http://netatalk.sourceforge.net/3.1/htmldocs/afp.conf.5.html).

#### Host mounted configuration

This is quite a simple way to change the configuration by supplying an additional docker flag when creating the container.

```bash
... --volume hostpath:/etc/afp.conf cptactionhank/netatalk
```
#### Container edited configuration

You can also edit the file from inside the container using your favorite tool, like sed, echo, etc.

Just start an interactive session with the running container by executing the following command and start doing your work:

```bash
docker exec -ti containername bash
```

If you would like to use an editor like nano, emacs, or vi you have to install it first using `apt-get install`.

### Setting up access credentials

If you supply environment variables to `docker run`

- AFP_USER        create a user in the container and allow it access to /share
- AFP_PASSWORD    password
- AFP_UID         uid of the created user
- AFP_GID         gid of the created user

Example:

```bash
docker run -d \
-v /mnt/sda1/share:/share \
--name=afp \
--net=host \
-e AFP_USER=$(id -un) \
-e AFP_PASSWORD=secret \
-e AFP_UID=$(id -u) \
-e AFP_GID=$(id -g) \
cptactionhank/netatalk
```

This replaces all occurences of %USER% in afp.conf with AFP_USER

```ini
[Global]
log file = /var/log/netatalk.log

[share]
path = /share
valid users = %USER%
```

### Service discovery

Service discovery works only when the Avahi daemon is on the same network as your users which is why you need to supply `--net=host` flag to Docker when creating the container, but do consider that `--net=host` is considered a security threat. Alternatively you can install and setup an mDNS server on the host and have this describing the AFP service for your container.

## Contributions

This has been made with the best intentions and current knowledge so it shouldn't be expected to be flawless. However you can support this too with best practices and other additions. 

Out of date documentation, version, lack of tests, etc. why not help out by either creating an issue to open a discussion or by sending a pull request with modifications.

