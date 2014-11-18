--[[
LuCI - Lua Configuration Interface

Copyright 2008 Steven Barth <steven@midlink.org>
Copyright 2011 Jo-Philipp Wich <xm@subsignal.org>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

$Id: home.lua 9558 2014-02-13 $

modify by houailing:2014-02-13 for UI services menu
]]--

module("luci.controller.admin.services", package.seeall)

function index()
	entry({"admin", "services"}, firstchild(), _("ids_services"), 30).index = true

	entry({"admin", "services", "share"}, alias("admin", "services", "share","cloud"), _("ids_share"), 3)	
	entry({"admin", "services", "share","cloud"}, template("admin_oem/services_Cloud"), _("ids_pCloud_pCloud"), 1)
	entry({"admin", "services", "share", "samba"}, call("_samba_ftp"), _("ids_storageShare"),2)
	entry({"admin", "services", "share", "minidlna"}, template("admin_oem/miniDLNA"), _("DLNA"),3)
	entry({"admin", "services", "share","usersettings"}, template("admin_oem/user_settings"), _("ids_user_pageTitle"), 4)
end

function _samba_ftp()
	if not nixio.fs.access("/etc/config/samba") then
		return
	end
	luci.template.render("admin_oem/sambaFtp",{})
end