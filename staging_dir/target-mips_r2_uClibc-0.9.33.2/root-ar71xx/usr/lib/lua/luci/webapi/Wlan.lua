module("luci.webapi.Wlan", package.seeall)

local common = require('luci.webapi.Util')
local uci = require("luci.model.uci").cursor()

--[[
get wifi state 
Parameters
	
responose value:
	State: 0 off ,1 on
]]
function GetWlanState()
	local rsp = {}
	local state
	rsp["State"] = 0		--0 off
	flags = uci:foreach("wireless", "wifi-iface",
                 function(s)
                   if s[".type"] == "wifi-iface" then  
					state = s["disabled"]
						if state == "0" or state == nil then
							rsp["State"] = 1 		--1 on
							return  true
						end
                    end
                 end)
	return rsp
end

--[[
set wifi off 
Parameters
	null
responose value:
	: off 1 
]]
function SetWlanOff()
	flags = uci:foreach("wireless", "wifi-iface",
                 function(s)
                   if s[".type"] == "wifi-iface" then  
						common.SetValue("wireless", s[".name"], "disabled", 1)  --off all ssid
                    end
                 end)
	ret = common.SaveFile("wireless")
	if ret == false then 
		errs = {code=50101, message="Set WLAN off failed"}
		return nil, errs
	end
	luci.util.exec("/sbin/restart_wifi &")	 
	return luci.json.null
end

--[[
Get Country List 
Parameters
	null
responose value:
	[{"ccode":"AD",
	"alpha2":"AD",
	"name":" Andorra"},
	...]
	
]]
function GetCountryList()
	local rsp = {}
	local iw = luci.sys.wifi.getiwinfo("radio0.network0")
	if iw == nil then
		for i = 1, 10 do
			local net = "radio0.network"..i
			iw = luci.sys.wifi.getiwinfo(net)
			if iw ~= nil then
				break
			end
		end
	end		
	local cl = iw and iw.countrylist
	rsp = cl
	return rsp
end


--[[
Get channel List 
Parameters
	null
responose value:
	[{"restricted":false,
	"mhz":2412,
	"channel":1
	},бн]
]]
function GetChannelList()
	local rsp = {}
	local iw = luci.sys.wifi.getiwinfo("radio0.network0")
	if iw == nil then
		for i = 1, 10 do
			local net = "radio0.network"..i
			iw = luci.sys.wifi.getiwinfo(net)
			if iw ~= nil then
				break
			end
		end
	end	
	local fc = iw and iw.freqlist
	rsp["Auto2.4g"] = "auto-2.4G"
	rsp["Auto5g"] = "auto-5G"
	rsp["ChannelList"] = fc
	return rsp
end


--[[
get wifi info 
Parameters
	null
responose value:
	"WlanFrequency":1,
	"Ssid5G":"",
	"Ssid":"",
	"SsidHidden5G":1,
	"SsidHidden":1,
	"CountryCode":"it",
	"SecurityMode":1,
	"WpaType ":1,
	"WpaKey ":"",
	"WepType ":1,
	"WepKey":"",
	"Channel":5,
	"ApIsolation5G":1,
	"ApIsolation":1,
	"Bandwidth":1
	"WMode":1,
	"MacAddress":""
]]
function GetWlanSettings()
	local rsp = {}
	local state = GetWlanState()["State"]
	local fixed = false
	local wifilist = common.GetValueList("wireless", "wifi-iface")   --etc/config/wireless
	local en_type = 0
	if wifilist ~= nil then
		for i=1,table.getn(wifilist.valuelist) do
			if wifilist.valuelist[i]["fixed"] == 1 or wifilist.valuelist[i]["fixed"] == "1" then
				fixed = true
			else
				fixed = false
			end
			if fixed == false then
				--encryption Security Mode
				if wifilist.valuelist[i]["wep_key"] == "" or wifilist.valuelist[i]["wep_key"] == nil then
						rsp["WepKey"] = ""
				else
						rsp["WepKey"] = wifilist.valuelist[i]["wep_key"]	
				end
				--rsp["WepKey1"] = wifilist.valuelist[i]["key1"]				--wep key
				--rsp["WepKey2"] = wifilist.valuelist[i]["key2"]
				--rsp["WepKey3"] = wifilist.valuelist[i]["key3"]
				--rsp["WepKey4"] = wifilist.valuelist[i]["key4"]
				if wifilist.valuelist[i]["wpa_key"] == "" or wifilist.valuelist[i]["wpa_key"] == nil then
						rsp["WpaKey"] = ""
				else
						rsp["WpaKey"] = wifilist.valuelist[i]["wpa_key"]	
				end
				--wpa key
				--2.4G
				if wifilist.valuelist[i]["band"] == "2.4" then
						
					if wifilist.valuelist[i]["ssid"] == nil or wifilist.valuelist[i]["ssid"] == "" then
						rsp["Ssid"] = ""
						else
						rsp["Ssid"] = wifilist.valuelist[i]["ssid"]
					end
					
					if wifilist.valuelist[i]["hidden"] == "1" then
						rsp["SsidHidden"] = 1					--enable	
					else
						rsp["SsidHidden"] = 0					-- disable
					end
					if wifilist.valuelist[i]["isolate"] == "" or wifilist.valuelist[i]["isolate"] == nil then
						rsp["ApIsolation"] = 0
						else
						rsp["ApIsolation"] = tonumber(wifilist.valuelist[i]["isolate"])  --0:disable 1:enable
					end
					
					--rsp["WpaKey"] = wifilist.valuelist[i]["key"]  --encryption key
				end
				
				rsp["WepType"] = 0	
				rsp["WpaType"] = 2			--auto
				
				if wifilist.valuelist[i]["encryption"] == "none" then
					en_type = 0
					rsp["SecurityMode"] = 0			--disable
				elseif wifilist.valuelist[i]["encryption"] == "wep-open" then
					en_type = 1
					rsp["SecurityMode"] = 1					--wep
					rsp["WepType"] = 0					--wep open
				elseif wifilist.valuelist[i]["encryption"] == "wep-shared" then
					en_type = 1
					rsp["SecurityMode"] = 1					--wep
					rsp["WepType"] = 1					--wep share
				elseif wifilist.valuelist[i]["encryption"] == "psk" then
					en_type = 2
					rsp["SecurityMode"] = 2					--wpa psk
					rsp["WpaType"] = 2					--wpa-psk auto
				elseif wifilist.valuelist[i]["encryption"] == "psk+ccmp" then
					en_type = 2
					rsp["SecurityMode"] = 2					--wpa psk
					rsp["WpaType"] = 1					--wpa-psk aes
				elseif wifilist.valuelist[i]["encryption"] == "psk+tkip" then
					en_type = 2
					rsp["SecurityMode"] = 2					--wpa psk
					rsp["WpaType"] = 0					--wpa-psk tkip
				elseif wifilist.valuelist[i]["encryption"] == "psk+tkip+ccmp" then
					en_type = 2
					rsp["SecurityMode"] = 2					--wpa psk
					rsp["WpaType"] = 3					--wpa-psk tkip and aes
				elseif wifilist.valuelist[i]["encryption"] == "psk2" then
					en_type = 2
					rsp["SecurityMode"] = 3					--wpa2 psk
					rsp["WpaType"] = 2					--wpa2-psk auto
				elseif wifilist.valuelist[i]["encryption"] == "psk2+ccmp" then
					en_type = 2
					rsp["SecurityMode"] = 3					--wpa2 psk
					rsp["WpaType"] = 1					--wpa2-psk aes
				elseif wifilist.valuelist[i]["encryption"] == "psk2+tkip" then
					en_type = 2
					rsp["SecurityMode"] = 3					--wpa2 psk
					rsp["WpaType"] = 0					--wpa2-psk tkip
				elseif wifilist.valuelist[i]["encryption"] == "psk2+tkip+ccmp" then
					en_type = 2
					rsp["SecurityMode"] = 3					--wpa2 psk
					rsp["WpaType"] = 3					--wpa2-psk tkip and aes
				elseif wifilist.valuelist[i]["encryption"] == "psk+mixed" then
					en_type = 2
					rsp["SecurityMode"] = 4				--wpa2+wpa psk
					rsp["WpaType"] = 2					--wpa2+wpa psk auto
				elseif wifilist.valuelist[i]["encryption"] == "psk+mixed+ccmp" then
					en_type = 2
					rsp["SecurityMode"] = 4				--wpa2+wpa psk
					rsp["WpaType"] = 1					--wpa2+wpa psk aes
				elseif wifilist.valuelist[i]["encryption"] == "psk+mixed+tkip" then
					en_type = 2
					rsp["SecurityMode"] = 4				--wpa2+wpa psk
					rsp["WpaType"] = 0					--wpa2+wpa psk tkip
				elseif wifilist.valuelist[i]["encryption"] == "psk+mixed+tkip+ccmp" then
					en_type = 2
					rsp["SecurityMode"] = 4				--wpa2+wpa psk
					rsp["WpaType"] = 3					--wpa2+wpa psk tkip and aes
				else
					en_type = 0
					rsp["SecurityMode"] = 0				
					rsp["WpaType"] = 0	
					rsp["WepType"] = 0					
				end
				--5G
				if wifilist.valuelist[i]["band"] == "5" then
					if wifilist.valuelist[i]["ssid"] == "" or wifilist.valuelist[i]["ssid"] == nil then
						rsp["Ssid5G"] = ""
						else
						rsp["Ssid5G"] = wifilist.valuelist[i]["ssid"]	
					end
					
					if wifilist.valuelist[i]["hidden"] == "1" then
						rsp["SsidHidden5G"] = 1					--enable	
					else
						rsp["SsidHidden5G"] = 0					-- disable
					end
					if wifilist.valuelist[i]["isolate"] == "" or wifilist.valuelist[i]["isolate"] == nil then
						rsp["ApIsolation5G"] = ""
						else
						rsp["ApIsolation5G"] = tonumber(wifilist.valuelist[i]["isolate"])  --0:disable 1:enable
					end
					
				end
				--[[if 0 == en_type then
					rsp["WpaKey"] = ""
					rsp["WepKey"] = ""
				end
				if 1 == en_type then
					rsp["WpaKey"] = ""
				end
				if 2 == en_type then
					rsp["WepKey"] = ""
				end
				]]--
			end
		end
	end
	local bandwidth = common.GetValue("wireless", "radio0", "htmode")   --htmode
	if bandwidth == "HT20" then
		rsp["Bandwidth"] = 0    --20M
	elseif bandwidth == "HT40-" then
		rsp["Bandwidth"] = 1    --40 below M
	elseif  bandwidth == "HT40+" then
		rsp["Bandwidth"] = 2    --40+ aboveM
	end 
	if common.GetValue("wireless", "radio0", "country") == nil or common.GetValue("wireless", "radio0", "country") == "" then
		rsp["CountryCode"] = "US"
	else
		rsp["CountryCode"] = common.GetValue("wireless", "radio0", "country")
	end
	
	local cl = common.GetValue("wireless", "radio0", "channel")
	rsp["Channel"] = cl
	if cl == "auto-2.4G" then
			rsp["WlanFrequency"] = 1       -- 2.4 G
			rsp["Channel"] = -1  --auto-2.4G
	elseif cl == "auto-5G" then
			rsp["WlanFrequency"] = 2       -- 5 G
			rsp["Channel"] = -2  --auto-5G
	else
			local cll = tonumber(cl)
			if cll > 14 then		--5G bigger then 14 
				rsp["WlanFrequency"] = 2       -- 5 G
			else
				rsp["WlanFrequency"] = 1       -- 2.4 G
			end
			
	end
	
	local cl2g = common.GetValue("wireless", "radio0", "24g_channel")
	local cl5g = common.GetValue("wireless", "radio0", "5g_channel")
	if cl2g == "auto-2.4G" or cl2g == nil then
		rsp["Channel2g"] = -1  --auto-2.4G
	else 
		rsp["Channel2g"] = cl2g
	end
	
	if cl5g == "auto-5G" or cl5g == nil then
		rsp["Channel5g"] = -2  --- 5 G
	else 
		rsp["Channel5g"] = cl5g
	end
	
	if state == 0 or state == "0" then
		rsp["WlanFrequency"] = 0       -- off
	end
	function getWMode(hwmode)
		local wmode = 0	
        if hwmode == nil or hwmode == "" then
			wmode = 0    --auto
		elseif hwmode == "11a" then
			wmode = 1    --802.11a
		elseif hwmode == "11b" then
			wmode = 2    --802.11b
		elseif hwmode == "11g" then
			wmode = 3    -- 802.11g
		elseif hwmode == "11na" then
			wmode = 4    --802.11a+n
		elseif hwmode == "11ng" then
			wmode = 5    --802.11g+n
		end
		return wmode	
	end
	
	local hwmode = common.GetValue("wireless", "radio0", "hwmode")   --hwmode
	rsp["WMode"] = getWMode(hwmode)
	local hwmode2g = common.GetValue("wireless", "radio0", "24g_hwmode")   --hwmode
	local hwmode5g = common.GetValue("wireless", "radio0", "5g_hwmode")   --hwmode
	
	if hwmode2g == nil or hwmode2g == "" then
		rsp["WMode2g"] = 5 --802.11g+n
	else
		rsp["WMode2g"] = getWMode(hwmode2g)
	end
	
	if hwmode5g == nil or hwmode5g == "" then
		rsp["WMode5g"] = 4 --802.11a+n
	else
		rsp["WMode5g"] = getWMode(hwmode5g)
	end
	
	
	--local netm = require "luci.model.network".init()
	--local net = netm:get_network("wan")
	--local device = net and net:get_interface()
	--if device then
		--device:mac()
	--end
	rsp["MacAddress"] =  luci.util.trim(luci.util.exec("ifconfig wlan0|grep wlan0|awk '{print $5}'")) -- mac address
	return rsp
end

--[[
set wifi info 
Parameters
	"WlanFrequency":1,
	"Ssid5G":"",
	"Ssid":"",
	"SsidHidden5G":1,
	"SsidHidden":1,
	"CountryCode":"it",
	"SecurityMode":1,
	"WpaType ":1,
	"WpaKey ":"",
	"WepType ":1,
	"WepKey":"",
	"Channel":5,
	"ApIsolation5G":1,
	"ApIsolation":1,
	"Bandwidth":1
	"WMode":1,

responose value:
	luci.json.null
]]
function SetWlanSettings(req)
	local wifiItem_2 = {}		--2.4G
	local wifiItem_5 = {}		--5G
	local WlanFrequency = req["WlanFrequency"]
	local Ssid5G = req["Ssid5G"]
	local Ssid = req["Ssid"]
	local SsidHidden5G = req["SsidHidden5G"]
	local SsidHidden = req["SsidHidden"]
	local CountryCode = req["CountryCode"]
	local SecurityMode = req["SecurityMode"]
	local WpaType = req["WpaType"]
	local WpaKey = req["WpaKey"]
	local WepType = req["WepType"]
	local WepKey = req["WepKey"]
	local Channel = req["Channel"]
	local ApIsolation5G = req["ApIsolation5G"]
	local ApIsolation = req["ApIsolation"]
	local Bandwidth = req["Bandwidth"]
	local WMode = req["WMode"]
	local htmode = "HT20" 
	local hwmode = ""
	if WlanFrequency == nil or Ssid5G == nil or Ssid == nil or SsidHidden5G == nil or SsidHidden == nil or CountryCode == nil or SecurityMode == nil then
		errs = {code=7, message="Bad parameter"}
		return nil, errs
	end 
	if WpaType == nil or WpaKey == nil or WepType == nil or WepKey == nil or Channel == nil or ApIsolation5G == nil or ApIsolation == nil then
		errs = {code=7, message="Bad parameter"}
		return nil, errs
	end
	if Bandwidth == nil or WMode == nil then
		errs = {code=7, message="Bad parameter"}
		return nil, errs
	end
	if WlanFrequency == 0 then
		errs = {code=50402, message="Must call SetWlanOff function."}
		return nil, errs
	end
	local wps = GetWpsSettings()
	local typeval = "2.4"
	if WlanFrequency == 1 then
		typeval = "2.4"
	end
	if WlanFrequency == 2 then
		typeval = "5"
	end
	
--[[	local ret = common.DeleteWifi(typeval)		 --etc/config/wireless
			
	if ret == false then
		errs = {code=50401, message="Set WLAN Settings failed."}
		return nil, errs
	end--]]
	--2.4G
	wifiItem_2["disabled"] = "1"
	wifiItem_5["disabled"] = "1"
	
	common.SetValue("wireless", "radio0", "current_band", WlanFrequency) --current_band
	if WlanFrequency == 1 then
		wifiItem_2["disabled"] = "0"
	end
	if WlanFrequency == 2 then
		wifiItem_5["disabled"] = "0"
	end
			wifiItem_2["device"] = "radio0"        --name
			wifiItem_5["device"] = "radio0"        --name
			wifiItem_2["band"] = "2.4"        --2.4G
			wifiItem_5["band"] = "5"        --5G
			wifiItem_2["mode"] = "ap"       --ap
			wifiItem_5["mode"] = "ap"       --ap
			wifiItem_2["ssid"] = Ssid
			wifiItem_5["ssid"] = Ssid5G
			wifiItem_2["hidden"] = "0"		--not hidden
			if SsidHidden == "1" or SsidHidden == 1 then
				wifiItem_2["hidden"] = "1"        --hidden
			end
			
			wifiItem_5["hidden"] = "0"        --5G not hidden
			if SsidHidden5G == "1" or SsidHidden5G == 1 then
				wifiItem_5["hidden"] = "1"        --hidden
			end 
			
			wifiItem_2["wep_key"] = WepKey
			wifiItem_5["wep_key"] = WepKey
			wifiItem_2["wpa_key"] = WpaKey
			wifiItem_5["wpa_key"] = WpaKey	
			if SecurityMode == 0 then			--none
				wifiItem_2["encryption"] ="none"
				wifiItem_5["encryption"] ="none"
				wifiItem_2["key"] = "none"
				wifiItem_5["key"] = "none"
				if WepKey ~= nil and WepKey ~= "" then
					wifiItem_2["key"] = WepKey
					wifiItem_5["key"] = WepKey
				end
				if WpaKey ~= nil and WpaKey ~= "" then
					wifiItem_2["key"] = WpaKey
					wifiItem_5["key"] = WpaKey
				end
				
			elseif SecurityMode == 1 and WepType == 0 then 		--wep open
				wifiItem_2["encryption"] ="wep-open"
				wifiItem_2["key"] = WepKey
				wifiItem_5["encryption"] ="wep-open"
				wifiItem_5["key"] = WepKey
			elseif SecurityMode == 1 and WepType == 1 then 		--wep share
				wifiItem_2["encryption"] ="wep-shared"
				wifiItem_2["key"] = WepKey
				wifiItem_5["encryption"] ="wep-shared"
				wifiItem_5["key"] = WepKey
			elseif SecurityMode == 2 and WpaType == 0 then 		--wpa tkip
				wifiItem_2["encryption"] ="psk+tkip"
				wifiItem_2["key"] = WpaKey
				wifiItem_5["encryption"] ="psk+tkip"
				wifiItem_5["key"] = WpaKey
			elseif SecurityMode == 2 and WpaType == 1 then 		--wpa aes
				wifiItem_2["encryption"] ="psk+ccmp"			--
				wifiItem_2["key"] = WpaKey
				wifiItem_5["encryption"] ="psk+ccmp"
				wifiItem_5["key"] = WpaKey
			elseif SecurityMode == 2 and WpaType == 2 then 		--wpa auto
				wifiItem_2["encryption"] ="psk"			--
				wifiItem_2["key"] = WpaKey
				wifiItem_5["encryption"] ="psk"
				wifiItem_5["key"] = WpaKey
			elseif SecurityMode == 3 and WpaType == 2 then 		--wpa2 psk auto
				wifiItem_2["encryption"] ="psk2"			--
				wifiItem_2["key"] = WpaKey
				wifiItem_5["encryption"] ="psk2"
				wifiItem_5["key"] = WpaKey
			elseif SecurityMode == 3 and WpaType == 1 then 		--wpa2 psk aes
				wifiItem_2["encryption"] ="psk2+ccmp"			--
				wifiItem_2["key"] = WpaKey
				wifiItem_5["encryption"] ="psk2+ccmp"
				wifiItem_5["key"] = WpaKey
			elseif SecurityMode == 3 and WpaType == 0 then 		--wpa2 psk tkip
				wifiItem_2["encryption"] ="psk2+tkip"			--
				wifiItem_2["key"] = WpaKey
				wifiItem_5["encryption"] ="psk2+tkip"
				wifiItem_5["key"] = WpaKey
			elseif SecurityMode == 4 and WpaType == 2 then 		--WPA/WPA2 auto
				wifiItem_2["encryption"] ="psk+mixed"			--
				wifiItem_2["key"] = WpaKey
				wifiItem_5["encryption"] ="psk+mixed"
				wifiItem_5["key"] = WpaKey
			elseif SecurityMode == 4 and WpaType == 1 then 		--WPA/WPA2 aes
				wifiItem_2["encryption"] ="psk+mixed+ccmp"			--
				wifiItem_2["key"] = WpaKey
				wifiItem_5["encryption"] ="psk+mixed+ccmp"
				wifiItem_5["key"] = WpaKey
			elseif SecurityMode == 4 and WpaType == 0 then 		--WPA/WPA2 tkip
				wifiItem_2["encryption"] ="psk+mixed+tkip"			--
				wifiItem_2["key"] = WpaKey
				wifiItem_5["encryption"] ="psk+mixed+tkip"
				wifiItem_5["key"] = WpaKey
			elseif SecurityMode == 4 and WpaType == 3 then 		--WPA/WPA2 tkip+aes
				wifiItem_2["encryption"] ="psk+mixed+tkip+ccmp"			--
				wifiItem_2["key"] = WpaKey
				wifiItem_5["encryption"] ="psk+mixed+tkip+ccmp"
				wifiItem_5["key"] = WpaKey
			end
			wifiItem_2["isolate"] = ApIsolation	
			wifiItem_5["isolate"] = ApIsolation5G
			if wps["WpsPin"] ~= nil or wps["WpsPin"] ~= "" then
				wifiItem_2["ap_pin"] = wps["WpsPin"]	
				wifiItem_5["ap_pin"] = wps["WpsPin"]
			end
			if wps["WpsMode"] ~= nil or wps["WpsMode"] ~= "" then
				if wps["WpsMode"] == 1 then
					wifiItem_2["wps_pushbutton"] = "1"		--wps pbc 
					wifiItem_2["wps_ap_pin"] = "0"		--wps pin 
					wifiItem_5["wps_pushbutton"] = "1"		--wps pbc 
					wifiItem_5["wps_ap_pin"] = "0"		--wps pin 
				end
				if wps["WpsMode"] == 0 then
					wifiItem_2["wps_ap_pin"] = "1"		--wps pin 
					wifiItem_2["wps_pushbutton"] = "0"		--wps pbc 
					wifiItem_5["wps_ap_pin"] = "1"		--wps pin 
					wifiItem_5["wps_pushbutton"] = "0"		--wps pbc 
				end
			end
			wifiItem_2["network"] = "lan"		--defualt config 
			wifiItem_5["network"] = "lan"		--defualt config 
			wifiItem_2["fixed"] = "0"		--defualt config 
			wifiItem_5["fixed"] = "0"		--defualt config
			--ret = common.AddSection("wireless", "wifi-iface", nil, wifiItem_2)
			ret = common.SetWifiSectionValues("wireless", "wifi-iface", "2.4", wifiItem_2)
			if ret == false then
				errs = {code=180201, message="Set WLAN Settings failed"}
				return nil, errs
			end
			--ret = common.AddSection("wireless", "wifi-iface", nil, wifiItem_5)
			ret = common.SetWifiSectionValues("wireless", "wifi-iface", "5", wifiItem_5)
			if ret == false then
				errs = {code=180201, message="Set WLAN Settings failed"}
				return nil, errs
			end	
			if Bandwidth == 0 then
				htmode = "HT20"
			elseif Bandwidth == 1 then
				htmode = "HT40-"
			elseif Bandwidth == 2 then 
				htmode = "HT40+"
			end
			
			if WMode == 0 then
				hwmode = ""
			elseif WMode == 1 then
				hwmode = "11a"
			elseif WMode == 2 then 
				hwmode = "11b"
			elseif WMode == 3 then 
				hwmode = "11g"
			elseif WMode == 4 then 
				hwmode = "11na"
			elseif WMode == 5 then 
				hwmode = "11ng"
			end
			
			common.SetValue("wireless", "radio0", "country", CountryCode) --country code
			local strchannel = "-1"
			if Channel == "-1" or Channel == -1 then
				strchannel = "auto-2.4G"
			elseif Channel == "-2" or Channel == -2 then
				strchannel = "auto-5G"
			else
				strchannel = Channel
			end
			
			-- Connie add start
			local cl = common.GetValue("wireless", "radio0", "channel")
			local ori_hwmode = common.GetValue("wireless", "radio0", "hwmode")
			-- Connie add end
			common.SetValue("wireless", "radio0", "channel", strchannel) --Channel code
			
			
			common.SetValue("wireless", "radio0", "htmode", htmode) --bandwidth 
			common.SetValue("wireless", "radio0", "hwmode", hwmode) --hwmode
			
			if WlanFrequency == 1 then
				common.SetValue("wireless", "radio0", "24g_channel", strchannel) --2.4g Channel code
				common.SetValue("wireless", "radio0", "24g_hwmode", hwmode) --2.4g hwmode
			elseif WlanFrequency == 2  then
				common.SetValue("wireless", "radio0", "5g_channel", strchannel) --5g Channel code
				common.SetValue("wireless", "radio0", "5g_hwmode", hwmode) --5g hwmode
			end
			
			ret = common.SaveFile("wireless")
			if ret == false then
				errs = {code=180201, message="Set WLAN Settings failed"}
				return nil, errs
			end	
			--Connie add start
			local index = 1
			flags = uci:foreach("wireless", "wifi-iface",
							function(s)
								if s[".type"] == "wifi-iface" then  
									local fixed    = uci:get("wireless", s[".name"], "fixed")
									local disabled = uci:get("wireless", s[".name"], "disabled")
									if fixed == "0" then
										if disabled == "0" or disabled == 0 then
											index = uci:get("wireless", s[".name"], "instance")
										end
									end
								end
							end)

			if cl ~= strchannel then
				common.InformValueChanged("InternetGatewayDevice.LANDevice.1.WLANConfiguration.",index,"Channel",strchannel,"xsd:string")
			end
			if ori_hwmode ~= hwmode then
				common.InformValueChanged("InternetGatewayDevice.LANDevice.1.WLANConfiguration.",index,"Standard",hwmode,"xsd:string")
			end
			--Connie add end

			luci.util.exec("/sbin/restart_wifi &")
	
	return luci.json.null
end


--[[
Get Wlan Host List 
Parameters
	null
responose value:
	[{
		"id":0,
		"MacAddress":"98:FC:D2:99:EF",
		"IPv4Address":"192.168.1.100",
		"IPv6Address":"fe80::40a4:b81c:3405:e4d1",
		"AssociationTime":100,
		"DeviceName":"d1-orange-link"
	},
	]
]]
function GetWlanHostList()
	local rv = { }
	local hostlist = {}
	local rsp = {}
	local list = {}
	local ntm = require "luci.model.network".init()
	local leasefile = "/var/dhcp.leases"
	local dev_name
	local dev
	for _, dev in ipairs(ntm:get_wifidevs()) do
		local rd = {
			--up       = dev:is_up(),
			device   = dev:name(),
			--name     = dev:get_i18n(),
			networks = { }
		}

		local net
		for _, net in ipairs(dev:get_wifinets()) do
			rd.networks[#rd.networks+1] = {
				--name       = net:shortname(),
--				link       = net:adminlink(),
				--up         = net:is_up(),
				--mode       = net:active_mode(),
				--ssid       = net:active_ssid(),
				--bssid      = net:active_bssid(),
			--	encryption = net:active_encryption(),
				--frequency  = net:frequency(),
			--	channel    = net:channel(),
			--	signal     = net:signal(),
				--quality    = net:signal_percent(),
				--noise      = net:noise(),
				--bitrate    = net:bitrate(),
				--ifname     = net:ifname(),
				assoclist  = net:assoclist()
				--country    = net:country(),
				--txpower    = net:txpower(),
				--txpoweroff = net:txpower_offset()
			}
		end

		rv[#rv+1] = rd
	end
	for i=1,table.getn(rv) do
		dev_name = rv[i]["device"]
		for j=1,table.getn(rv[i]["networks"]) do
			hostlist[j] = rv[i]["networks"][j]["assoclist"]	
		end
	end
	local i = 0
	for k = 1, table.getn(hostlist) do
		for s,v in pairs(hostlist[k]) do
				i = i + 1
				host = {}
				host["MacAddress"] = s
				host["DeviceName"] = ""
				host["IPv4Address"] = ""
				host["IPv6Address"] = ""
				host["AssociationTime"] = ""
		
				local fd = io.open(leasefile, "r")
				if fd then
					while true do
						local ln = fd:read("*l")
						if not ln then
							break
						else
							local ts, mac, ip, name, duid = ln:match("^(%d+) (%S+) (%S+) (%S+) (%S+)")
							if ts and mac and ip and name and duid then
								if ip:match(".") then   --ipv4
									if string.find(string.lower(s), string.lower(mac)) then
										host["DeviceName"] = (name ~= "*") and name
										host["IPv4Address"] = ip
										host["AssociationTime"] = os.difftime(tonumber(ts) or 0, os.time())
									end
									--hostlist["Expires"] = os.difftime(tonumber(ts) or 0, os.time())   -- String.format('%t', expires);
									
								end
							end
						end
					end
					fd:close()
				end
				list[i] = host
		end
	end
	rsp["HostList"]	 = list	
	return rsp
end


--[[
Get current Hosts  
Parameters
	null
responose value:
	"NumOfHosts":2	
	"MaxNumOfHosts":10

]]
function GetNumOfHosts()
	local rv = { }
	local hostlist = {}
	local rsp = {}
	local ntm = require "luci.model.network".init()
	local dev_name
	local dev
	for _, dev in ipairs(ntm:get_wifidevs()) do
		local rd = {
			--up       = dev:is_up(),
			device   = dev:name(),
			--name     = dev:get_i18n(),
			networks = { }
		}

		local net
		for _, net in ipairs(dev:get_wifinets()) do
			rd.networks[#rd.networks+1] = {
			--	name       = net:shortname(),
--				link       = net:adminlink(),
			--	up         = net:is_up(),
			--	mode       = net:active_mode(),
				--ssid       = net:active_ssid(),
				--bssid      = net:active_bssid(),
				--encryption = net:active_encryption(),
				--frequency  = net:frequency(),
				--channel    = net:channel(),
				--signal     = net:signal(),
				--quality    = net:signal_percent(),
				--noise      = net:noise(),
				--bitrate    = net:bitrate(),
				--ifname     = net:ifname(),
				assoclist  = net:assoclist()
				--country    = net:country(),
				--txpower    = net:txpower(),
				--txpoweroff = net:txpower_offset()
			}
		end

		rv[#rv+1] = rd
	end
	for i=1,table.getn(rv) do
		dev_name = rv[i]["device"]
		for j=1,table.getn(rv[i]["networks"]) do
			hostlist[j] = rv[i]["networks"][j]["assoclist"]
		end
	end
	local i = 0
	for k = 1, table.getn(hostlist) do
		for s,v in pairs(hostlist[k]) do
			i = i + 1
		end
	end
	rsp["NumOfHosts"] = i
	rsp["MaxNumOfHosts"] = 10
	return rsp
end



--[[
Get wlan staticstics   
Parameters
	null
responose value:
	[{
	"Ssid":"H850-459D",
	"ReceivedByte": 0,
	"ReceivedPacket": 0,
	"ReceivedError": 0,
	"ReceivedDiscarded": 0,
	"SentdByte": 0,
	"SentPacket": 0,
	"SentError": 0,
	"SentDiscarded": 0},бн]
]]
function GetWlanStatistics()
	local rsp = {}
	local statlist = {}
	local wifilist = common.GetValueList("wireless", "wifi-iface")   --etc/config/wireless
	local k = 0
	if wifilist ~= nil then
		for i=1,table.getn(wifilist.valuelist) do
			enable = wifilist.valuelist[i]["disabled"]
			fixed = wifilist.valuelist[i]["fixed"]
			if enable ~= "1" and fixed == "0"then
				k = k + 1
				statlist["Ssid"] = wifilist.valuelist[i]["ssid"]
				statlist["ReceivedByte"] =  tonumber(luci.util.trim(luci.util.exec("cat /proc/net/dev | grep 'wlan0:' | awk '{print $2}'"))) -- RxBytes
				statlist["ReceivedPacket"] =  tonumber(luci.util.trim(luci.util.exec("cat /proc/net/dev | grep 'wlan0:' | awk '{print $3}'"))) -- Rxpackets
				statlist["ReceivedError"] =  tonumber(luci.util.trim(luci.util.exec("cat /proc/net/dev | grep 'wlan0:' | awk '{print $4}'"))) -- Rxerror
				statlist["ReceivedDiscarded"] =  tonumber(luci.util.trim(luci.util.exec("cat /proc/net/dev | grep 'wlan0:' | awk '{print $5}'"))) -- Rxdrops
				statlist["SentdByte"] =  tonumber(luci.util.trim(luci.util.exec("cat /proc/net/dev | grep 'wlan0:' | awk '{print $10}'"))) -- TxBytes
				statlist["SentPacket"] =  tonumber(luci.util.trim(luci.util.exec("cat /proc/net/dev | grep 'wlan0:' | awk '{print $11}'"))) -- Txpackets
				statlist["SentError"] =  tonumber(luci.util.trim(luci.util.exec("cat /proc/net/dev | grep 'wlan0:' | awk '{print $12}'"))) -- Txerror
				statlist["SentDiscarded"] =  tonumber(luci.util.trim(luci.util.exec("cat /proc/net/dev | grep 'wlan0:' | awk '{print $13}'"))) -- Txdrops
				rsp[k] = statlist
			end
			
		end
	end
	return rsp
end


--[[
Get wps pin   
Parameters
	null
responose value:
	"WpsMode":1,
	"WpsPin":"1234"

]]
function GetWpsSettings()
	local rsp = {}
	local state = 0
	local wifilist = common.GetValueList("wireless", "wifi-iface")   --etc/config/wireless
	local k = 0
	if wifilist ~= nil then
		for i=1,table.getn(wifilist.valuelist) do
			if wifilist.valuelist[i]["wps_pushbutton"] == "1" then --0 is disable  1 is enable
				state = 1
			end
			if wifilist.valuelist[i]["wps_ap_pin"] == "1" then    --0 is disable  1 is enable
				state = 0
			end
			if wifilist.valuelist[i]["ap_pin"] == nil then
				rsp["WpsPin"] = ""
			else
				rsp["WpsPin"] = wifilist.valuelist[i]["ap_pin"]
			end
			
			rsp["WpsMode"] = state
		end
	end
	return rsp
end

--[[
Set wps pin   
Parameters
	"WpsMode":1,
	"WpsPin":"1234"
responose value:
	null

]]
function SetWpsSettings(req)
	local pbc_state = 0
	local pin_state = 0
	local wps_pin = req["WpsPin"]
	local wps_mode = req["WpsMode"]
	if wps_mode == 0 or wps_mode == "0" then
		pbc_state = 0 
		pin_state = 1
		uci:set("wireless", "radio0", "wps_hotplug", "0")
	else
		pbc_state = 1 
		pin_state = 0
		uci:set("wireless", "radio0", "wps_hotplug", "1")
	end
	if wps_pin == nil or wps_mode == nil then
		return nil, errs
	end
	local wifilist = common.GetValueList("wireless", "wifi-iface")   --etc/config/wireless
	if wifilist == nil then
		errs = {code=50901, message="Set WPS Settings failed."}
		return nil, errs
	end
	local k = 0
	if wifilist ~= nil then
		for i=1,table.getn(wifilist.valuelist) do
			if wifilist.valuelist[i]["ssid"] ~= "" or wifilist.valuelist[i]["ssid"] ~= nil then 
				flags = uci:foreach("wireless", "wifi-iface",
                 function(s)
                   if s[".type"] == "wifi-iface" then  
						value = uci:set("wireless", s[".name"], "wps_pushbutton", pbc_state) --wps pbc 
						value = uci:set("wireless", s[".name"], "wps_ap_pin", pin_state) --wps pin 
						value = uci:set("wireless", s[".name"], "ap_pin", wps_pin)	--wps ap pin
                    end
                 end)
					--common.SetTypeValue("wireless", "wifi-iface", "wps_pushbutton", pbc_state) --wps pbc 
					--common.SetTypeValue("wireless", "wifi-iface", "wps_ap_pin", pin_state) --wps pin 
					--common.SetTypeValue("wireless", "wifi-iface", "ap_pin", wps_pin) --wps ap pin
			end
		end
	end
	uci:save("wireless")
	ret = uci:commit("wireless")
	if ret == false then
		errs = {code=50901, message="Set WPS Settings failed."}
		return nil, errs
	end
	
	luci.util.exec("/sbin/restart_wifi &")		
	return luci.json.null
end
