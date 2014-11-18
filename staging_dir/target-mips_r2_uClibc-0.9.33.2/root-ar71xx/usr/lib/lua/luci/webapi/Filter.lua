module("luci.webapi.Filter", package.seeall)

local common = require('luci.webapi.Util')

--[[
Request data:

Response data:
		"State":1,
		"IpList":[
		{
		"Id":"1", 
		"LanIP": "",
		"LanPort": "55",
		"WanIP": "",
		"WanPort": "66",
		"Protocol": "1"
		},бн
		]	
		},
]]
function GetIPFilterSettings()
	local rsp = {}
	local iplist = {}
	local ipfilterlist = common.GetValueList("ipfilter", "ipfilter")   --etc/config/ipfilter
	local filter = common.GetValue("ipfilter", "main", "state")
	if ipfilterlist == nil or filter == nil then
		rsp["State"] = 0    --off
		rsp["IpList"] = ""
		--errs = {code=170101, message="Get IP Filter Settings failed"}
		return rsp
	end
	rsp["State"] = tonumber(filter)    --off
	for i=1,table.getn(ipfilterlist.valuelist) do
				nwItem = {}
				nwItem["Id"] = i						-- net id  
				if ipfilterlist.valuelist[i]["srcip"] == nil then
					nwItem["LanIP"] = ""
				else
					nwItem["LanIP"] = ipfilterlist.valuelist[i]["srcip"]
				end
				if ipfilterlist.valuelist[i]["lansrcport"] == nil then
					nwItem["LanSrcPort"] = ""
				else
					nwItem["LanSrcPort"] = ipfilterlist.valuelist[i]["lansrcport"]
				end
				if ipfilterlist.valuelist[i]["landestport"] == nil then
					nwItem["LanDestPort"] = ""
				else
					nwItem["LanDestPort"] = ipfilterlist.valuelist[i]["landestport"]
				end
				
				if ipfilterlist.valuelist[i]["destip"] == nil then
					nwItem["WanIP"] = ""
				else
					nwItem["WanIP"] = ipfilterlist.valuelist[i]["destip"]
				end
				if ipfilterlist.valuelist[i]["destip"] == nil then
					nwItem["WanIP"] = ""
				else
					nwItem["WanIP"] = ipfilterlist.valuelist[i]["destip"]
				end
				if ipfilterlist.valuelist[i]["wandestport"] == nil then
					nwItem["WanDestPort"] = ""
				else
					nwItem["WanDestPort"] = ipfilterlist.valuelist[i]["wandestport"]
				end
				if ipfilterlist.valuelist[i]["wansrcport"] == nil then
					nwItem["WanSrcPort"] = ""
				else
					nwItem["WanSrcPort"] = ipfilterlist.valuelist[i]["wansrcport"]
				end
				if ipfilterlist.valuelist[i]["portocol"] == nil then
					nwItem["Protocol"] = ""
				else
					nwItem["Protocol"] = ipfilterlist.valuelist[i]["portocol"]
				end
				iplist[i] = nwItem
				
	end
	rsp["IpList"] = iplist
	return rsp 
end


--[[
Request data:

Response data:
		"State":1,
		"IpList":[
		{
		"Id":"1", 
		"LanIP": "",
		"LanPort": "55",
		"WanIP": "",
		"WanPort": "66",
		"Protocol": "1"
		},бн
		]	
		},
]]
function SetIPFilterSettings(req)
	local state = req["State"]
	local iplist = req["IpList"]
	local item = {} 
	local filterlist = {}
	
	if iplist == nil then
		if state ~= 0 then
			errs = {code=7, message="Bad parameter"}
			return nil, errs
		end
	end
	local filter_init_lib = assert(package.loadlib("/usr/lib/libfilter.so", "luaopen_filter_init_lib"))
		filter_init_lib()
		
	if filterlib == nil then
		errs = {code=170202, message="load filter init lib error"}
		return nil, errs
	end
	item["state"] = state
	common.DeleteSection("ipfilter", "ipfilter")
	local ret = common.AddSection("ipfilter", "filter", "main", item)
	if ret == false then
		errs = {code=170201, message="Set IP Filter Settings failed"}
		return nil, errs
	end
	
	for i=1,table.getn(iplist) do
				item = {}
				item["srcip"] = iplist[i]["LanIP"]        
				item["lansrcport"] = iplist[i]["LanSrcPort"]    
				item["landestport"] = iplist[i]["LanDestPort"]   
				item["destip"] = iplist[i]["WanIP"] 
				item["wansrcport"] = iplist[i]["WanSrcPort"]        
				item["wandestport"] = iplist[i]["WanDestPort"]        
				item["portocol"] = iplist[i]["Protocol"]        
				ret = common.AddSection("ipfilter", "ipfilter", nil, item)
				if ret == false then
					errs = {code=170201, message="Set IP Filter Settings failed"}
					return nil, errs
				end
				local tmp ={}
				tmp = {iplist[i]["Protocol"], iplist[i]["LanIP"], iplist[i]["LanSrcPort"], iplist[i]["LanDestPort"],iplist[i]["WanIP"], iplist[i]["WanSrcPort"], iplist[i]["WanDestPort"]}   
				table.insert(filterlist,tmp)
	end
		ret = common.SaveFile("ipfilter")
		if ret == false then
				errs = {code=170201, message="Set IP Filter Settings failed"}
				return nil, errs
		end
		
		filterlib.config_ip_filter(state,filterlist)
		os.execute("/etc/init.d/firewall restart")
		return luci.json.null 
end


--[[
Request data:

Response data:
		"State":1,
		"MacList":["44:44:22:d5:21:24",бн]

]]
function GetMacFilterSettings()
	local rsp = {}
	local maclist = {}
	local macfilterlist = common.GetValueList("macfilter", "macfilter")   --etc/config/macfilter
	local filter = common.GetValue("macfilter", "main", "state")
	if macfilterlist == nil or filter == nil then
		rsp["State"] = 0    --off
		rsp["MacList"] = ""
		--errs = {code=170101, message="Get IP Filter Settings failed"}
		return rsp
	end
	rsp["State"] = tonumber(filter)    --off
	for i=1,table.getn(macfilterlist.valuelist) do
				maclist[i] = {macfilterlist.valuelist[i]["macaddr"]}
	end
	rsp["MacList"] = maclist
	return rsp 
end

--[[
Request data:
		"State":1,
		"MacList":["44:44:22:d5:21:24",бн]
Response data:
		null
]]
function SetMacFilterSettings(req)
	local filterlist = {}
	local item = {}
	local state = req["State"]
	local maclist = req["MacList"]
	local filter_init_lib = assert(package.loadlib("/usr/lib/libfilter.so", "luaopen_filter_init_lib"))
	filter_init_lib()
	
	if maclist == nil then
		if state ~= 0 then
			errs = {code=7, message="Bad parameter"}
			return nil, errs
		end
	end	
	
	if filterlib == nil then
		errs = {code=170401, message="load filter init lib error"}
		return nil, errs
	end
	item["state"] = state
	
	common.DeleteSection("macfilter", "macfilter")
	local ret = common.AddSection("macfilter", "filter", "main", item)
	if ret == false then
		errs = {code=170401, message="Set MAC Filter settings failed"}
		return nil, errs
	end
	for i=1,table.getn(maclist) do
				
				item["macaddr"] = maclist[i]               
				ret = common.AddSection("macfilter", "macfilter", nil, item)
				if ret == false then
					errs = {code=170401, message="Set MAC Filter settings failed"}
					return nil, errs
				end 
				table.insert(filterlist,maclist[i][1])
	end
		ret = common.SaveFile("macfilter")
		if ret == false then
				errs = {code=170401, message="Set MAC Filter settings failed"}
				return nil, errs
		end
		filterlib.config_mac_filter(state,maclist)
		os.execute("/etc/init.d/firewall restart")
	return luci.json.null 
end


--[[
Request data:

Response data:
		"State":1
		"UrlList":["www:256.com","www.dfgsd.com",бн]


]]
function GetUrlFilterSettings()
	local rsp = {}
	local urllist = {}
	local urlfilterlist = common.GetValueList("urlfilter", "urlfilter")   --etc/config/urlfilter
	local filter = common.GetValue("urlfilter", "main", "state")
	if urlfilterlist == nil or filter == nil then
		rsp["State"] = 0    --off
		rsp["MacList"] = ""
		--errs = {code=170101, message="Get IP Filter Settings failed"}
		return rsp
	end
	rsp["State"] = tonumber(filter)    --off
	for i=1,table.getn(urlfilterlist.valuelist) do
				urllist[i] = {urlfilterlist.valuelist[i]["urladdr"]}
	end
	rsp["UrlList"] = urllist
	return rsp 
end


--[[
Request data:
		"State":1
		"UrlList":["www:256.com","www.dfgsd.com",бн]
Response data:
		null
]]
function SetUrlFilterSettings(req)
	local filterlist = {}
	local item = {}
	local state = req["State"]
	local urllist = req["UrlList"]
	local filter_init_lib = assert(package.loadlib("/usr/lib/libfilter.so", "luaopen_filter_init_lib"))
	filter_init_lib()
	
	if urllist == nil then
		if state ~= 0 then
			errs = {code=7, message="Bad parameter"}
			return nil, errs
		end
	end	
		
	if filterlib == nil then
		errs = {code=170601, message="load filter init lib error"}
		return nil, errs
	end
	item["state"] = state
	common.DeleteSection("urlfilter", "urlfilter")
	local ret = common.AddSection("urlfilter", "filter", "main", item)
	if ret == false then
		errs = {code=170601, message="Set MAC Filter settings failed"}
		return nil, errs
	end
	for i=1,table.getn(urllist) do
				item = {}
				item["urladdr"] = urllist[i]               
				ret = common.AddSection("urlfilter", "urlfilter", nil, item)
				if ret == false then
					errs = {code=170601, message="Set URL Filter Settings failed."}
					return nil, errs
				end
				--filterlist[i] = {urllist[i]}  
				table.insert(filterlist,urllist[i][1]) 
	end
		ret = common.SaveFile("urlfilter")
		if ret == false then
				errs = {code=170601, message="Set URL Filter Settings failed."}
				return nil, errs
		end
	filterlib.config_url_filter(state,urllist)
	os.execute("/etc/init.d/firewall restart")
	return luci.json.null 
end