# FROM debian:stretch-slim AS pack
FROM debian:buster

RUN apt-get update -y && apt-get install -y netatalk
COPY docker-entrypoint.sh /docker-entrypoint.sh
COPY afp.conf /etc/afp.conf
RUN chmod a+r /etc/afp.conf

ENTRYPOINT ["/docker-entrypoint.sh"]
