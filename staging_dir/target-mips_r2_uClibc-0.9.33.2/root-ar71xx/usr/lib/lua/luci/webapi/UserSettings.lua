module("luci.webapi.UserSettings", package.seeall)

local common = require('luci.webapi.Util')

--[[
Get User Settings
Parameters
	
Return value:
	[{
		"DeviceName":"iphone5s",
		"DeviceIP":"192.168.17",
		"DeviceMac":"f8:1e:df:e4:ed:8b",
		"DeviceType":"1",
		"InternetRight":"0",
		"StorageRight":"0"
	},бн]
]]

function GetUserSettings()
	local rsp = {}
	local nwItem = {}
	local userlist = common.GetValueList("acl", "device")   --etc/config/acl
	if userlist == nil then
		errs = {code=190101, message="Get User Settings list info failed."}
		return nil, errs
	end
	
	rsp["List"] = {}
	for i=1,table.getn(userlist.valuelist) do
				nwItem = {}
				nwItem["DeviceName"] = userlist.valuelist[i]["name"]
				nwItem["DeviceIP"] = ""
				nwItem["DeviceMac"] = ""
				if userlist.valuelist[i]["type"] == "default" then
					nwItem["DeviceType"] = 0
				else
					nwItem["DeviceType"] = 1
				end
				if userlist.valuelist[i]["internet"] == 0 or userlist.valuelist[i]["internet"] == "0" then
					nwItem["InternetRight"] = 0
				else
					nwItem["InternetRight"] = 1
				end
				if userlist.valuelist[i]["storage"] == 0 or userlist.valuelist[i]["storage"] == "0" then
					nwItem["StorageRight"] = 0
				else
					nwItem["StorageRight"] = 1
				end
				rsp["List"][i] = nwItem
				
	end
	
	return rsp
end

--[[
Set User Settings
Parameters
	[{
		"DeviceName":"iphone5s",
		"DeviceIP":"192.168.17",
		"DeviceMac":"f8:1e:df:e4:ed:8b",
		"DeviceType":"1",
		"InternetRight":"0",
		"StorageRight":"0"
	},бн]

Return value:
		null
]]
function SetUserSettings(req)
	local userlist = req["List"]
	if userlist == nil then
		errs = {code=7, message="Bad parameter"}
		return nil, errs
	end
	local ret = common.DeleteSection("acl", "device")		 --etc/config/acl

	if ret == false then
		errs = {code=190201, message="Set User Settings failed."}
		return nil, errs
	end
	for i=1,table.getn(userlist) do
				nwItem = {}
				nwItem["name"] = userlist[i]["DeviceName"]        
				nwItem["internet"] = userlist[i]["InternetRight"]       
				nwItem["storage"] = userlist[i]["StorageRight"]
				if userlist[i]["DeviceType"] == 0 or userlist[i]["DeviceType"] == "0" then
					nwItem["type"] = "default"
				else
					nwItem["type"] = ""
				end
				
				ret = common.AddSection("acl", "device", nil, nwItem)
				if ret == false then
					errs = {code=190201, message="Set User Settings failed."}
					return nil, errs
				end
	end
	
	ret = common.SaveFile("acl")
		if ret == false then
				errs = {code=190201, message="Set User Settings failed."}
				return nil, errs
		end
	ret = common.Exec("/etc/init.d/firewall restart")     -- restart firewall 
	if ret == false then
				errs = {code=190201, message="Set User Settings failed."}
				return nil, errs
		end
	return luci.json.null
end
