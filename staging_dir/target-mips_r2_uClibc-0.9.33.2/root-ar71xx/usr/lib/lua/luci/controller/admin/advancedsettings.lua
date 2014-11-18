--[[
LuCI - Lua Configuration Interface

Copyright 2008 Steven Barth <steven@midlink.org>
Copyright 2011 Jo-Philipp Wich <xm@subsignal.org>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

$Id: home.lua 9558 2014-02-13 $

modify by houailing:2014-02-19 for UI Advanced Settings menu
]]--

module("luci.controller.admin.advancedsettings", package.seeall)

function index()
	entry({"admin", "advancedsettings"}, alias("admin", "advancedsettings", "nat"), _("ids_wlan_advancedSettings"), 50).index = true
	entry({"admin", "advancedsettings", "nat"}, alias("admin", "advancedsettings", "nat","dmz"), _("ids_natTitle"), 1)
	entry({"admin", "advancedsettings", "nat","dmz"}, template("admin_oem/dmz_settings"), _("ids_dmz_pageTitle"), 1)
	entry({"admin", "advancedsettings", "nat","alg"}, template("admin_oem/alg"), _("ids_alg_title"), 2)
	entry({"admin", "advancedsettings", "nat","upnp"}, template("admin_oem/upnp_settings"), _("ids_upnp_pageTitle"), 3)
	entry({"admin", "advancedsettings", "nat","virtualServer"}, template("admin_oem/virtualServer"), _("ids_vtServer_titleVirtualServer"), 5)
	--entry({"admin", "advancedsettings", "vpn"}, template("admin_home/statistics"), _("VPN Settings"), 2)
	entry({"admin", "advancedsettings", "qos"}, alias("admin", "advancedsettings", "qos","miniqos"), _("ids_qos_titleQos"), 3)
	entry({"admin", "advancedsettings", "qos","miniqos"}, call("advance_qos"), _("ids_qos_titleQos"), 10)
end
function advance_qos()
	if not nixio.fs.access("/etc/config/qos") then
		return
	end
	luci.template.render("admin_oem/qos",{})
end