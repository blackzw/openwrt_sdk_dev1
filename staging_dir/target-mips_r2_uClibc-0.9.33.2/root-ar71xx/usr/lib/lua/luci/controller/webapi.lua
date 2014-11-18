module("luci.controller.webapi", package.seeall)

function index()
	entry({"jrd", "webapi"}, call("handler"), "Web API", 10).dependent = false
end


function handler()
	local jsonrpc2 = require "luci.jsonrpc2"
	local http    = require "luci.http"
	local ltn12   = require "luci.ltn12"

	http.prepare_content("application/json")
	ltn12.pump.all(jsonrpc2.handle(http.source()), http.write)
end

