module("luci.webapi.DMZ", package.seeall)

local common = require('luci.webapi.Util')

--[[
get DMZ settings information
Parameters
	DMZStatus: 0 disable ,1 enable	
	DMZIPAddress: "192.168.1.2",
Return value:
	String containg the return the output of the command 
]]
function GetDMZSettings()
	local rsp = {}
	local dmz_ip = common.GetValue("dmz","dmz","dest_ip")
	local dmz_status = common.GetValue("dmz","dmz","enable")              --etc/config/dmz

	if dmz_ip == nil or dmz_status == nil then
		errs = {code=180101, message="Get dmz config info failed"}
		return nil, errs
	end	

    rsp["DMZStatus"] = tonumber(dmz_status)	
	rsp["DMZIPAddress"] = dmz_ip
	return rsp
end

--[[
SetDMZSettings function
	 1.Modify DMZ information
	 2.restart damon firewall
Parameters
	DMZStatus: 0 disable ,1 enable	
	DMZIPAddress: "192.168.1.2",
Return value:
	String containg the return the output of the command 
]]

function SetDMZSettings(req)
	local rsp = {}
	local dmz_ip = req["DMZIPAddress"]
	local dmz_status = req["DMZStatus"]                           	 --etc/config/dmz

	if dmz_ip == nil or dmz_status == nil then
		errs = {code=7, message="Bad parameter"}
		return nil, errs
	end	

	ret = common.SetValue("dmz", "dmz", "dest_ip", dmz_ip)          --modify dmz option value
	ret = common.SetValue("dmz", "dmz", "enable", dmz_status)
				
		if ret == false then
				errs = {code=180201, message="Set dmz config info failed"}
				return nil, errs
		end

	
	ret = common.SaveFile("dmz")
		if ret == false then
				errs = {code=180201, message="Set dmz config info failed"}
				return nil, errs
		end
	ret = common.Exec("/etc/init.d/firewall restart")     -- restart dmz 
	if ret == false then
				errs = {code=180201, message="Set dmz config info failed"}
				return nil, errs
		end
	return luci.json.null
	
end
