if iwinfo == nil then
        local iwinfolib = package.loadlib("/usr/lib/iwinfo.so", "luaopen_iwinfo")
        iwinfolib()
        return iwinfo
else
        return iwinfo
end
                                
