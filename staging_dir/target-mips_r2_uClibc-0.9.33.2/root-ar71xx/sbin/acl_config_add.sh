#this script is used for add /etc/config/acl section for the new host, 
#when CPE send DHCP ACK, it will run this script.
#!/bin/sh
 
. /lib/functions.sh

config_load acl

local hostname
local default_internet
local default_storage
local find_hostname

hostname=$1

loop_exist_hostname(){ 
	local name
	config_get name $1 name
	#storage the exist host name to /tmp/exist_hostname for looking whether the new incomer exist or not
	if [ "$hostname" = "$name" ];then
		logger "$hostname has been  added in /etc/config/acl."
		find_hostname="exist"
	fi
} 

#get all the device name from the /etc/config/acl
config_foreach loop_exist_hostname device

#the default rule should be storaged at the first section
default_internet=$(uci get acl.@device[0].internet)
default_storage=$(uci get acl.@device[0].storage)

#if hostname has been find in acl config, so there is no need to write it in acl config
if [ "$find_hostname" != "exist" ];then
	logger "$1 does not exist, so add /etc/config/acl device section for it"
	uci add acl device
	uci set acl.@device[-1].name=$1
	uci set acl.@device[-1].internet=$default_internet
	uci set acl.@device[-1].storage=$default_storage
	uci commit acl
fi

if [ $default_internet -eq 0 ] || [ $default_storage -eq 0 ];then
	#add firewall rule for the hostname, if firewall rule has been added before, it won't be added again, $2 is the ip address of the hostname
	logger "call /etc/firewall_rule_add.sh to add iptables rule"
	/sbin/firewall_rule_add.sh $2 $1
fi
