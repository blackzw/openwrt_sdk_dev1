--[[

LuCI uShare
(c) 2008 Yanira <forum-2008@email.de>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

$Id: ushare.lua 9558 2012-12-18 13:58:22Z jow $

]]--

module("luci.controller.admin.sms", package.seeall)

function index()
	entry({"admin", "services", "sms"},  alias("admin", "services", "sms","read"), _("ids_sms_titleSms"), 1).index = true
	entry({"admin", "services", "sms","new"}, template("admin_services/sms/write"), _("ids_sms_newMessage"), 60).dependent = false
	entry({"admin", "services", "sms","read"}, call("sms_read"), _("ids_sms_inbox"), 20).dependent = false
	entry({"admin", "services", "sms","sent"}, call("sms_sent"), _("ids_sms_outbox"), 40).dependent = false
	entry({"admin", "services", "sms","draft"}, call("sms_draft"), _("ids_sms_draft"), 50).dependent = false
	entry({"admin", "services", "sms","report"}, call("sms_report"), _("ids_sms_settingSmsReport"), 70).dependent = false
	entry({"admin", "services", "sms","sms_settings"}, template("admin_services/sms/sms_settings"), _("ids_settings"), 80).dependent = false
end

function sms_read()
	local list = luci.http.formvalue("list") or "read"
	local view = luci.http.formvalue("view") or "list"
	local pageNum = luci.http.formvalue("pageNum") or "1"
	local sms_id = luci.http.formvalue("sms_id") or ""
	luci.template.render("admin_services/sms/list",{
						list = list	,
						view = view ,
						pageNum = pageNum,
						sms_id = sms_id
	})
end

function sms_sent()
	local list = luci.http.formvalue("list") or "sent"
	local view = luci.http.formvalue("view") or "list"
	local pageNum = luci.http.formvalue("pageNum") or "1"
	local sms_id = luci.http.formvalue("sms_id") or ""
	luci.template.render("admin_services/sms/list",{
						list = list	,
						view = view ,
						pageNum = pageNum,
						sms_id = sms_id
	})
end

function sms_draft()
	local list = luci.http.formvalue("list") or "draft"
	local view = luci.http.formvalue("view") or "list"
	local pageNum = luci.http.formvalue("pageNum") or "1"
	local sms_id = luci.http.formvalue("sms_id") or ""
	luci.template.render("admin_services/sms/list",{
						list = list	,
						view = view ,
						pageNum = pageNum,
						sms_id = sms_id
	})
end

function sms_report()
	local view = luci.http.formvalue("view") or "list"
	local pageNum = luci.http.formvalue("pageNum") or "1"
	local sms_id = luci.http.formvalue("sms_id") or ""
	luci.template.render("admin_services/sms/report",{
						view = view ,
						pageNum = pageNum,
						sms_id = sms_id
	})
end