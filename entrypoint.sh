#!/usr/bin/env bash

set -e

# Useful on a container restart
rm -f /var/run/dbus/pid
rm -f /run/avahi-daemon/pid

dbus-uuidgen --ensure
dbus-daemon --system
avahi-daemon --daemonize --no-chroot

if [ ! -e ".first-run" ]; then

  groupadd afp-share

  [ -d /media/home ]        || mkdir /media/home
  [ -d /media/share ]       || mkdir /media/share
  [ -d /media/timemachine ] || mkdir /media/timemachine

  USERS=($USERS)
  PASSWORDS=($PASSWORDS)

  createUser(){
    local login="$1"
    local password="$2"
    adduser $cmd --home "/media/home/$login" --disabled-password --ingroup afp-share --gecos '' "$login"

    if [ "$password" ]; then
      echo "$login:$password" | chpasswd
    fi
  }

  for ((index=0; index<${#USERS[@]}; index++)); do
    createUser "${USERS[$index]}" "${PASSWORDS[$index]}"
  done

  chown "${USERS[0]}:afp-share" /media/share
  chmod g+swrx /media/share
  chown "${USERS[0]}:afp-share" /media/timemachine
  chmod g+swrx /media/timemachine

  pack="${USERS[@]}"
  sed -i'' -e "s,%NAME%,$NAME,g" /etc/afp.conf
  sed -i'' -e "s,%USER%,$pack,g" /etc/afp.conf

  touch .first-run
  echo "Successfully configured on first run"
fi

# XXX set the hostname for avahi?:     sed -i "s/.*host-name.*/host-name=${DS_HOSTNAME}/" /etc/avahi/avahi-daemon.conf

# Debug
echo ---begin-afp.conf--
cat /etc/afp.conf
echo ---end---afp.conf--

exec netatalk -d -F /etc/afp.conf "$@"
