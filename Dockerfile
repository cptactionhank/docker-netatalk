FROM cptactionhank/ubuntu:trusty
MAINTAINER cptactionhank <cptactionhank@users.noreply.github.com>

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys AC857259 \
    && echo "deb http://ppa.launchpad.net/ali-asad-lotia/netatalk-stable/ubuntu $(lsb_release -cs) main" \
       > /etc/apt/sources.list.d/launchpad-ali-asad-lotia-netatalk.list \
    && apt-get update -qq \
    && apt-get -yqq install netatalk

EXPOSE 548

VOLUME ["/etc/netatalk", "/var/lib/netatalk", "/var/log"]

ADD start.sh /start

ENTRYPOINT /start
