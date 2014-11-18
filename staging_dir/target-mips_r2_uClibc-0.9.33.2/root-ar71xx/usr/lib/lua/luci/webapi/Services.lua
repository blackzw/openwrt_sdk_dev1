module("luci.webapi.Services", package.seeall)
require("luci.sys")
require('luci.util')
local common = require("luci.webapi.common")

ServiceTypes =
{
	"SAMBA", -- 0
    "DLNA", -- 1
    "FTP", -- 2
	"RILD" -- 3
}

ServiceTypes = common.CreateEnumTable(ServiceTypes, 0)

--[[
Request data:
@Req param "ServiceType":0

Response data:
@Rsp param "State":1
@Rsp param "ServiceType":1
--]]
function GetServiceState(req)
	local service_type = req["ServiceType"]
	local rsp = {}
	local errs = nil
	if service_type == nil then
		errs = common.GetCommonErrorObject(common.ReturnCode.RILD_ERRID_BAD_PARAMETER)
		return nil, errs	
	end

	local service_name = get_service_name(service_type)	

	if service_name == nil then
		errs = common.GetCommonErrorObject(common.ReturnCode.RILD_ERRID_BAD_PARAMETER)
		return nil, errs	
	end

	if is_enabled_service(service_name)	then
		rsp["State"] = 1
	else
		rsp["State"] = 0
	end

	rsp["ServiceType"] = service_type

	return rsp
end


--[[
Request data:
@Req param "ServiceType":0
@Req param "State":1
--]]
function SetServiceState(req)
	local service_type = req["ServiceType"]
	local state = req["State"]
	local errs = nil
	if service_type == nil or state == nil then
		errs = common.GetCommonErrorObject(common.ReturnCode.RILD_ERRID_BAD_PARAMETER)
		return nil, errs	
	end

	local service_name = get_service_name(service_type)		

	if service_name == nil then
		errs = common.GetCommonErrorObject(common.ReturnCode.RILD_ERRID_BAD_PARAMETER)
		return nil, errs	
	end

	if (is_enabled_service(service_name) and state == 1) or (not is_enabled_service(service_name) and state == 0) then
		-- already closed or opened: do nothing here
	else
		if state == 0 then
			if not disable_service(service_name) then
				return nil, {code=100301, message="Set service state failed"}
			end
			luci.sys.call("/etc/init.d/" .. service_name .. " stop >/dev/null 2>&1 &")			
		else
			if not enable_service(service_name) then
				return nil, {code=100301, message="Set service state failed"}
			end
			luci.sys.call("/etc/init.d/" .. service_name .. " start >/dev/null 2>&1 &")
		end		
		
	end

	return luci.json.null
end

--[[
Request data:
@Req param "ServiceType":0
--]]
function RestartService(req)

	local service_type = req["ServiceType"]
	local errs = nil
	if service_type == nil then
		errs = common.GetCommonErrorObject(common.ReturnCode.RILD_ERRID_BAD_PARAMETER)
		return nil, errs	
	end

	local service_name = get_service_name(service_type)		

	if service_name == nil then
		errs = common.GetCommonErrorObject(common.ReturnCode.RILD_ERRID_BAD_PARAMETER)
		return nil, errs	
	end

	restart_service(service_name)

	return luci.json.null
end

function restart_service(service_name)
	luci.sys.call("/etc/init.d/" .. service_name .. " restart >/dev/null 2>&1 &")
end

function is_enabled_service(stype)
	local init_enabled = luci.sys.init.enabled(stype)
	local uci = require("luci.model.uci").cursor()
	local res = uci:get(stype, "config", "enabled")
	if res == nil or res == "0" then
		return false
	else
		if not init_enabled then
			luci.sys.call("/etc/init.d/" .. stype .. " enable >/dev/null 2>&1")
			restart_service(stype)						
		end
		return true
	end

end

function disable_service(stype)
	if luci.sys.init.disable(stype) then
		local uci = require("luci.model.uci").cursor()
		uci:set(stype, "config", "enabled", "0")
		uci:save(stype)
		uci:commit(stype)
		return true
	end

	return false
end

function enable_service(stype)
	if luci.sys.init.enable(stype) then
		local uci = require("luci.model.uci").cursor()
		uci:set(stype, "config", "enabled", "1")
		uci:save(stype)
		uci:commit(stype)
		return true
	end

	return false
end

function get_service_name(stype)
	if stype == ServiceTypes.SAMBA then
		return "samba"
	elseif stype == ServiceTypes.DLNA then
		return "minidlna"
	elseif stype == ServiceTypes.FTP then
		return "vsftpd"
	elseif stype == ServiceTypes.RILD then
		return "rild"
	else
		return nil
	end
end

function get_device_type(dir)
	local dtype = 2

	--if dir ~= nil and luci.util.cmatch(dir, "sd[a-z][0-9]") > 0 then
	if dir ~= nil and dir == "/mnt/usb" then
		dtype = 1
	elseif dir ~= nil and dir == "/mnt/airdisk" then
		--TODO: judge mm100 path
		dtype = 0
	end

	return dtype
end

function get_dir_by_device_type(dType)
	local media_path = ""
	local flag = false
	if dType == 0 then
		--TODO: set mm100 media_path
		flag = true
		media_path = "/mnt/airdisk"
	elseif dType == 1 then
		
		flag = true
		media_path = "/mnt/usb"
		--local m = luci.sys.mounts()
		--for i=1, table.getn(m) do
		--	if m[i]["fs"] ~= nil and m[i]["mountpoint"] ~= nil then
		--			if luci.util.cmatch(m[i]["fs"], "/dev/sd[a-z][0-9]") > 0 then
		--				media_path = m[i]["mountpoint"]
		--				flag = true
		--				break	
		--			end	
		--	end
		--end

	end

	return flag, media_path
end

Samba = {}
--[[
Request data:{}

Response data:
@Rsp param "HostName":"Openwrt"
@Rsp param "Description":"Openwrt"
@Rsp param "WorkGroup":"WORKGROUP"
@Rsp param "AccessPath":"smb://192.168.1.1/"
@Rsp param "DevType":0
@Rsp param "Anonymous":0
@Rsp param "UserName":"admin"
@Rsp param "Password":"admin"
@Rsp param "AuthType":0
--]]
function Samba.GetSettings(req)
	local uci = require("luci.model.uci").cursor()
	local service_name = get_service_name(ServiceTypes.SAMBA)
	local hostname = uci:get(service_name, "config", "name")
	local description = uci:get(service_name, "config", "description")
	local workgroup = uci:get(service_name, "config", "workgroup")
	local accesspath = ""

	--local netm = require "luci.model.network".init()	
	--local net = netm:get_network("lan")
	--local device = net and net:get_interface()
	local addr = g_http_request_env.SERVER_ADDR
	--if device then
	--	local _, a
	--	for _, a in ipairs(device:ipaddrs()) do
	--		addr = a:host():string()				
	--	end
	--end

	if addr ~= "" then
		accesspath = "smb://" .. addr .. "/"
	end
		
	local users = uci:get(service_name, "config", "users")
	local rdonly = uci:get(service_name, "config", "read_only")
	local anon = uci:get(service_name, "config", "guest_ok")
	local password = uci:get(service_name, "config", "password")
	local dtype = tonumber(uci:get(service_name, "config", "device_type"))

	if anon == "yes" then
		anon = 1
	else
		anon = 0
	end

	if rdonly == "yes" then
		rdonly = 0
	else
		rdonly = 1
	end

	return {HostName=hostname, Description=description, WorkGroup=workgroup, AccessPath=accesspath, DevType=dtype, Anonymous=anon, UserName=users, Password=password, AuthType=rdonly}
end


--[[
Request data:
@Req param "Anonymous":0
@Req param "DevType":1
@Req param "UserName":"admin"
@Req param "Password":"admin"
@Req param "AuthType":0

Response data: {}
--]]
function Samba.SetSettings(req)
	local anon = req["Anonymous"]
	local dtype = req["DevType"]
	--local username = req["UserName"]
	--local password = req["Password"]
	local auth = req["AuthType"]

	if anon == nil or dtype == nil or auth == nil then --password == nil or
		errs = common.GetCommonErrorObject(common.ReturnCode.RILD_ERRID_BAD_PARAMETER)
		return nil, errs
	end
	
	
	local guest_ok = "yes"
	if anon == 0 then
		guest_ok = "no"
	end

	local rdonly = "no"
	if auth == 0 then
		rdonly = "yes"
	end

	local uci = require("luci.model.uci").cursor()
	local service_name = get_service_name(ServiceTypes.SAMBA)
	
	if not uci:set(service_name, "config", "device_type", dtype) then
		return nil, {code=100601, message="Set Samba settings failed, set device type failed"}
	end
	
	if not uci:set(service_name, "config", "read_only", rdonly) then
		return nil, {code=100601, message="Set Samba settings failed, set read_only failed"}
	end
	if not uci:set(service_name, "config", "guest_ok", guest_ok) then
		return nil, {code=100601, message="Set Samba settings failed, set guest_ok failed"}
	end	

	if not uci:save(service_name) then
		return nil, {code=100601, message="Set Samba settings failed, save uci failed"}
	end

	if not uci:commit(service_name) then
		return nil, {code=100601, message="Set Samba settings failed, commit uci failed"}
	end

	if is_enabled_service(service_name) then
		restart_service(service_name)
	end

	return luci.json.null
end

FTP = {}
--[[
Request data:{}

Response data:
@Rsp param "AccessPath":"ftp://192.168.1.1/"
@Rsp param "Anonymous":0
@Rsp param "DevType":1
@Rsp param "UserName":"admin"
@Rsp param "Password":"admin"
@Rsp param "AuthType":0
--]]
function FTP.GetSettings(req)
	local uci = require("luci.model.uci").cursor()
	local service_name = get_service_name(ServiceTypes.FTP)
	local dir = uci:get(service_name, "config", "root_dir")
	local anon = tonumber(uci:get(service_name, "config", "anonymous"))
	local username = uci:get(service_name, "config", "username")
	local auth_type = tonumber(uci:get(service_name, "config", "auth_type"))
	local password = ""
	local accesspath = ""

	--if username ~= nil and username ~= "" then
	--	password = luci.sys.user.getpasswd(username)
	--	if password == nil then
	--		password = ""
	--	end
	--end

	local dtype = get_device_type(dir)

	--local netm = require "luci.model.network".init()	
	--local net = netm:get_network("lan")
	--local device = net and net:get_interface()
	local addr = g_http_request_env.SERVER_ADDR
	--if device then
	--	local _, a
	--	for _, a in ipairs(device:ipaddrs()) do
	--		addr = a:host():string()				
	--	end
	--end

	if addr ~= "" then
		accesspath = "ftp://" .. addr .. "/"
	end

	return {AccessPath=accesspath, Anonymous=anon, DevType=dtype, UserName=username, Password=password, AuthType=auth_type}
end

--[[
Request data:
@Req param "Anonymous":0
@Req param "DevType":1
@Req param "UserName":"admin"
@Req param "Password":"admin"
@Req param "AuthType":0

Response data: {}
--]]
function FTP.SetSettings(req)
	local anon = req["Anonymous"]
	local dtype = req["DevType"]
	--local username = req["UserName"]
	--local password = req["Password"]
	local auth = req["AuthType"]

	if anon == nil or dtype == nil or auth == nil then --password == nil or
		errs = common.GetCommonErrorObject(common.ReturnCode.RILD_ERRID_BAD_PARAMETER)
		return nil, errs
	end

	local flag = false
	local dir = ""

	flag, dir = get_dir_by_device_type(dtype)

	if not flag then
		return nil, {code=101001, message="Set FTP settings failed, device not available"}
	end

	local uci = require("luci.model.uci").cursor()
	local service_name = get_service_name(ServiceTypes.FTP)
	--local username = uci:get(service_name, "config", "username")
	--if luci.sys.user.setpasswd(username, password) >= 1 then
	--	return nil, {code=101001, message="Set FTP settings failed, set password failed"}
	--end

	if not uci:set(service_name, "config", "root_dir", dir) then
		return nil, {code=101001, message="Set FTP settings failed, set root_dir failed"}
	end
	if not uci:set(service_name, "config", "anonymous", anon) then
		return nil, {code=101001, message="Set FTP settings failed, set anonymous failed"}
	end
	if not uci:set(service_name, "config", "auth_type", auth) then
		return nil, {code=101001, message="Set FTP settings failed, set auth_type failed"}
	end
	if not uci:save(service_name) then
		return nil, {code=101001, message="Set FTP settings failed, save uci failed"}
	end

	if not uci:commit(service_name) then
		return nil, {code=101001, message="Set FTP settings failed, commit uci failed"}
	end

	if is_enabled_service(service_name) then
		restart_service(service_name)
	end

	return luci.json.null
end

DLNA = {}
--[[
Request data:{}

Response data:
@Rsp param "FriendlyName":"Openwrt"
@Rsp param "MediaDirectories":"/mnt"
@Rsp param "DevType":1

--]]
function DLNA.GetSettings(req)
	local uci = require("luci.model.uci").cursor()
	local service_name = get_service_name(ServiceTypes.DLNA)
	local fn = uci:get(service_name, "config", "friendly_name")
	if fn == nil then
		fn = ""
	end
	
	local dir = uci:get(service_name, "config", "media_dir")
	if dir == nil then
		dir = ""
	elseif type(dir) == "table" then
		if table.getn(dir) > 0 then
			dir = dir[1]
		else
			dir = ""
		end
	end

	local dtype = get_device_type(dir)

	return {FriendlyName=fn, MediaDirectories=dir, DevType=dtype}
end

--[[
Request data:
@Req param "DevType":0

Response data: {}
--]]
function DLNA.SetSettings(req)
	local dType = req["DevType"]
	local errs = nil
	if dType == nil or dType < 0 or dType > 2 then
		errs = common.GetCommonErrorObject(common.ReturnCode.RILD_ERRID_BAD_PARAMETER)
		return nil, errs	
	end

	local media_path = ""	
	local flag = false

	flag, media_path = get_dir_by_device_type(dType)

	if not flag then
		return nil, {code=100801, message="Set DLNA settings failed, device not available"}
	end

	local uci = require("luci.model.uci").cursor()
	local service_name = get_service_name(ServiceTypes.DLNA)
	
	uci:set(service_name, "config", "media_dir", {media_path})
	uci:save(service_name)
	uci:commit(service_name)

	if is_enabled_service(service_name) then
		restart_service(service_name)
	end

	return luci.json.null
end

TR069 = {}

function TR069.GetClientConfiguration(req)

	local uci = require("luci.model.uci").cursor()
	local configs = {}
        local res = {}
        local usename = nil
        local password = nil
        flags = uci:foreach("easycwmp","acs",
                 function(s)
                    if s[".type"] == "acs" then  
                        configs["AcsUserName"] = s["username"]
                        configs["AcsUserPassword"] = s["password"]
                        res["scheme"] = s["scheme"]
                        res["hostname"] = s["hostname"]
                        res["port"] = s["port"]
                        res["path"] = s["path"]
                        --configs["AcsUrl"] =  res["scheme"].."://"..res["hostname"]..":"..res["port"].."/"..res["path"]
                        configs["AcsUrl"] =  res["scheme"].."://"..res["hostname"]..":"..res["port"]..res["path"]  ---patch to modify "/"
			configs["Inform"] = tonumber(s["periodic_enable"])
			configs["InformInterval"] = tonumber(s["periodic_interval"])
                    end
                 end)

        if flags == false then
            return nil, {code=80201, message="Get Acsname,password and AcsUrl failed"}        
        end     
        

        configs["ConReqAuthent"] = 0            ---The section option is not show currently, consideration is dynamic, or static generation
                                                ---         config ClientRequestAuth 
                                                ---         option ConReqAuthent 1
        configs["ConReqUserName"] = nil         --- 	    option CPEusername 'CPEusername'
	                                        ----        option CPEuserpassword 'CPEuserpassword'
        configs["ConReqUserPassword"] = nil
 
        flags = uci:foreach("easycwmp", "local", 
                    function(s)
                         if (s[".type"] == "local" and s["username"] ~= nil) then 
                             configs["ConReqAuthent"] = 1
                             configs["CPEusername"] = s["username"]
                             configs["ConReqUserPassword"] = s["password"]
                         end
                     end)

   
	return configs
end


function TR069.SetClientConfiguration(req)
      local uci = require("luci.model.uci").cursor()
      local flags = false     

--acs      
      flags = uci:foreach("easycwmp", "acs", 
           function(s)
               if s[".type"] == "acs" then
                   
			uci:set("easycwmp", s[".name"], "periodic_enable", req["Inform"]) 
			uci:set("easycwmp", s[".name"], "periodic_interval", req["InformInterval"]) 
				

                        if not  uci:set("easycwmp", s[".name"], "username",req["AcsUserName"]) then
                           return nil, {code=80101, message="Set Acs and password failed"}     
                        end

                       if not  uci:set("easycwmp", s[".name"], "password",req["AcsUserPassword"]) then
                          return nil, {code=80103, message="Set Acs and password failed"}     
                       end

                       local acsurl = req["AcsUrl"]
                       local a,b,scheme,hostname,port,path = string.find(acsurl,"(%a+)://([%w%p]+):(%d+)/([%w%p]*)") ---Parse the string for exampe:http://172.24.222.56:8009/openacs/acs
                       if scheme == nil or hostname == nil or port == nil then
                       	return nil, {code=80101, message="Set acs url failed"}
                       end
                       if path ~= nil then
                     	  path = "/"..path  ---patch ---2014/03/17 modify /openacs/acs
                       else
                       	  path = "/"
                       end
                       if not (uci:set("easycwmp", s[".name"], "scheme",scheme) and uci:set("easycwmp", s[".name"], "hostname",hostname) and  ---acs modify 
                               uci:set("easycwmp", s[".name"], "port",port) and uci:set("easycwmp", s[".name"], "path",path)) then
                       return nil, {code=80103, message="Set AcsURL failed"}                
                       end
                   -- 
                  return false ---only a acs section 
               end
           end)

--Client      
        flags = uci:foreach("easycwmp", "local", ---section option that is dynamic section 
                    function(s)
                      if s[".type"] == "local" then 
                           if req["ConReqAuthent"] == 1 then
                              if not  uci:set("easycwmp", s[".name"], "username",req["ConReqUserName"]) then
                                   return nil, {code=80102, message="Set CPE and password failed"}     
                               end

                               if not  uci:set("easycwmp", s[".name"], "password",req["ConReqUserPassword"]) then
                                  return nil, {code=80102, message="Set CPE and password failed"}     
                               end
                              else 
                               uci:delete("easycwmp", s[".name"],"username")
                               uci:delete("easycwmp", s[".name"],"password")
                            end
                       end    
                    end)

         uci:save("easycwmp")
	 uci:commit("easycwmp")
	 luci.sys.call("/etc/init.d/easycwmpd restart > /dev/null 2>&1 &") 
        --  luci.sys.call("ubus ${UBUS_SOCKET:+-s $UBUS_SOCKET} call tr069 command reload > /dev/null 2>&1") --Here to send ubus message better. because of having a Cache time
	 return luci.json.null

end

PrivateCloud = {}
--[[
Request data:{}
@Req	"DevType": 0
Response data:
@Rsp param null

--]]
function PrivateCloud.SetStorage(req)
	local common = require('luci.webapi.Util')
	local stype = req["DevType"]
	local devpath = ""
	local item = {}
	if stype == nil or stype == "" then
		errs = {code=7, message="Bad parameter"}
		return nil, errs 
	end
	local ret = common.DeleteSection("private_cloud", "private_cloud")		 --etc/config/private_cloud
	if stype == 1 or stype == "1" then
		devpath = "/mnt/usb"
	elseif stype == 0 or stype == "0" then
		devpath = "/mnt/airdisk"
	else
		devpath = "/mnt/null"
	end
	item["path"] = devpath
	common.AddSection("private_cloud", "private_cloud", nil, item)
	ret = common.SaveFile("private_cloud")
		if ret == false then
				errs = {code=101201, message="Set private cloud failed."}
				return nil, errs
		end
	return luci.json.null
end

--[[
Request data:{}
@Req	null
Response data:
@Rsp param "DevType": 0

--]]
function PrivateCloud.GetStorage(req)
	local common = require('luci.webapi.Util')
	local rsp = {}
	local cloudlist = common.GetValueList("private_cloud", "private_cloud")   --etc/config/private_cloud
	if cloudlist == nil then
		errs = {code=101301, message="Get private cloud failed."}
		return nil, errs
	end
	rsp["DevType"] = 1
	for i=1,table.getn(cloudlist.valuelist) do
				tmp =  cloudlist.valuelist[i]["path"]
				if tmp == "/mnt/usb" then
					rsp["DevType"] = 1
				elseif  tmp == "/mnt/airdisk" then
					rsp["DevType"] = 0
				else
					rsp["DevType"] = 1
				end
	end

	return rsp
end
