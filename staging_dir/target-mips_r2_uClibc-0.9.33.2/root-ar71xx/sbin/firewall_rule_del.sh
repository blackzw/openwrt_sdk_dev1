#when the host leave this CPE domain, it will send DHCP RELEASE packet,
#then CPE DHCP will call this script to delete the iptalbes rules for the host
#!/bin/sh

. /lib/functions.sh

local hostname
local lan_ip
local listen_http
local port
local ipaddr

listen_http=$(uci get uhttpd.main.listen_http)
port=${listen_http#*:}

lan_ip=$(uci get network.lan.ipaddr)
hostname=$1
ipaddr=$2

config_load acl

local default_internet
local default_storage

loop_exist_hostname(){ 
	local name
	local internet
	local storage
	
	config_get name $1 name

	if [ "$name" = "default" ];then
		config_get default_internet $1 internet
		config_get default_storage $1 storage
	fi
	
	if [ "$name" = "$hostname" ];then
		config_get internet $1 internet
		config_get storage $1 storage		
		if [ $default_internet -ne $internet ];then
			if [ $internet -eq 0 ];then
				#delete the internet block rule
				logger "iptables -t filter -D ACLINTERNET -s $ipaddr -j DROP"
				iptables -t filter -D ACLINTERNET -s $ipaddr -j DROP
			fi
			if [ $internet -eq 1 ];then
				#block the internet packet from specific lan ip
				logger "iptables -t filter -D ACLINTERNET -s $ipaddr -j ACCEPT"
				iptables -t filter -D ACLINTERNET -s $ipaddr -j ACCEPT
				iptables -t filter -D ACLINTERNET -d $ipaddr -j ACCEPT
			fi				
		fi
		if [ $default_storage -ne $storage ];then
			if [ $storage -eq 0 ];then
				#delete the storage block rule"
				logger "iptables -t filter -D ACLSTORAGE -s $ipaddr -d $lan_ip -p tcp -m multiport ! --destination-port $port,23 -j DROP"
				iptables -t filter -D ACLSTORAGE -s $ipaddr -d $lan_ip -p tcp -m multiport ! --destination-port $port,23 -j DROP
			fi
			if [ $storage -eq 1 ];then
				#all tcp packet will be drop except the packet's port number is http_port and 23	
				logger "iptables -t filter -I ACLSTORAGE -s $ipaddr -d $lan_ip -p tcp -m multiport ! --destination-port $port,23 -j ACCEPT"
				iptables -t filter -D ACLSTORAGE -s $ipaddr -d $lan_ip -p tcp -m multiport ! --destination-port $port,23 -j ACCEPT
			fi				
		fi
		exit 0
	fi
} 

config_foreach loop_exist_hostname device
