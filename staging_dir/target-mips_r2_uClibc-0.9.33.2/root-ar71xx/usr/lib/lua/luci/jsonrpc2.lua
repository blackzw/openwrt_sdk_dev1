--[[

]]--

module("luci.jsonrpc2", package.seeall)
require "luci.json"
require "luci.ltn12"
require "luci.util"
function resolve(mod, method)
	local path = luci.util.split(method, ".")
	
	for j=2, #path-1 do
		if not type(mod) == "table" then
			break
		end
		mod = rawget(mod, path[j])
		if not mod then
			break
		end
	end
	mod = type(mod) == "table" and rawget(mod, path[#path]) or nil
	if type(mod) == "function" then
		return mod
	end
end

function resolve_module(module_name)
	local m = nil
	module_name = "luci.webapi." .. module_name
	state, m = luci.util.copcall(require, module_name)
	if state then
		return m
	else 
		return nil
	end
end

function handle(rawsource, ...)
	local decoder = luci.json.Decoder()
	local stat = luci.ltn12.pump.all(rawsource, decoder:sink())
	local json = decoder:get()
	local response
	local success = false
	
	if stat then
		if type(json.method) == "string"
		 and (not json.params or type(json.params) == "table") then
			local path = luci.util.split(json.method, ".")
			if #path > 1 then
				local tbl = resolve_module(path[1])
				local method = resolve(tbl, json.method)
				if method then
					response = reply(json.jsonrpc, json.id,
					 proxy(method, json.params or {}))
				else
			 		response = reply(json.jsonrpc, json.id,
				 	 nil, {code=-32601, message="Method not found."})
				end
			else
				response = reply(json.jsonrpc, json.id,
			 	nil, {code=-32600, message="Invalid request."})
			end		
			
		else
			response = reply(json.jsonrpc, json.id,
			 nil, {code=-32600, message="Invalid request."})
		end
	else
		response = reply("2.0", nil,
		 nil, {code=-32700, message="Parse error."})
	end

	return luci.json.Encoder(response, ...):source()
end

function reply(jsonrpc, id, res, err)
	require "luci.json"
	id = id or luci.json.null
	
	-- 1.0 compatibility
	if jsonrpc ~= "2.0" then
		jsonrpc = nil
		res = res or luci.json.null
		err = err or luci.json.null
	end

	if err == nil or err == luci.json.null then
		return 	{id=id, result=res, jsonrpc=jsonrpc}
	else
		return {id=id, error=err, jsonrpc=jsonrpc}
	end

end

function proxy(method, ...)
	return method(...)
--	local res = {luci.util.copcall(method, ...)}
--	local stat = res[1]
	
--	if not stat then
--		return nil, {code=-32602, message="Invalid params."} 
--	else
--		if #res <= 2 then
--			return res[2] or luci.json.null
--		else
--			return res[2],res[3]
--		end
--	end
end
