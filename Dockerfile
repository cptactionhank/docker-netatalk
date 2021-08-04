ARG           FROM_REGISTRY=ghcr.io/dubo-dubon-duponey

ARG           FROM_IMAGE_RUNTIME=base:runtime-bullseye-2021-08-01@sha256:edc80b2c8fd94647f793cbcb7125c87e8db2424f16b9fd0b8e173af850932b48

#######################
# Running image
#######################
FROM          $FROM_REGISTRY/$FROM_IMAGE_RUNTIME

# hadolint ignore=DL3002
USER          root

# Install dependencies and tools
RUN           --mount=type=secret,uid=100,id=CA \
              --mount=type=secret,uid=100,id=CERTIFICATE \
              --mount=type=secret,uid=100,id=KEY \
              --mount=type=secret,uid=100,id=GPG.gpg \
              --mount=type=secret,id=NETRC \
              --mount=type=secret,id=APT_SOURCES \
              --mount=type=secret,id=APT_CONFIG \
              apt-get update -qq && \
              apt-get install -qq --no-install-recommends \
                dbus=1.12.20-2 \
                avahi-daemon=0.8-5 \
                netatalk=3.1.12~ds-8 && \
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
              && chown "$BUILD_UID":afp-share /media/home \
              && chown "$BUILD_UID":afp-share /media/share \
              && chown "$BUILD_UID":afp-share /media/timemachine \
              && chmod g+srwx /media/home \
              && chmod g+srwx /media/share \
              && chmod g+srwx /media/timemachine

# XXX disable healthchecker for now
# COPY          --from=builder-healthcheck /dist/boot/bin           /dist/boot/bin
# RUN           chmod 555 /dist/boot/bin/*

VOLUME        /etc
VOLUME        /var/log
VOLUME        /data
VOLUME        /run
EXPOSE        548

ENV           NAME="Farcloser Netatalk"

ENV           USERS=""
ENV           PASSWORDS=""

ENV           NAME=TotaleCroquette

# ENV           HEALTHCHECK_URL=http://127.0.0.1:548

VOLUME        /media/home
VOLUME        /media/share
VOLUME        /media/timemachine
