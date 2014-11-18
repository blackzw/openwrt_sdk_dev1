module("luci.webapi.LAN", package.seeall)

local common = require('luci.webapi.Util')
local bit = require('luci.webapi.bit')

function Ip2Int(strip)
	local o1,o2,o3,o4 = strip:match("(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)" )
	local num = 2^24*o1 + 2^16*o2 + 2^8*o3 + o4
	return num
end

function Int2Ip(ipaddr)
	local strip = ""
	local s1 = bit.bit:_rshift(ipaddr, 24)
	local s2 = bit.bit:_and(ipaddr, 0x00FFFFFF)
	local s3 = bit.bit:_and(ipaddr, 0x0000FFFF)
	local s4 = bit.bit:_and(ipaddr, 0x000000FF)
	local ip1,ip2,ip3,ip4
	ip1 = s1
	ip2 =  bit.bit:_rshift(s2, 16)
	ip3 =  bit.bit:_rshift(s3, 8)
	ip4 =  s4
	strip = ip1.."."..ip2.."."..ip3.."."..ip4
    return  strip
end
--[[ 
get get lan settings  
Parameters
	
responose value:
	"IPv4IPAddress": "192.168.1.1"£¬
	"SubnetMask":"255.255.255.0 "£¬
	"DHCPServerStatus":"0"£¬
	"StartIPAddress": "192.168.1.3"£¬
	"EndIPAddress":"192.168.1.99 "£¬
	"DHCPLeaseTime":"12" hours

]]
function GetLanSettings()
	local rsp = {}
	
	--/etc/config/network
	rsp["IPv4IPAddress"] = common.GetValue("network", "lan", "ipaddr")
	rsp["SubnetMask"] = common.GetValue("network", "lan", "netmask")
	
	--/etc/config/dhcp
	local state = common.GetValue("dhcp", "lan", "ignore")
	if state == "1" then
		rsp["DHCPServerStatus"] = 0   --disable
	else
		rsp["DHCPServerStatus"] = 1   --enable
	end
	local startip = common.GetValue("dhcp", "lan", "start")
	local limitip = common.GetValue("dhcp", "lan", "limit")
	local o1,o2,o3,o4 = rsp["IPv4IPAddress"]:match("(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)" )
	local intip = tonumber(startip) + Ip2Int(rsp["IPv4IPAddress"]) - o4
	if startip ~= nil then
		rsp["StartIPAddress"] = Int2Ip(intip)   
	else
		rsp["StartIPAddress"] = ""  
	end
	if limitip ~= nil then
		intip = limitip + intip - 1--Ip2Int(rsp["IPv4IPAddress"])
		rsp["EndIPAddress"] = Int2Ip(intip)   
	else
		rsp["EndIPAddress"] = ""
	end
	rsp["DHCPLeaseTime"] = common.GetValue("dhcp", "lan", "leasetime")
	return rsp
end

--[[
network
	"IPv4IPAddress": "192.168.1.1"£¬
	"SubnetMask":"255.255.255.0 "£¬
dhcp
	"DHCPServerStatus":"0"£¬
	"StartIPAddress": "192.168.1.3"£¬
	"EndIPAddress":"192.168.1.99 "£¬
	"DHCPLeaseTime":"12"
--]]

function SetLanSettings(req)
	
	local ipaddr = req["IPv4IPAddress"]
	local subnetmask = req["SubnetMask"]
	local ignore = req["DHCPServerStatus"]
	local strip = req["StartIPAddress"]
	local strendip = req["EndIPAddress"]
	local leasetime = req["DHCPLeaseTime"]
	local dhcpserverenable = "false" -- Connie add, 2014/6/19
	if ipaddr == nil or subnetmask == nil or ignore == nil or strip == nil or strendip == nil or leasetime == nil then
		errs = {code=7, message="Bad parameter"}
		return nil, errs
	end
	-- Connie add start, 2014/6/23
	local ori_state      = common.GetValue("dhcp",    "lan", "ignore")
	local ori_ipaddr     = common.GetValue("network", "lan", "ipaddr")
	local ori_subnetmask = common.GetValue("network", "lan", "netmask")
	local ori_startip    = common.GetValue("dhcp",    "lan", "start")
	local ori_limitip    = common.GetValue("dhcp",    "lan", "limit")
	local ori_strip      = ""
	local ori_strendip   = ""
	local ori_o1,ori_o2,ori_o3,ori_o4 = ori_ipaddr:match("(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)" )
	local intip = tonumber(ori_startip) + Ip2Int(ori_ipaddr) - ori_o4
	if ori_startip ~= nil then
		ori_strip = Int2Ip(intip)   
	else
		ori_strip = ""  
	end
	if ori_limitip ~= nil then
		intip = ori_limitip + intip - 1--Ip2Int(ori_ipaddr)
		ori_strendip = Int2Ip(intip)   
	else
		ori_strendip = ""
	end
	-- Connie add end, 2014/6/23
	if ignore == 0 or ignore == "0" then
		ignore = "1"
		dhcpserverenable = "false" -- Connie add, 2014/6/19
	else
		ignore = "0"
		dhcpserverenable = "true" -- Connie add, 2014/6/19
	end
	--/etc/config/network
	common.SetValue("network", "lan", "ipaddr", ipaddr)
	common.SetValue("network", "lan", "netmask",subnetmask)
	
	--/etc/config/dhcp
	common.SetValue("dhcp", "lan", "ignore", ignore)
	local start1 = Ip2Int(strip)
	local start2 = Ip2Int(ipaddr) 
	local o1,o2,o3,o4 = ipaddr:match("(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)" )
	local startip = start1 - start2 + o4
	common.SetValue("dhcp", "lan", "start", startip)
	start1 = Ip2Int(strendip)
	start2 = Ip2Int(strip)
	local endip = start1  + 1 - start2
	local limitip = common.SetValue("dhcp", "lan", "limit", endip)
	common.SetValue("dhcp", "lan", "leasetime", leasetime)
	
	ret = common.SaveFile("network")
	if ret == false then                --error
		errs = {code=160201, message="Set LAN settings failed"}
		return nil, errs
	end
	
	ret = common.SaveFile("dhcp")
	if ret == false then                --error
		errs = {code=160201, message="Set LAN settings failed"}
		return nil, errs
	end
	-- Connie modify start, 2014/7/4
	local new_state      = common.GetValue("dhcp",    "lan", "ignore")
	common.WriteInformtoNewFile("InternetGatewayDevice.LANDevice.1.LANHostConfigManagement.",1,"DHCPServerConfigurable","true","xsd:boolean")
	if ori_state ~= new_state then
		common.WriteInformtoExistFile("InternetGatewayDevice.LANDevice.1.LANHostConfigManagement.",1,"DHCPServerEnable",dhcpserverenable,"xsd:boolean")
	end
	if ori_strip ~= strip then
		common.WriteInformtoExistFile("InternetGatewayDevice.LANDevice.1.LANHostConfigManagement.",1,"MinAddress",strip,"xsd:string")
	end
	if ori_strendip ~= strendip then
		common.WriteInformtoExistFile("InternetGatewayDevice.LANDevice.1.LANHostConfigManagement.",1,"MaxAddress",strendip,"xsd:string")
	end
	if ori_subnetmask ~= subnetmask then
		common.WriteInformtoExistFile("InternetGatewayDevice.LANDevice.1.LANHostConfigManagement.",1,"SubnetMask",subnetmask,"xsd:string")
	end
	if ori_ipaddr ~= ipaddr then
		common.WriteInformtoExistFile("InternetGatewayDevice.LANDevice.1.LANHostConfigManagement.",1,"IPRouters",ipaddr,"xsd:string")
	end
	luci.sys.reboot()
	-- Connie modify end, 2014/7/4
	return luci.json.null
end



--[[
get lan prort info  
Parameters
	
responose value:
 [{
	"LanFlag":"LAN1",
	"ConnectionStatus":"1",
	"IPAddress": "192.168.1.3",
	"MACAddress":" 03: 5D: 9E 36",
	"DHCPServer":" 192.168.1.1"
},¡­]


--]]
--[[function GetLanPortInfo()
	local rsp = {}
	local rv = { }
	local nfs = require "nixio.fs"
	local leasefile = "/var/dhcp.leases"
	uci = require "luci.model.uci".cursor()
	local family = 4
	uci:foreach("dhcp", "dnsmasq",
		function(s)
			if s.leasefile and nfs.access(s.leasefile) then
				leasefile = s.leasefile
				return false
			end
		end)

	local fd = io.open(leasefile, "r")
	local i = 0
	if fd then
		while true do
			local ln = fd:read("*l")
			if not ln then
				break
			else
				local ts, mac, ip, name, duid = ln:match("^(%d+) (%S+) (%S+) (%S+) (%S+)")
				if ts and mac and ip and name and duid then
					if family == 4 and not ip:match(":") then
						local lanlist = {}
						i = i + 1
						rv[#rv+1] = {
							expires  = os.difftime(tonumber(ts) or 0, os.time()),
							macaddr  = mac,
							ipaddr   = ip,
							hostname = (name ~= "*") and name
						}
						lanlist["LanFlag"] = (name ~= "*") and name
						lanlist["ConnectionStatus"] = 1			--no interface
						lanlist["IPAddress"] = ip
						lanlist["MACAddress"] = mac
						lanlist["RemainTime"] = os.difftime(tonumber(ts) or 0, os.time())   -- String.format('%t', expires);
						lanlist["DHCPServer"] = common.GetValue("network", "lan", "ipaddr")   --gataway address
						rsp[i] = lanlist
					elseif family == 6 and ip:match(":") then
						rv[#rv+1] = {
							expires  = os.difftime(tonumber(ts) or 0, os.time()),
							ip6addr  = ip,
							duid     = (duid ~= "*") and duid,
							hostname = (name ~= "*") and name
						}
						
					end
				end
			end
		end
		fd:close()
	end

	return rsp
end--]]

--[[function GetLanPortInfo()
	local rsp = {}
	local rv = { }
	
	local lan_info = luci.util.exec("/etc/init.d/lan_host")	
	local k = 0
	local arry = {}
	arry = Split(lan_info, "\n")
	for i=1,table.getn(arry) do
			lanlist = {}
			if arry[i] ~= nil then
				local sp_array = {}
				sp_array =  Split(arry[i], " ")
				for j=1,table.getn(sp_array) do
					if sp_array[1] ~= "" and sp_array[1] ~= nil then
						k = k + 1
						lanlist["LanFlag"] = "LAN"
						lanlist["ConnectionStatus"] = 1			--no interface
						lanlist["IPAddress"] = sp_array[1]
						lanlist["MACAddress"] = sp_array[2]
						--statlist["RemainTime"] = os.difftime(tonumber(ts) or 0, os.time())   -- String.format('%t', expires);
						lanlist["DHCPServer"] = common.GetValue("network", "lan", "ipaddr")   --gataway address
						rsp[k] = lanlist
						break
					end
				end
			end
	end
	
	--rsp["LAN"] = arry
	return rsp
end--]]

function GetLanPortInfo()
	local rsp = {}
	local lanhost = common.GetValueList("lanhost", "lan")   --etc/config/network
	if lanhost == nil then
		return luci.json.null
	end
	local k = 0
	rsp["List"] = {}
	for i=1,table.getn(lanhost.valuelist) do
			lanlist = {}
			if lanhost.valuelist[i] ~= nil then
				lanlist["LanFlag"] = "LAN"
				lanlist["ConnectionStatus"] = 1			--no interface default is connected
				if lanhost.valuelist[i]["ipaddr"] == nil or lanhost.valuelist[i]["ipaddr"] == "" then
					lanlist["ConnectionStatus"] = 0
				end
				
				lanlist["IPAddress"] = lanhost.valuelist[i]["ipaddr"]
				lanlist["MACAddress"] =  lanhost.valuelist[i]["macaddr"]
				lanlist["DHCPServer"] = common.GetValue("network", "lan", "ipaddr")   --gataway address
				k = k + 1
				rsp["List"][k] = lanlist
			end
	end
	 luci.util.exec("/etc/init.d/lanhost &")	--get lan informations in background
	return rsp
end

function Split(szFullString, szSeparator)
	local nFindStartIndex = 1
	local nSplitIndex = 1
	local nSplitArray = {}
	while true do
	   local nFindLastIndex = string.find(szFullString, szSeparator, nFindStartIndex)
	   if not nFindLastIndex then
		nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, string.len(szFullString))
		break
	   end
	   nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, nFindLastIndex - 1)
	   nFindStartIndex = nFindLastIndex + string.len(szSeparator)
	   nSplitIndex = nSplitIndex + 1
	end
	return nSplitArray
end

--[[

 get lan statistics  
Parameters
	
responose value:
[{
	"LanFlag":"LAN1",
	"ReceivedByte": "0",	
	"ReceivedPacket":"0",
	"ReceivedError": "0",
	"ReceivedDiscarded": "0",
	"SentByte": "0",
	"SentPacket": "0",
	"SentError": "0",
	"SentDiscarded": "0"

}]

--]]

function GetLanStatistics()
	local rsp = {}
	local lanlist = common.GetValueList("network", "switch_vlan")   --etc/config/network
	if lanlist == nil then
		return luci.json.null
	end
	local k = 0
	rsp["List"] = {}
	for i=1,table.getn(lanlist.valuelist) do
			statlist = {}
			
			if lanlist.valuelist[i]["device"] ~= nil then
				vlan = string.format("%s.%s", lanlist.valuelist[i]["device"], lanlist.valuelist[i]["vlan"])
				statlist["LanFlag"] = vlan
				statlist["ReceivedByte"] =  tonumber(luci.util.trim(luci.util.exec("cat /proc/net/dev | grep "..vlan.." | awk '{print $2}'"))) -- RxBytes
				statlist["ReceivedPacket"] =  tonumber(luci.util.trim(luci.util.exec("cat /proc/net/dev | grep "..vlan.." | awk '{print $3}'"))) -- Rxpackets
				statlist["ReceivedError"] =  tonumber(luci.util.trim(luci.util.exec("cat /proc/net/dev | grep "..vlan.." | awk '{print $4}'"))) -- Rxerror
				statlist["ReceivedDiscarded"] =  tonumber(luci.util.trim(luci.util.exec("cat /proc/net/dev | grep "..vlan.." | awk '{print $5}'"))) -- Rxdrops
				statlist["SentByte"] =  tonumber(luci.util.trim(luci.util.exec("cat /proc/net/dev | grep "..vlan.." | awk '{print $10}'"))) -- TxBytes
				statlist["SentPacket"] =  tonumber(luci.util.trim(luci.util.exec("cat /proc/net/dev | grep "..vlan.." | awk '{print $11}'"))) -- Txpackets
				statlist["SentError"] =  tonumber(luci.util.trim(luci.util.exec("cat /proc/net/dev | grep "..vlan.." | awk '{print $12}'"))) -- Txerror
				statlist["SentDiscarded"] =  tonumber(luci.util.trim(luci.util.exec("cat /proc/net/dev | grep "..vlan.." | awk '{print $13}'"))) -- Txdrops
				k = k + 1
				rsp["List"][k] = statlist
			end
	end
	return rsp
end

--[[
Add by houailing 2014-04-18

responose value:
[{
	"HostName":"",
	"IPAddress": "192.168.1.3",
	"MACAddress":" 03: 5D: 9E 36",
	"Expires":""
}]
]]

function GetDHCPHostList()
	local rsp = {}
	local rv = { }
	local nfs = require "nixio.fs"
	local leasefile = "/var/dhcp.leases"
	uci = require "luci.model.uci".cursor()
	
	uci:foreach("dhcp", "dnsmasq",
		function(s)
			if s.leasefile and nfs.access(s.leasefile) then
				leasefile = s.leasefile
				return false
			end
		end)

	rsp["List"] = {}
	local fd = io.open(leasefile, "r")
	local i = 0
	if fd then
		while true do
			local ln = fd:read("*l")
			if not ln then
				break
			else
				local ts, mac, ip, name, duid = ln:match("^(%d+) (%S+) (%S+) (%S+) (%S+)")
				if ts and mac and ip and name and duid then
					if ip:match(".") then
						local hostlist = {}
						i = i + 1
						hostlist["HostName"] = (name ~= "*") and name
						hostlist["IPAddress"] = ip
						hostlist["MACAddress"] = mac
						hostlist["Expires"] = os.difftime(tonumber(ts) or 0, os.time())   -- String.format('%t', expires);
						rsp["List"][i] = hostlist
					end
				end
			end
		end
		fd:close()
	else
	    errs = {code=160501, message="Get DHCP host list failed."}
		return nil, errs
	end

	return rsp
	
end
