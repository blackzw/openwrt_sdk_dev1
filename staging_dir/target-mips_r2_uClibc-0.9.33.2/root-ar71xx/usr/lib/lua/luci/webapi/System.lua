module("luci.webapi.System", package.seeall)

require("luci.sys.zoneinfo")
require("luci.sys")
local fs = require("luci.fs")
local common = require('luci.webapi.common')
local util = require('luci.util')
local util2 = require('luci.webapi.Util') -- Connie add, 2014/6/19
local uci = require('luci.model.uci').cursor()


--config file /etc/config/webs_cfg
function GetWebCfg()
	local rsp = {}
	rsp["Manufacturer"] = util.trim(uci:get("webs_cfg", "system", "Manufacturer"))
	rsp["Model"] = util.trim(uci:get("webs_cfg", "system", "Model"))
	rsp["DeviceName"] = util.trim(uci:get("webs_cfg", "system", "DeviceName"))
	rsp["HwVersion"] = util.trim(uci:get("webs_cfg", "system", "HwVersion"))
	rsp["SwVersion"] = util.trim(uci:get("webs_cfg", "system", "SwVersion"))
	rsp["HttpApiVersion"] = util.trim(uci:get("webs_cfg", "system", "HttpApiVersion"))
	rsp["WebUiVersion"] = util.trim(uci:get("webs_cfg", "system", "WebUiVersion"))
	return rsp
end


--[[ Response data:
@Rsp param  "Manufacturer":"JRD",
@Rsp param  "DeviceName":"H850",
@Rsp param	"Model":" K1234 ",
@Rsp param	"IMEI":"123456789012",
@Rsp param	"HwVersion":"ABCD",
@Rsp param	"SwVersion":"",
@Rsp param	"HttpApiVersion":"1.0",
@Rsp param  "WebUiVersion":"",
]]
function GetSystemInfo(req)
	local rsp = {}
	local ret_code, sys_info = rild_client.get_system_equipment_info()
	
	--get equipment error 
	if ret_code ~= 0 then 
		errs = common.GetCommonErrorObject(ret_code)
		if errs == nil then
			errs = {code=20101, message="Get items failed"}
		end
		return errs
	end 
	rsp = GetWebCfg()
	if rsp == nil then
		errs = {code=20101, message="Get items failed"}
	end
	rsp["IMEI"] = sys_info.strSerialNumber -- strCommercialSerialNumber
	rsp["ModuleExtVersion"] = sys_info.strExternalVersion
	rsp["MacAddress"] = util.trim(luci.util.exec("ifconfig eth0|grep eth0|awk '{print $5}'")) -- mac address
	return rsp
	
end

function GetLanguage(req)
	local rsp = {}
	local list = {}
	local lan = uci:get("luci", "main", "lang")
	if lan == nil then
		errs = {code=20301, message="Get current language setting fail"}
		return nil, errs
	end
	rsp["Language"] = lan     --current language
	-- get languages list 
	local i18ndir = luci.util.libpath() .. "/i18n/" .. "base."
	local r4 = luci.model.uci.cursor():get_all("luci", "languages")--luci.config.languages
	for k, v in luci.util.kspairs(r4) do
		local file = i18ndir .. k:gsub("_", "-")
		if k:sub(1, 1) ~= "." and luci.fs.access(file .. ".lmo") then
			list[k]=v				
		end
	end
	rsp["LanguageList"] = list
	return rsp
end

function SetLanguage(req)
	local value = req["Language"]
	if value == nil then
		errs = {code=7, message="Bad parameter"}
		return nil, errs
	end
	local bture = uci:set("luci", "main", "lang", value) and uci:commit("luci")
	if bture then
		return luci.json.null
	else
		errs = {code=20201, message="Set current language setting fail"}
		return nil, errs
	end
	
end
	
function SetCurrentTime(req)
	local value = req["TimeZone"]
	--local curr_time = req["CurrentTime"]
	if value == nil then
			errs = {code=7, message="Bad parameter"}
			return nil, errs
	end
	local function lookup_zone(value)            -- get zone info
		for _, zone in ipairs(luci.sys.zoneinfo.TZ) do
			if zone[1] == value then 
				return zone[2] 
			end
		end
	end
	local timezone = lookup_zone(value) or "GMT0" 
	-- Connie add start, 2014/6/23
	local ori_tz = uci:get("system", "cfg02e48a", "timezone")
	local ori_zn = uci:get("system", "cfg02e48a", "zonename")
	-- Connie add start, 2014/6/23
	uci:set("system", "cfg02e48a", "zonename", value)
	local bture = uci:set("system", "cfg02e48a", "timezone", timezone) and uci:commit("system") --cfg02e48a section maybe error
	if bture then
		fs.writefile("/etc/TZ", timezone .. "\n")
		luci.util.exec("date -k") 
		-- Connie add start, 2014/6/19
		if ori_tz ~= timezone then
			util2.InformValueChangedWithoutIndex("InternetGatewayDevice.Time.","LocalTimeZone",timezone,"xsd:string")
		end
		if ori_zn ~= value then
			util2.InformValueChangedWithoutIndex("InternetGatewayDevice.Time.","LocalTimeZoneName",value,"xsd:string")
		end
		-- Connie add end, 2014/6/19
		return luci.json.null
	else
		errs = {code=20401, message="Set time zone fail"}
		return nil, errs
	end
	
	-- set time 
	--luci.http.protocol.date.tz_offset(timezone)
	--[[if curr_time ~= nil then
		local _time = string.gsub(curr_time, " ","-", 1)
		util.trim(luci.util.exec("date -s ".._time))
	end--]]

end

function GetCurrentTime(req)
	local rsp = {}
	local list = {}
	local time_date = os.date("%Y-%m-%d", os.time())--luci.http.protocol.date.to_unix("2014.3.26 10:07:00")
	local times = os.date("%H:%M:%S", os.time())
	rsp["CurrTime"] = time_date.." "..times
	local tz = uci:get("system", "cfg02e48a", "timezone")   --cfg02e48a section maybe error
	local zn = uci:get("system", "cfg02e48a", "zonename")   --cfg02e48a section maybe error	
       
	if tz == nil then
		tz = ""
	end
	if zn == nil then
		zn = ""
	end


	rsp["TimeZone"] = tz
	rsp["ZoneName"] = zn
	--timezone list
	for _, zone in ipairs(luci.sys.zoneinfo.TZ) do
			list[zone[1]] = zone[2] 
	end
	if list == nil then
		errs = {code=20501, message="Get current time fail"}
		return nil, errs
	end
	rsp["TimeZoneList"] = list

	return rsp
end

function GetFeatureList(req)
	local rsp = {}
	rsp["Model"] = util.trim(uci:get("webs_cfg", "system", "Model"))
	rsp["HttpApiVersion"] = util.trim(uci:get("webs_cfg", "system", "HttpApiVersion"))
	local system = {"GetSystemInfo", "GetLanguage", "SetLanguage", "SetCurrentTime", "GetCurrentTime", "GetFeatureList", "GetExternalStorageDevice"}
	local sms = {"GetSmsList", "DeleteSms", "SendSms", "ModifySmsReadStatus", "GetSendSmsResult", "SaveSms", "GetSmsSettings", "SetSmsSettings", "GetSmsStorageState", "GetSmsCount"}
	local sim = {"GetSimStatus", "UnlockPin", "UnlockPuk", "ChangePin", "ChangePinState", "GetAutoEnterPinState", "SetAutoEnterPinState", "UnlockSimlock"}
	local user = {"Login", "GetLoginState", "Logout", "ChangePassword"}
	local network = {"GetNetworkInfo", "SearchNetwork", "SearchNetworkResult", "RegisterNetwork", "GetNetworkRegisterState", "GetNetworkSettings", "SetNetworkSettings"}
	local wlan = {"GetWlanState", "SetWlanState", "GetWlanSettings", "SetWlanSettings", "GetWlanStatistics", "GetNumOfHosts", "GetWlanHostList", "GetWpsState", "GetWpsSettings", "SetWpsSettings"}
	local statistics = {"GetUsageHistory", "GetBillingDay", "SetBillingDay", "GetCalibrationValue", "SetCalibrationValue", "GetLimitValue", "SetLimitValue", 
						"GetTotalValue", "SetTotalValue", "GetUsageSettings", "GetDevicePushInfo", "SetDevicePushInfo", "DeleteDevicePushInfo", "ClearAllRecords", "SetDisconnectOvertime", 
						"SetDisconnectOvertimeState", "SetDisconnectOverflowState", "GetHistoryStatistics", "SetUsageAlert", "GetCurrentMonthUsage"}
	local wan = {"GetConnectionState", "Connect", "DisConnect", "GetConnectionSettings", "SetConnectionSettings", "GetConnectionType", "SetConnectionType"}	
	local service = {"TR069.SetClientConfiguration", "TR069.GetClientConfiguration", "SetServiceState", "GetServiceState", "Samba.GetSettings", "Samba.SetSettings", "DLNA.GetSettings", "DLNA.SetSettings", "FTP.GetSettings", "FTP.SetSettings"}
	local calllog = {"GetCallLogList", "DeleteCallLog", "ClearCallLog"}
	local lan = {"GetLanSettings", "SetLanSettings", "GetLanStatistics", "GetLanPortInfo"}
	local feature = {System=system, SMS=sms, SIM=sim, User=user, Network=network, Wlan=wlan, Statistics=statistics, WanConnection=wan, Services=service, CallLog=calllog, LAN=lan}   -- feature list
	rsp["Features"] = feature
	return rsp
end

--[[ Response data:
@Rsp param  "DeviceList":
	[
		{
			"DevType":0,
			"DefPath":"/mnt/sda1"
		},
		{
			"DevType":1,
			"DefPath":"/mnt/nfs"
		}
	]
]]
function GetExternalStorageDevice(req)
	local rsp = {}
	local index = 1	
	rsp["DeviceList"] = {}
				
	if fs.isfile("/tmp/usbstorageavailable") then
		rsp["DeviceList"][index] = {}
		rsp["DeviceList"][index]["DevType"] = 1
		rsp["DeviceList"][index]["DefPath"] = "/mnt/usb"				
		index = index+1	
	end

        --TODO: Get MM100 device here
	if fs.isfile("/tmp/airdiskavailable") then
		rsp["DeviceList"][index] = {}
		rsp["DeviceList"][index]["DevType"] = 0
		rsp["DeviceList"][index]["DefPath"] = "/mnt/airdisk"				
		index = index+1	
	end			

	
	
	return rsp
end


--[[ 
Requst data:
	@Rsp null
Response data:
	@Rsp null
]]

function SetSystemSettings(req)
	local ntp1 = req["NtpServer1"]
	local ntp2 = req["NtpServer2"]
	local anten = req["AntennaSwitch"]
	if ntp1 == nil or ntp2 == nil or anten == nil then
		errs = {code=7, message="Bad parameter"}
		return nil, errs
	end

	-- Connie add start, 2014/6/23
	local ori_ntp = uci:get("system", "ntp", "server")   --ntp section maybe error
	local ori_ntp1 = ""
	local ori_ntp2 = ""
	
	if ori_ntp ~= nil and ori_ntp ~= "" then
		for i=1,table.getn(ori_ntp) do
			if i == 1 then
				ori_ntp1 = ori_ntp[1]
			end
			if i == 2 then
				ori_ntp2 = ori_ntp[2]
			end
		end
	end
	-- Connie add end, 2014/6/23
	uci:section("system", "timeserver", "ntp",
			{
                	enable_server = 0
	})
	uci:section("system", "timeserver", "ntp",
			{
                	server = { ntp1, ntp2}
			})
	uci:save("system")
	ret = uci:commit("system")
	if ret == false then
		errs = {code=20901, message="Set information fail."}
		return nil, errs
	end
	-- Connie add start, 2014/6/19
	if ori_ntp1 ~= ntp1 then
		util2.InformValueChangedWithoutIndex("InternetGatewayDevice.Time.","NTPServer1",ntp1,"xsd:string")
	end
	if ori_ntp2 ~= ntp2 then
		util2.InformValueChangedWithoutIndex("InternetGatewayDevice.Time.","NTPServer2",ntp2,"xsd:string")
	end
	-- Connie add end, 2014/6/19

	local jrd_switch_antenna_func = assert(package.loadlib("/usr/lib/libjrd_led.so", "luaopen_led_client"))
	jrd_switch_antenna_func()
	if luaopen_led_client == nil then
		errs = {code=20901, message="Set information fail."}
		return nil, errs
	end
	luaopen_led_client.jrd_switch_antenna(anten)
	return luci.json.null
end

--[[ 
Requst data:
	@Rsp null
Response data:
	"AntennaSwitch":0,
	"NtpServer1":"192.168.9.12",
	"NtpServer2":"192.168.9.13",

]]

function GetSystemSettings()
	local ntp2 = ""
	local anten = ""
	local rsp = {}
	local ntp1 = uci:get("system", "ntp", "server")   --ntp section maybe error
	
	if ntp1 == nil or ntp1 == "" then
		errs = {code=20701, message="Get System information fail"}
		return nil, errs
	end
	for i=1,table.getn(ntp1) do
		if i == 1 then
			rsp["NtpServer1"] = ntp1[1]
		end
		if i == 2 then
			rsp["NtpServer2"] = ntp1[2]
		end
	end
	local jrd_switch_antenna_func = assert(package.loadlib("/usr/lib/libjrd_led.so", "luaopen_led_client"))
	jrd_switch_antenna_func()
	if luaopen_led_client == nil then
		errs = {code=20901, message="Get information fail."}
		return nil, errs
	end 

	local state = luaopen_led_client.jrd_get_antenna_status()
	if state == 2 then
		errs = {code=20901, message="Get information fail."}
		return nil, errs
	end
	rsp["AntennaSwitch"] = state
	return rsp
end


--[[ 
Requst data:
	@Rsp null
Response data:
	"NetworkType":1,
	"SignalStrength":1,
	"WlanState":1,
	"ConnectionStatus":1,
	"SmsState":1,
	"UsbState":1
]]

function GetSystemStatus()
	
	local rsp = {}
	local wifistate = 0    --off
	local smssate = 0
	local usbstate = 0
	local ret_nw_info_code, nw_info = rild_client.get_current_network_info()
		--get network info error 
	if ret_nw_info_code ~= 0 then 
--[[		errs = common.GetCommonErrorObject(ret_nw_info_code)
		if errs == nil then
			errs = {code=21001, message="Get system Status fail."}
		end
		return nil, errs--]]
		rsp["NetworkType"] = 0
		rsp["SignalStrength"] = 0
	else
		rsp["NetworkType"] = nw_info.nBearer
		rsp["SignalStrength"] = nw_info.nRssi
	end 
	
	--wifi state
	flags = uci:foreach("wireless", "wifi-iface",
                 function(s)
                   if s[".type"] == "wifi-iface" then  
					state = s["disabled"]
						if state == "0" or state == nil then
							wifistate = 1 		--1 on
							return true
						end
                    end
                 end)
	rsp["WlanState"] = wifistate
	--Connection Status		
	local ret_code, ril_res = rild_client.get_wan_connection_info()	
		if ret_code ~= 0 then 
			--[[errs = common.GetCommonErrorObject(ret_nw_info_code)
			if errs == nil then
				errs = {code=21001, message="Get system Status fail."}
			end
			return nil, errs--]]
			rsp["ConnectionStatus"] = 0
		end 
		if ril_res == nil or ril_res["nState"] == nil or ril_res["nState"] == "" then
			rsp["ConnectionStatus"] = 0
		else
			rsp["ConnectionStatus"] = ril_res["nState"]
		end
		
		--sms state
		local ret_code_sms, response = rild_client.get_sms_list(5, 0)   --all message
		if ret_code_sms == 0 then
			for i=1,table.getn(response.SmsItemList) do
				smssate = 3   --read
				if response.SmsItemList[i]["nTag"] == 1 or response.SmsItemList[i]["nTag"] == "1" then
					smssate = 2   --not read
					break
				end
				
			end
		else
			--[[errs = common.GetCommonErrorObject(ret_code_sms)
			if errs == nil then
				errs = {code=21001, message="Get system Status fail."}
			end
			return nil, errs--]]
		end
		
		
	ret_code_sms, response = rild_client.get_sms_storage_info()
	if ret_code_sms == 0 then
		local used_total = response["SimUsed"] + response["DeviceUsed"]
		local total = response["SimTotal"] + response["DeviceTotal"]
		if total == used_total then
			smssate = 1   --device sms full
		end 
	else
		--[[errs = common.GetCommonErrorObject(ret_code_sms)
		if errs == nil then
			errs = {code=21001, message="Get system Status fail."}
		end
		return nil, errs--]]
	end
	rsp["SmsState"] = smssate
	
	-- USB state 
	local m = luci.sys.mounts()
	for i=1, table.getn(m) do
		if m[i]["fs"] ~= nil and m[i]["mountpoint"] ~= nil then
				if luci.util.cmatch(m[i]["fs"], "/dev/sd[a-z][0-9]") > 0 then
					usbstate = 1
					break			
				end	
		end
	end
	rsp["UsbState"] = usbstate
	return rsp
end
