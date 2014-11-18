--[[

Session authentication
(c) 2008 Steven Barth <steven@midlink.org>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

$Id: sauth.lua 8900 2012-08-08 09:48:47Z jow $

]]--

--- LuCI session library.
module("luci.sauth", package.seeall)
require("luci.util")
require("luci.sys")
require("luci.config")
local nixio = require "nixio", require "nixio.util"
local fs = require "nixio.fs"
local lucifs = require "luci.fs"


luci.config.sauth = luci.config.sauth or {}
sessionpath = luci.config.sauth.sessionpath
sessiontime = tonumber(luci.config.sauth.sessiontime) or 15 * 60

--Added by Tian Yiqing, Get client ipaddr for webapi, start
function get_client_ipaddr()
	if luci.http == nil or luci.http.request == nil then
		if g_http_request_env ~= nil then
			return g_http_request_env.REMOTE_ADDR
		else 
			return nil
		end
	else
		return luci.http.getenv("REMOTE_ADDR")
	end 
end
--Added by Tian Yiqing, Get client ipaddr for webapi, end

--- Prepare session storage by creating the session directory.
function prepare()
	fs.mkdir(sessionpath, 700)
	if not sane() then
		error("Security Exception: Session path is not sane!")
	end
end

local function _read(id)
	local blob = fs.readfile(sessionpath .. "/" .. id)
	return blob
end

local function _write(id, data)
	local f = nixio.open(sessionpath .. "/" .. id, "w", 600)
	f:writeall(data)
	f:close()
end

local function _checkid(id)
	return not not (id and #id == 32 and id:match("^[a-fA-F0-9]+$"))
end

--- Write session data to a session file.
-- @param id	Session identifier
-- @param data	Session data table
function write(id, data)
	if not sane() then
		prepare()
	end

	assert(_checkid(id), "Security Exception: Session ID is invalid!")
	assert(type(data) == "table", "Security Exception: Session data invalid!")

	data.atime = luci.sys.uptime()
	if data.login_ip == nil then
		data.login_ip = get_client_ipaddr()
	end
	_write(id, luci.util.get_bytecode(data))
end

--- Read a session and return its content.
-- @param id	Session identifier
-- @return		Session data table or nil if the given id is not found
function read(id)
	if not id or #id == 0 then
		return nil
	end

	--modify by lichangqin 2014-06-25 for session id or session file error begin
	--assert(_checkid(id), "Security Exception: Session ID is invalid!")
	if _checkid(id) == false then
		luci.util.exec("mkdir /tmp/crash_log_1")  
--		luci.util.exec("rm /tmp/luci-sessions/*")--session id error,so delete. login again
		return nil
	end

	if not sane(sessionpath .. "/" .. id) then
		return nil
	end

	local blob = _read(id)
	local func = loadstring(blob)
	setfenv(func, {})

	local sess = func()
	--assert(type(sess) == "table", "Session data invalid!")
	if type(sess) == "table" then
		if sess.atime and sess.atime + sessiontime < luci.sys.uptime() then
			kill(id)
--			luci.util.exec("rm /tmp/luci-sessions/*")   modify by lichangqin 2014-3-19
			return nil
		end
	else
		luci.util.exec("mkdir /tmp/crash_log_2")  
		luci.util.exec("rm /tmp/luci-sessions/" .. id)--not table must session file error,so delete. login again
		return nil
	end
	--modify by lichangqin 2014-06-25 for session id or session file error begin
	
	-- refresh atime in session
	write(id, sess)

	return sess
end

--- Check whether Session environment is sane.
-- @return Boolean status
function sane(file)
	return luci.sys.process.info("uid")
			== fs.stat(file or sessionpath, "uid")
		and fs.stat(file or sessionpath, "modestr")
			== (file and "rw-------" or "rwx------")
end

--- Kills a session
-- @param id	Session identifier
function kill(id)
	assert(_checkid(id), "Security Exception: Session ID is invalid!")
	fs.unlink(sessionpath .. "/" .. id)
end

--- Remove all expired session data files
function reap()
	if sane() then
		local id
		for id in nixio.fs.dir(sessionpath) do
			if _checkid(id) then
				-- reading the session will kill it if it is expired
				read(id)
			end
		end
	end
end

function readsession(id)
	if not id or #id == 0 then
		return nil
	end

	--modify by lichangqin 2014-06-25 for session id or session file error begin
	--assert(_checkid(id), "Security Exception: Session ID is invalid!")
	if _checkid(id) == false then
		luci.util.exec("mkdir /tmp/crash_log_1")  
--		luci.util.exec("rm /tmp/luci-sessions/*")--session id error,so delete. login again
		return nil
	end

	if not sane(sessionpath .. "/" .. id) then
		return nil
	end

	local blob = _read(id)
	local func = loadstring(blob)
	setfenv(func, {})

	local sess = func()
	--assert(type(sess) == "table", "Session data invalid!")
	if type(sess) == "table" then
		if sess.atime and sess.atime + sessiontime < luci.sys.uptime() then
			kill(id)
			return nil
		end
	else
		luci.util.exec("mkdir /tmp/crash_log_2")  
		luci.util.exec("rm /tmp/luci-sessions/" .. id)--not table must session file error,so delete. login again
		return nil
	end

	return sess
end
--add by lichangqin 2014-3-19 begin
-- return login state
function loginstate()
	local ipaddr = get_client_ipaddr()
	local pathTable = lucifs.dir("/tmp/luci-sessions")
	if pathTable == nil then
		return 0
	end

	for n=1,table.getn(pathTable) do
		local fileName = pathTable[n]
		if fileName ~= "." and fileName ~= ".." then
			local sess = readsession(fileName)
			if sess ~= nil then
				return (sess.login_ip == ipaddr and 2) or 1
			end
		end
	end
	return 0
end
--add by lichangqin 2014-3-19 end
