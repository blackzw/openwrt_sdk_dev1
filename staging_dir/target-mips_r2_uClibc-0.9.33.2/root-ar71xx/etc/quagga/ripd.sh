#!/bin/sh

. /lib/functions.sh

config_load quagga
local version
config_get version ripd version "1 2"

cat > "./ripd.conf" << EOF
!
! Zebra configuration saved from vty
!   2014/03/06 12:52:12
!
hostname H850-RIP
password zebra
!
interface usb0
router rip
network usb0
interface usb0
 ip rip send version $version
 ip rip receive version $version
!
interface br-lan
router rip
network br-lan
interface br-lan
 ip rip send version $version
 ip rip receive version $version
!
access-list vty permit 127.0.0.0/8
access-list vty deny any
!
line vty
access-class vty
!