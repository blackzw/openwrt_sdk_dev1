module("luci.webapi.Util", package.seeall)

local sys = require("luci.sys")
local util    = require("luci.util")
local uci = require('luci.model.uci').cursor()

-- Connie add start for inform value changed to TR069, 2014/6/18
--[[
Inform TR069 value changed
Parameters
	paramPrefix: TR069 parameter prefix          eg. "InternetGatewayDevice.LANDevice.1.WLANConfiguration."
	index:       TR069 parameter Setting index   eg. 1
	paramName:   TR069 parameter name            eg. "Enable"
	value:       TR069 parameter value           eg. true
	stype:       TR069 parameter type            eg. "xsd:boolean"
Return value:
	Boolean whether operation succeeded
]]
function InformValueChanged(paramPrefix, index, paramName, value, stype)
	if value == nil then
		return true
	end
	local command = "ubus call tr069 notify '{\"parameter\":\""..paramPrefix..index.."."..paramName.."\",\"value\":\""..value.."\",\"type\":\""..stype.."\"}' > /dev/null 2>&1 &"
	luci.sys.call(command)
	--eg. luci.sys.call("ubus call tr069 notify '{\"parameter\":\"InternetGatewayDevice.LANDevice.1.WLANConfiguration.1.Enable\",\"value\":true,\"type\":\"xsd:boolean\"}' &")
	return true
end

function InformValueChangedWithoutIndex(paramPrefix, paramName, value, stype)
	if value == nil then 
		return true
	end
	local command = "ubus call tr069 notify '{\"parameter\":\""..paramPrefix..paramName.."\",\"value\":\""..value.."\",\"type\":\""..stype.."\"}' > /dev/null 2>&1 &"
	luci.sys.call(command)
	--eg. luci.sys.call("ubus call tr069 notify '{\"parameter\":\"InternetGatewayDevice.LANDevice.1.WLANConfiguration.1.Enable\",\"value\":true,\"type\":\"xsd:boolean\"}' &")
	return true
end

function WriteInformtoNewFile(paramPrefix, index, paramName, value, stype)
	if value == nil then 
		return true
	end
	local command = "'{\"parameter\":\""..paramPrefix..index.."."..paramName.."\",\"value\":\""..value.."\",\"type\":\""..stype.."\"}'"
	local command2 = "echo "..command.." > /usr/share/easycwmp/oem/do_after_reboot 2>&1 &"
	luci.sys.call(command2)
	return true
end
function WriteInformtoExistFile(paramPrefix, index, paramName, value, stype)
	if value == nil then 
		return true
	end
	local command = "'{\"parameter\":\""..paramPrefix..index.."."..paramName.."\",\"value\":\""..value.."\",\"type\":\""..stype.."\"}'"
	local command2 = "echo "..command.." >> /usr/share/easycwmp/oem/do_after_reboot 2>&1 &"
	luci.sys.call(command2)
	return true
end

-- Connie add end for inform value changed to TR069, 2014/6/18

--[[
Execute a given shell command and capture its standard output 
Parameters
	command: Command to call 
	stype:0 no return value ,1 return shell infos
Return value:
	String containg the return the output of the command 
]]
function Exec(command, stype)
	local rsp = {}
	if stype == 1 then 
		rsp["result"] = luci.util.execi(command)
	else
		luci.sys.exec(command)
	end
	return rsp
end

--[[
Get a section type or an option 
Parameters
	config: UCI config file name
	section: UCI section name 
	option: UCI option (optional) 
Return value:
	UCI value 
]]
function GetValue(file_name, section, option)
	value = uci:get(file_name, section, option)
	if value == nil then
		value = ""
	end
	return value
end

--[[
Get list section type or an option 
Parameters
	config: UCI config file name
	type: UCI type (not section name) 
Return value:
	UCI table list 
]]
function GetValueList(file_name, stype)
	local value = {}
	local valuelist = {}
	local i = 0
	flags = uci:foreach(file_name,stype,
                 function(s)
                   if s[".type"] == stype then  
					i = i + 1
					valuelist[i] = s
                    end
                 end)
	value = {valuelist=valuelist}
	return value
end

--[[
save a section type or an option 
Parameters
	file_name: UCI config file name
	option: UCI option or UCI section type 
	option_table: UCI type table {...}
	value: UCI set value
Return value:
	UCI table list 
]]
function SetTypeValue(file_name, stype, option, value)
	local value
	flags = uci:foreach(file_name, stype,
                 function(s)
                   if s[".type"] == stype then  
						value = uci:set(file_name, s[".name"], option, value) 
                    end
                 end)
	
	return value
end

--[[
Set a value or create a named section. 
Parameters
	config: UCI config file name
	section: UCI section name 
	option: UCI option or UCI section type 
	value: UCI value or nil if you want to create a section 
Return value:
	Boolean whether operation succeeded 
]]
function SetValue(file_name, section, option, value)
	ret = uci:set(file_name, section, option, value)
	if ret == nil then
		ret = false
	end
	return ret
end

--[[
Create a new section and initialize it with data. 
Parameters
	file_name: UCI config 
type: UCI section type 
	name: UCI section name (optional) ,name is nil will just type 
values: Table of key - value pairs to initialize the section with 
	Return value:
Name of created section 

]]
function AddSection(file_name, stype, name, values)
	if file_name == "" or stype == "" or name == "" then
		errs = {message="error"}
		return nil, errs
	end
	ret = uci:section(file_name, stype, name, values)
	if ret == nil then
		ret = false
	end
	return ret
end

--[[
Deletes a section or an option. 
Parameters
	file_name: UCI config 
	stype: UCI section type 
	option: UCI option (optional) 
	stype:0 have section name,  1  no section name
Return value:
	Boolean whether operation succeeded 

]]
function DeleteOption(file_name, stype, option)
	if file_name == "" or stype == "" or name == "" then
		return false
	end
	flags = uci:foreach(file_name, stype,
            function(s)
                if s[".type"] == stype then  
						value = uci:delete(file_name, s[".name"], option) 
                    end
                end)

	return false
end

--[[
Deletes a section
Parameters
	file_name: UCI config 
	stype: UCI section type 
Return value:
	Boolean whether operation succeeded 
]]
function DeleteSection(file_name, stype)
	if file_name == "" or stype == "" then
		return false
	end

	flags = uci:foreach(file_name, stype,
            function(s)
                   if s[".type"] == stype then  
						value = uci:delete(file_name, s[".name"]) 
                    end
              end)
	return true
end


--[[
set a section
Parameters
	file_name: UCI config file name
	band: 2.4 or 5
	option_table: UCI type table {...}
	value: UCI set values
Return value:
	UCI table list 
]]
function SetWifiSectionValues(file_name, stype, band, values)
	local value = true
	flags = uci:foreach(file_name, stype,
                 function(s)
                   if s[".type"] == stype then  
						local vband = uci:get(file_name, s[".name"], "band")
						local fixed = uci:get(file_name, s[".name"], "fixed")
						local index = uci:get(file_name, s[".name"], "instance") -- Connie add, 2014/6/19
						if vband == band then
							-- Connie add start, 2014/6/19
							local ori_disabled   = uci:get(file_name, s[".name"], "disabled")
							local ori_ssid       = uci:get(file_name, s[".name"], "ssid")
							local ori_encryption = uci:get(file_name, s[".name"], "encryption")
							local ori_key        = uci:get(file_name, s[".name"], "key")
							-- Connie add end, 2014/6/19
							uci:set(file_name, s[".name"], "disabled", values["disabled"])
							if fixed == "0" then
								uci:set(file_name, s[".name"], "device", values["device"]) 
								uci:set(file_name, s[".name"], "network", values["network"]) 
								uci:set(file_name, s[".name"], "mode", values["mode"]) 
								uci:set(file_name, s[".name"], "band", values["band"]) 
								uci:set(file_name, s[".name"], "ssid", values["ssid"]) 
								uci:set(file_name, s[".name"], "encryption", values["encryption"]) 
								uci:set(file_name, s[".name"], "key", values["key"]) 
								uci:set(file_name, s[".name"], "isolate", values["isolate"]) 
								uci:set(file_name, s[".name"], "wps_pushbutton", values["wps_pushbutton"]) 
								uci:set(file_name, s[".name"], "wps_ap_pin", values["wps_ap_pin"]) 
								uci:set(file_name, s[".name"], "ap_pin", values["ap_pin"]) 
								uci:set(file_name, s[".name"], "hidden", values["hidden"])
								uci:set(file_name, s[".name"], "wep_key", values["wep_key"]) 
								uci:set(file_name, s[".name"], "wpa_key", values["wpa_key"]) 
								--break 
								-- Connie add start
								local new_disabled   = uci:get(file_name, s[".name"], "disabled")
								local new_ssid       = uci:get(file_name, s[".name"], "ssid")							
								local new_encryption = uci:get(file_name, s[".name"], "encryption")
								local new_key        = uci:get(file_name, s[".name"], "key")
								if ori_disabled ~= new_disabled then
									local value1 = "false"
									local value2 = "down"
									if new_disabled == "0" or new_disabled == 0 then
										value1 = "true"
										value2 = "up"
									end
									InformValueChanged("InternetGatewayDevice.LANDevice.1.WLANConfiguration.", index, "Enable", value1, "xsd:boolean")
									InformValueChanged("InternetGatewayDevice.LANDevice.1.WLANConfiguration.", index, "Status", value2, "xsd:string")
								end
								if new_disabled == "0" or new_disabled == 0 then
									if ori_ssid ~= new_ssid then
										InformValueChanged("InternetGatewayDevice.LANDevice.1.WLANConfiguration.", index, "SSID", new_ssid, "xsd:string")
									end
									if ori_encryption ~= new_encryption then
										InformValueChanged("InternetGatewayDevice.LANDevice.1.WLANConfiguration.", index, "BasicEncryptionModes", new_encryption, "xsd:string")
									end
									if ori_key ~= new_key then
										InformValueChanged("InternetGatewayDevice.LANDevice.1.WLANConfiguration.", index, "KeyPassphrase", new_key, "xsd:string")
									end

									if ori_encryption ~= new_encryption or ori_key ~= new_key then
										local BeaconType = ""
										local BasicAuthenticationMode = ""
										local WPAEncryptionModes = ""
										
										if new_encryption == "none"               then
											BeaconType              = "none"
											BasicAuthenticationMode = "EAPAuthentication"
										elseif new_encryption == "wep-open"       then
											BeaconType              = "Basic"
											BasicAuthenticationMode = "EAPAuthentication"
											WPAEncryptionModes      = "WEPEncryption"
										elseif new_encryption == "wep-shared"     then
											BeaconType              = "Basic"
											BasicAuthenticationMode = "none"
											WPAEncryptionModes      = "WEPEncryption"
										elseif new_encryption == "psk+tkip"       then
											BeaconType              = "WPA"
											BasicAuthenticationMode = "EAPAuthentication"
											WPAEncryptionModes      = "TKIPEncryption"
										elseif new_encryption == "psk+ccmp"       then
											BeaconType              = "WPA"
											BasicAuthenticationMode = "EAPAuthentication"
											WPAEncryptionModes      = "AESEncryption"
										elseif new_encryption == "psk"            then
											BeaconType              = "WPA"
											BasicAuthenticationMode = "EAPAuthentication"
											WPAEncryptionModes      = "TKIPEncryption"
										elseif new_encryption == "psk2+tkip"      then
											BeaconType              = "11i"
											BasicAuthenticationMode = "EAPAuthentication"
											WPAEncryptionModes      = "TKIPEncryption"
										elseif new_encryption == "psk2+ccmp"      then
											BeaconType              = "11i"
											BasicAuthenticationMode = "EAPAuthentication"
											WPAEncryptionModes      = "AESEncryption"
										elseif new_encryption == "psk2"           then
											BeaconType              = "11i"
											BasicAuthenticationMode = "EAPAuthentication"
											WPAEncryptionModes      = "AESEncryption"
										elseif new_encryption == "psk+mixed+tkip" then
											BeaconType              = "noWPAand11ine"
											BasicAuthenticationMode = "EAPAuthentication"
											WPAEncryptionModes      = "TKIPEncryption"
										elseif new_encryption == "psk+mixed+ccmp" then
											BeaconType              = "WPAand11i"
											BasicAuthenticationMode = "EAPAuthentication"
											WPAEncryptionModes      = "AESEncryption"
										elseif new_encryption == "psk+mixed"      then
											BeaconType              = "WPAand11i"
											BasicAuthenticationMode = "EAPAuthentication"
											WPAEncryptionModes      = "TKIPEncryption"
										end
										InformValueChanged("InternetGatewayDevice.LANDevice.1.WLANConfiguration.", index, "BeaconType", BeaconType, "xsd:string")
										InformValueChanged("InternetGatewayDevice.LANDevice.1.WLANConfiguration.", index, "BasicAuthenticationMode", BasicAuthenticationMode, "xsd:string")
										InformValueChanged("InternetGatewayDevice.LANDevice.1.WLANConfiguration.", index, "WPAEncryptionModes", WPAEncryptionModes, "xsd:string")
									end
								end
								-- Connie add end
							end
						end
					end
				end)
	--value = flags
	return value
end

--[[
Deletes wifi section
Parameters
	file_name: UCI config 
	stype: UCI section type 
Return value:
	Boolean whether operation succeeded 
]]
function DeleteWifi(bandval)
	 flags = uci:foreach("wireless", "wifi-iface",
            function(s)
                   if s[".type"] == "wifi-iface" then  
						local wifi_band = uci:get("wireless", s[".name"], "band")
						if wifi_band == bandval then
							uci:set("wireless", s[".name"], "disabled", "0") 
						else
							uci:set("wireless", s[".name"], "disabled", "1") 
						end
						local opval ={}
						opval = s
						if opval["fixed"] == 0 or opval["fixed"] == "0" then
							value = uci:delete("wireless", s[".name"]) 
						end
                    end
              end)
	return true
end
--[[
save file. 
Parameters
	file_name: UCI config file name
Return value:
	Boolean whether operation succeeded 
]]
function SaveFile(file_name)
	if file_name == "" or file_name == nil then
		return false
	end
	uci:save(file_name)
	ret = uci:commit(file_name)
	return ret
end

--[[
set config directory
Parameters:
	dir_name: UCI config directory
Return value:
	olddir_name: old UCI config directory
--]]
function SetConfigDir(dir_name)
	if dir_name == "" or file_name == nil then
		return nil
	end
	local olddir = uci:get_confdir()
	if uci:set_confdir(dir_name) == true then
		return olddir
	end
	return nil
end

--[[
sleep
Parameters:
	nSeconds: sleep time
Return value:
--]]
function Sleep(nSeconds)
	Exec("sleep " .. nSeconds)
end

--[[
change samba password
Parameters:
	username: user name
	password: new password
Return value:
--]]
function ChangeSMBPassword(username, password)
	if password then
		password = password:gsub("'", [['"'"']])
	end

	if username then
		username = username:gsub("'", [['"'"']])
	end

	return os.execute(
		"(echo '" .. password .. "'; sleep 1; echo '" .. password .. "') | " ..
		"smbpasswd -s '" .. username .. "' >/dev/null 2>&1"
	)
end
