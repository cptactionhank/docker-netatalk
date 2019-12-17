#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

helpers::dbus(){
  # On container restart, cleanup the crap
  rm -f /run/dbus/pid

  # https://linux.die.net/man/1/dbus-daemon-1
  dbus-daemon --system

  until [ -e /run/dbus/system_bus_socket ]; do
    sleep 1s
  done
}

helpers::avahi(){
  # On container restart, cleanup the crap
  rm -f /run/avahi-daemon/pid

  # Set the hostname, if we have it
  sed -i'' -e "s,%AVAHI_NAME%,$AVAHI_NAME,g" /data/avahi-daemon.conf

  # https://linux.die.net/man/8/avahi-daemon
  avahi-daemon -f /data/avahi-daemon.conf --daemonize --no-chroot
}

########################################################################################################################
# Specific to this image
########################################################################################################################

# helper to create user accounts
helpers::createUser(){
  local login="$1"
  local password="$2"
  adduser --home "/media/home/$login" --disabled-password --ingroup afp-share --gecos '' "$login"

  if [ "$password" ]; then
    printf "%s:%s" "$login" "$password" | chpasswd
  fi
}

# On first run
if [ ! -e ".first-run" ]; then
  # shellcheck disable=SC2206
  USERS=($USERS)
  # shellcheck disable=SC2206
  PASSWORDS=($PASSWORDS)

  printf "Creating users\n"
  for ((index=0; index<${#USERS[@]}; index++)); do
    helpers::createUser "${USERS[$index]}" "${PASSWORDS[$index]}"
  done

  # Set config
  sed -i'' -e "s,%NAME%,$NAME,g" /data/afp.conf

  touch .first-run
  printf "Done with first run, all set\n"
fi

# Run with it
helpers::dbus
helpers::avahi

# XXX not likely to work?
exec chroot --userspec=dubo-dubon-duponey / netatalk -d -F /data/afp.conf "$@"
