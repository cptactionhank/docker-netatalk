FROM debian:wheezy
MAINTAINER cptactionhank <cptactionhank@users.noreply.github.com>

ENV NETATALK_MAJOR 3.1
ENV NETATALK_VERSION 3.1.7

COPY ./root /

RUN set -x \
	&& DEBIAN_FRONTEND="noninteractive" \
	&& RUNTMDEPS="libpam-ldap libnss-ldap supervisor python-dbus dbus-x11 avahi-daemon tracker tracker-extract tracker-miner-fs tracker-utils libevent-2.0-5 libssl1.0.0 libgssapi-krb5-2 libk5crypto3 libkrb5-3 libwrap0 libdb5.1 libtdb1 libmysqlclient18 libavahi-client3 libcrack2 cracklib-runtime python libdbus-1-3 libdbus-glib-1-2 libglib2.0-0 libtracker-sparql-0.14-0" \
	&& BUILDDEPS="curl bzip2 gcc cpp make patch libevent-dev libssl-dev libgcrypt11-dev libkrb5-dev libpam0g-dev libwrap0-dev libdb-dev libtdb-dev libmysqlclient-dev libavahi-client-dev libacl1-dev libldap2-dev libcrack2-dev systemtap-sdt-dev libdbus-1-dev libdbus-glib-1-dev libglib2.0-dev libtracker-sparql-0.14-dev libtracker-miner-0.14-dev" \
	&& apt-get --quiet --yes update \
	&& apt-get --quiet --yes install --no-install-recommends ${RUNTMDEPS} ${BUILDDEPS} \
	&& rm -rf "/var/lib/apt/lists/*" \
	&& pam-auth-update --package ldap \
	&& mkdir -p "/usr/src/netatalk/netatalk-${NETATALK_VERSION}" \
	&& cd "/usr/src/netatalk/netatalk-${NETATALK_VERSION}" \
	&& curl -SL "http://ufpr.dl.sourceforge.net/project/netatalk/netatalk/${NETATALK_VERSION}/netatalk-${NETATALK_VERSION}.tar.bz2" \
		| tar xj --directory "/usr/src/netatalk/netatalk-${NETATALK_VERSION}" --strip-components=1 \
	&& ./configure \
		--with-pam-confdir="/etc/pam.d" \
		--with-pkgconfdir="/etc/netatalk" \
		--with-tracker-pkgconfig-version="0.14" \
		--with-cracklib \
		--with-acls \
		--with-init-style="debian-sysv" \
		--without-libevent \
		--without-tdb \
		--enable-krbV-uam \
		--enable-fhs \
	&& find "/usr/src/netatalk/patches" -name "*.patch" -exec patch -p0 -i {} \; \
	&& make pkgconfdir="/etc/netatalk" check \
	&& make install \
	&& make clean \
	&& apt-get --quiet --yes purge --auto-remove $BUILDDEPS \
	&& apt-get --quiet --yes autoclean \
	&& apt-get --quiet --yes autoremove \
	&& apt-get --quiet --yes clean

EXPOSE 548 636 5353/udp

VOLUME ["/var/netatalk", "/etc/netatalk"]

CMD ["/usr/bin/supervisord", "--nodaemon"]
