#######################
# Usual avahi/dbus image
#######################
FROM debian:buster-slim
MAINTAINER dubo-dubon-duponey@jsboot.space

WORKDIR /dubo-dubon-duponey
RUN apt-get update \
  && apt-get install -y --no-install-recommends dbus avahi-daemon \
  && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*
RUN mkdir -p /var/run/dbus
COPY avahi-daemon.conf /etc/avahi/avahi-daemon.conf

#######################
# Netatalk section
#######################
RUN apt-get update \
  && apt-get install -y --no-install-recommends netatalk \
  && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

COPY afp.conf /etc/afp.conf
# XXX per-user connections require this?
RUN chmod a+r /etc/afp.conf

ENV USERS=""
ENV PASSWORDS=""
EXPOSE 548
VOLUME "/media/home"
VOLUME "/media/share"
VOLUME "/media/timemachine"

#######################
# Entrypoint
#######################
COPY entrypoint.sh .
ENTRYPOINT ["./entrypoint.sh"]
