module("luci.webapi.UPnP", package.seeall)

local common = require('luci.webapi.Util')

--[[
get UPnP settings information
Parameters
	UPnPStatus: 0 disable ,1 enable	
Return value:
	String containg the return the output of the command 
]]
function GetUPnPSettings()
	local rsp = {}	
	local upnp_status = common.GetValue("upnpd","config","enable_upnp")              --etc/config/upnpd

	if upnp_status == nil then
		errs = {code=180101, message="Get upnp config info failed"}
		return nil, errs
	end	

    rsp["UPnPStatus"] = tonumber(upnp_status)	
	return rsp
end

--[[
SetUPnPSettings function
	 1.Modify UPnP information
	 2.restart damon firewall
Parameters
	UPnPStatus: 0 disable ,1 enable	
Return value:
	String containg the return the output of the command 
]]

function SetUPnPSettings(req)
	local rsp = {}	
	local upnp_status = req["UPnPStatus"]                           	 --etc/config/upnpd

	if upnp_status == nil then
		errs = {code=7, message="Bad parameter"}
		return nil, errs
	end	
    local ori_upnp_status = common.GetValue("upnpd","config","enable_upnp") -- Connie add, 20140710
	ret = common.SetValue("upnpd", "config", "enable_upnp", upnp_status)          --modify upnpd option value
				
		if ret == false then
				errs = {code=180201, message="Set upnp config info failed"}
				return nil, errs
		end

	if ori_upnp_status ~= upnp_status then
		local Status = "Disabled"
		if upnp_status == 0 or upnp_status == "0" then
			Status = "Disabled"
		else
			Status = "Enabled"
		end
		common.InformValueChangedWithoutIndex("InternetGatewayDevice.Services.X_ALU_UPNP.","Status",Status,"xsd:string")
	end
	ret = common.SaveFile("upnpd")
		if ret == false then
				errs = {code=180201, message="Set upnp config info failed"}
				return nil, errs
		end
	ret = common.Exec("/etc/init.d/miniupnpd restart")     -- restart upnpd 
	if ret == false then
				errs = {code=180201, message="Set upnp config info failed"}
				return nil, errs
		end
	return luci.json.null
	
end
