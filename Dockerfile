#######################
# Extra builder for healthchecker
#######################
FROM          --platform=$BUILDPLATFORM dubodubonduponey/base:builder                                                   AS builder-healthcheck

ARG           HEALTH_VER=51ebf8ca3d255e0c846307bf72740f731e6210c3

WORKDIR       $GOPATH/src/github.com/dubo-dubon-duponey/healthcheckers
RUN           git clone git://github.com/dubo-dubon-duponey/healthcheckers .
RUN           git checkout $HEALTH_VER
RUN           arch="${TARGETPLATFORM#*/}"; \
              env GOOS=linux GOARCH="${arch%/*}" go build -v -ldflags "-s -w" -o /dist/bin/http-health ./cmd/http

RUN           chmod 555 /dist/bin/*

#######################
# Running image
#######################
FROM          dubodubonduponey/base:runtime

# hadolint ignore=DL3002
USER          root

# Install dependencies and tools
ARG           DEBIAN_FRONTEND="noninteractive"
ENV           TERM="xterm" LANG="C.UTF-8" LC_ALL="C.UTF-8"
RUN           apt-get update -qq && \
              apt-get install -qq --no-install-recommends \
                dbus=1.12.16-1 \
                avahi-daemon=0.7-4+b1 \
                netatalk=3.1.12~ds-3 && \
              apt-get -qq autoremove      && \
              apt-get -qq clean           && \
              rm -rf /var/lib/apt/lists/* && \
              rm -rf /tmp/*               && \
              rm -rf /var/tmp/*

RUN           dbus-uuidgen --ensure \
              && mkdir -p /run/dbus \
              && chown "$BUILD_UID":root /run/dbus \
              && chmod 775 /run/dbus \
              && groupadd afp-share \
              && mkdir -p /media/home \
              && mkdir -p /media/share \
              && mkdir -p /media/timemachine \
              && chown "$BUILD_UID":afp-share -p /media/home \
              && chown "$BUILD_UID":afp-share -p /media/share \
              && chown "$BUILD_UID":afp-share -p /media/timemachine \
              && chmod g+srwx /media/home \
              && chmod g+srwx /media/share \
              && chmod g+srwx /media/timemachine \

VOLUME        /data
VOLUME        /run
EXPOSE        548

ENV           NAME="Farcloser Netatalk"

ENV           USERS=""
ENV           PASSWORDS=""

VOLUME        /media/home
VOLUME        /media/share
VOLUME        /media/timemachine
