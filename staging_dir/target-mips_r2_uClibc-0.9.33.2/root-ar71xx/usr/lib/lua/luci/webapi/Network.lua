module("luci.webapi.Network", package.seeall)

local common = require('luci.webapi.common')

--common.LoadRildClientLibrary()

--[[ Response data:
@Rsp "PLMN":"26202",
@Rsp "NetworkType":1,
@Rsp "NetworkName":¡±¡±,
@Rsp "SpnName":¡±¡±,
@Rsp "LAC":"",
@Rsp "CellId":"",
@Rsp "RncId":"",
@Rsp "Roaming":0,
@Rsp "SignalStrength":1,
]]
function GetNetworkInfo()
	local rsp = {}
	local ret_nw_info_code, nw_info = rild_client.get_current_network_info()
	local ret_lc_code, lc_info = rild_client.get_network_lac_cellid()
	--get network info error 
	if ret_nw_info_code ~= 0 then 
		errs = common.GetCommonErrorObject(ret_nw_info_code)
		if errs == nil then
			errs = {code=40101, message="Get network information data error"}
		end
		return nil, errs
	end 
	
	--get location info error 
	if ret_lc_code ~= 0 then 
		errs = common.GetCommonErrorObject(ret_lc_code)
		if errs == nil then
			errs = {code=40101, message="Get network information data error"}
		end
		return nil, errs
	end 
	
	--network type 
	rsp["NetworkType"] = nw_info.nBearer
	rsp["NetworkName"] = nw_info.strOperator
	rsp["SpnName"] = nw_info. strSpName  
	rsp["LAC"] = lc_info.nLac									--Reserved this filed, not implemented. Return value is empty string currently 	
	rsp["CellId"] = lc_info.nCellID   							--Reserved this filed, not implemented. Return value is empty string currently
	rsp["RncId"] = ""  											--Reserved this filed, not implemented. Return value is empty string currently
	if nw_info.nRoamState == 1 then
		rsp["Roaming"] = 1 		--roaming state
	else
		rsp["Roaming"] = 0 		--no roaming
	end
	  
	rsp["SignalStrength"] = nw_info.nRssi
	rsp["PLMN"] = nw_info.strOperator
	return rsp
end

--[[ Response data:{}
@Rsp {}
]]
function SearchNetwork(req)
	local ret_nw_code = rild_client.search_network_async()
	if ret_nw_code == 0 then
		return luci.json.null
	end
	errs = common.GetCommonErrorObject(ret_nw_code)
	if errs == nil then
		errs = {code=40201, message="Search network failed"}
	end
	return nil, errs
end

--[[ Response data:{}
@Rsp "SearchState":0,
@Rsp "ListNetworkItem":[{¡°NetworkID¡±:12,"State":0,"Numberic":¡±46001¡±,"Rat":¡±¡±,"FullName":¡±¡±,"ShortName":¡±¡±},...]

]]
function SearchNetworkResult(req)
	local rsp = {}
	local nwlist = {}
	local ret_nw_code, nw_info = rild_client.get_search_network_result()
	
	-- get network list
	if ret_nw_code == 0 and nw_info ~= nil then
		if nw_info.listNetworkItem ~= nil then 
			for i=1,table.getn(nw_info.listNetworkItem) do
				nwItem = {}
				nwItem["NetworkID"] = nw_info.listNetworkItem[i]["nIndex"]						-- net id  
				nwItem["State"] = nw_info.listNetworkItem[i]["nState"]
				nwItem["Numberic"] = nw_info.listNetworkItem[i]["strNumericAlpha"]         --plmn
				if nw_info.listNetworkItem[i]["nAct"] <= 1 or nw_info.listNetworkItem[i]["nAct"] == 3 then 
					nwItem["Rat"] = 1								--GSM/2G
				elseif nw_info.listNetworkItem[i]["nAct"] >= 4 and nw_info.listNetworkItem[i]["nAct"] <= 6 or nw_info.listNetworkItem[i]["nAct"] == 2 then 
					nwItem["Rat"] = 2								--UMTS/3G  
				elseif nw_info.listNetworkItem[i]["nAct"] == 7 then 
					nwItem["Rat"] = 3								--LTE/4G  
				elseif nw_info.listNetworkItem[i]["nAct"] == 8 then
					nwItem["Rat"] = 4								--Unknown
				end
				nwItem["FullName"] = nw_info.listNetworkItem[i]["strLongAlpha"]
				nwItem["ShortName"] = nw_info.listNetworkItem[i]["strShortAlpha"]
				
				nwlist[i] = nwItem
				
			end
		
		
			if ret_nw_code ~= 0 then
				--error response
				errs = common.GetCommonErrorObject(ret_nw_code)
				if errs == nil then
					errs = {code=40301, message="Get result failed"}
				end
				return nil, errs
			end
		
		end 
	
		
			rsp = {ListNetworkItem=nwlist, SearchState=nw_info.nState}
			return rsp
	else
		--error response
		errs = common.GetCommonErrorObject(ret_nw_code)
		if errs == nil then
			errs = {code=40301, message="Get result failed"}
		end
		return nil, errs
		
	end


end


--[[ Response data:
@Rsp param "NetworkMode":"0",
@Rsp param "NetselectionMode":"0",
]]
function GetNetworkSettings(req)
	local rsp = {}
	--[[local ret_nw_info_code, nw_info = rild_client.get_current_network_info()
	local ret_mode_code, nw_mode = rild_client.get_network_mode()
	--get network info error 
	if ret_nw_info_code ~= 0 then 
		errs = common.GetCommonErrorObject(ret_nw_info_code)
		if errs == nil then
			errs = {code=40501, message="Get network setting failed"}
		end
		return nil, errs
	end --]]
	
	local ret_mode_code, nw_info = rild_client.get_network_mode_ex()
	-- get network mode error
	if ret_mode_code ~= 0 or nw_info == nil then 
		errs = common.GetCommonErrorObject(ret_mode_code)
		if errs == nil then
			errs = {code=40501, message="Get network setting failed"}
		end
		return nil, errs
	end 

	rsp["NetselectionMode"] = nw_info.nSearchMode 
	if nw_info.nMode == 0 then
		rsp["NetworkMode"] = 0					--auto 
	elseif 	nw_info.nMode == 3 then
		rsp["NetworkMode"] = 1					--2g only 
	elseif 	nw_info.nMode == 1 then
		rsp["NetworkMode"] = 2					--3g only 
	elseif 	nw_info.nMode == 7 then
		rsp["NetworkMode"] = 3					--4g/LTE only
	end
	return rsp
end


--[[ Response data:
@Req post param "NetworkMode":"0",
@Req post param "NetselectionMode":"0",
]]
function SetNetworkSettings(req)
	local net_mode = req["NetworkMode"]
	local sel_mode = req["NetselectionMode"]
	local nw_mode_tmp = 0
	local mask = 1        -- only set mode
	if net_mode == nil or sel_mode == nil then
		errs = {code=7, message="Bad parameter"}
		return nil, errs
	else
	    -- convert to ril interface value
		if net_mode == 0 then
			nw_mode_tmp = 0				--auto
		elseif net_mode == 1 then
			nw_mode_tmp = 3				--2g only
		elseif net_mode == 2 then
			nw_mode_tmp = 1				--3g only 
		elseif net_mode == 3 then
			nw_mode_tmp = 7				--4g/LTE only
		end
		-- call ril interface set value
--[[		local ret_code = rild_client.set_network_mode(nw_mode_tmp) 
			local res_code = rild_client.set_network(1, sel_mode, 0, "", 0)     --only set sel mode ,other will be default
		
			if ret_code ~= 0  then
							--error code 
				errs = common.GetCommonErrorObject(res_code)
				if errs == nil then
					errs = {code=40703, message="Set network settings selection failed"}
					return nil, errs
				end
			end	--]]	
		local ret_code = rild_client.set_network_mode_ex(nw_mode_tmp, sel_mode) 
		if ret_code == 0  then
			return luci.json.null
		end
			--error code 
		errs = common.GetCommonErrorObject(ret_code)
		if errs == nil then
			errs = {code=40701, message="Set network settings failed"}
			return nil, errs
		end
		
	end
end


--[[ Response data:
@Req post param "NetworkID":"1",
]]
function RegisterNetwork(req)
	local net_id = req["NetworkID"]
	if net_id == nil then
		errs = {code=7, message="Bad parameter"}
		return nil, errs
	else
		local ret_code = rild_client.register_network(net_id)     
		if ret_code == 0 then
			return luci.json.null
		end
			--error code 
		errs = common.GetCommonErrorObject(ret_code)
		if errs == nil then
			errs = {code=40401, message="Register network fail"}
		end
		return nil, errs
	end
end

--[[ Response data:
@Rsp param "NetworkMode":"0",
@Rsp param "NetselectionMode":"0",
]]
function GetNetworkRegisterState(req)
	local rsp = {}
	local ret_reg_code, reg_state = rild_client.get_network_reg_state()

	--get register network state error 
	if ret_reg_code ~= 0 then 
		errs = common.GetCommonErrorObject(ret_reg_code)
		if errs == nil then
			errs = {code=40501, message="Get register network state failed"}
		end
		return nil, errs
	end 
	--rsp["nState"] = reg_state.nState
	if reg_state.nState == 0 then
		rsp["State"] = 0														--not regiseter 
	elseif 	reg_state.nState == 1 then
		rsp["State"] = 1														--registting
	elseif 	reg_state.nState == 2 or reg_state.nState == 5 then
		rsp["State"] = 3														--registration failed 
	elseif 	reg_state.nState == 3 or reg_state.nState == 4 then
		rsp["State"] = 2														--register successful
	end
	return rsp
end
