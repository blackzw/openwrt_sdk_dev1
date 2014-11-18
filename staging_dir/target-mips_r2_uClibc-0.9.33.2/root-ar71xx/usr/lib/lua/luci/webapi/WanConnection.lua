module("luci.webapi.WanConnection", package.seeall)
local common = require('luci.webapi.common')
-- Connie add start, 2014/6/19
local util    = require('luci.webapi.Util')
local profile = require('luci.webapi.Profile')
-- Connie add end, 2014/6/19

--[[ 
Request data: {}
Response data:
@Rsp param "ConnectionStatus":2,
@Rsp param "ConnectProfile":"China Unicom",
@Rsp param "UlRate":300,
@Rsp param "DlRate":400,
@Rsp param "UlBytes":10000,
@Rsp param "DlBytes":67890,
@Rsp param "IPv4Address":"10.168.1.12",
@Rsp param "IPv6Address":"fe80::7646:a0ff:feaa:ed9",
@Rsp param "ConnectionTime":600
]]
function GetConnectionState(req)
	--common.LoadRildClientLibrary()
	ret_code, ril_res = rild_client.get_wan_connection_info()
	if ret_code == 0 then
		res = {}
		res["ConnectionStatus"] = ril_res["nState"]
		res["ConnectProfile"] = ril_res["strProfileName"]
		res["UlRate"] = ril_res["nSendSpeed"]
		res["DlRate"] = ril_res["nRecvSpeed"]
		res["UlBytes"] = tonumber(ril_res["nSendBytes"])
		res["DlBytes"] = tonumber(ril_res["nRecvBytes"])
		res["IPv4Address"] = ril_res["strIPv4Addr"]
		res["IPv6Address"] = ril_res["strIPv6Addr"]
		res["ConnectionTime"] = ril_res["nDuration"]
		return res
	else
		errs = common.GetCommonErrorObject(ret_code)
		if errs == nil then
			errs = {code=80101, message="Get connection state failed."}
		end
		return nil, errs
	end
end


-- Connie add start, 2014/6/25
--[[ 
Request data: {}
Response data: {}
]]
function InformAfterConnected()	
	rild_client_lib = assert(package.loadlib("/usr/lib/librild_client.so", "luaopen_rild_client"))
	rild_client_lib()

	ret_code, ril_res = rild_client.get_wan_connection_info()
	if ret_code == 0 then
		local status = "Connected"
		
		if ril_res["nState"] == 0 then
			status = "Disconnected"
		elseif ril_res["nState"] == 1 then
			status = "Connecting"
		elseif ril_res["nState"] == 2 then
			status = "Connected"
		elseif ril_res["nState"] == 3 then
			status = "Disconnecting"
		end

		if status == "Connected" then
			util.InformValueChanged("InternetGatewayDevice.WANDevice.1.WANConnectionDevice.1.WANIPConnection.",1,"ConnectionStatus",status,"xsd:string")
			util.InformValueChanged("InternetGatewayDevice.WANDevice.1.WANConnectionDevice.1.WANIPConnection.",1,"ExternalIPAddress",ril_res["strIPv4Addr"],"xsd:string")

			local profilename = ril_res["strProfileName"]
			local profilelist = profile.GetProfileList()
			if profilelist ~= nil then
				for i=1,table.getn(profilelist) do
					if profilename == profilelist[i]["strProfileName"] then     
						util.InformValueChanged("InternetGatewayDevice.WANDevice.1.WANConnectionDevice.1.WANPPPConnection.", 1, "Username", profilelist[i]["strUserName"], "xsd:string")
						util.InformValueChanged("InternetGatewayDevice.WANDevice.1.WANConnectionDevice.1.WANPPPConnection.", 1, "Password", profilelist[i]["strPasswd"],   "xsd:string")
					end
				end            
			end
			print("done")
		else
			print("none")
		end
	else
		print("none")
	end
end
-- Connie add start, 2014/6/25


--[[ 
Request data: {}
Response data: {}
]]
function Connect(req)	
	--common.LoadConnectManagerClient()
	ret_code = rild_client.connect_wan()
	if ret_code == 0 then
		-- Connie add start, 2014/6/25
		luci.sys.call("/usr/share/easycwmp/oem/inform_later > /dev/null 2>&1 &")
		-- Connie add end, 2014/6/25
		return luci.json.null
	else
		errs = common.GetCommonErrorObject(ret_code)
		if errs == nil then
			errs = {code=80201, message="Connect failed."}
		end
		return nil, errs
	end
end

--[[ 
Request data: {}
Response data: {}
]]
function DisConnect(req)
	--common.LoadConnectManagerClient()
	connect_manager_client.set_disconnect_state("1")
	ret_code = rild_client.disconnect_wan()
	if ret_code == 0 then
		return luci.json.null
	else
		errs = common.GetCommonErrorObject(ret_code)
		if errs == nil then
			errs = {code=80301, message="Disconnect failed."}
		end
		return nil, errs
	end
end

--[[ 
Request data: {}
Response data: 
@Rsp param "IdleTime":500,
@Rsp param "RoamingConnect":0,
@Rsp param "ConnectMode":1
]]
function GetConnectionSettings(req)
        --common.LoadConnectManagerClient()
	ret_code, response = connect_manager_client.get_connection_settings()
	if ret_code == 0 then
                res = {}
                res["IdleTime"] = response["IdleTime"]
                res["RoamingConnect"] = response["RoamingConnect"]
                res["ConnectMode"] = response["ConnectMode"]
		return res
	else
		errs = common.GetCommonErrorObjectForStatistics(ret_code)
		if errs == nil then
			errs = {code=80401, message="Get connection settings failed"}
		end
		return nil, errs
	end
end

--[[ 
Request data:
@Req param "IdleTime":500,
@Req param "RoamingConnect":0,
@Req param "ConnectMode":1

Response data: {}
]]
function SetConnectionSettings(req)
        --common.LoadConnectManagerClient()
	local idleTime = req["IdleTime"]
        local roaming = req["RoamingConnect"]
	local connectMode = req["ConnectMode"]
        if idleTime == nil or roaming == nil or connectMode == nil then
		return nil, {code=7, message="Bad parameter for rild."}
	end
	ret_code, response = connect_manager_client.set_connection_settings(idleTime, roaming, connectMode)
	if ret_code == 0 then
		return luci.json.null
	else
		errs = common.GetCommonErrorObjectForStatistics(ret_code)
		if errs == nil then
			errs = {code=80501, message="Set connection settings failed"}
		end
		return nil, errs
	end
end


--[[ 
Request data: {}
Response data: 
@Rsp param "nPdpType":0
]]
function GetConnectionType(req)
	--common.LoadRildClientLibrary()
	ret_code, ril_res = rild_client.get_connection_type()
	if ret_code == 0 then
		res = {}
		res["nPdpType"] = ril_res["nPdpType"]		
		return res
	else
		errs = common.GetCommonErrorObject(ret_code)
		if errs == nil then
			errs = {code=80601, message="Get connection type failed."}
		end
		return nil, errs
	end
end

--[[ 
Request data:
@Req param "nPdpType":1
Response data: {}
]]
function SetConnectionType(req)
	local nType = req["nPdpType"]
	if nType == nil then
		errs = common.GetCommonErrorObject(common.ReturnCode.RILD_ERRID_BAD_PARAMETER)
		return nil, errs
	else
		--common.LoadRildClientLibrary()
		local ret_code, rsp = rild_client.set_connection_type(nType)
		if ret_code == 0 then
			return luci.json.null
		end
		errs = common.GetCommonErrorObject(ret_code)
		if errs == nil then
			errs = {code=80701, message="Set connection type failed."}
		end
		return nil, errs
	end
end


