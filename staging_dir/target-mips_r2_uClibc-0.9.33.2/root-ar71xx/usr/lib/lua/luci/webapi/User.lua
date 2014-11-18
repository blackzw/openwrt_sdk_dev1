module("luci.webapi.User", package.seeall)

local sys = require("luci.sys")
local sauth   = require("luci.sauth")
local ltn12   = require("luci.ltn12")
local util    = require("luci.util")
local uci = require('luci.model.uci').cursor()
local nixio = require "nixio"
local fs = require "luci.fs"

require("luci.webapi.Util")

--[[Request data:
@Req param "Username": "user",
@Req param "Password": "pwd"

Response data:
@Rsp param "Tokens":"1234567890abcde"
]] 
function Login(req)
	local rsp = {}
	local server = {}
	local user = req["Username"]
	local pass = req["Password"]
	if user == nil or pass == nil then
		errs = {code=7, message="Bad parameter"}
		return nil, errs
	end
	local state = sauth.loginstate()
	if state == 1 then
		errs = {code=101023, message="Other user logined"}
		return nil, errs
	end
		
	local function check_login(user, pass)
		local sid, token, secret
		if sys.user.checkpasswd(user, pass) then
			sid = sys.uniqueid(16)
			token = sys.uniqueid(16)
			secret = sys.uniqueid(16)
--			luci.http.header("Set-Cookie", "Login=" .. sid.."; path=/")
			sauth.reap()
			sauth.write(sid, {
				user=user,
				token=token,
				secret=secret
			})	
		end
		return sid and {sid=sid, token=token, secret=secret}
	end
	server.challenge = check_login(user, pass)
	-- login fail
	if server.challenge == nil then
		errs = {code=10102, message="login failed"}
		return nil, errs
	end
	--login ok
	 server.login = function(...)
		local challenge = server.challenge(...)
		return challenge and challenge.sid
	end
	

	rsp["Tokens"] = server.challenge.token
	rsp["Login"] = server.challenge.sid
	return rsp
end



--[[Request data:


Response data:
@Rsp param "Tokens":"1234567890abcde"
@Rsp param "UserName":"root'
]]
function Logout()
	local dsp = require "luci.dispatcher"
	local rsp = {}
	rsp["UserName"]="admin"
	rsp["Tokens"]=""
	local ipaddr = sauth.get_client_ipaddr()
	local pathTable = fs.dir("/tmp/luci-sessions")
	if pathTable == nil then
		return rsp
	end

	for n=1,table.getn(pathTable) do
		local fileName = pathTable[n]
		if fileName ~= "." and fileName ~= ".." then
			local sess = sauth.readsession(fileName)
			if sess ~= nil then
				if sess.login_ip == ipaddr then
					luci.util.exec("rm /tmp/luci-sessions/" .. fileName)
					rsp["UserName"]=sess.user
					rsp["Tokens"]=sess.token
					return rsp
				else
					errs = {code=10301, message="Logout failed"}
					return nil, errs
				end
			end
		end
	end
	return rsp 
end

--[[Response data:
@Rsp param "Tokens":"1234567890abcde"
@Rsp param "state":0
]]
function GetLoginState()
	local rsp = {}
	local state = sauth.loginstate()
	rsp["State"] = state
	--if state == 2 then      --2 is login ,but same ip so can login in the same computer
	--	rsp["State"] = 1
	--end
	return rsp
end

--[[Request data:
@Req param "UserName": "root",
@Req param "NewPassword": "pwd"

Response data:
@Rsp param "Tokens":"1234567890abcde"
]]
function ChangePassword(req)
	local rsp = {}
	local user_name = req["UserName"]
	local pwd = req["NewPassword"]
	local currpwd = req["CurrPassword"]
	if user_name == nil  or pwd == nil then
		errs = {code=7, message="Bad parameter"}
		return nil, errs
	end
	if luci.sys.user.checkpasswd(user_name, currpwd) == false then
		errs = {code=10402, message="Current password failed"}
		return nil, errs 
	end
	if luci.sys.user.setpasswd(user_name, pwd) ~= 0 then                --root default user name
		errs = {code=10401, message="Change password failed"}
		return nil, errs
	end
	
        --if user_name same as admin then Synchronize samba password
	if user_name == "admin" then
		luci.webapi.Util.ChangeSMBPassword(user_name, pwd)
	end
	uci:set("login", "config", "username", user_name)
	uci:set("login", "config", "password", pwd)
	uci:save("login")
	uci:commit("login")
	
	return rsp
end

--[[Response data:
@Rsp param 
@Rsp param nil
]]
function UpdateLoginTime(req)
	local sid = req["sysauth"]
	if sid == nil  or sid == "" then
		errs = {code=7, message="Bad parameter"}
		return nil, errs
	end
	--sauth.updatelogintime()
--	local state = sauth.loginstate()
--	if state == 1 or  state == 2 then
		--[[atime = luci.sys.uptime()
		local f = nixio.open("/tmp/session-time", "w", 600)
		f:writeall(atime)
		f:close()--]]
		sauth.read(sid)
--	end
	return luci.json.null
end
