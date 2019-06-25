#!/usr/bin/env bash

set -e

# Useful on a container restart
rm -f /var/run/dbus/pid

dbus-uuidgen --ensure
dbus-daemon --system
avahi-daemon --daemonize --no-chroot

if [ ! -e ".first-run" ]; then

  addgroup afp-share

  [ -d /media/home ]        || mkdir /media/home
  [ -d /media/share ]       || mkdir /media/share
  [ -d /media/timemachine ] || mkdir /media/timemachine

  USERS=($USERS)
  PASSWORDS=($PASSWORDS)
  UIDS=($UIDS)
  GIDS=($GIDS)

  chown "${USERS[0]}:afp-share" /media/share
  chmod g+swrx /media/share
  chown "${USERS[0]}:afp-share" /media/timemachine
  chmod g+swrx /media/timemachine

  createUser(){
    local login="$1"
    local password="$2"
    local uid="$3"
    local gid="$4"
    if [ "$uid" ]; then
      cmd="--uid $uid"
    fi
    if [ "$gid" ]; then
      cmd="$cmd --gid $gid"
      groupadd --gid "$gid" "$login"
    fi
    groupadd afp-share

    adduser $cmd --home "/media/home/$login" --disabled-password --gecos '' "$login"

    if [ "$password" ]; then
      echo "$login:$password" | chpasswd
    fi
  }

  for ((index=0; index<${#USERS[@]}; index++)); do
    createUser "${USERS[$index]}" "${PASSWORDS[$index]}" "${UIDS[$index]}" "${GIDS[$index]}"
  done

  sed -i'' -e "s,%NAME%,${NAME},g" /etc/afp.conf
  sed -i'' -e "s,%USER%,${USERS[@]},g" /etc/afp.conf

  touch .first-run
fi

# XXX set the hostname for avahi?:     sed -i "s/.*host-name.*/host-name=${DS_HOSTNAME}/" /etc/avahi/avahi-daemon.conf

# Debug
echo ---begin-afp.conf--
cat /etc/afp.conf
echo ---end---afp.conf--

exec netatalk -d -F /etc/afp.conf "$@"
