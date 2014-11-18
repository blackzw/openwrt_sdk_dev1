if nixio == nil then
	local nixiolib = package.loadlib("/usr/lib/nixio.so", "luaopen_nixio")
	nixiolib()
	return nixio
else
	return nixio
end
