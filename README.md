# Netatalk in a Docker container

[![Docker Build Status](http://hubstatus.container42.com/cptactionhank/netatalk)](https://registry.hub.docker.com/u/cptactionhank/netatalk) 

An environment running AFP filesharing, Tracker (search/spotlight integration), and mDNS server for service discovery.

## I'm in the fast lane! Get me started

To quickly get started with running an Confluence instance, first run the following command:
```bash
docker run --detach --publish 548:548 cptactionhank/netatalk:latest
```

Important: This does not announce the AFP service on the network; connecting to the server should be by Finder's Go -> Connect Server (CMD+K) and then typing `afp://servername`

Default configuration of Netatalk has one share called _My AFP Share_ and shares to containers `/media` directory. So host mounting a volume to this path will be the quickest way to start sharing files from your host.

```bash
docker run --detach --volume hostpath:/media --publish 548:548 cptactionhank/netatalk:latest
```

## The slower road

With the slower roads documentation some knowledge in administering Docker is implicitly assumed.

### Configuring shares

There are two ways of configuring the Netatalk which is either by mounting a configuration file or editing the file from the container itself. Documentation of the configuration file `/etc/netatalk/afp.conf` can be found [here](http://netatalk.sourceforge.net/3.1/htmldocs/afp.conf.5.html).

#### Host mounted configuration

This is quite a simple way to change the configuration by supplying an additional docker flag when creating the container.

```bash
... --volume hostpath:/etc/netatalk/afp.conf cptactionhank/netatalk
```
#### Container edited configuration

You can also edit the file from inside the container using your favorite tool, like sed, echo, etc.

Just start an interactive session with the running container by executing the following command and start doing your work:

```bash
docker exec -ti containername bash
```

If you would like to use an editor like nano, emacs, or vi you have to install it first using `apt-get install`.

### Setting up access credentials

The container comes installed with `libnss-ldap` and `libpam-ldap` if you want to use LDAP for authentication, however this is out of scope of this README. So instead we can do the simple thing of creating new Debian users to the container.

```bash
docker exec -ti containername adduser --no-create-home timemachine
```

And then the shares could be configured with a share like

```ini
[Secured Share]
path = /media/secure
valid users = timemachine
```

### Service discovery

Service discovery works only when the Avahi daemon is on the same network as your users which is why you need to supply `--net=host` flag to Docker when creating the container, but do consider that `--net=host` is considered a security threat. Alternatively you can install and setup an mDNS server on the host and have this describing the AFP service for your container.

## Contributions

This has been made with the best intentions and current knowledge so it shouldn't be expected to be flawless. However you can support this too with best practices and other additions. 

Out of date documentation, version, lack of tests, etc. why not help out by either creating an issue to open a discussion or by sending a pull request with modifications.

