module("luci.webapi.SysUpgrade", package.seeall)

local common = require("luci.webapi.common")
local webapiUtil = require("luci.webapi.Util")
local upgradeFile = "/tmp/system_upgrade"
common.LoadRildClientLibrary()

function CheckFileExist(path)
	local exist = webapiUtil.Exec("test -e " .. path .. " && echo '1' || echo '0'", 1)
	if exist["result"] ~= nil and exist["result"]() == '1' then
		return true
	end
	return false
end

function CheckUpgrading()
	return CheckFileExist(upgradeFile)
end

function CreateUpgradingFile()
	webapiUtil.Exec("touch " .. upgradeFile)
	
	return CheckFileExist(upgradeFile)
end

function CheckATPort()
	local path = webapiUtil.GetValue("rild_service","SerialPort","PortFile")
	
	return CheckFileExist(path)
end

function UpgradeModem(req)
	local ret = rild_client.system_module_upgrade()
	if ret == 0 then
		return true
	end
	return false
end

local upgradeStatus={}
upgradeStatus["nStep"]=0
upgradeStatus["nStatus"]=0
upgradeStatus["nInfo"]=0
upgradeStatus["atPort"]=true

function WriteLog(umask)
	webapiUtil.Exec("echo \"umask " .. umask .. "\" >> " ..  upgradeFile)
	if (umask ~= 0) then
		webapiUtil.Exec("echo \"nStep " .. upgradeStatus["nStep"] .. "\" >> " ..  upgradeFile)
	end

	if (umask == 3 or umask == 7) then
		webapiUtil.Exec("echo \"nStatus " .. upgradeStatus["nStatus"] .. "\" >> " ..  upgradeFile)
	end

	if (umask == 7) then
		webapiUtil.Exec("echo \"nInfo " .. upgradeStatus["nInfo"] .. "\" >> " ..  upgradeFile)
	end
end

function GetUpgradeStatus(req)
	local ret = true
	local ret_code, status = rild_client.get_system_module_upgrade_status()
	if ret_code == 0 then
		local umask = status["nMask"]
		if (umask ~= 0) then
			upgradeStatus["nStep"] = status["nStep"]
		end
		if (umask == 3 or umask == 7) then
			upgradeStatus["nStatus"] = status["nStatus"]
		end
		if (umask == 7) then
			upgradeStatus["nInfo"] = status["nInfo"]
		end
		
		WriteLog(umask)
		--error
		if (umask == 3 or umask == 7) and ((upgradeStatus["nStep"] == 0 and upgradeStatus["nStatus"] == 0) or 
		   (upgradeStatus["nStep"] == 1 and upgradeStatus["nStatus"] == -1)) then
			ret = false
		end

		--don't need upgrade or enter recovery mode
		if (umask == 3 or umask == 7) and ((upgradeStatus["nStep"] == 2 and upgradeStatus["nStatus"] == 0) or 
		   (upgradeStatus["nStep"] == 2 and upgradeStatus["nStatus"] == 3)) then
			ret = false
		end 
	else
		ret = false
	end
	
	return ret
end

--[[
Request data:
@Req param: "ImagePath":"/tmp/sysgrade.bin"
@Req param: "SaveConfig": "1"
Response data:
-1: failed
0: success
1: upgrading with other
--]]
function UpgradeFirmware(req)
	local path = req["ImagePath"]
	if path == nil then
		return -1
	end
	local ret = CheckUpgrading()
	if ret == true then
		return 1
	end
	CreateUpgradingFile()
	ret = UpgradeModem()
	if ret == true then
		local complete = false
		local retryCount = 1
		while true do
			local status = GetUpgradeStatus()
			if status == false then
				break
			end
			if upgradeStatus["nStep"] == 2 and upgradeStatus["nStatus"] == 3 then
				complete = true
				break
			end
			if upgradeStatus["nStep"] == 0 then
				if retryCount > 300 then
					break
				end
				retryCount = retryCount+1
			end
			webapiUtil.Sleep(1)
		end
	
		while complete do
			local atExist = CheckATPort()
			if atExist and upgradeStatus["atPort"] == false then
				break
			end
			upgradeStatus["atPort"] = atExist
			
			webapiUtil.Sleep(1)
		end
	end

	local saveConfig = req["SaveConfig"]
	local command = "/sbin/sysupgrade "
	if saveConfig == "0" then
		command = command .. "-n "
	end
	command = command .. path
 	ret = webapiUtil.Exec(command, 1)
	if ret["result"] == nil or ret["result"]() ~= "Upgrade completed" then
		webapiUtil.Exec("rm -f " .. upgradeFile)
		return -1
	end
	return 0
end

local req = {}
req["ImagePath"] = arg[1]
if table.getn(arg) > 1 then
	req["SaveConfig"] = arg[2]
else
	req["SaveConfig"] = "0"
end
UpgradeFirmware(req)
