--module("luci.controller.webapi", package.seeall)

--function index()
--	entry({"jrd", "webapi"}, call("handler"), "Web API", 10).dependent = false
--end


--function handler()
--	local jsonrpc2 = require "luci.jsonrpc2"
--	local http    = require "luci.http"
--	local ltn12   = require "luci.ltn12"

--	http.prepare_content("application/json")
--	ltn12.pump.all(jsonrpc2.handle(http.source()), http.write)
--end

function handle_request()

	local jsonrpc2 = require "luci.jsonrpc2"
	exectime = os.clock()	

	local len = g_http_request_env.CONTENT_LENGTH or 0
	local function recv()
		if len > 0 then
			local rlen, rbuf = uhttpd.recv(4096)
			if rlen >= 0 then
				len = len - rlen
				return rbuf
			end
		end
		return nil
	end

	local function send(...)
		return uhttpd.send(...)
	end

	local function sendc(...)
		if g_http_request_env.HTTP_VERSION > 1.0 then
			return uhttpd.sendc(...)
		else
			return uhttpd.send(...)
		end
	end

	if g_http_request_env.REQUEST_METHOD ~= "POST" then		
		send(g_http_request_env.SERVER_PROTOCOL)
		send(" 404 T​h​e​ ​r​e​q​u​e​s​t​e​d​ ​r​e​s​o​u​r​c​e​ ​i​s​ ​n​o​t​ ​a​v​a​i​l​a​b​l​e​\r\n")
		send("Content-Type: text/plain\r\n\r\n")
	end	
	
--	local x = coroutine.create(jsonrpc2.handle)
	--local hcache = { }
	--local active = true

	--if env.HTTP_VERSION > 1.0 then
	--	hcache["Transfer-Encoding"] = "chunked"
	--end


--	while coroutine.status(x) ~= "dead" do
--		local res = coroutine.resume(x, buffer)
		local res = jsonrpc2.handle(recv)
		if not res then
			send(g_http_request_env.SERVER_PROTOCOL)
			send(" 500 Internal Server Error\r\n")
			send("Content-Type: text/plain\r\n\r\n")
			--send(tostring(id))
--			break
		end

		send(g_http_request_env.SERVER_PROTOCOL)
		send(" 200 OK\r\n")
		send("Content-Type: application/json\r\n\r\n")

		local chunk = res()
		while true do
			if not chunk then
				break
			else
				send(chunk)
				chunk = res()
			end
			
		end
		
		send("\n")
--	end

end

