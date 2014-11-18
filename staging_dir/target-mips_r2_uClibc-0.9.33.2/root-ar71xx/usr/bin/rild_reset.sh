#!/bin/sh

echo "1" > /proc/gpio36/4g_pwr
touch /tmp/rild_reset_flag
sleep 2
/etc/init.d/rild restart
