FROM debian:stretch-slim
ENV DEPS="libwrap0 libcrack2 libavahi-client3 libevent-2.0-5 netbase python perl"
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
 && apt-get install \
        --no-install-recommends \
        --fix-missing \
        --assume-yes \
        $DEPS \
        avahi-daemon \
        curl \
        ca-certificates \
        && NETATALK_VERSION="$(curl -Ls https://api.github.com/repos/dgilman/netatalk-debian/releases/latest | grep 'tag_name' | cut -d\" -f4)" \
        && curl -Ls -o libatalk18_${NETATALK_VERSION}_amd64.deb "https://github.com/dgilman/netatalk-debian/releases/download/${NETATALK_VERSION}/stretch_libatalk18_${NETATALK_VERSION}_amd64.deb" \
        && curl -Ls -o netatalk_${NETATALK_VERSION}_amd64.deb "https://github.com/dgilman/netatalk-debian/releases/download/${NETATALK_VERSION}/stretch_netatalk_${NETATALK_VERSION}_amd64.deb" \
        && dpkg -i *.deb \
        && rm *.deb \
        &&  apt-get --quiet --yes autoclean \
         &&  apt-get --quiet --yes autoremove \
          &&  apt-get --quiet --yes clean \
           &&  rm -rf /netatalk* \
            &&  rm -rf /usr/share/man \
             &&  rm -rf /usr/share/doc \
              &&  rm -rf /usr/share/icons \
               &&  rm -rf /usr/share/poppler \
                &&  rm -rf /usr/share/mime \
                 &&  rm -rf /usr/share/GeoIP \
                  &&  rm -rf /var/lib/apt/lists* \
                   &&  rm -rf /var/log/* \
                    &&  mkdir /media/share

COPY docker-entrypoint.sh /docker-entrypoint.sh
COPY afp.conf /etc/afp.conf
ENV DEBIAN_FRONTEND=newt

CMD ["/docker-entrypoint.sh"]
