# Stretch netatalk version is too old
FROM debian:buster
MAINTAINER dubo-dubon-duponey@jsboot.space

RUN apt-get update \
  && apt-get install -y --no-install-recommends dbus avahi-daemon netatalk \
  && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

# For some reason, the debian package does not create this, but their init.d script does
RUN mkdir -p /var/run/dbus

WORKDIR /dubo-dubon-duponey

COPY entrypoint.sh .
COPY afp.conf /etc/afp.conf
COPY avahi-daemon.conf /etc/avahi/avahi-daemon.conf

RUN chmod a+r /etc/afp.conf

ENV USERS=""
ENV PASSWORDS=""
ENV UIDS=""
ENV GID=""
EXPOSE 548
#VOLUME "/etc/afp.conf"
#VOLUME "/etc/avahi/avahi-daemon.conf"
VOLUME "/media/home"
VOLUME "/media/share"
VOLUME "/media/timemachine"

ENTRYPOINT ["./entrypoint.sh"]
