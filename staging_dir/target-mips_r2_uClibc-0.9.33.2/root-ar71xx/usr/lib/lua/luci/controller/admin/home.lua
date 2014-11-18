--[[
LuCI - Lua Configuration Interface

Copyright 2008 Steven Barth <steven@midlink.org>
Copyright 2011 Jo-Philipp Wich <xm@subsignal.org>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

$Id: home.lua 9558 2014-02-13 $

modify by houailing:2014-02-13 for UI Home menu
]]--

module("luci.controller.admin.home", package.seeall)

function index()
	entry({"admin", "home"}, alias("admin", "home", "status"), _("ids_home"), 20).index = true
	entry({"admin", "home", "status"}, alias("admin", "home", "status", "internet"), _("ids_status"), 1)
		entry({"admin", "home", "status","internet"}, template("admin_oem/status_internet"), _("ids_internet"), 1)
		entry({"admin", "home", "status","lan"}, template("admin_oem/status_lan"), _("ids_lan_Lan"), 2)
		entry({"admin", "home", "status","wlan"}, template("admin_oem/status_wlan"), _("ids_wlan_wlan"), 3)
	entry({"admin", "home", "quicksetup"}, alias("admin", "home", "quicksetup", "quicksetup"), _("ids_setupWizard"), 2)
		entry({"admin", "home", "quicksetup","quicksetup"}, template("admin_oem/quicksetup"), _("ids_setupWizard"), 3)
	entry({"admin", "home", "statistics"}, alias("admin", "home", "statistics", "internet"), _("ids_statistics"), 3)
		entry({"admin", "home", "statistics","internet"}, template("admin_oem/statistics_internet"), _("ids_internet"), 1)
		entry({"admin", "home", "statistics","lan"}, template("admin_oem/statistics_lan"), _("ids_lan_Lan"), 2)
		entry({"admin", "home", "statistics","wlan"}, template("admin_oem/statistics_wlan"), _("ids_wlan_wlan"), 3)
end