if uci == nil then
        local ucilib = package.loadlib("/usr/lib/uci.so", "luaopen_uci")
        ucilib()  
        return uci
else              
        return uci
end
                                
