#!/bin/sh

set -eu

netatalk -F /etc/netatalk/afp.conf
sleep 2
tail -f /var/log/netatalk.log
