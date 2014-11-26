#!/bin/bash

LOGFILE=/var/lib/dibbler/client.sh-log

# uncomment this to get full list of available variables
#set >> $LOGFILE

echo "-----------" >> $LOGFILE

if [ "$OPTION_NEXT_HOP" != "" ]; then

    ip -6 route del default > /dev/null 2>&1
    ip -6 route add default via ${OPTION_NEXT_HOP} dev $IFACE
    echo "Added default route via ${OPTION_NEXT_HOP} on interface $IFACE/$IFINDEX" >> $LOGFILE

fi

if [ "$OPTION_NEXT_HOP_RTPREFIX" != "" ]; then

    NEXT_HOP=`echo ${OPTION_NEXT_HOP_RTPREFIX} | awk '{print $1}'`
    NETWORK=`echo ${OPTION_NEXT_HOP_RTPREFIX} | awk '{print $2}'`
    #LIFETIME=`echo ${OPTION_NEXT_HOP_RTPREFIX} | awk '{print $3}'`
    METRIC=`echo ${OPTION_NEXT_HOP_RTPREFIX} | awk '{print $4}'`

    if [ "$NETWORK" == "::/0" ]; then

        ip -6 route del default > /dev/null 2>&1
        ip -6 route add default via ${OPTION_NEXT_HOP} dev $IFACE
        echo "Added default route via  ${OPTION_NEXT_HOP} on interface $IFACE/$IFINDEX" >> $LOGFILE

    else

        ip -6 route add ${NETWORK} nexthop via ${NEXT_HOP} dev $IFACE weight ${METRIC}
        echo "Added nexthop to network ${NETWORK} via ${NEXT_HOP} on interface $IFACE/$IFINDEX, metric ${METRIC}" >> $LOGFILE

    fi

fi

if [ "$OPTION_RTPREFIX" != "" ]; then

    ONLINK=`echo ${OPTION_RTPREFIX} | awk '{print $1}'`
    METRIC=`echo ${OPTION_RTPREFIX} | awk '{print $3}'`
    ip -6 route add ${ONLINK} dev $IFACE onlink metric ${METRIC}
    echo "Added route to network ${ONLINK} on interface $IFACE/$IFINDEX onlink, metric ${METRIC}" >> $LOGFILE

fi


if [ "$ADDR1" != "" ]; then
    echo "Address ${ADDR1} (operation $1) to client $REMOTE_ADDR on inteface $IFACE/$IFINDEX" >> $LOGFILE
fi

if [ "$PREFIX1" != "" ]; then
    echo "Prefix ${PREFIX1} (operation $1) to client $REMOTE_ADDR on inteface $IFACE/$IFINDEX" >> $LOGFILE
    addr1=${PREFIX1}1
    addr2=${PREFIX1}fffe
    pool1="pool $addr1-$addr2"
    sed -i "s/.*pool.*/${pool1}/g" /etc/dibbler/server.conf
    ifconfig br-lan down
    ifconfig br-lan up
    wait
    LINKADDR=$(ifconfig br-lan | awk '/inet6/ {print $3}')
    ip -6 addr del ${LINKADDR} dev br-lan
    ip -6 addr add fe80::1/64 dev br-lan
    ip -6 route add ${PREFIX1}/64 dev br-lan
    killall -9 dibbler-server
    wait
    dibbler-server  start

fi

# sample return code. Dibbler will just print it out.
exit 3
