module("luci.webapi.Profile", package.seeall)

local common = require('luci.webapi.common')

--common.LoadRildClientLibrary()

--[[ Response data:{}
@Rsp param list: [{"ProfileID":1,
		"ProfileName":"China Unicom",
		"APN":"3gnet",
		"UserName":"china",
		"AuthType":0,
		"DailNumber":"*99#"
		"Password":"1234",	
		"Default":1,
		"IsPredefine":1,
		},...
]]
function GetProfileList(req)
	local rsp = {}
	local ret_profile_code, pro_list = rild_client.get_profile_list()
	-- get profile list
	if ret_profile_code == 0  then
		if pro_list == nil then
			return luci.json.null
		end
		for i=1,table.getn(pro_list.profileList) do  
			nwItem = {}
			nwItem["ProfileID"] = pro_list.profileList[i]["nProfileId"]
			if pro_list.profileList[i]["strProfileName"] == nil then
				nwItem["ProfileName"] = ""         --profile name
			else
				nwItem["ProfileName"] = pro_list.profileList[i]["strProfileName"]         --profile name
			end
			if pro_list.profileList[i]["strApn"] == nil then
				nwItem["APN"] = ""
			else
				nwItem["APN"] = pro_list.profileList[i]["strApn"]
			end
			if pro_list.profileList[i]["nAuthType"] == nil then
				nwItem["AuthType"] =0
			else
				nwItem["AuthType"] = pro_list.profileList[i]["nAuthType"]
			end
			if pro_list.profileList[i]["strUserName"] == nil then
				nwItem["UserName"] = ""
			else
				nwItem["UserName"] = pro_list.profileList[i]["strUserName"]
			end
			if pro_list.profileList[i]["strPasswd"] == nil then
				nwItem["Password"] = ""
			else
				nwItem["Password"] = pro_list.profileList[i]["strPasswd"]
			end
			if pro_list.profileList[i]["strDialNumber"] == nil then
				nwItem["DailNumber"] = ""
			else
				nwItem["DailNumber"] = pro_list.profileList[i]["strDialNumber"]
			end
			if pro_list.profileList[i]["bIsPreDefined"] == nil then
				nwItem["IsPredefine"] = 0
			else
				nwItem["IsPredefine"] = pro_list.profileList[i]["bIsPreDefined"]
			end
			if pro_list.profileList[i]["bIsActive"] == nil then
				nwItem["Default"] = 0               --1 default ,0 not default
			else
				nwItem["Default"] = pro_list.profileList[i]["bIsActive"]                 --1 default ,0 not default
			end
			
			--nwItem["PdpAddr"] = pro_list.profileList[i]["strPdpAddr"]
			--nwItem["PdpAddr"] = pro_list.profileList[i]["strPdpAddr"]
			--nwItem["DComp"] = pro_list.profileList[i]["nDComp"]
			--nwItem["HComp"] = pro_list.profileList[i]["nHComp"]
			--nwItem["IsActive"] = pro_list.profileList[i]["bIsActive"]
			rsp[i] = nwItem
		end

		return rsp
	end
		--error response
		errs = common.GetCommonErrorObject(ret_profile_code)
	if errs == nil then
		errs = {code=90101, message="Get profile list failed"}
	end
	return nil, errs
   --return rsp
end


--[[ Response data:{}
]]
function AddNewProfile(req)
	local profile_name = req["ProfileName"]
	local apn = req["APN"]
	local user_name = req["UserName"]
	local password = req["Password"]
	local auth_type = req["AuthType"]
	local dail_number = req["DailNumber"]					--Reserved this filed
	
	if profile_name == nil or apn == nil or user_name == nil or password == nil or auth_type == nil then
		errs = {code=7, message="Bad parameter"}
		return nil, errs
	end
	-- default params
	local ret_code = rild_client.add_new_profile_item("IP", apn, "0.0.0.0", 0, 0, auth_type, user_name, password, profile_name, dail_number)
	--local ret_code = rild_client.add_new_profile_item("IP", "3gnet", "0.0.0.0", 0, 0, 2, "9876", "6789","tyq")

	if ret_code == 0  then
		return luci.json.null
	else
			--error code 
		errs = common.GetCommonErrorObject(ret_code)
		if errs == nil then
			errs = {code=90201, message="Add new profile failed"}
		end
		return nil, errs
	end
	
end


--[[ Response data:
@Req post param "ProfileID":1,
@Req post param	"ProfileName":¡±China Unicom¡±,
@Req post param	"APN":¡±3gnet¡±,
@Req post param	"UserName":¡±china¡±,
@Req post param	"Password":¡±1234¡±,	
@Req post param¡°AuthType¡±:¡±¡±,
@Req post param¡°DailNumber¡±:¡±*99#¡±
]]
function EditProfile(req)
	local profile_id = req["ProfileID"]
	local profile_name = req["ProfileName"]
	local apn = req["APN"]
	local user_name = req["UserName"]
	local password = req["Password"]
	local auth_type = req["AuthType"]
	local dail_number = req["DailNumber"]					--Reserved this filed

	if profile_name == nil or apn == nil or user_name == nil or password == nil or auth_type == nil or profile_id == nil then
		errs = {code=7, message="Bad parameter"}
		return nil, errs
	end
	
	-- default params
	local ret_code = rild_client.update_profile_item(profile_id, "IP", apn, "0.0.0.0", 0, 0, auth_type, user_name, password, profile_name, dail_number)
	if ret_code == 0  then
		return luci.json.null
	else
			--error code 
		errs = common.GetCommonErrorObject(ret_code)
		if errs == nil then
			errs = {code=90301, message="Edit profile failed"}
		end
		return nil, errs
	end
end


--[[ Response data:
@Req post param "ProfileID":1,
]]
function DeleteProfile(req)
	local profile_id = req["ProfileID"]
	if profile_id == nil then
		errs = {code=7, message="Bad parameter"}
		return nil, errs
	end
	-- default params
	local ret_code = rild_client.delete_profile_item(profile_id)

	if ret_code == 0  then
		return luci.json.null
	else
			--error code 
		errs = common.GetCommonErrorObject(ret_code)
		if errs == nil then
			errs = {code=90401, message="Delete profile failed"}
		end
		return nil, errs
	end
end


--[[ Response data:
@Req post param "ProfileID":1,
]]
function SetDefaultProfile(req)
	local profile_id = req["ProfileID"]
	if profile_id == nil then
		errs = {code=7, message="Bad parameter"}
		return nil, errs
	end
	-- default params
	local ret_code = rild_client.set_default_profile_item(profile_id)

	if ret_code == 0  then
		return luci.json.null
	else
			--error code 
		errs = common.GetCommonErrorObject(ret_code)
		if errs == nil then
			errs = {code=90501, message="Set default profile failed"}
		end
		return nil, errs
	end
end
