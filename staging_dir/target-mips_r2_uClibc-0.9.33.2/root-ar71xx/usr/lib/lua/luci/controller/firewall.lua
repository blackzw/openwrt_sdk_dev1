module("luci.controller.firewall", package.seeall)

function index()
	--[[entry({"admin", "basicsettings", "security", "firewall"},
		alias("admin", "basicsettings", "security", "firewall", "zones"),
		_("Firewall"), 3)

	entry({"admin", "basicsettings", "security", "firewall", "zones"},
		arcombine(cbi("firewall/zones"), cbi("firewall/zone-details")),
		_("General Settings"), 10).leaf = true

	entry({"admin", "basicsettings", "security", "firewall", "forwards"},
		arcombine(cbi("firewall/forwards"), cbi("firewall/forward-details")),
		_("Port Forwards"), 20).leaf = true

	entry({"admin", "basicsettings", "security", "firewall", "rules"},
		arcombine(cbi("firewall/rules"), cbi("firewall/rule-details")),
		_("Traffic Rules"), 30).leaf = true

	entry({"admin", "basicsettings", "security", "firewall", "custom"},
		cbi("firewall/custom"),
		_("Custom Rules"), 40).leaf = true]]--
end
