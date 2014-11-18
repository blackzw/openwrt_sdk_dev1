module("luci.webapi.SIM", package.seeall)

local common = require('luci.webapi.common')

--common.LoadRildClientLibrary()

--[[ Response data:
@Rsp param "Imsi":"460080000000",
@Rsp param "Iccid":"123456789123456",
@Rsp param "MSISDN":"12345678912",
@Rsp param "SIMState":1,
@Rsp param "PinOperationalState":1,
@Rsp param "PinRemainingTimes":3,
@Rsp param "PukRemainingTimes":10
@Rsp param "PinState":1,
]]
--[[ sim lock value
{"PH-FSIM PIN", PIN_STATE_PHFSIM_PIN},
{"PH-FSIM PUK", PIN_STATE_PHFSIM_PUK},
{"PH-SIM PIN", PIN_STATE_PHSIM_PIN},
{"PH-NET PIN", PIN_STATE_PHNET_PIN},
{"PH-NET PUK", PIN_STATE_PHNET_PUK},
{"PH-NETSUB PIN", PIN_STATE_PHNETSUB_PIN},
{"PH-NETSUB PUK", PIN_STATE_PHNETSUB_PUK},
{"PH-SP PIN", PIN_STATE_PHSP_PIN},
{"PH-SP PUK", PIN_STATE_PHSP_PUK},
{"PH-CORP PIN", PIN_STATE_PHCORP_PIN},
{"PH-CORP PUK", PIN_STATE_PHCORP_PUK},

]]
function GetSimStatus(req)
	local rsp = {}
	local ret_eq_info_code, eq_info = rild_client.get_system_equipment_info()
	--get equipment error 
	if ret_eq_info_code ~= 0 then 
		errs = common.GetCommonErrorObject(ret_eq_info_code)
		if errs == nil then
			errs = {code=30201, message="Get SIM status failed"}
		end
		return nil, errs
	end 
	
	local ret_iccid_code, iccid = rild_client.get_system_iccid()
		--get iccid error 
	if ret_iccid_code ~= 0 then 
		errs = common.GetCommonErrorObject(ret_iccid_code)
		if errs == nil then
			errs = {code=30201, message="Get SIM status failed"}
		end
		return nil, errs
	end 
	
	local ret_pin_info_code, pin_info = rild_client.check_pin_state()
	--get pin info error 
	if ret_pin_info_code ~= 0 then 
		errs = common.GetCommonErrorObject(ret_pin_info_code)
		if errs == nil then
			errs = {code=30201, message="Get SIM status failed"}
		end
		return nil, errs
	end 
	
	local ret_pin_state_code, pin_state = rild_client.get_pin_enabled()
		--get pin state error 
	if ret_pin_info_code ~= 0 then 
		errs = common.GetCommonErrorObject(ret_pin_state_code)
		if errs == nil then
			errs = {code=30201, message="Get SIM status failed"}
		end
		return nil, errs
	end 
	
	
	rsp["Imsi"] = eq_info.strImsi
	rsp["MSISDN"] = eq_info.strMsisdn
	rsp["Iccid"] = iccid.strICCID
	rsp["SimLockState"] = -1 --no sim lock	
	rsp["SimlockTimes"] = 0    --sim lock times
	if pin_info.nState == 0 then
		rsp["SIMState"] = 0    	--no sim
		rsp["PinState"] = 0      --pin Not available
	elseif pin_info.nState == 1 then
		rsp["SIMState"] = 3    	--sim ready
	elseif pin_info.nState == 2 then
		rsp["SIMState"] = 1    	--pin required 
	elseif pin_info.nState == 3 then
		rsp["SIMState"] = 2    	--puk required 
		rsp["PinState"] = 3      --3: PIN required puk
	elseif pin_info.nState == 4 then
		rsp["SIMState"] = 6    	--sim lock 
		rsp["PinState"] = 0      --pin Not available
		rsp["SimLockState"] = 4		-- PCK 
		rsp["SimlockTimes"] = pin_info.nPinCnt 
	elseif pin_info.nState == 5 then
		rsp["SIMState"] = 6    	--sim lock 
		rsp["PinState"] = 0      --pin Not available
		rsp["SimLockState"] = 4		-- PCK 
		rsp["SimlockTimes"] = pin_info.nPinCnt 
	elseif pin_info.nState == 6 then
		rsp["SIMState"] = 6    	--sim lock 
		rsp["PinState"] = 0      --pin Not available
		rsp["SimLockState"] = 15	--rck
		rsp["SimlockTimes"] = pin_info.nPukCnt    --sim lock times 
	elseif pin_info.nState == 9 then
		rsp["SIMState"] = 6    	--sim lock 
		rsp["PinState"] = 0      --pin Not available
		rsp["SimLockState"] = 0		-- nck
		rsp["SimlockTimes"] = pin_info.nPinCnt 
	elseif pin_info.nState == 10 then
		rsp["SIMState"] = 6    	--sim lock 
		rsp["PinState"] = 0      --pin Not available
		rsp["SimLockState"] = 16		-- rck
		rsp["SimlockTimes"] = pin_info.nPukCnt    --sim lock times
	elseif pin_info.nState == 11 then
		rsp["SIMState"] = 6    	--sim lock 
		rsp["PinState"] = 0      --pin Not available
		rsp["SimLockState"] = 1   --nsck	
		rsp["SimlockTimes"] = pin_info.nPinCnt 
	elseif pin_info.nState == 12 then
		rsp["SIMState"] = 6    	--sim lock 
		rsp["PinState"] = 0      --pin Not available
		rsp["SimLockState"] = 17		-- rck
		rsp["SimlockTimes"] = pin_info.nPukCnt    --sim lock times
	elseif pin_info.nState == 13 then
		rsp["SIMState"] = 6    	--sim lock 
		rsp["PinState"] = 0      --pin Not available
		rsp["SimLockState"] = 2   --SPCK 	
		rsp["SimlockTimes"] = pin_info.nPinCnt 
	elseif pin_info.nState == 14 then
		rsp["SIMState"] = 6    	--sim lock 
		rsp["PinState"] = 0      --pin Not available
		rsp["SimLockState"] = 18		-- rck
		rsp["SimlockTimes"] = pin_info.nPukCnt    --sim lock times
	elseif pin_info.nState == 15 then
		rsp["SIMState"] = 6    	--sim lock 
		rsp["PinState"] = 0      --pin Not available
		rsp["SimLockState"] = 3		-- CCK 
		rsp["SimlockTimes"] = pin_info.nPinCnt 
	elseif pin_info.nState == 16 then
		rsp["SIMState"] = 6    	--sim lock 
		rsp["PinState"] = 0      --pin Not available
		rsp["SimLockState"] = 19		-- rck
		rsp["SimlockTimes"] = pin_info.nPukCnt    --sim lock times
	elseif pin_info.nState == 17 then
		rsp["SIMState"] = 6    	--sim lock 
		rsp["PinState"] = 0      --pin Not available
		rsp["SimLockState"] = 30		-- rck
	else
		rsp["SIMState"] = 5    	--Unknown 
		rsp["PinState"] = 0      --pin Not available
	end
		
		rsp["PinRemainingTimes"] = pin_info.nPinCnt  
		rsp["PukRemainingTimes"] = pin_info.nPukCnt 	
		rsp["PinOperationalState"] = pin_state.bEnabled   --pin state  for shanghai apps
		
		if pin_state.bEnabled == 0 then
		   rsp["PinState"] = 1    --1: PIN disable 
		elseif pin_state.bEnabled == 1 then
		   rsp["PinState"] = 2    --1: PIN enable
		end

	return rsp
end


--[[ Response data:{}
@Req post param "Pin": "",
]]
function UnlockPin(req)
	local pin_code = req["Pin"]
	if pin_code == nil then
		errs = {code=7, message="Bad parameter"}
		return nil, errs
	else
		local ret_code, rsp = rild_client.verify_pin_code(pin_code)
		if ret_code == 0 then
			return luci.json.null
		end
		errs = common.GetCommonErrorObject(ret_code)
		if errs == nil then
			errs = {code=30201, message="Invalid Pin"}
		end
		return nil, errs
	end
end

--[[ Response data:{}
@Req post param "Pin": "",
@Req post param "Puk": "",
]]
function UnlockPuk(req)
	local new_pin = req["Pin"]
	local puk_code = req["Puk"]
	if new_pin == nil or puk_code == nil then
		errs = {code=7, message="Bad parameter"}
		return nil, errs
	else
		local ret_code, rsp = rild_client.verify_pin_puk_code(new_pin, puk_code)
		if ret_code == 0 then
			return luci.json.null
		end
		errs = common.GetCommonErrorObject(ret_code)
		if errs == nil then
			errs = {code=30301, message="Invalid Puk"}
		end
		return nil, errs
	end
end

--[[ Response data:{}
@Req post param "NewPin": "",
@Req post param "CurrentPin": "",
]]
function ChangePin(req)
	local new_pin = req["NewPin"]
	local old_pin = req["CurrentPin"]
	if new_pin == nil or old_pin == nil then
		errs = {code=7, message="Bad parameter"}
		return nil, errs
	else
		local ret_code, rsp = rild_client.change_pin_code(new_pin, old_pin)
		if ret_code == 0 then
			return luci.json.null
		end
		errs = common.GetCommonErrorObject(ret_code)
		if errs == nil then
			errs = {code=30401, message="Change Pin failed"}
		end
		return nil, errs
	end
end

--[[ Response data:{}
@Req post param "NewPin": "",
@Req post param "CurrentPin": "",
]]
function ChangePinState(req)
	local pin_code = req["Pin"]
	local state = req["State"]
	if pin_code == nil or state == nil then
		errs = {code=7, message="Bad parameter"}
		return nil, errs
	else
		local ret_code, rsp = rild_client.set_pin_enabled(state, pin_code)
		if ret_code == 0 then
			return luci.json.null
		end
		errs = common.GetCommonErrorObject(ret_code)
		if errs == nil then
			errs = {code=30501, message="Change Pin state failed"}
		end
		return nil, errs
	end
end

--[[ Response data:
@Rsp param "State": ""
]]
function GetAutoEnterPinState(req)
	local rsp = {}
	local ret_code, pin_sate = rild_client.get_auto_pin_state()
	if ret_code == 0 then
		rsp["State"] = pin_sate.nState
		return rsp
	end
	
	errs = common.GetCommonErrorObject(ret_code)
	if errs == nil then
		errs = {code=30601, message="Get auto pin State failed"}
	end
	return nil, errs
end

--[[ Response data:{}
@Req post param "State": "",
@Req post param "Pin": "",
]]
function SetAutoEnterPinState(req)
	local pin_code = req["Pin"]
	local state = req["State"]
	if pin_code == nil or state == nil then
		errs = {code=7, message="Bad parameter"}
		return nil, errs
	else
	--Verify pin code
		local rsp_code = rild_client.change_pin_code(pin_code, pin_code)
		if rsp_code ~= 0 then
			errs = common.GetCommonErrorObject(rsp_code)
			if errs == nil then
				errs = {code=30703, message="Verify pin code failed"}
				return nil, errs
			end
		end
		--set auto pin
		local ret_code, rsp = rild_client.set_auto_pin_state(state, pin_code)
		if ret_code == 0 then
			return luci.json.null
		end
		errs = common.GetCommonErrorObject(ret_code)
		if errs == nil then
			errs = {code=30701, message="Set auto pin State failed"}
		end
		return nil, errs
	end
end


--[[ Response data:{}
@Req post param "State": "",
@Req post param "Pin": "",
]]
function UnlockSimlock(req)
	local state = req["SimLockState"]
	local lock_code = req["SimLockCode"]
	if state == nil or lock_code == nil then
		errs = {code=7, message="Bad parameter"}
		return nil, errs
	else
	--Verify sim lock code
		local ret_code, rsp = rild_client.verify_pin_code(lock_code)
		if ret_code == 0 then
			return luci.json.null
		end
		errs = common.GetCommonErrorObject(ret_code)
		if errs == nil then
			errs = {code=30801, message="Unlock sim lock failed"}
		end
		return nil, errs
	end
end