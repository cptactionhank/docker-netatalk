#!/bin/sh

set -eu

netatalk -F /etc/netatalk/afp.conf
sleep 1
tail -f /var/log/netatalk.log
