FROM alpine:latest as builder
ENV NETATALK_VERSION 3.1.11

WORKDIR /

# Prerequisites
RUN apk update && \
    apk upgrade && \
    apk add --no-cache \
      bash \
      curl \
      libldap \
      libgcrypt \
      python \
      dbus \
      dbus-glib \
      py-dbus \
      linux-pam \
      cracklib \
      db \
      libevent \
      file \
      acl \
      openssl \
      avahi \
      tdb-libs \
      supervisor && \
    apk add --no-cache --virtual .build-deps \
      build-base \
      autoconf \
      automake \
      libtool \
      libgcrypt-dev \
      linux-pam-dev \
      krb5-dev \
      tdb-dev \
      cracklib-dev \
      acl-dev \
      db-dev \
      dbus-dev \
      libevent-dev && \
    ln -s -f /bin/true /usr/bin/chfn && \
    cd /tmp

RUN    curl -o netatalk-${NETATALK_VERSION}.tar.gz -L https://downloads.sourceforge.net/project/netatalk/netatalk/${NETATALK_VERSION}/netatalk-${NETATALK_VERSION}.tar.gz && \
    tar xvf netatalk-${NETATALK_VERSION}.tar.gz && \
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
      --with-dbus-sysconf-dir=/etc/dbus-1/system.d \
      --with-tracker-pkgconfig-version=1.0 && \
      make && \
      make install && \
      cd /tmp && \
      rm -rf netatalk-${NETATALK_VERSION} netatalk-${NETATALK_VERSION}.tar.gz && \
      apk del .build-deps

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
