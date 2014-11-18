module("luci.webapi.SMS", package.seeall)

local common = require("luci.webapi.common")

--common.LoadRildClientLibrary()

--[[
Request data:
@Req param "Type":0
@Req param "Page":1
Response data:
@Rsp param "Id":2
@Rsp param "StoreIn":0
@Rsp param "Tag":0
@Rsp param "Content":"Hello world"
@Rsp param "Number":"12377595499"
@Rsp param "Time":"2014-01-03 09:12:22"
--]]
function GetSmsList(req)
        local smsType = req["Type"]
	local page = req["Page"]
        if smsType == nil or page == nil then
		return nil, {code=7, message="Bad parameter for rild."}
	end
	local ret_code_sms, response = rild_client.get_sms_list(smsType, page)
	if ret_code_sms == 0 then
        	res = {}
        	res["Type"] = req["Type"]
        	res["Page"] = req["Page"]
        	res["SmsList"] = {}
		for i=1,table.getn(response.SmsItemList) do
			msgItem = {}
			msgItem["Id"] = response.SmsItemList[i]["nRef"]
			msgItem["StoreIn"] = response.SmsItemList[i]["nStoreIn"]
			msgItem["Tag"] = response.SmsItemList[i]["nTag"]
			msgItem["Content"] = response.SmsItemList[i]["strContent"]
			msgItem["Number"] = response.SmsItemList[i]["strNumber"]
			msgItem["Time"] = response.SmsItemList[i]["strDateTime"]
			res["SmsList"][i] = msgItem
		end
        	return res
	else
		errs = common.GetCommonErrorObject(ret_code_sms)
		if errs == nil then
			errs = {code=60101, message="Get sms list failed."}
		end
		return nil, errs
	end
end

--[[
Request data:
@Req param: "Id":1
@Req param: "StoreIn":1
Response data:{}
--]]
function DeleteSms(req)	
	local id = req["Id"]
--	local storeIn = req["StoreIn"]     or storeIn == nil 
	if id == nil then
		return nil, {code=7, message="Bad parameter for rild."}
	end
	local ret_code_sms = rild_client.delete_sms(id)
	if ret_code_sms == 0 then
	     	return luci.json.null
	else 
		errs = common.GetCommonErrorObject(ret_code_sms)
		if errs == nil then
			errs = {code=60201, message="Delete sms failed."}
		end
		return nil, errs
	end 
end

--[[
Request data:
@Req param: "Id":-1
@Req param: "Content":"Hello World"
@Req param: "PhoneNumber":"123354322"
@Req param: "Priority":"Normal"
Response data: 
@Rsp param: "SmsSendId":1
--]]
function SendSms(req)
	local id = req["Id"]
	local number = req["PhoneNumber"]
	local content = req["Content"]
	local priority = req["Priority"]
	if id == nil or number == nil or content == nil or priority == nil then
		return nil, {code=7, message="Bad parameter for rild."}
	end
	local ret_code_sms, response = rild_client.send_sms(id, number, content, priority)
	if ret_code_sms == 0 then
		res = {}
		res["SmsSendId"] = response["SmsSendId"]
		return res
	else
		errs = common.GetCommonErrorObject(ret_code_sms)
		if errs == nil then
			errs = {code=60301, message="Send sms failed."}
		end
		return nil, errs
	end     
end

--[[
Request data:
@Req param: "Id":0
@Req param: "Status":0
Response data: {}
--]]
function ModifySmsReadStatus(req)
	local id = req["Id"]
	local status = req["Status"]
	if id == nil or status == nil then
		return nil, {code=7, message="Bad parameter for rild."}
	end
	local ret_code_sms = rild_client.modify_sms_tag(id, status)
	if ret_code_sms == 0 then
		return luci.json.null
	else
		errs = common.GetCommonErrorObject(ret_code_sms)
		if errs == nil then
			errs = {code=60401, message="Modify sms read status failed."}
		end
		return nil, errs
	end
end

--[[
Request data:
@Req param: "SmsSendId":1
Response data:
@Rsp param: "SendStatus":0
--]]
function GetSendSmsResult(req)
	local sendId = req["SmsSendId"]
	if sendId == nil then
		return nil, {code=7, message="Bad parameter for rild."}
	end
	local ret_code_sms, response = rild_client.get_sms_send_progress_info(sendId)
	if ret_code_sms == 0 then
		res = {}
		res["SendStatus"] = response["SendStatus"]
		return res
	else
		errs = common.GetCommonErrorObject(ret_code_sms)
		if errs == nil then
			errs = {code=60501, message="Get sending sms status failed."}
		end
		return nil, errs
	end
end

--[[
Request data:
@Req param: "Id":-1
@Req param: "Number":"1234456664"
@Req param: "Content":"Hello World"
Response data: {}
--]]
function SaveSms(req)
	local id = req["Id"]
	local number = req["Number"]
	local content = req["Content"]
	if id == nil or number == nil or content == nil then
		return nil, {code=7, message="Bad parameter for rild."}
	end
	local ret_code_sms = rild_client.save_sms(id, number, content)
	if ret_code_sms == 0 then
		return luci.json.null
	else
		errs = common.GetCommonErrorObject(ret_code_sms)
		if errs == nil then
			errs = {code=60601, message="Save sms failed."}
		end
		return nil, errs
	end
end

--[[
Request data: {}
Response data:
@Rsp param: "SmsReportSwitch":0
@Rsp param: "StoreFlag":0
@Rsp param: "SmsCenter":"13888888888"
--]]
function GetSmsSettings(req)
	local ret_code_sms, response = rild_client.get_sms_settings()
        if ret_code_sms == 0 then
		res = {}
		res["SmsReportSwitch"] = response["SmsReportSwitch"]
		res["StoreFlag"] = response["StoreFlag"]
		res["SmsCenter"] = response["SmsCenter"]
		return res
	else
		errs = common.GetCommonErrorObject(ret_code_sms)
		if errs == nil then
			errs = {code=60701, message="Get sms settings failed."}
		end
		return nil, errs
	end
end

--[[
Request data: 
@Req param: "SmsReportSwitch":0
@Req param: "StoreFlag":0
@Req param: "SmsCenter":"13888888888"
Response data: {}
--]]
function SetSmsSettings(req)
	local report = req["SmsReportSwitch"]
	local storeFlag = req["StoreFlag"]
	local smsCenter = req["SmsCenter"]
	if report == nil or storeFlag == nil or smsCenter == nil then
		return nil, {code=7, message="Bad parameter for rild."}
	end
	local ret_code_sms = rild_client.set_sms_settings(report, storeFlag, smsCenter)
	if ret_code_sms == 0 then
		return luci.json.null
	else
		errs = common.GetCommonErrorObject(ret_code_sms)
		if errs == nil then
			errs = {code=60801, message="Set sms settings failed."}
		end
		return nil, errs
	end
end

--[[
Request data:{}
Response data:
@Rsp param: "Total":100
@Rsp param: "Used":10
--]]
function GetSmsStorageState(req)
	local ret_code_sms, response = rild_client.get_sms_storage_info()
	if ret_code_sms == 0 then
		res = {}
		res["SimTotal"] = response["SimTotal"]
		res["SimUsed"] = response["SimUsed"]
		res["DeviceTotal"] = response["DeviceTotal"]
		res["DeviceUsed"] = response["DeviceUsed"]
		return res
	else
		errs = common.GetCommonErrorObject(ret_code_sms)
		if errs == nil then
			errs = {code=60901, message="Get sms storage state failed."}
		end
		return nil, errs
	end
end

--[[
Request data:
@Req param: "Type":0
Response data:
@Rsp param: "SmsCount":100
--]]
function GetSmsCount(req)
	local smsType = req["Type"]
	if smsType == nil then
		return nil, {code=7, message="Bad parameter for rild."}
	end
	local ret_code_sms, response = rild_client.get_sms_count(smsType)
	if ret_code_sms == 0 then
		res = {}
		res["SmsCount"] = response["SmsCount"]
		return res
	else
		errs = common.GetCommonErrorObject(ret_code_sms)
		if errs == nil then
			errs = {code=61001, message="Get sms count failed."}
		end
		return nil, errs
	end
end
