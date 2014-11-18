--[[

Luci Voice Core
(c) 2009 Daniel Dickinson

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

]]--

module("luci.controller.luci_voice", package.seeall)

function index()
   local e

   e = entry({"admin", "services","voice"}, template("admin_oem/CallList") , _("ids_call_pageTitle"), 2)
   e.index = true
   entry({"admin", "services", "voice"}, alias("admin", "services", "voice", "incoming"), _("ids_call_pageTitle"), 2)

   e = entry({"admin", "services", "voice", "incoming"}, template("admin_oem/CallList"), _("ids_call_Incoming"), 1)
   e.index = true

   e = entry({"admin", "services", "voice", "outgoing"}, template("admin_oem/CallList"), _("ids_call_Outgoing"), 2)
   e.index = true
   e = entry({"admin", "services", "voice", "missed"}, template("admin_oem/CallList"), _("ids_call_Missed"), 3)
   e.index = true

end
