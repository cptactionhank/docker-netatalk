#!/bin/bash

[ -d /media/share ] || mkdir /media/share
[ -d /media/timemachine ] || mkdir /media/timemachine

if [ "${AFP_USER}" ]; then
  chown "${AFP_USER}" /media/share
  chown "${AFP_USER}" /media/timemachine

  if [ "${AFP_UID}" ]; then
    cmd="--uid ${AFP_UID}"
  fi
  if [ "${AFP_GID}" ]; then
    cmd="$cmd --gid ${AFP_GID}"
    groupadd --gid ${AFP_GID} ${AFP_USER}
  fi
  adduser $cmd --no-create-home --disabled-password --gecos '' "${AFP_USER}"
  if [ "${AFP_PASSWORD}" ]; then
    echo "${AFP_USER}:${AFP_PASSWORD}" | chpasswd
  fi
fi

sed -i'' -e "s,%USER%,${AFP_USER:-},g" /etc/afp.conf

echo ---begin-afp.conf--
cat /etc/afp.conf
echo ---end---afp.conf--

mkdir -p /var/run/dbus
rm -f /var/run/dbus/pid
dbus-daemon --system
if [ "${AVAHI}" == "1" ]; then
    sed -i '/rlimit-nproc/d' /etc/avahi/avahi-daemon.conf
    avahi-daemon -D
else
    echo "Skipping avahi daemon, enable with env variable AVAHI=1"
fi;

exec netatalk -d -F /etc/afp.conf

