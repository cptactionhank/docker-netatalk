ARG           BUILDER_BASE=dubodubonduponey/base:builder
ARG           RUNTIME_BASE=dubodubonduponey/base:runtime

#######################
# Extra builder for healthchecker
#######################
# hadolint ignore=DL3006
FROM          --platform=$BUILDPLATFORM $BUILDER_BASE                                                                   AS builder-healthcheck

ARG           GIT_REPO=github.com/dubo-dubon-duponey/healthcheckers
ARG           GIT_VERSION=51ebf8ca3d255e0c846307bf72740f731e6210c3

WORKDIR       $GOPATH/src/$GIT_REPO
RUN           git clone git://$GIT_REPO .
RUN           git checkout $GIT_VERSION
# hadolint ignore=DL4006
RUN           env GOOS=linux GOARCH="$(printf "%s" "$TARGETPLATFORM" | sed -E 's/^[^/]+\/([^/]+).*/\1/')" go build -v -ldflags "-s -w" \
                -o /dist/boot/bin/http-health ./cmd/http

#######################
# Running image
#######################
# hadolint ignore=DL3006
FROM          $RUNTIME_BASE

# hadolint ignore=DL3002
USER          root

# Install dependencies and tools
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

# HEALTHCHECK --interval=30s --timeout=30s --start-period=10s --retries=1 CMD http-health || exit 1
