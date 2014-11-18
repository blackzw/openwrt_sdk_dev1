module("luci.webapi.Update", package.seeall)
require("luci.fs")
require('luci.util')
local bit=require('luci.webapi.bit')
local common = require('luci.webapi.common')

local upgrade_indicator="/tmp/system_upgrade"

--common.LoadRildClientLibrary()

function SetFOTAStartCheckVersion(req)
	local ret_code = rild_client.system_module_multistep_upgrade(0, 0)

	if ret_code == 0  then
		return luci.json.null
	else
		--error code 
		errs = common.GetCommonErrorObject(ret_code)
		if errs == nil then
			errs = {code=220201, message="Set FOTA start check Version failed."}
		end
		return nil, errs
	end

end

function SetFOTAStartDownload(req)
	local ret_code = rild_client.system_module_multistep_upgrade(1, 1)

	if ret_code == 0  then
		return luci.json.null
	else
		--error code 
		errs = common.GetCommonErrorObject(ret_code)
		if errs == nil then
			errs = {code=220401, message="Set FOTA Start Download failed."}
		end
		return nil, errs
	end

end

function SetFOTADownloadStop(req)
	local ret_code = rild_client.system_module_multistep_upgrade(1, 0)

	if ret_code == 0  then
		return luci.json.null
	else
		--error code 
		errs = common.GetCommonErrorObject(ret_code)
		if errs == nil then
			errs = {code=220501, message="Set FOTA Download stop failed."}
		end
		return nil, errs
	end

end

function SetDeviceStartUpdate(req)
	local ret_code = rild_client.system_module_multistep_upgrade(2, 1)

	if ret_code == 0  then
		return luci.json.null
	else
		--error code 
		errs = common.GetCommonErrorObject(ret_code)
		if errs == nil then
			errs = {code=220601, message="Set Device start update failed."}
		end
		return nil, errs
	end

end

--[[ 
Request data:{}
Response data:{}
]]
function StartFOTAUpgradeOneStep(req)

	--if luci.fs.isfile(upgrade_indicator) then
	--	return nil, {code=220802, message="Upgrade already started"}
	--end

	local ret_code = rild_client.system_module_upgrade()

	if ret_code == 0  then
		return luci.json.null
	else
		--error code 
		errs = common.GetCommonErrorObject(ret_code)
		if errs == nil then
			errs = {code=220801, message="Start Fota upgrade failed"}
		end
		return nil, errs
	end

end


--[[ 
Request data:{}
Response data:
@Rsp param "nStep":0,
@Rsp param "nStatus":0,
@Rsp param "nInfo":0
]]
function GetFOTAUpgradeState(req)

	local ret_code, up_state = rild_client.get_system_module_upgrade_status()

	if ret_code == 0 then
		local rsp = {nStep=-1, nStatus=-1, nInfo=-1}
		if bit.bit:_and(up_state.nMask, 0x1) > 0 then
			rsp["nStep"] = up_state.nStep			
		end
		
		if bit.bit:_and(up_state.nMask, 0x2) > 0 then
			rsp["nStatus"] = up_state.nStatus		
		end

		if bit.bit:_and(up_state.nMask, 0x4) > 0 then			
			rsp["nInfo"] = up_state.nInfo		
		end

		return rsp
	else
		--error code 
		errs = common.GetCommonErrorObject(ret_code)
		if errs == nil then
			errs = {code=220901, message="Get fota upgrade state failed"}
		end
		return nil, errs
	end

end

