#this script is used for add firewall rule, when there is a new host, it will add 
#iptables rules for internet and storage access.
#!/bin/sh

. /lib/functions.sh

config_load acl

local listen_http
local port
local ipaddr
local host_name

listen_http=$(uci get uhttpd.main.listen_http)
port=${listen_http#*:}

local lan_ip
lan_ip=$(uci get network.lan.ipaddr)

ipaddr=$1
host_name=$2

local default_internet
local default_storage

add_iptables_rule(){
	local name
	local internet
	local storage
	config_get name $1 name
	
	if [ "$name" = "default" ];then
		config_get default_internet $1 internet
		config_get default_storage $1 storage
	fi	
	
	if [ "$name" = "$host_name" ];then
		config_get internet $1 internet
		config_get storage $1 storage
		if [ -z "$(cat /tmp/dhcp.leases | grep $name)" ];then			
			if [ $default_internet -ne $internet ];then
				if [ $internet -eq 0 ];then
					#block the internet packet from specific lan ip
					logger "iptables -t filter -I ACLINTERNET -s $ipaddr -j DROP"
					iptables -t filter -D ACLINTERNET -s $ipaddr -j DROP
					iptables -t filter -I ACLINTERNET -s $ipaddr -j DROP
				fi
				if [ $internet -eq 1 ];then
					#block the internet packet from specific lan ip
					logger "iptables -t filter -I ACLINTERNET -s $ipaddr -j ACCEPT"
					iptables -t filter -D ACLINTERNET -s $ipaddr -j ACCEPT
					iptables -t filter -D ACLINTERNET -d $ipaddr -j ACCEPT
					iptables -t filter -I ACLINTERNET -s $ipaddr -j ACCEPT
					iptables -t filter -I ACLINTERNET -d $ipaddr -j ACCEPT
				fi				
			fi	
			if [ $default_storage -ne $storage ];then
				if [ $storage -eq 0 ];then
					#all tcp packet will be drop except the packet's port number is http_port and 23
					logger "iptables -t filter -I ACLSTORAGE -s $ipaddr -d $lan_ip -p tcp -m multiport ! --destination-port $port,23 -j DROP"
					iptables -t filter -D ACLSTORAGE -s $ipaddr -d $lan_ip -p tcp -m multiport ! --destination-port $port,23 -j DROP
					iptables -t filter -I ACLSTORAGE -s $ipaddr -d $lan_ip -p tcp -m multiport ! --destination-port $port,23 -j DROP
				fi
				if [ $storage -eq 1 ];then
					#all tcp packet will be drop except the packet's port number is http_port and 23	
					logger "iptables -t filter -I ACLSTORAGE -s $ipaddr -d $lan_ip -p tcp -m multiport ! --destination-port $port,23 -j ACCEPT"
					iptables -t filter -D ACLSTORAGE -s $ipaddr -d $lan_ip -p tcp -m multiport ! --destination-port $port,23 -j ACCEPT
					iptables -t filter -I ACLSTORAGE -s $ipaddr -d $lan_ip -p tcp -m multiport ! --destination-port $port,23 -j ACCEPT
				fi				
			fi	
		fi
		exit 0
	fi			
}

config_foreach add_iptables_rule device
