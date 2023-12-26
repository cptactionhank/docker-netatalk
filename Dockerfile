FROM ubuntu:22.04 as builder
ENV NETATALK_VERSION 3.1.18

WORKDIR /

# Prerequisites
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
      bash \
      curl \
      libldap-2.5-0 \
      libgcrypt20 \
      python3 \
      dbus \
      dbus-x11 \
      python3-dbus \
      libpam0g \
      libcrack2 \
      libdb5.3 \
      libevent-2.1-7 \
      file \
      acl \
      avahi-daemon \
      libtdb1 \
      supervisor && \
    apt-get install -y --no-install-recommends \
      build-essential \
      autoconf \
      automake \
      libtool \
      libgcrypt20-dev \
      libpam0g-dev \
      libkrb5-dev \
      libtdb-dev \
      libcrack2-dev \
      libacl1-dev \
      libdb-dev \
      libdbus-1-dev \
      libevent-dev && \
    cd /tmp

# removed libssl1.1 

RUN    curl -o netatalk-${NETATALK_VERSION}.tar.bz2 -L https://github.com/Netatalk/netatalk/releases/download/netatalk-$(echo $NETATALK_VERSION | tr '.' '-')/netatalk-${NETATALK_VERSION}.tar.bz2 && \
    tar xvf netatalk-${NETATALK_VERSION}.tar.bz2 && \
    cd netatalk-${NETATALK_VERSION} && \
    CFLAGS="-Wno-unused-result -O2" ./configure \
      --prefix=/usr \
      --sysconfdir=/etc \
      --with-init-style=debian-sysv \
      --without-libevent \
      --without-tdb \
      --with-cracklib \
      --enable-krbV-uam \
      --with-pam-confdir=/etc/pam.d \
      --disable-shell-check \
      --with-dbus-sysconf-dir=/etc/dbus-1/system.d \
      --with-tracker-pkgconfig-version=1.0 && \
      make && \
      make install && \
      cd /tmp && \
      rm -rf netatalk-${NETATALK_VERSION} netatalk-${NETATALK_VERSION}.tar.bz2 && \
      apt-get autoremove -y && \
      apt-get clean && \
      rm -rf /var/lib/apt/lists/*

COPY files/run.sh /run.sh
COPY files/afp.conf /etc/afp.conf

EXPOSE 548

#---------------- flatten image -----------------#
FROM scratch
copy --from=builder / /

#========= expose =========#
EXPOSE 548
#========= entrypoint =========#
CMD ["/run.sh"]
