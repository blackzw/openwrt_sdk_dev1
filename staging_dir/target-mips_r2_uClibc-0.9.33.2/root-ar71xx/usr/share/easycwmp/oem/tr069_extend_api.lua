module("tr069_extend_api", package.seeall)
require("luci.sys")

function get_auth_type(type_id)
	if type_id == 0 then
		return "None"
	elseif type_id == 1 then
		return "PAP"
	elseif type_id == 2 then
		return "CHAP"
	elseif type_id == 3 then
		return "CHAP_PAP"
	else
		return ""
	end
end

function get_current_profile_name()
	rild_client_lib = assert(package.loadlib("/usr/lib/librild_client.so", "luaopen_rild_client"))
    	rild_client_lib()
	local err = 0
	local profile_name = ""

	local ret_code, ril_res = rild_client.get_wan_connection_info()
	if ret_code == 0 then		
		profile_name = ril_res["strProfileName"]		
	else
		err = 1
	end

	if err ~= 0 then
		print("Error=" .. err .. ";")
	else
		print("Error=0;ProfileName=" .. profile_name .. ";")
	end
	
end

function get_profile_list(output_filename)
	local err = 0

	rild_client_lib = assert(package.loadlib("/usr/lib/librild_client.so", "luaopen_rild_client"))
    	rild_client_lib()

	local ret_profile_code, pro_list = rild_client.get_profile_list()
	if ret_profile_code == 0  then
		luci.sys.call("rm -f " .. output_filename)
		if pro_list == nil or table.getn(pro_list.profileList) <=0 then
			err = 0
		else
			for i=1,table.getn(pro_list.profileList) do  
				pid = pro_list.profileList[i]["nProfileId"]
				username = pro_list.profileList[i]["strUserName"]
				password = pro_list.profileList[i]["strPasswd"]
				apn = pro_list.profileList[i]["strApn"]
				pname = pro_list.profileList[i]["strProfileName"]
				auth_type = get_auth_type(pro_list.profileList[i]["nAuthType"])
				dial_num = pro_list.profileList[i]["strDialNumber"]
				str = "Id=" .. pid .. ";APNName=" .. pname .. ";APN=" .. apn .. ";Auth=" .. auth_type .. ";Username=" .. username .. ";Password=" .. password .. ";DialNum=" .. dial_num .. ";"
				luci.sys.call("echo \"" .. str .."\" >> " .. output_filename)							
			end
		end
	else
		err = 1
	end

	print("Error=" .. err .. ";")		
	
end

function update_profile_item(pid, param_name, param_value)
	local err = 0
	local profile_item = nil
	
	pid = tonumber(pid)

	if param_name == "nAuthType" then
		param_value = tonumber(pid)
	end

	rild_client_lib = assert(package.loadlib("/usr/lib/librild_client.so", "luaopen_rild_client"))
    	rild_client_lib()

	local ret_profile_code, pro_list = rild_client.get_profile_list()
	if ret_profile_code == 0  then
		if pro_list == nil or table.getn(pro_list.profileList) <=0 then
			err = 1
		else
			for i=1,table.getn(pro_list.profileList) do 
				if  pro_list.profileList[i]["nProfileId"] == pid then
					profile_item = pro_list.profileList[i]					
					break
				end
								
			end
		end
	else
		err = 1
	end

	if err == 0 and profile_item ~= nil then
		profile_item[param_name] = param_value
		ret_profile_code = rild_client.update_profile_item(pid, profile_item["strPdpType"], profile_item["strApn"], profile_item["strPdpAddr"], profile_item["nDComp"], profile_item["nHComp"], profile_item["nAuthType"], profile_item["strUserName"], profile_item["strPasswd"], profile_item["strProfileName"], profile_item["strDialNumber"])
		if ret_profile_code ~= 0 then
			err = 1
		end
	else
		err = 1
	end

	print("Error=" .. err .. ";")		
end

function add_profile_item(profile_name, apn, auth, username, password, number)
	local err = 0
	auth=tonumber(auth)
	rild_client_lib = assert(package.loadlib("/usr/lib/librild_client.so", "luaopen_rild_client"))
    	rild_client_lib()

	local ret_profile_code = rild_client.add_new_profile_item("IP", apn, "0.0.0.0", 0, 0, auth, username, password, profile_name, number)
	if ret_profile_code == 0  then
		err = 0
	else
		err = 1
	end

	print("Error=" .. err .. ";")	
end

function del_profile_item(pid)
	local err = 0
	pid = tonumber(pid)
	rild_client_lib = assert(package.loadlib("/usr/lib/librild_client.so", "luaopen_rild_client"))
    	rild_client_lib()

	local ret_profile_code = rild_client.delete_profile_item(pid)
	if ret_profile_code == 0  then
		err = 0
	else
		err = 1
	end

	print("Error=" .. err .. ";")		
end

function get_timezone_offset(tz_name)
	require("luci.sys.zoneinfo")
	res="OFFSET="
	for k, v in ipairs(luci.sys.zoneinfo.TZ) do
		if v[1] == tz_name then
			local flag,offset,mins=v[2]:match("([%+%-]?)([0-9]+)([:]?[0-9]*)")
			if offset then
				offset = tonumber(offset)
			end
			if (flag == nil or flag == "" ) and offset ~= 0 then
				flag = "-"
			elseif(flag == "-") then
				flag = "+"
			end

			if (mins == nil or mins == "") and offset ~= 0 then
				mins = ":00"		
			end

			if offset == 0 then
				flag = "+"
				mins = ":00"
			end
			
			res = res .. flag .. tostring(offset) .. mins
			break
		end		
	end
	res = res .. ";"
	print(res)
end

function get_connection_state(status)
	if status == 0 then
		return "Disconnected"
	elseif status == 1 then
		return "Connecting"
	elseif status == 2 then
		return "Connected"
	elseif status == 3 then
		return "Disconneting"
	end

	return "PendingDisconnect"
end

function GetSystemInfo()
	local ModuleExtVersion=""
	rild_client_lib = assert(package.loadlib("/usr/lib/librild_client.so", "luaopen_rild_client"))
    	rild_client_lib()

	local ret_code, sys_info = rild_client.get_system_equipment_info()
	if ret_code ~= 0 then
		print("Error=1;")
	else
		ModuleExtVersion=sys_info.strExternalVersion
		print("Error=0;IMEI=" .. sys_info.strSerialNumber .. ";MODULEEXTVERSION=" .. ModuleExtVersion .. ";IMSI=" .. sys_info.strImsi .. ";")
	end
end

function get_conn_type(type)
	if type == 0 then
		return "PDP_TYPE_IPv4"
	elseif type == 1 then
		return "PDP_TYPE_PPP"
	elseif type == 2 then
		return "PDP_TYPE_IPv6"
	elseif type == 3 then
		return "PDP_TYPE_IPv4v6"
	end

	return "Unconfigured"
end

function get_access_type(type)
	if type == 0 then
		return "No service"
	elseif type == 1 then
		return "GPRS"
	elseif type == 2 then
		return "EDGE"
	elseif type == 3 then
		return "UMTS"
	elseif type == 4 then
		return "HSDPA"
	elseif type == 5 then
		return "HSPA"
	elseif type == 6 then
		return "HSUPA"
	elseif type == 7 then
		return "DC-HSPA+"
	elseif type == 8 then
		return "LTE"
	elseif type == 9 then
		return "GSM"
	elseif type == 10  then
		return "HSPA+"
	end

	return "UNKNOWN"
end



function GetConnectionState()
	local username=""
	local password=""
	local apn=""
	local ipv4=""
	local ipv6=""
	local mac_addr=""
	local conn_status = 5
	local conn_type=""
	local upstring_max_rate=""
	local downstring_max_rate=""
	local uptime=0
	local err = 0

	rild_client_lib = assert(package.loadlib("/usr/lib/librild_client.so", "luaopen_rild_client"))
    rild_client_lib()

	local ret_profile_code, pro_list = rild_client.get_profile_list()
	-- get profile list
	if ret_profile_code == 0  then
		if pro_list == nil or table.getn(pro_list.profileList) <=0 then
			err = 0
			conn_status = 0
		else
			for i=1,table.getn(pro_list.profileList) do  
				if pro_list.profileList[i]["bIsActive"] == 1 then
					username = pro_list.profileList[i]["strUserName"]
					password = pro_list.profileList[i]["strPasswd"]
					apn = pro_list.profileList[i]["strApn"]
					break
				end			
			end
		end
	else
		err = 1
	end
	
	if err ~= 0 then
		print("Error=" .. err .. ";")
		return
	elseif err == 0 and conn_status == 0 then
		print("Error=0;ConnectionStatus=0;Username=;Password=;ExternalIPv4Address=;ExternalIPv6Address=;MACAddress=;UpStringMaxBitRate=;DownStringMaxBitRate=;TotalBytesSent=;TotalBytesReceived=;ConnectionType=;AccessType=;Uptime=")
		return
	end

	local ret_code, ril_res = rild_client.get_wan_connection_info()
	if ret_code == 0 then		
		conn_status = get_connection_state(ril_res["nState"])		
		ipv4 = ril_res["strIPv4Addr"]
		ipv6 = ril_res["strIPv6Addr"]		
		uptime = ril_res["nDuration"]
		upstring_max_rate = ril_res["nSendSpeed"]
		downstring_max_rate = ril_res["nRecvSpeed"]
		total_bytes_sent = tonumber(ril_res["nSendBytes"])
		total_bytes_received = tonumber(ril_res["nRecvBytes"])
	else
		err = 1
	end

	local ret_code, ril_res = rild_client.get_connection_type()
	if ret_code == 0 then
		conn_type = get_conn_type(ril_res["nPdpType"])
	else
		err = 1
	end

	local ret_code, ril_res = rild_client.get_current_network_info()
	if ret_code == 0 then
		access_type = get_access_type(ril_res.nBearer)
	else
		err = 1
	end

	if err ~= 0 then
		print("Error=" .. err .. ";")
	else
		print("Error=0;ConnectionStatus=" .. conn_status .. ";Username=" .. username .. ";Password=" .. password .. ";ExternalIPv4Address=" .. ipv4 .."; ExternalIPv6Address=" .. ipv6 .. ";MACAddress=" .. mac_addr .. ";UpStringMaxBitRate=" .. upstring_max_rate .. ";DownStringMaxBitRate=" .. downstring_max_rate .."; TotalBytesSent=" .. total_bytes_sent .. ";TotalBytesReceived=" .. total_bytes_received .. ";ConnectionType=" .. conn_type .. ";AccessType=" .. access_type .. ";Uptime=" .. uptime .. ";")
	end
	
end

function GetNetworkLacCellId()
	rild_client_lib = assert(package.loadlib("/usr/lib/librild_client.so", "luaopen_rild_client"))
	rild_client_lib()
	    
	local ret_lc_code, lc_info = rild_client.get_network_lac_cellid()	
	if ret_lc_code ~= 0 then
	print("Error=1;")
	else
	print("Error=0;CELLID=" .. lc_info.nCellID .. ";LACID=" .. lc_info.nLac .. ";")
	end
end

function GetNetworkSignalValue()
	rild_client_lib = assert(package.loadlib("/usr/lib/librild_client.so", "luaopen_rild_client"))
	rild_client_lib()
	    
	local ret_code, sig_val = rild_client.get_network_signal_value()	
	if ret_code ~= 0 then
		print("Error=1;")
	else
		print("Error=0;RSSI=" .. sig_val.nRSSI .. ";RSRP=" .. sig_val.nRSRP .. ";RSCP=" .. sig_val.nRSCP .. ";RSRQ=" .. sig_val.nRSRQ .. ";Ecno=" .. sig_val.nEcno .. ";Ber=" .. sig_val.nBer .. ";")
	end
end

function GetNetworkInfo()
	local SignalStrength=""	
	local RoamStatus=""
	local NetworkType=""
	local PLMN=""	
	local NetworkName=""
	
	rild_client_lib = assert(package.loadlib("/usr/lib/librild_client.so", "luaopen_rild_client"))
	rild_client_lib()
	
	local ret_nw_info_code, nw_info = rild_client.get_current_network_info()	
	if ret_nw_info_code ~= 0 then	
		print("Error=1;")
	else
		if nw_info.nRssi == 0 then
			SignalStrength="Level 0"		
		elseif nw_info.nRssi == 1 then
			SignalStrength="Level 1"
		elseif nw_info.nRssi == 2 then
			SignalStrength="Level 2"
		elseif nw_info.nRssi == 3 then
			SignalStrength="Level 3"
		elseif nw_info.nRssi == 4 then
			SignalStrength="Level 4"
		elseif nw_info.nRssi == 5 then
			SignalStrength="Level 5"
		else
			SignalStrength="Unknown"
		end
		
		if nw_info.nRoamState == 0 then
			RoamStatus="No Roaming"
		elseif nw_info.nRoamState == 1 then
			RoamStatus="Roaming"
		else
			RoamStatus="Unknown"
		end
		
		if nw_info.nBearer == 0 or nw_info.nBearer == 11 then
			NetworkType="No service"
		elseif nw_info.nBearer == 1  then
			NetworkType="GPRS"
		elseif nw_info.nBearer == 2  then
			NetworkType="EDGE"
		elseif nw_info.nBearer == 3  then
			NetworkType="UMTS"
		elseif nw_info.nBearer == 4  then
			NetworkType="HSDPA"
		elseif nw_info.nBearer == 5  then
			NetworkType="HSPA"
		elseif nw_info.nBearer == 6  then
			NetworkType="HSUPA"
		elseif nw_info.nBearer == 7  then
			NetworkType="DC-HSPA+"
		elseif nw_info.nBearer == 8  then
			NetworkType="LTE"
		elseif nw_info.nBearer == 9  then
			NetworkType="GSM"
		elseif nw_info.nBearer == 10  then
			NetworkType="HSPA+"
		else
			NetworkType="No service"
		end	
			
		PLMN		= nw_info.strOperator
		NetworkName	= nw_info.strOperator	
		print("Error=0;SIGNALSTRENGTH=" .. SignalStrength .. ";ROAMSTATUS=" .. RoamStatus .. ";NETWORKTYPE=" .. NetworkType .. ";PLMN=" .. PLMN .. ";NetworkName=" .. NetworkName .. ";")
	end
end

function GetPinStatusInfo()
	--[[local Imsi=""
	local MSISDN=""
	local iccid=""
	--]]
	local SimStatus = "Unknown"
	rild_client_lib = assert(package.loadlib("/usr/lib/librild_client.so", "luaopen_rild_client"))
    	rild_client_lib()
    	
	--[[local ret_eq_info_code, eq_info = rild_client.get_system_equipment_info()
	--get equipment error 
	if ret_eq_info_code ~= 0 then 
		print("Error=1;Get SIM status failed;")	
		return
	end 
	
	local ret_iccid_code, iccid = rild_client.get_system_iccid()
		--get iccid error 
	if ret_iccid_code ~= 0 then 
		print("Error=1;Get SIM status failed;")	
	return
	end 
	--]]
	
	local ret_pin_info_code, pin_info = rild_client.check_pin_state()
	--get pin info error 
	if ret_pin_info_code ~= 0 then 
		print("Error=1;Get SIM status failed;")	
		return
	end 
		
	--[[Imsi=eq_info.strImsi
	MSISDN=eq_info.strMsisdn	
	
	iccid=iccid.strICCID
	--]]
	if pin_info.nState == 0 then		
		SimStatus = "No (U)SIM card"
	elseif pin_info.nState == 1 then		
		SimStatus = "(U)SIM card ready"
	elseif pin_info.nState == 2 then		  	
		SimStatus = "(U)SIM card required pin code" --pin required 
	elseif pin_info.nState == 3 then
		SimStatus = "(U)SIM card required puk code" --puk required 		
	elseif pin_info.nState == 4 or pin_info.nState == 5 then
		SimStatus = "SIMLock is on PCK"     	 --sim lock
	elseif pin_info.nState == 6 or pin_info.nState == 10 or pin_info.nState == 12 or pin_info.nState == 14 or pin_info.nState == 16 then
		SimStatus = "SIMLock is on RCK"      	--sim lock 		
	elseif pin_info.nState == 9 then
		SimStatus = "SIMLock is on NCK"     	--sim lock 	
	elseif pin_info.nState == 11 then
		SimStatus = "SIMLock is on NSCK"    	--sim lock 	
	elseif pin_info.nState == 13 then
		SimStatus = "SIMLock is on SPCK"   		--sim lock 		
	elseif pin_info.nState == 15 then
		SimStatus = "SIMLock is on CCK"    		--sim lock	
	elseif pin_info.nState == 17 then
		SimStatus = "SIMLock is on RCK FORBID"    	--sim lock 		
	else
		SimStatus = "Unknown"     	--Unknown 		
	end
	print("Error=0;SIMSTATUS=" .. SimStatus .. ";")	
end

function GetNetworkSettings()
	local NetworkModem=""
	local NetworkSelectionModem=""
	rild_client_lib=assert(package.loadlib("/usr/lib/librild_client.so", "luaopen_rild_client"))
 	rild_client_lib()
 	
 	local ret_modem_code, nw_info = rild_client.get_network_mode_ex()
 	if ret_modem_code ~= 0 then
 		print("Error=1;")
 	else
 		if nw_info.nSearchMode == 1 then
 			NetworkSelectionModem="Manual"
 		else
 			NetworkSelectionModem="Auto"
 		end
 		 			
 		if nw_info.nMode == 0 then
 			NetworkModem="Auto"
 		elseif nw_info.nMode == 3 then
 			NetworkModem="2G only"
 		elseif nw_info.nMode == 1 then
 		 	NetworkModem="3G only"
 		elseif nw_info.nMode == 7 then
 			NetworkModem="LTE only"
 		elseif nw_info.nMode == 2 then
 			NetworkModem="3G PREFERRED"
		elseif nw_info.nMode == 4 then
			NetworkModem="2G PREFERRED"
		elseif nw_info.nMode == 5 then
			NetworkModem="Auto"
		elseif nw_info.nMode == 6 then
			NetworkModem="2G & 3G only"
		elseif nw_info.nMode == 8 then
			NetworkModem="Unknown"
 		end
 		print("Error=0;NETWORKSELECTIONMODEM=" .. NetworkSelectionModem .. ";NetworkModem=" .. NetworkModem .. ";")
 	end	
end

function GetNetworkServiceStatus()
	local service_status = ""

	rild_client_lib = assert(package.loadlib("/usr/lib/librild_client.so", "luaopen_rild_client"))
	rild_client_lib()
	
	local ret_nw_info_code, nw_info = rild_client.get_current_network_info()	
	if ret_nw_info_code ~= 0 then	
		print("Error=1;")
	else		
		if nw_info.nBearer == 0 or nw_info.nBearer == 11 then
			service_status="No service"		
		else
			if nw_info.nRoamState == 1 then
				service_status="Roaming"
			elseif nw_info.nRoamState == 0 then
				service_status="Registered"
			elseif nw_info.nRoamState == 2 then
				service_status="Searching"
			elseif nw_info.nRoamState == 3 then
				service_status="Unregistered"
			else
				service_status="Unknown"
			end
		end	
			
		print("Error=0;ServiceStatus=" .. service_status .. ";")
	end

end

function GetNetworkLTEBand()
	
	rild_client_lib = assert(package.loadlib("/usr/lib/librild_client.so", "luaopen_rild_client"))
	rild_client_lib()
	
	local ret_code, band_info = rild_client.get_network_lte_band_ex()	
	if ret_code ~= 0 then	
		print("Error=1;")
	else		
		if band_info.nMode == 8 then
			local lteband = ""
			if band_info.nBand == 120 then
				lteband = "2100"
			elseif band_info.nBand == 121 then
				lteband = "1900"
			elseif band_info.nBand == 122 then
				lteband = "1800"
			elseif band_info.nBand == 124 then
				lteband = "850"
			elseif band_info.nBand == 126 then
				lteband = "2600"
			elseif band_info.nBand == 127 then
				lteband = "900"
			elseif band_info.nBand == 128 then
				lteband = "1700"
			elseif band_info.nBand == 131 or band_info.nBand == 132 or band_info.nBand == 134 then
				lteband = "700"
			elseif band_info.nBand == 133 then
				lteband = "Safety Band 700"
			elseif band_info.nBand == 145 then
				lteband = "800ED"
			elseif band_info.nBand == 146 then
				lteband = "1500"
			elseif band_info.nBand == 140 then
				lteband = "2600"
			elseif band_info.nBand == 141 then
				lteband = "1900"
			elseif band_info.nBand == 142 then
				lteband = "2300"
			elseif band_info.nBand == 149 then
				lteband = "2600"
			elseif band_info.nBand == 150 then
				lteband = "3500"
			end

			print("Error=0;LTEBand=" .. lteband .. ";")		
		else
			print("Error=0;LTEBand= ;")
		end		
		
	end


end

function main()
	if table.getn(arg) >= 1 then
		local methods = rawget(_G["tr069_extend_api"], arg[1])
		if methods ~= nil then
			methods(unpack(arg, 2))
		end
	end
end

main()


