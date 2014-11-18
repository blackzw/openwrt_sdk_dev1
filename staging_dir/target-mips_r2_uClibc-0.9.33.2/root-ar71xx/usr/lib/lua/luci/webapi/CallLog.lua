module("luci.webapi.CallLog", package.seeall)

local common = require('luci.webapi.common')

--common.LoadRildClientLibrary()

--[[ 
Request data:{}
@Req param list:
{
	"Type":1
}

Response data:{}
@Rsp param list: {
	"CallLogList":[{
			"Id":1,
			"TelNumber":"13003219876",
			"TelName":"TYQ",
			"Time":34856,
			"Duration":121,
			"Type":1		
			},...
	]
}
]]
function GetCallLogList(req)
	if req["Type"] == nil then
		errs = common.GetCommonErrorObject(common.ReturnCode.RILD_ERRID_BAD_PARAMETER)
		return nil, errs
	end

	local rsp = {}
	rsp["CallLogList"] = {}
	local ret_code, call_list = rild_client.get_call_log_list(req["Type"])
	-- get call log list
	if ret_code == 0  then
		if call_list == nil or call_list.calllogList == nil then
			return luci.json.null
		end
		for i=1,table.getn(call_list.calllogList) do  
			nwItem = {}
			nwItem["Id"] = call_list.calllogList[i]["nId"]
			nwItem["TelNumber"] = call_list.calllogList[i]["strTelNumber"]
			nwItem["TelName"] = call_list.calllogList[i]["strTelName"]
			nwItem["Time"] = call_list.calllogList[i]["nStartTime"]
			nwItem["DurationTime"] = call_list.calllogList[i]["nDuration"]
			nwItem["Type"] = call_list.calllogList[i]["nType"]
			
			rsp["CallLogList"][i] = nwItem
		end

		return rsp
	end
	--error response
	errs = common.GetCommonErrorObject(ret_code)
	if errs == nil then
		errs = {code=110101, message="Get call log list failed"}
	end
	return nil, errs
   --return rsp
end

--[[ 
Request data:{}
@Req param list:
{
	"Id":1
}

Response data:{}
]]
function DeleteCallLog(req)
	if req["Id"] == nil then
			errs = common.GetCommonErrorObject(common.ReturnCode.RILD_ERRID_BAD_PARAMETER)
			return nil, errs
	end
	local ret_code = rild_client.delete_call_log_item(req["Id"])
	if ret_code == 0  then
		return luci.json.null
	else
		--error code 
		errs = common.GetCommonErrorObject(ret_code)
		if errs == nil then
			errs = {code=110201, message="Delete call log failed"}
		end
		return nil, errs
	end
end


--[[ 
Request data:{}
@Req param list:
{
	"Type":1
}

Response data:{}
]]
function ClearCallLog(req)
	if req["Type"] == nil then
			errs = common.GetCommonErrorObject(common.ReturnCode.RILD_ERRID_BAD_PARAMETER)
			return nil, errs
	end
	local ret_code = rild_client.clear_call_logs(req["Type"])
	if ret_code == 0  then
		return luci.json.null
	else
		--error code 
		errs = common.GetCommonErrorObject(ret_code)
		if errs == nil then
			errs = {code=110301, message="Clear call log failed"}
		end
		return nil, errs
	end
end




