module("luci.webapi.Nat", package.seeall)

local common = require('luci.webapi.Util')

--[[
get port forwarding settings information
Parameters
	VirtualServerStatus: 0 disable ,1 enable
	ServerConfigList:port forwarding list 
					"Id":1, 
					"VirtualServerName":"sample",
					"WanPort":"25"
					"LanIP": "192.168.1.3" ,
					"LanPort": "21",
					"Protocol": 1,
					"SingleServerStatus": 1,
Return value:
	String containg the return the output of the command 
]]
function GetVirtualServerSettings()
	local rsp = {}
	local nwlist = {}
	local forwardinglist = common.GetValueList("firewall", "redirect")   --etc/config/firewall
	if forwardinglist == nil then
		errs = {code=180101, message="Get virtual Server config info failed"}
		return nil, errs
	end

	for i=1,table.getn(forwardinglist.valuelist) do
					nwItem = {}
					nwItem["Id"] = i						-- net id 
					if  forwardinglist.valuelist[i]["name"] == nil then
						nwItem["VirtualServerName"] = ""
					else
						nwItem["VirtualServerName"] = forwardinglist.valuelist[i]["name"]
					end
				
					if forwardinglist.valuelist[i]["src_dport"] == nil then
						nwItem["WanPort"] = ""
					else
						nwItem["WanPort"] = forwardinglist.valuelist[i]["src_dport"]        
					end
					if forwardinglist.valuelist[i]["dest_ip"] == nil then
						nwItem["LanIP"] = ""
					else
						nwItem["LanIP"] = forwardinglist.valuelist[i]["dest_ip"]
					end
					if forwardinglist.valuelist[i]["dest_port"] == nil then
						nwItem["LanPort"] = ""
					else
						nwItem["LanPort"] = forwardinglist.valuelist[i]["dest_port"]
					end
					
					local protocol = forwardinglist.valuelist[i]["proto"]
					if string.find(protocol, "tcp udp") then
						nwItem["Protocol"] = 2			--tcp&udp
					elseif string.find(protocol, "tcp") then
						nwItem["Protocol"] = 0			--tcp
					elseif string.find(protocol, "udp") then
						nwItem["Protocol"] = 1			--udp
					else
						nwItem["Protocol"] = 2			--tcp&udp
					end
					local state = forwardinglist.valuelist[i]["enabled"]
					nwItem["SingleServerStatus"] = tonumber(state)
					nwlist[i] = nwItem
				
			end
	local virstatus = common.GetValue("firewall", "redirect_witch", "enabled")   --etc/config/firewall		
	rsp["VirtualServerStatus"] = tonumber(virstatus)   --0 disable ,1 enable  --not interface 
	
	rsp["ServerConfigList"] =   nwlist 
	return rsp
end

--[[
SetVirtualServerSettings function
	 1.delete all port forwarding type list
	 2.add all port forwarding type list
	 3.restart damon firewall
Parameters
	VirtualServerStatus: 0 disable ,1 enable
	ServerConfigList:port forwarding list 
					"Id":1, 
					"VirtualServerName":"sample",
					"WanPort":"25"
					"LanIP": "192.168.1.3" ,
					"LanPort": "21",
					"Protocol": 1,
					"SingleServerStatus": 1,
Return value:
	String containg the return the output of the command 
]]
function SetVirtualServerSettings(req)
	local rsp = {}
	local cfglist = req["ServerConfigList"]
	local pfenable = req["VirtualServerStatus"]
	local ret = common.DeleteSection("firewall", "redirect")		 --etc/config/firewall

	if ret == false or cfglist == nil or pfenable == nil then
		errs = {code=7, message="Bad parameter"}
		return nil, errs
	end
	for i=1,table.getn(cfglist) do
				nwItem = {}
				--nwItem["Id"] = i						-- net id  
				nwItem["name"] = cfglist[i]["VirtualServerName"]         --name
				nwItem["src_dport"] = cfglist[i]["WanPort"]         --plmn
				nwItem["dest_ip"] = cfglist[i]["LanIP"]
				nwItem["src"] ="wan"        --default
				nwItem["dest"] ="lan"	--default
				nwItem["dest_port"] = cfglist[i]["LanPort"]
				local protocol = cfglist[i]["Protocol"]
				if protocol == 2 then
					nwItem["proto"] = "tcp udp"			--tcp&udp
				elseif protocol == 0 then
					nwItem["proto"] = "tcp"			--tcp
				elseif protocol == 1 then
					nwItem["proto"] = "udp"		--udp
				end
				local state = cfglist[i]["SingleServerStatus"]
				nwItem["enabled"] = state 	-- disable
		--[[		if state == 0 then
					nwItem["enabled"] = 1 	-- disable
				end
				if pfenable == 0 then
					nwItem["enabled"] = 1 	
				end--]]
				ret = common.AddSection("firewall", "redirect", nil, nwItem)
				if ret == false then
					errs = {code=180201, message="Set virtual Server config info failed"}
					return nil, errs
				end
	end 
--[[	local switch_item = {}
	switch_item["enabled"] =  pfenable
	switch_item["name"] =  "def_pf"
	ret = common.AddSection("firewall", "redirect", nil, switch_item)--]]
	common.SetValue("firewall", "redirect_witch", "enabled", pfenable)
	ret = common.SaveFile("firewall")
		if ret == false then
				errs = {code=180201, message="Set virtual Server config info failed"}
				return nil, errs
		end
	ret = common.Exec("/etc/init.d/firewall restart")     -- restart firewall 
	if ret == false then
				errs = {code=180201, message="Set virtual Server config info failed"}
				return nil, errs
	end
	return luci.json.null
	
end
