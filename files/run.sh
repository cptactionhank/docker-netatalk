#!/bin/bash

setup(){
    if [[ -n "${AFP_USER}" ]]; then
        adduser -u ${AFP_UID} -g ${AFP_GID} -H -D "${AFP_USER}"
        if [[ -n "${AFP_PASSWORD}" ]]; then
            echo "${AFP_USER}:${AFP_PASSWORD}" | chpasswd
        fi
    fi


    if [[ ! -d /media/share ]]; then
        mkdir /media/share
    fi
    chown "${AFP_USER}" /media/share

    if [[ ! -d /media/timemachine ]]; then
        mkdir /media/timemachine
    fi
    chown "${AFP_USER}" /media/timemachine

    sed -i'' -e "s,%USER%,${AFP_USER:-},g" /etc/afp.conf

    mkdir -p /var/run/dbus
    rm -f /var/run/dbus.pid
    dbus-daemon --system
    if [[ "${AVAHI}" == "1" ]]; then
        sed -i '/rlimit-nproc/d' /etc/avahi/avahi-daemon.conf
        avahi-daemon -D
    else
        echo "Skipping avahi daemon. Set AVAHI=1 to enable."
    fi
}

main(){
    setup
    exec netatalk -d
}

main
exit $?