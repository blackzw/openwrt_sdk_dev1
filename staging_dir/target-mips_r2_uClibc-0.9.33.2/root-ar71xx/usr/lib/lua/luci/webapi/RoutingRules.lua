module("luci.webapi.RoutingRules", package.seeall)

local common = require('luci.webapi.Util')

--[[
Get Dynamic Routing information
Parameters
	
Return value:
	"State":1,
	"RipState": "1",
	"Operation": "1",
	"RipVerion": "0"

]]
function GetDynamicRouting()
	local rsp = {}
	local state = common.GetValue("ripd", "ripd", "enabled")   -- /etc/config/ripd
	local ripverion = common.GetValue("ripd", "ripd", "version")   -- /etc/config/ripd
	if state == nil or state == "" then
		state = 0
	end
	if ripverion == nil or ripverion == "" then
		ripverion = 0   --Rip V1&Rip V2
	elseif string.match(ripverion, "1 1") then
		ripverion = 1   --Rip V1
	elseif string.match(ripverion, "2 2") then
		ripverion = 2   --Rip V2
	elseif string.match(ripverion, "1 2") then
		ripverion = 0   --Rip V1&Rip V2
	end
	--rsp["State"] = 1         --0:disable   1: enable
	rsp["RipState"] = state          --0:disable   1: enable  //no this section
	rsp["Operation"] = 1    	 --0:disactive   1: active //no this section
	rsp["RipVerion"] = ripverion    	
	return rsp
end

--[[
Get Dynamic Routing information
Parameters
	
Return value:
	"State":1,
	"RipState": "1",
	"Operation": "1",
	"RipVerion": "0"

]]
function SetDynamicRouting(req)
	--local rsp = {}
	--local state = req["State"]
	local ripverion = req["RipVerion"]
	local ripstate = req["RipState"]
	local version = "1 2"
	if ripverion == nil or ripstate == nil then
		errs = {code=7, message="Bad parameter"}
		return nil, errs
	end
	if ripverion == 0 then
		version = "1 2"
	elseif ripverion == 1 then
		version = "1 1"
	elseif ripverion == 2 then
		version = "2 2"
	end
	local ret = common.SetValue("ripd", "ripd", "enabled", ripstate)   -- /etc/config/ripd
	if ret == false then
		errs = {code=210401, message="Set Dynamic Routing rules failed."}
		return nil, errs
	end
	ret = common.SetValue("ripd", "ripd", "version", version)   -- /etc/config/ripd
	if ret == false then
		errs = {code=210401, message="Set Dynamic Routing rules failed."}
		return nil, errs
	end
	ret = common.SaveFile("ripd")
	if ret == false then
		errs = {code=210401, message="Set Dynamic Routing rules failed."}
		return nil, errs
	end
		
	if ripstate == 0 then
		common.Exec("/etc/iquagga/quagga.init stop")      -- disable
	end
	if ripstate == 1 then
		common.Exec("/etc/iquagga/quagga.init stop")      -- disable
		common.Exec("/etc/iquagga/quagga.init start")     -- enbale
	end
	return luci.json.null
end


--[[
Get Static Routing information
Parameters
	
Return value:
	"State":1,
	"StaticRoutingList":[{
						"Id":1, 
						"DestNetAddr": "201.19.10.123" ,
						"DestNetmask": "255.255.255.0",
						"GateWay": "192.168.1.1",
						"SourceNetAddr": "1",
						"SourceNetmask": "255.255.0.0",
						"Interface": "1",
						"Metric": "20",
						"MTU": "1500"
	},бн]


]]
function GetStaticRouting()
	local rsp = {}
	local nwlist = {}
	local rulelist = common.GetValueList("network", "route")   -- /etc/config/network
	local state = common.GetValue("network", "switch", "enabled")
	if state == nil then
		state = 1
	end
	if rulelist == nil then
		--errs = {code=210101, message="Get Static Routing rules list failed."}
		rsp["State"] = tonumber(state)
		rsp["StaticRoutingList"] = nwlist
		return rsp
	end
	rsp["State"] = tonumber(state)
  	for i=1,table.getn(rulelist.valuelist) do
				nwItem = {}
				if rulelist.valuelist[i]["instance"] == nil or rulelist.valuelist[i]["instance"] == "" then
					nwItem["Id"] = 0
				else
					nwItem["Id"] = tonumber(rulelist.valuelist[i]["instance"])
				end
				
				if rulelist.valuelist[i]["interface"] == "lan" then
					nwItem["Interface"] = 1		--1:lan
				else
					nwItem["Interface"] = 0     --0:wan
				end
				if rulelist.valuelist[i]["target"] == nil or rulelist.valuelist[i]["target"] == "" then
					nwItem["DestNetAddr"] = ""
				else
					nwItem["DestNetAddr"] = rulelist.valuelist[i]["target"]
				end
				if rulelist.valuelist[i]["netmask"] == nil or rulelist.valuelist[i]["netmask"] == "" then
					nwItem["DestNetmask"] = ""
				else
					nwItem["DestNetmask"] = rulelist.valuelist[i]["netmask"]
				end
				if rulelist.valuelist[i]["gateway"] == nil or rulelist.valuelist[i]["gateway"] == "" then
					nwItem["GateWay"] = ""
				else
					nwItem["GateWay"] = rulelist.valuelist[i]["gateway"]
				end
				if rulelist.valuelist[i]["mtu"] == nil or rulelist.valuelist[i]["mtu"] == "" then
					nwItem["MTU"] = 1500
				else
					nwItem["MTU"] = tonumber(rulelist.valuelist[i]["mtu"])
				end
				if rulelist.valuelist[i]["srcaddr"] == nil or rulelist.valuelist[i]["srcaddr"] == "" then
					nwItem["SourceNetAddr"] = ""
				else
					nwItem["SourceNetAddr"] = rulelist.valuelist[i]["srcaddr"]
				end
				if rulelist.valuelist[i]["srcmask"] == nil or rulelist.valuelist[i]["srcmask"] == "" then
					nwItem["SourceNetmask"] = ""
				else
					nwItem["SourceNetmask"] = rulelist.valuelist[i]["srcmask"]
				end
				if rulelist.valuelist[i]["metric"] == nil or rulelist.valuelist[i]["metric"] == "" then
					nwItem["Metric"] = 0
				else
					nwItem["Metric"] = tonumber(rulelist.valuelist[i]["metric"])
				end
				if rulelist.valuelist[i]["type"] == nil or rulelist.valuelist[i]["type"] == "" then
					nwItem["Type"] = 2
				else
					nwItem["Type"] = tonumber(rulelist.valuelist[i]["type"])
				end
				
				nwlist[i] = nwItem
				--rsp["State"] = tonumber(rulelist.valuelist[i]["enabled"])
	end
	
	rsp["StaticRoutingList"] = nwlist
	return rsp
end

--[[
SetVirtualServerSettings function
	 1.delete all route rules type list
	 2.add all  route rules type list
	 3.restart damon network
Parameters
		"State":1,
		"StaticRoutingList":[{
							"Id":1, 
							"DestNetAddr": "201.19.10.123",
							"DestNetmask": "255.255.255.0",
							"GateWay": "192.168.1.1",
							"SourceNetAddr": "1",
							"SourceNetmask": "255.255.0.0",
							"Interface": "1",
							"Metric": "20",
							"MTU": "1500"
		},бн]

Return value:
	String containg the return the output of the command 
]]
function SetStaticRouting(req)
	local rsp = {}
	local cfglist = req["StaticRoutingList"]
	local state = req["State"]
	-- Connie add start, 2014/6/19
	local enable = "false"
	local status = "Disabled"
	-- Connie add end, 2014/6/19

	if state == nil or state == ""  or cfglist == nil then
		errs = {code=7, message="Bad parameter"}
		return nil, errs
	end
	local ret = common.DeleteSection("network", "route")		 --etc/config/network
	--common.DeleteSection("network", "switch")		 --etc/config/network
	for i=1,table.getn(cfglist) do
				nwItem = {}
				--nwItem["Id"] = i						-- net id  
				nwItem["target"] = cfglist[i]["DestNetAddr"]         
				nwItem["netmask"] = cfglist[i]["DestNetmask"]         
				nwItem["gateway"] = cfglist[i]["GateWay"]
				if cfglist[i]["Interface"] == 1 then
					nwItem["interface"] = "lan"
				elseif cfglist[i]["Interface"] == 0 then
					nwItem["interface"] = "wan"
				else
					nwItem["interface"] = "lan"
				end
				if state == 0 or state == "0" then
					nwItem["enabled"] = "0"
					-- Connie add start, 2014/6/19
					enable = "false"
					status = "Disabled"
					-- Connie add end, 2014/6/19
				else
					nwItem["enabled"] = "1"
					-- Connie add start, 2014/6/19
					enable = "true"
					status = "Enabled"
					-- Connie add end, 2014/6/19
				end
				if cfglist[i]["Id"] ~= nil then
					nwItem["instance"] = cfglist[i]["Id"]
				end
				if cfglist[i]["SourceNetAddr"] == nil or cfglist[i]["SourceNetAddr"] == "" then
					nwItem["srcaddr"] = "0.0.0.0"
				else
					nwItem["srcaddr"] = cfglist[i]["SourceNetAddr"]
				end
				if cfglist[i]["SourceNetmask"] == nil or cfglist[i]["SourceNetmask"] == "" then
					nwItem["srcmask"] = "0.0.0.0"
				else
					nwItem["srcmask"] = cfglist[i]["SourceNetmask"]
				end
				if cfglist[i]["Metric"] == nil or cfglist[i]["Metric"] == "" then
					nwItem["metric"] = 0
				else
					nwItem["metric"] = cfglist[i]["Metric"]
				end
				if cfglist[i]["MTU"] == nil or cfglist[i]["MTU"] == "" then
					nwItem["mtu"] = 1500
				else
					nwItem["mtu"] = cfglist[i]["MTU"]
				end
				if cfglist[i]["Type"] == nil or cfglist[i]["Type"] == "" then
					nwItem["type"] = 2
				else
					nwItem["type"] = cfglist[i]["Type"]
				end
				
				ret = common.AddSection("network", "route", nil, nwItem)
				if ret == false then
					errs = {code=210201, message="Set Static Routing rules failed."}
					return nil, errs
				end
				-- Connie add start, 2014/6/19    	        
				common.InformValueChanged("InternetGatewayDevice.Layer3Forwarding.Forwarding.", i, "Enable",           enable,                      "xsd:string")
				common.InformValueChanged("InternetGatewayDevice.Layer3Forwarding.Forwarding.", i, "Status",           status,                      "xsd:string")
				common.InformValueChanged("InternetGatewayDevice.Layer3Forwarding.Forwarding.", i, "Type",             nwItem["type"],              "xsd:string")
				common.InformValueChanged("InternetGatewayDevice.Layer3Forwarding.Forwarding.", i, "DestIPAddress",    cfglist[i]["DestNetAddr"],   "xsd:string")
				common.InformValueChanged("InternetGatewayDevice.Layer3Forwarding.Forwarding.", i, "DestSubnetMask",   cfglist[i]["DestNetmask"],   "xsd:string")
				common.InformValueChanged("InternetGatewayDevice.Layer3Forwarding.Forwarding.", i, "SourceIPAddress",  cfglist[i]["SourceNetAddr"], "xsd:string")
				common.InformValueChanged("InternetGatewayDevice.Layer3Forwarding.Forwarding.", i, "SourceSubnetMask", cfglist[i]["SourceNetmask"], "xsd:string")
				common.InformValueChanged("InternetGatewayDevice.Layer3Forwarding.Forwarding.", i, "GatewayIPAddress", cfglist[i]["GateWay"],       "xsd:string")
				common.InformValueChanged("InternetGatewayDevice.Layer3Forwarding.Forwarding.", i, "Interface",        nwItem["interface"],         "xsd:string")
				common.InformValueChanged("InternetGatewayDevice.Layer3Forwarding.Forwarding.", i, "ForwardingMetric", cfglist[i]["Metric"],        "xsd:int")
				-- Connie add end, 2014/6/19
	end
	nwItem = {}
	nwItem["enabled"] = state
	common.AddSection("network", "route_switch", "switch", nwItem)
	ret = common.SaveFile("network")
		if ret == false then
				errs = {code=210201, message="Set Static Routing rules failed."}
				return nil, errs
		end
	--luci.sys.reboot()     
	ret = common.Exec("ubus call network reload &")     -- restart firewall -- restart network 
	return luci.json.null
	
end