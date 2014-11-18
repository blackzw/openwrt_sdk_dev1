module("luci.webapi.Statistics", package.seeall)

local common = require("luci.webapi.common")

--common.LoadConnectManagerClient()

--[[
Request data:
@Req param "StartDay":"2014-03-11"
@Req param "EndDay":"2014-03-12"
Response data:
@Rsp param "Id":0
@Rsp param "Date":"2014-03-11"
@Rsp param "DownloadBytes":1234
@Rsp param "UploadBytes":1234
--]]
function GetUsageHistory(req)
	local startDay, endDay = req["StartDay"], req["EndDay"]
	if startDay == nil or endDay == nil then
		return nil, {code=7, message="Bad parameter for connect manager."}
	end
        local ret_code, response = connect_manager_client.get_usage_history(startDay, endDay)
        if ret_code == 0 then
        	res = {}
                res["UsageHistoryList"] = {}
                for i=1,table.getn(response.UsageHistoryList) do
                        item = {}
                        item["Id"] = response.UsageHistoryList[i]["Id"]
                        item["Date"] = response.UsageHistoryList[i]["Date"]
                        item["DownloadBytes"] = tonumber(response.UsageHistoryList[i]["DownloadBytes"])
                        item["UploadBytes"] = tonumber(response.UsageHistoryList[i]["UploadBytes"])
                        res["UsageHistoryList"][i] = item
		end
        	return res
	else
                errs = common.GetCommonErrorObjectForStatistics(ret_code)
		if errs == nil then
                        errs = {code=70101, message="Get usage history list failed."}
		end
		return nil, errs
	end
end

--[[
Request data:{}
Response data:
@Rsp param "BillingDay":1
--]]
function GetBillingDay(req)
        local ret_code, response = connect_manager_client.get_billing_day()
        if ret_code == 0 then
                res = {}
                res["BillingDay"] = tonumber(response["BillingDay"])
                return res
	else 
                errs = common.GetCommonErrorObjectForStatistics(ret_code)
		if errs == nil then
                        errs = {code=70201, message="Get billing day failed."}
		end
		return nil, errs
	end 
end

--[[
Request data:
@Req param: "BillingDay":1
Response data:{}
--]]
function SetBillingDay(req)
	local billingDay = req["BillingDay"]
	if billingDay == nil then
		return nil, {code=7, message="Bad parameter for connect manager."}
	end
        local ret_code = connect_manager_client.set_billing_day(billingDay)
        if ret_code == 0 then
                return luci.json.null
	else
                errs = common.GetCommonErrorObjectForStatistics(ret_code)
		if errs == nil then
                        errs = {code=70301, message="Set billing day failed."}
		end
		return nil, errs
	end     
end

--[[
Request data:{}
Response data:
@Rsp param "CalibrationValue":1
--]]
function GetCalibrationValue(req)
        local ret_code, response = connect_manager_client.get_calibration_value()
        if ret_code == 0 then
                res = {}
                res["CalibrationValue"] = tonumber(response["CalibrationValue"])
                return res
        else
                errs = common.GetCommonErrorObjectForStatistics(ret_code)
                if errs == nil then
                        errs = {code=70401, message="Get calibration value failed."}
                end
                return nil, errs
        end
end

--[[
Request data:
@Req param: "CalibrationValue":55
Response data:{}
--]]
function SetCalibrationValue(req)
	local calibrationValue = req["CalibrationValue"]
	if calibrationValue == nil then
		return nil, {code=7, message="Bad parameter for connect manager."}
	end
        local ret_code = connect_manager_client.set_calibration_value(calibrationValue)
        if ret_code == 0 then
                return luci.json.null
        else
                errs = common.GetCommonErrorObjectForStatistics(ret_code)
                if errs == nil then
                        errs = {code=70501, message="Set calibration value failed."}
                end
                return nil, errs
        end
end

--[[
Request data:{}
Response data:
@Rsp param "LimitValue":55
--]]
function GetLimitValue(req)
        local ret_code, response = connect_manager_client.get_limit_value()
        if ret_code == 0 then
                res = {}
                res["LimitValue"] = tonumber(response["LimitValue"])
                return res
        else
                errs = common.GetCommonErrorObjectForStatistics(ret_code)
                if errs == nil then
                        errs = {code=70601, message="Get limit value failed."}
                end
                return nil, errs
        end
end

--[[
Request data:
@Req param: "LimitValue":55
Response data:{}
--]]
function SetLimitValue(req)
	local limitValue = req["LimitValue"]
	if limitValue == nil then
		return nil, {code=7, message="Bad parameter for connect manager."}
	end
        local ret_code = connect_manager_client.set_limit_value(limitValue)
        if ret_code == 0 then
                return luci.json.null
        else
                errs = common.GetCommonErrorObjectForStatistics(ret_code)
                if errs == nil then
                        errs = {code=70701, message="Set limit value failed."}
                end
                return nil, errs
        end
end

--[[
Request data:{}
Response data:
@Rsp param "TotalValue":55
--]]
function GetTotalValue(req)
        local ret_code, response = connect_manager_client.get_total_value()
        if ret_code == 0 then
                res = {}
                res["TotalValue"] = tonumber(response["TotalValue"])
                return res
        else
                errs = common.GetCommonErrorObjectForStatistics(ret_code)
                if errs == nil then
                        errs = {code=70801, message="Get total value failed."}
                end
                return nil, errs
        end
end

--[[
Request data:
@Req param: "TotalValue":1
Response data:{}
--]]
function SetTotalValue(req)
	local totalValue = req["TotalValue"]
	if totalValue == nil then
		return nil, {code=7, message="Bad parameter for connect manager."}
	end
        local ret_code = connect_manager_client.set_total_value(totalValue)
        if ret_code == 0 then
                return luci.json.null
        else
                errs = common.GetCommonErrorObjectForStatistics(ret_code)
                if errs == nil then
                        errs = {code=70901, message="Set total value failed."}
                end
                return nil, errs
        end
end

--[[
Request data:
@Req param: "UsageAlert":0
Response data:{}
--]]
function SetUsageAlert(req)
	local usageAlert = req["UsageAlert"]
	if usageAlert == nil then
		return nil, {code=7, message="Bad parameter for connect manager."}
	end
        local ret_code = connect_manager_client.set_usage_alert(usageAlert)
        if ret_code == 0 then
                return luci.json.null
        else
                errs = common.GetCommonErrorObjectForStatistics(ret_code)
                if errs == nil then
                        errs = {code=71901, message="Set usage alert failed."}
                end
                return nil, errs
        end
end

--[[
Request data:{}
Response data:
@Rsp param "BillingDay":1
@Rsp param "CalibrationValue":55
@Rsp param "LimitValue":55
@Rsp param "TotalValue":55
@Rsp param "Overtime":3
@Rsp param "OvertimeState":0
@Rsp param "OverflowState":0
@Rsp param "UsageAlert":0
--]]
function GetUsageSettings(req)
        local ret_code, response = connect_manager_client.get_usage_settings()
        if ret_code == 0 then
                res = {}
                res["BillingDay"] = tonumber(response["BillingDay"])
                res["CalibrationValue"] = tonumber(response["CalibrationValue"])
                res["LimitValue"] = tonumber(response["LimitValue"])
                res["TotalValue"] = tonumber(response["TotalValue"])
                res["Overtime"] = tonumber(response["Overtime"])
                res["OvertimeState"] = tonumber(response["OvertimeState"])
                res["OverflowState"] = tonumber(response["OverflowState"])
		res["UsageAlert"] = tonumber(response["UsageAlert"])
                return res
        else
                errs = common.GetCommonErrorObjectForStatistics(ret_code)
                if errs == nil then
                        errs = {code=71001, message="Get usage settings failed."}
                end
                return nil, errs
        end
end

--[[
Request data:
@Req param: "DeviceToken":"ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789"
Response data:
@Rsp param: "DeviceToken":"ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789"
@Rsp param: "MacAddress":"64:A7:69:0D:01:4C"
@Rsp param: "OSType":"IOS"
@Rsp param: "Message":"Has exceeded the maximum flow!"
--]]
function GetDevicePushInfo(req)
	local deviceToken = req["DeviceToken"]
	if deviceToken == nil then
		return nil, {code=7, message="Bad parameter for connect manager."}
	end
        local ret_code, response = connect_manager_client.get_device_pushinfo(deviceToken)
        if ret_code == 0 then
                res = {}
                res["DeviceToken"] = response["DeviceToken"]
                res["MacAddress"] = response["MacAddress"]
                res["OSType"] = response["OSType"]
                res["Message"] = response["Message"]
                return res
        else
                errs = common.GetCommonErrorObjectForStatistics(ret_code)
                if errs == nil then
                        errs = {code=71101, message="Get device push information failed."}
                end
                return nil, errs
        end
end

--[[
Request data:
@Req param: "DeviceToken":"ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789"
@Req param: "IP":"192.168.1.180"
@Req param: "OSType":"IOS"
@Req param: "Message":"Has exceeded the maximum flow!"
Response data:{}
--]]
function SetDevicePushInfo(req)
	local deviceToken, ipAddr, osType, message = req["DeviceToken"], req["IP"], req["OSType"], req["Message"]
	if deviceToken == nil or ipAddr == nil or osType == nil or message == nil then
		return nil, {code=7, message="Bad parameter for connect manager."}
	end
        local ret_code = connect_manager_client.set_device_pushinfo(deviceToken, ipAddr, osType, message)
        if ret_code == 0 then
                return luci.json.null
        else
                errs = common.GetCommonErrorObjectForStatistics(ret_code)
                if errs == nil then
                        errs = {code=71201, message="Set device push information failed."}
                end
                return nil, errs
        end
end

--[[
Request data:
@Req param: "DeviceToken":"ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789"
Response data:{}
--]]
function DeleteDevicePushInfo(req)
	local deviceToken = req["DeviceToken"]
	if deviceToken == nil then
		return nil, {code=7, message="Bad parameter for connect manager."}
	end
        local ret_code = connect_manager_client.delete_device_pushinfo(deviceToken)
        if ret_code == 0 then
                return luci.json.null
        else
                errs = common.GetCommonErrorObjectForStatistics(ret_code)
                if errs == nil then
                        errs = {code=71301, message="Delete device push information failed."}
                end
                return nil, errs
        end
end

--[[
Request data:{}
Response data:{}
--]]
function ClearAllRecords(req)
        local ret_code = connect_manager_client.clear_all_records()
        if ret_code == 0 then
                return luci.json.null
        else
                errs = common.GetCommonErrorObjectForStatistics(ret_code)
                if errs == nil then
                        errs = {code=71401, message="Clear all records failed."}
                end
                return nil, errs
        end
end

--[[
Request data:
@Req param: "Overtime":1
Response data:{}
--]]
function SetDisconnectOvertime(req)
	local overtime = req["Overtime"]
	if overtime == nil then
		return nil, {code=7, message="Bad parameter for connect manager."}
	end
        local ret_code = connect_manager_client.set_overtime(overtime)
        if ret_code == 0 then
                return luci.json.null
        else
                errs = common.GetCommonErrorObjectForStatistics(ret_code)
                if errs == nil then
                        errs = {code=71501, message="Set auto disconnect overtime failed."}
                end
                return nil, errs
        end
end

--[[
Request data:
@Req param: "OvertimeState":0
Response data:{}
--]]
function SetDisconnectOvertimeState(req)
	local overtimeState = req["OvertimeState"]
	if overtimeState == nil then
		return nil, {code=7, message="Bad parameter for connect manager."}
	end
        local ret_code = connect_manager_client.set_overtime_state(overtimeState)
        if ret_code == 0 then
                return luci.json.null
        else
                errs = common.GetCommonErrorObjectForStatistics(ret_code)
                if errs == nil then
                        errs = {code=71601, message="Set auto disconnect overtime state failed."}
                end
                return nil, errs
        end
end

--[[
Request data:
@Req param: "OverflowState":0
Response data:{}
--]]
function SetDisconnectOverflowState(req)
	local overflowState = req["OverflowState"]
	if overflowState == nil then
		return nil, {code=7, message="Bad parameter for connect manager."}
	end
        local ret_code = connect_manager_client.set_overflow_state(req["OverflowState"])
        if ret_code == 0 then
                return luci.json.null
        else
                errs = common.GetCommonErrorObjectForStatistics(ret_code)
                if errs == nil then
                        errs = {code=71701, message="Set auto disconnect overflow state failed."}
                end
                return nil, errs
        end
end

--[[
Request data:{}
Response data:
@Rsp param: "LastDuration":10
@Rsp param: "LastUpload":11
@Rsp param: "LastDownload":11
@Rsp param: "LastUsage":22
@Rsp param: "TotalDuration":30
@Rsp param: "TotalUpload":22
@Rsp param: "TotalDownload":22
@Rsp param: "TotalUsage":44
@Rsp param: "ClearTime":"12"
--]]
function GetHistoryStatistics(req)
        local ret_code, response = connect_manager_client.get_history_statistics()
        if ret_code == 0 then
                res = {}
                res["LastDuration"] = response["LastDuration"]
                res["LastUpload"] = response["LastUpload"]
                res["LastDownload"] = response["LastDownload"]
                res["LastUsage"] = response["LastUsage"]
                res["TotalDuration"] = response["TotalDuration"]
                res["TotalUpload"] = response["TotalUpload"]
                res["TotalDownload"] = response["TotalDownload"]
                res["TotalUsage"] = response["TotalUsage"]
                res["ClearTime"] = response["ClearTime"]
                return res
        else
                errs = common.GetCommonErrorObjectForStatistics(ret_code)
                if errs == nil then
                        errs = {code=71801, message="Get history statistics failed."}
                end
                return nil, errs
        end
end

--[[
Request data:{}
Response data:
@Rsp param "DownloadBytes":1234
@Rsp param "UploadBytes":1234
--]]
function GetCurrentMonthUsage(req)
        local ret_code, response = connect_manager_client.get_current_month_usage()
        if ret_code == 0 then
        	res = {}
                res["DownloadBytes"] = tonumber(response["DownloadBytes"])
                res["UploadBytes"] = tonumber(response["UploadBytes"])
        	return res
	else
                errs = common.GetCommonErrorObjectForStatistics(ret_code)
		if errs == nil then
                        errs = {code=72001, message="Get current month usage history failed."}
		end
		return nil, errs
	end
end
