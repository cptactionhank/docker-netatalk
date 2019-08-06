#######################
# Usual avahi/dbus image
#######################
FROM        debian:buster-slim

LABEL       dockerfile.copyright="Dubo Dubon Duponey <dubo-dubon-duponey@jsboot.space>"

# Install dependencies and tools
ARG         DEBIAN_FRONTEND="noninteractive"
ENV         TERM="xterm" LANG="C.UTF-8" LC_ALL="C.UTF-8"
RUN         apt-get update              > /dev/null && \
            apt-get dist-upgrade -y                 && \
            apt-get install -y --no-install-recommends dbus=1.12.16-1 avahi-daemon=0.7-4+b1 netatalk=3.1.12~ds-3 \
                                        > /dev/null && \
            apt-get -y autoremove       > /dev/null && \
            apt-get -y clean            && \
            rm -rf /var/lib/apt/lists/* && \
            rm -rf /tmp/*               && \
            rm -rf /var/tmp/*

WORKDIR     /dubo-dubon-duponey
RUN         mkdir -p /var/run/dbus
COPY        avahi-daemon.conf /etc/avahi/avahi-daemon.conf
COPY        entrypoint.sh .

COPY        afp.conf /etc/afp.conf
# XXX per-user connections require this?
RUN         chmod a+r /etc/afp.conf

ENV         USERS=""
ENV         PASSWORDS=""
EXPOSE      548
VOLUME      "/media/home"
VOLUME      "/media/share"
VOLUME      "/media/timemachine"

ENTRYPOINT ["./entrypoint.sh"]
