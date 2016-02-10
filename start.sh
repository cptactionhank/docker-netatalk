#!/bin/bash
if [ ! -z "${AFP_USER}" ]; then
    if [ ! -z "${AFP_UID}" ]; then
        cmd="$cmd --uid ${AFP_UID}"
    fi
    if [ ! -z "${AFP_GID}" ]; then
        cmd="$cmd --gid ${AFP_GID}"
    fi
    adduser $cmd --no-create-home --disabled-password --gecos '' "${AFP_USER}"
    if [ ! -z "${AFP_PASSWORD}" ]; then
        echo "${AFP_USER}:${AFP_PASSWORD}" | chpasswd
    fi
fi
[ ! -d /share ] && mkdir /share && chown ${AFP_USER} /share && echo "use -v /my/dir/to/share:/share" > readme.txt
sed -i'' -e "s,%USER%,${AFP_USER},g" /etc/afp.conf
echo ---begin-afp.conf--
cat /etc/afp.conf
echo ---end---afp.conf--
mkdir /var/run/dbus
dbus-daemon --system
avahi-daemon -D
netatalk
while true; do
LOG=/var/log/netatalk.log
[ -f ${LOG} ] && tail -f ${LOG}
sleep 1;
done
