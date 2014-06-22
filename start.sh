#!/bin/sh

set -eu

netatalk -F /etc/netatalk/afp.conf
sleep 2
exec tail -f /var/log/netatalk.log
