module("luci.webapi.Qos", package.seeall)

local common = require('luci.webapi.Util')

--[[
Request data:

Response data:
"State":1,
"QoSList":[{
"Id":1, 
"Priority": "1" ,
"IPAdrress": "192.168.1.10",
"Protocol": "1",
"Port": "8080",
"Service":'1'
},бн]
]]
function GetQosSettings()
	local rsp = {}
	local qoslistout = {}
	local qoslist = common.GetValueList("qos", "classify")   --etc/config/qos
	local qos_state = common.GetValue("qos", "wan", "enabled")
	if qos_state == nil or qos_state == "" then
		errs = {code=200101, message="Get QoS Settings failed."}
		return nil, errs
	end
	rsp["State"] = qos_state
	
	if qoslist == nil or qoslist == "" then
		rsp["QosList"] = ""
	else
	for i=1,table.getn(qoslist.valuelist) do
				qosItem = {}
				qosItem["Id"] = i						-- qos id  
				local priority = qoslist.valuelist[i]["target"]
				  if priority == "Priority" then
				    qosItem["Priority"] = 0
				  elseif priority == "Express" then
				    qosItem["Priority"] = 1
				  elseif priority == "Normal" then
				    qosItem["Priority"] = 2
				  elseif priority == "Bulk" then
				    qosItem["Priority"] = 3
				  else
				    qosItem["Priority"] = 0
				  end
				
				local srcIPAddress = qoslist.valuelist[i]["srchost"]
				  if srcIPAddress == nil or srcIPAddress =="" then
				    qosItem["SrcIPAddress"] = ""
				  else 
				    qosItem["SrcIPAddress"] = srcIPAddress
				  end				
				
				local dstIPAddress = qoslist.valuelist[i]["dsthost"]
				  if dstIPAddress == nil or dstIPAddress =="" then
				    qosItem["DstIPAddress"] = ""
				  else 
				    qosItem["DstIPAddress"] = dstIPAddress
				  end				
 
                local protocol = qoslist.valuelist[i]["proto"]
				  if protocol == "tcp" then
				    qosItem["Protocol"] = 1
				  elseif protocol == "udp" then
					qosItem["Protocol"] = 2
				  elseif protocol == "icmp" then
					qosItem["Protocol"] = 3
				  else
				    qosItem["Protocol"] = 0
				  end
				
				local port = qoslist.valuelist[i]["ports"]
				  if port == nil or port == "" then
				    qosItem["Port"] = ""
				  else 
				    qosItem["Port"] = port
				  end
				
				local service = qoslist.valuelist[i]["layer7"]
				  if service == "aim" then
				    qosItem["Service"] = 1
				  elseif service == "bittorrent" then
				    qosItem["Service"] = 2
				  elseif service == "edonkey" then
				    qosItem["Service"] = 3
				  elseif service == "fasttrack" then
				    qosItem["Service"] = 4		
				  elseif service == "ftp" then
				    qosItem["Service"] = 5			
				  elseif service == "gnutella" then
				    qosItem["Service"] = 6	
				  elseif service == "http" then
				    qosItem["Service"] = 7		
				  elseif service == "ident" then
				    qosItem["Service"] = 8		
				  elseif service == "irc" then
				    qosItem["Service"] = 9		
				  elseif service == "jabber" then
				    qosItem["Service"] = 10		
				  elseif service == "msnmessenger" then
				    qosItem["Service"] = 11		
				  elseif service == "ntp" then
				    qosItem["Service"] = 12		
				  elseif service == "pop3" then
				    qosItem["Service"] = 13	
				  elseif service == "smtp" then
				    qosItem["Service"] = 14
				  elseif service == "ssl" then
				    qosItem["Service"] = 15
				  elseif service == "vnc" then
				    qosItem["Service"] = 16
				  else 
				    qosItem["Service"] = 0
				  end
				qoslistout[i] = qosItem
				
	end
	    rsp["QosList"] = qoslistout
	end
	return rsp 
end

function SetQosSettings(req)
	local state = req["State"]
	local qoslistin = req["QosList"]
	local item = {} 
	
	if qoslistin == nil then
		if state ~= 0 then
			errs = {code=7, message="Bad parameter."}
			return nil, errs
		end
	end
	
	if state == 0 then 
	common.SetValue("qos", "wan", "enabled", 0)
	else
	common.SetValue("qos", "wan", "enabled", 1)   --update interface wan enabled value
	end
		
	local ret = common.DeleteSection("qos", "classify")
	if ret == false then
		errs = {code=200201, message="Set QoS settings failed."}
		return nil, errs
	end

	
	for i=1,table.getn(qoslistin) do
		item = {}
		
		local priority = qoslistin[i]["Priority"]
		
            if 	priority ==nil or priority=="" then	 
				errs = {code=7, message="Bad parameter."}
		        return nil, errs   
			elseif priority ==1 then
		      item["target"] = "Express"   
		    elseif priority == 2 then
			  item["target"] = "Normal" 
			elseif priority == 3 then
			  item["target"] = "Bulk" 
			else
			  item["target"] = "Priority"
		    end  
		
		local protocl = qoslistin[i]["Protocol"]
		    if protocl == 1  then
		      item["proto"] =  "tcp"
			elseif protocl == 2 then
			  item["proto"] =  "udp"
			elseif protocl == 3 then
			  item["proto"] =  "icmp"
			else
			  item["proto"] =  ""
		    end
			
		local srcIPAddress = qoslistin[i]["SrcIPAddress"]      
		    if srcIPAddress== nil or srcIPAddress == "" then
		      item["srchost"] = ""
			else
			  item["srchost"] = srcIPAddress
		    end    
		local  ports = qoslistin[i]["Port"]  
            if ports == nil or ports =="" then 		
		      item["ports"] = ""
			else
			  item["ports"] = ports
		    end  
		local service = qoslistin[i]["Service"] 
			if service == 1 then    
			  item["layer7"] =   "aim" 
			elseif service == 2 then    
			  item["layer7"] =   "bittorrent" 
			elseif service == 3 then    
			  item["layer7"] =   "edonkey" 
			elseif service == 4 then    
			  item["layer7"] =   "fasttrack" 
			elseif service == 5 then    
			  item["layer7"] =   "ftp" 
			elseif service == 6 then    
			  item["layer7"] =   "gnutella" 
			elseif service == 7 then    
			  item["layer7"] =   "http" 
			elseif service == 8 then    
			  item["layer7"] =   "ident" 
			elseif service == 9 then    
			  item["layer7"] =   "irc" 
			elseif service == 10 then    
			  item["layer7"] =   "jabber" 
			elseif service == 11 then    
			  item["layer7"] =   "msnmessenge" 
			elseif service == 12 then    
			  item["layer7"] =   "ntp" 
			elseif service == 13 then    
			  item["layer7"] =   "pop3" 
			elseif service == 14 then    
			  item["layer7"] =   "smtp" 
			elseif service == 15 then    
			  item["layer7"] =   "ssl" 
			elseif service == 16 then    
			  item["layer7"] =   "vnc" 
			else
			  item["layer7"] =   "" 
			end		    
		
		ret = common.AddSection("qos", "classify", nil, item)
		if ret == false then
			errs = {code=200201, message="Set QoS settings failed."}
			return nil, errs
		end
	end
		ret = common.SaveFile("qos")
		
		if ret == false then
				errs = {code=200201, message="Set QoS settings failed."}
				return nil, errs
		end
		
		os.execute("/etc/init.d/qos reload &")
		return luci.json.null
end

