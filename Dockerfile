FROM debian:jessie
ENV NETATALK_MAJOR 3.1
ENV NETATALK_VERSION 3.1.8
ENV DEPS build-essential \
libevent-dev \
libssl-dev \
libgcrypt11-dev \
libkrb5-dev \
libpam0g-dev \
libwrap0-dev \
libdb-dev \
libtdb-dev \
libmysqlclient-dev \
libavahi-client-dev \
libacl1-dev \
libldap2-dev \
libcrack2-dev \
systemtap-sdt-dev \
libdbus-1-dev \
libdbus-glib-1-dev \
libglib2.0-dev \
libtracker-sparql-1.0-dev \
libtracker-miner-1.0-dev \
file
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install \
        --no-install-recommends \
        --fix-missing \
        -y \
        $DEPS \
        tracker \
        avahi-daemon \
        curl \
        && \
    curl -O -SL "http://ufpr.dl.sourceforge.net/project/netatalk/netatalk/${NETATALK_VERSION}/netatalk-${NETATALK_VERSION}.tar.bz2" \
    && tar xjf netatalk-${NETATALK_VERSION}.tar.bz2 && \
    cd netatalk-${NETATALK_VERSION} && \
    ./configure \
        --prefix=/usr \
        --sysconfdir=/etc \
        --with-init-style=debian-systemd \
        --without-libevent \
        --without-tdb \
        --with-cracklib \
        --enable-krbV-uam \
        --with-pam-confdir=/etc/pam.d \
        --with-dbus-sysconf-dir=/etc/dbus-1/system.d \
        --with-tracker-pkgconfig-version=1.0 && \
    make -j8 && make install && \
	apt-get --quiet --yes purge --auto-remove \
        $DEPS \
        tracker-gui \
        libgl1-mesa-dri \
        && \
    DEBIAN_FRONTEND=noninteractive apt-get install --yes \
        libevent-2.0 \
        libavahi-client3 \
        libevent-core-2.0 \
        libwrap0 \
        libtdb1 \
        libmysqlclient18 \
        libcrack2 \
        libdbus-glib-1-2 \
    && \
    apt-get --quiet --yes autoclean && \
    apt-get --quiet --yes autoremove && \
    apt-get --quiet --yes clean && \
    rm -rf /netatalk* && \
    rm -rf /usr/share/man && \
    rm -rf /usr/share/doc && \
    rm -rf /usr/share/locale && \
    rm -rf /usr/share/icons && \
    rm -rf /usr/share/poppler && \
    rm -rf /usr/share/mime && \
    rm -rf /usr/share/GeoIP && \
    rm -rf /var/lib/apt/lists*
COPY start.sh /
COPY afp.conf /etc/afp.conf
CMD /start.sh
