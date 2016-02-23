FROM debian:jessie
ENV NETATALK_VERSION 3.1.8

ENV DEPS="build-essential libevent-dev libssl-dev libgcrypt11-dev libkrb5-dev libpam0g-dev libwrap0-dev libdb-dev libtdb-dev libmysqlclient-dev libavahi-client-dev libacl1-dev libldap2-dev libcrack2-dev systemtap-sdt-dev libdbus-1-dev libdbus-glib-1-dev libglib2.0-dev libtracker-sparql-1.0-dev libtracker-miner-1.0-dev file"
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update
RUN apt-get install \
        --no-install-recommends \
        --fix-missing \
        --assume-yes \
        $DEPS \
        tracker \
        avahi-daemon \
        curl wget
RUN wget      "http://ufpr.dl.sourceforge.net/project/netatalk/netatalk/3.1.8/netatalk-3.1.8.tar.gz"
RUN curl -SL  "http://ufpr.dl.sourceforge.net/project/netatalk/netatalk/3.1.8/netatalk-3.1.8.tar.gz" | tar xvz
WORKDIR netatalk-3.1.8
RUN ./configure \
        --prefix=/usr \
        --sysconfdir=/etc \
        --with-init-style=debian-systemd \
        --without-libevent \
        --without-tdb \
        --with-cracklib \
        --enable-krbV-uam \
        --with-pam-confdir=/etc/pam.d \
        --with-dbus-sysconf-dir=/etc/dbus-1/system.d \
        --with-tracker-pkgconfig-version=1.0
RUN make
RUN make install
RUN apt-get --quiet --yes purge --auto-remove \
        $DEPS \
        tracker-gui \
        libgl1-mesa-dri
RUN DEBIAN_FRONTEND=noninteractive apt-get install --yes \
        libevent-2.0 \
        libavahi-client3 \
        libevent-core-2.0 \
        libwrap0 \
        libtdb1 \
        libmysqlclient18 \
        libcrack2 \
        libdbus-glib-1-2
RUN apt-get --quiet --yes autoclean
RUN apt-get --quiet --yes autoremove
RUN apt-get --quiet --yes clean
RUN rm -rf /netatalk*
RUN rm -rf /usr/share/man
RUN rm -rf /usr/share/doc
RUN rm -rf /usr/share/icons
RUN rm -rf /usr/share/poppler
RUN rm -rf /usr/share/mime
RUN rm -rf /usr/share/GeoIP
RUN rm -rf /var/lib/apt/lists*
RUN mkdir /media/share

COPY docker-entrypoint.sh /docker-entrypoint.sh
COPY afp.conf /etc/afp.conf

CMD ["/docker-entrypoint.sh"]
