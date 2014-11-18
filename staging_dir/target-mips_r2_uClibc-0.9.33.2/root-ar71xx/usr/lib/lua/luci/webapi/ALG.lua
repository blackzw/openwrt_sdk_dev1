module("luci.webapi.ALG", package.seeall)

local common = require('luci.webapi.Util')

--[[
get ALG settings information
Parameters
	"PptpStatus": "0",
	"H323AlgStatus": "0",
	"SipAlgStatus":"0",
	"SipAlgPort":"5060",
	
	option pptp '1'
	option h323 '1'
	option sip '1'
	option sip_port '5060'
Return value:
	String containg the return the output of the command 
]]
function GetALGSettings()
	local rsp = {}
	local PptpStatus = common.GetValue("alg","alg_switch","pptp")
	local H323AlgStatus = common.GetValue("alg","alg_switch","h323")
	local SipAlgStatus = common.GetValue("alg","alg_switch","sip")
	local SipAlgPort = common.GetValue("alg","alg_switch","sip_port")              --etc/config/alg
	local ftp = common.GetValue("alg","alg_switch","ftp")              --etc/config/alg

	if PptpStatus == nil or H323AlgStatus == nil or SipAlgStatus == nil or SipAlgPort == nil then
		errs = {code=150101, message="Get dmz config info failed"}
		return nil, errs
	end	

    rsp["PptpStatus"] = tonumber(PptpStatus)	
	rsp["H323AlgStatus"] = tonumber(H323AlgStatus)	
	rsp["SipAlgStatus"] = tonumber(SipAlgStatus)	
	rsp["Ftp"] = tonumber(ftp)	
	rsp["SipAlgPort"] = SipAlgPort
	return rsp
end

--[[
SetALGSettings function
	 1.Modify ALG information
	 2.restart damon ALG
Parameters
	"PptpStatus": "0",
	"H323AlgStatus": "0",
	"SipAlgStatus":"0",
	"SipAlgPort":"5060",
	
	option pptp '1'
	option h323 '1'
	option sip '1'
	option sip_port '5060'
Return value:
	String containg the return the output of the command 
]]

function SetALGSettings(req)
	local rsp = {}
	local PptpStatus = req["PptpStatus"]
	local H323AlgStatus = req["H323AlgStatus"]
	local SipAlgStatus = req["SipAlgStatus"]
	local SipAlgPort = req["SipAlgPort"]                           	 --etc/config/alg
	local Ftp = req["Ftp"]

	if PptpStatus == nil or H323AlgStatus == nil or SipAlgStatus == nil or SipAlgPort == nil then
		errs = {code=7, message="Bad parameter"}
		return nil, errs
	end	
--[[	
	local logo = assert(io.open("\\logo.txt","a"))
	logo:write(PptpStatus,"--",H323AlgStatus,"--",SipAlgStatus,"--",SipAlgPort,"\n") 
	logo:close()	
--]]

	-- Connie add start, 20140710
	local ori_SipAlgStatus = common.GetValue("alg","alg_switch","sip")
	local ori_SipAlgPort = common.GetValue("alg","alg_switch","sip_port")
	-- Connie add end, 20140710

	ret = common.SetValue("alg", "alg_switch", "pptp", PptpStatus)          --modify alg option value
	ret = common.SetValue("alg", "alg_switch", "h323", H323AlgStatus) 
	ret = common.SetValue("alg", "alg_switch", "sip", SipAlgStatus) 
	ret = common.SetValue("alg", "alg_switch", "sip_port", SipAlgPort)
	ret = common.SetValue("alg", "alg_switch", "ftp", Ftp)
				
		if ret == false then
				errs = {code=180201, message="Set dmz config info failed"}
				return nil, errs
		end
	-- Connie add start, 20140710
	if ori_SipAlgStatus ~= SipAlgStatus then
		local SIPEnable = "false"
		if SipAlgStatus == 0 or SipAlgStatus == "0" then
			SIPEnable = "false"
		else
			SIPEnable = "true"
		end
		common.InformValueChangedWithoutIndex("InternetGatewayDevice.Services.X_ALU_ALGAbility.","SIPEnable",SIPEnable,"xsd:boolean")
	end
	if ori_SipAlgPort ~= SipAlgPort then
		common.InformValueChangedWithoutIndex("InternetGatewayDevice.Services.X_ALU_ALGAbility.","SIPPort",SipAlgPort,"xsd:unsignedInt")
	end
	-- Connie add end, 20140710
	
	ret = common.SaveFile("alg")
		if ret == false then
				errs = {code=180202, message="Save dmz config info failed"}
				return nil, errs
		end
	ret = common.Exec("/etc/init.d/alg restart")     -- restart alg 
	if ret == false then
				errs = {code=180203, message="Restart dmz config info failed"}
				return nil, errs
		end
	return luci.json.null
	
end
