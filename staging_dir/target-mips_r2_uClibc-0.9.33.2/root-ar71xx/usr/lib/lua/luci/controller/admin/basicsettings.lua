--[[

Luci Voice Core
(c) 2009 Daniel Dickinson

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0
modify by houailing:2014-02-13 for UI basic settings menu
]]--

module("luci.controller.admin.basicsettings", package.seeall)

function index()
	
	entry({"admin", "basicsettings"}, alias("admin", "basicsettings", "dialup"), _("ids_wlan_basicSettings"), 40).index = true
	entry({"admin", "basicsettings", "dialup"}, alias("admin", "basicsettings", "dialup", "mobile_connection"), _("ids_dialUp"), 1)
	entry({"admin", "basicsettings", "dialup", "mobile_connection"}, template("admin_oem/mobile_connection"), _("ids_network_Mobconn"), 1)
	entry({"admin", "basicsettings", "dialup", "profile_management"}, template("admin_oem/profile_management"), _("ids_profile_pageTitle"), 2).leaf = true
	entry({"admin", "basicsettings", "dialup", "network"}, template("admin_oem/network_settings"), _("ids_netwrok_Title"), 3).leaf = true
	entry({"admin", "basicsettings", "dialup", "monthly_plan"}, template("admin_oem/Monthly_plan"), _("ids_monthlyPlan_pageTitle"), 4).leaf = true
	entry({"admin", "basicsettings", "wlan"}, alias("admin", "basicsettings", "wlan","Basic"), _("ids_wlan_wlan"), 2)
	entry({"admin", "basicsettings", "wlan","Basic"}, template("admin_oem/wlan_basic"), _("ids_wlan_basic"), 1)
	entry({"admin", "basicsettings", "wlan","Advanced"}, template("admin_oem/wlan_advanced"), _("ids_wlan_advanced"), 2)
	entry({"admin", "basicsettings", "wlan","wps"}, template("admin_oem/wps_settings"), _("WPS"), 3)
    	entry({"admin", "basicsettings", "security"}, alias("admin", "basicsettings", "security", "pin"), _("ids_wlan_security"), 4)
	entry({"admin", "basicsettings", "security", "pin"}, template("admin_oem/pin_management"), _("ids_sim_pinManagement"), 1).leaf = true
	entry({"admin", "basicsettings", "security", "routingRules"}, template("admin_oem/routingRules"), _("ids_router_Title"), 2).leaf = true
	entry({"admin", "basicsettings", "security", "firewall"}, template("admin_oem/firewall"), _("ids_firewall"), 3).leaf = true
	entry({"admin", "basicsettings", "security", "filter"}, template("admin_oem/filter"), _("ids_filter"), 5).leaf = true

	entry({"admin", "basicsettings", "lan"}, alias("admin", "basicsettings", "lan","lanSettings"), _("ids_lan_Lan"), 2)
	entry({"admin", "basicsettings", "lan","lanSettings"}, template("admin_oem/lan_basic"), _("ids_lan_lanSettings"), 1)

end
