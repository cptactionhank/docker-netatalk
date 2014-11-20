FROM ubuntu:trusty
MAINTAINER cptactionhank <cptactionhank@users.noreply.github.com>

ENV VERSION 3.1.6

WORKDIR /usr/src/netatalk/netatalk-${VERSION}

RUN apt-get update -qqy \
    && apt-get install --no-install-recommends -qqy \
			 libacl1-dev \
			 libavahi-client-dev \
			 libcrack2-dev \
			 libdb5.1-dev \
			 libdbus-1-dev \
			 libdbus-glib-1-dev \
			 libgcrypt11-dev \
			 libglib2.0-dev \
			 libkrb5-dev \
			 libldap2-dev \
			 libmysqlclient-dev \
			 libpam0g-dev \
			 libssl-dev \
			 libtdb-dev \
			 libtracker-miner-0.16-dev \
			 libtracker-sparql-0.16-dev \
			 libwrap0-dev \
			 systemtap-sdt-dev \
			 tracker \
    	 curl \
       build-essential \ 
       libevent-dev \
		&& apt-get clean

RUN curl -SsL http://sourceforge.net/projects/netatalk/files/netatalk/${VERSION}/netatalk-${VERSION}.tar.gz/download | tar xz --strip-components=1

RUN ./configure \
        --with-pam-confdir=/etc/pam.d \
        --with-pkgconfdir=/etc/netatalk \
        --with-tracker-pkgconfig-version=0.16 \
        --with-cracklib \
        --with-acls \
        --with-init-style=debian-sysv \
        --without-libevent \
        --without-tdb \
        --enable-krbV-uam \
        --enable-fhs 

COPY patches /usr/src/netatalk/patches
RUN set -x; for file in $(find /usr/src/netatalk/patches -name "*.patch"); do patch -p0 -i "$file"; done;

CMD ["make", "DESTDIR=/media", "PKGCONFDIR=/etc/netatalk", "pkgconfdir=/etc/netatalk", "install"]
