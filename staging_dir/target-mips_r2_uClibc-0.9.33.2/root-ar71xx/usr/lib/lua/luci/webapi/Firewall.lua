module("luci.webapi.Firewall", package.seeall)

local common = require('luci.webapi.Util')

--[[
get Firewall settings information
Parameters
	WanPortPingState: 0 disable ,1 enable	
Return value:
	String containg the return the output of the command 
]]
function GetFirewallSettings()
	local rsp = {}	
	local ping_state = common.GetValue("firewall","wanping","enabled")              --etc/config/firewall

	if ping_state == nil or ping_state == "" then
		errs = {code=230201, message="Get Firewall Settings failed."}
		return nil, errs
	end	

    rsp["WanPortPingState"] = tonumber(ping_state)	
	return rsp
end

--[[
Set Firewall Settings function
	 1.Modify Firewall information
	 2.restart damon firewall
Parameters
	WanPortPingState: 0 disable ,1 enable	
Return value:
	String containg the return the output of the command 
]]

function SetFirewallSettings(req)
	local rsp = {}	
	local ping_state = req["WanPortPingState"]                           	 --etc/config/firewall

	if ping_state == nil then
		errs = {code=7, message="Bad parameter"}
		return nil, errs
	end	

	ret = common.SetValue("firewall", "wanping", "enabled", ping_state)          --modify wan ping option value
				
		if ret == false then
				errs = {code=230101, message="Set Firewall Settings failed."}
				return nil, errs
		end

	
	ret = common.SaveFile("firewall")
		if ret == false then
				errs = {code=230101, message="Set Firewall Settings failed."}
				return nil, errs
		end
	ret = common.Exec("/etc/init.d/firewall restart")     -- restart firewall 
	if ret == false then
				errs = {code=230101, message="Set Firewall Settings failed."}
				return nil, errs
		end
	return luci.json.null
	
end
