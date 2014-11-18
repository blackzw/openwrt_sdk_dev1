if ubus == nil then
        local ubuslib = package.loadlib("/usr/lib/ubus.so", "luaopen_ubus")
        ubuslib()
        return ubus
else
        return ubus
end
                                
