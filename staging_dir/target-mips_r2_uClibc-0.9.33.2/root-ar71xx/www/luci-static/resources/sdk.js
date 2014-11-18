var G_SDK_SIM_STATE_NO_SIM = 0; //no sim card
var G_SDK_SIM_STATE_PIN = 1; //pin required
var G_SDK_SIM_STATE_PUK = 2; //puk required
var G_SDK_SIM_STATE_READY = 3; //sim ready
var G_SDK_SIM_STATE_INVALID = 4; //sim invalid
var G_SDK_SIM_STATE_UNKNOWN = 5; //unknown
var G_SDK_SIM_STATE_SIMLOCK = 6; //sim lock

//SIM lock State
var G_SDK_SIMLOCK_NO = -1;
var G_SDK_SIMLOCK_NCK = 0;
var G_SDK_SIMLOCK_NSCK = 1;
var G_SDK_SIMLOCK_SPCK = 2;
var G_SDK_SIMLOCK_CCK = 3;
var G_SDK_SIMLOCK_PCK = 4;
var G_SDK_SIMLOCK_RCK = 5;
var G_SDK_SIMLOCK_RCK_FORBID = 6;

var G_SDK_PIN_STATE_NOT_AVAILABLE = 0; //not available
var G_SDK_PIN_STATE_DISABLE = 1; //pin disable
var G_SDK_PIN_STATE_ENABLE = 2; //pin enable
var G_SDK_PIN_STATE_PUK = 3; //puk

var G_SDK_PIN_SET_STATE_DISABLE = 0; //disable pin
var G_SDK_PIN_SET_STATE_ENABLE = 1; //enable pin

var G_SDK_PIN_AUTO_ENTER_STATE_DISABLE = 0; //pin auto enter disable
var G_SDK_PIN_AUTO_ENTER_STATE_ENABLE = 1; //pin auto enter enable

//network settings
var G_SDK_NETWORK_SETTINGS_NETWORK_SELECTION_MODE_AUTO = 0;
var G_SDK_NETWORK_SETTINGS_NETWORK_SELECTION_MODE_MANUAL = 1;

var G_SDK_NETWORK_CONNCTION_DISCONNECTED = 0;
var G_SDK_NETWORK_CONNCTION_CONNECTING = 1;
var G_SDK_NETWORK_CONNCTION_CONNECTED = 2;
var G_SDK_NETWORK_CONNCTION_DISCONNECTING = 3;

/*
var G_SDK_NETWORK_SEARCH_NOT_SEARCH = 0;
var G_SDK_NETWORK_SEARCH_SEARCHING = 1;
var G_SDK_NETWORK_SEARCH_SUCCESS = 2;
var G_SDK_NETWORK_SEARCH_FAIL = 3;

var G_SDK_NETWORK_REGISTER_STATE_NONE = 0;
var G_SDK_NETWORK_REGISTER_STATE_REGISTTING = 1;
var G_SDK_NETWORK_REGISTER_STATE_SUCCESS = 2;
var G_SDK_NETWORK_REGISTER_STATE_FAIL = 3;
*/
var G_SDK_TIMER_GET_NETWORK_SEARCH_RESULT = null;
var G_SDK_TIMER_GET_NETWORK_REGISTER_RESULT = null;

var G_SDK_TIMER_CONNECT_NETWORK_TIMER = null;
var G_SDK_TIMER_DISCONNECT_NETWORK_TIMER = null;

//roaming
var G_SDK_ROAM_STATE_YES = 1;
var G_SDK_ROAM_STATE_NO = 0;

//network type
var G_SDK_NETWORK_TYPE_NO_SERVICE = 0;
var G_SDK_NETWORK_TYPE_GPRS = 1;
var G_SDK_NETWORK_TYPE_EDGE = 2;
var G_SDK_NETWORK_TYPE_UMTS = 3;
var G_SDK_NETWORK_TYPE_HSDPA = 4;
var G_SDK_NETWORK_TYPE_HSPA = 5;
var G_SDK_NETWORK_TYPE_HSUPA = 6;
var G_SDK_NETWORK_TYPE_DC_HSPA_PLUS = 7;
var G_SDK_NETWORK_TYPE_LTE = 8;
var G_SDK_NETWORK_TYPE_GSM = 9;
var G_SDK_NETWORK_TYPE_HSPA_PLUS = 10;
var G_SDK_NETWORK_TYPE_UNKNOWN = 11;

var G_SDK_CONNECT_MODE_MANUAL = 0;
var G_SDK_CONNECT_MODE_AUTO = 1;

var G_SDK_ROAMING_CONNECT_OFF = 0;
var G_SDK_ROAMING_CONNECT_ON = 1;

var G_SDK_DMZ_STATUS_DISABLE = 0;
var G_SDK_DMZ_STATUS_ENABLE = 1;

var SDK = (function(){
    //common fn start
    function requestJsonRpcAsync(method,params,id,callback){
        var postData={"jsonrpc":"2.0","method":method,"params":params,"id":id};
        var postDataStr = JSON2.stringify(postData);//need use json2.js on ie6,ie7,ie8 compatibility
        $.ajax({
            type:"post",
            url:"/jrd/webapi",
            dataType:"text",
            data:postDataStr,
            success:function(datas){
                var data = jQuery.parseJSON(datas);
                if(data.hasOwnProperty("result") && !data.hasOwnProperty("error")){
                    callback(data.result);
                }else{
					callback(data);
                }  
            }
        })
    }
    
    function requestJsonRpcSync(method,params,id){
        var postData={"jsonrpc":"2.0","method":method,"params":params,"id":id};
        var postDataStr = JSON2.stringify(postData);//need use json2.js on ie6,ie7,ie8 compatibility
        var returnData;
        $.ajax({
            type:"post",
            url:"/jrd/webapi",
            dataType:"text",
            async:false,
            data:postDataStr,
            success:function(data){
                returnData=jQuery.parseJSON(data);
            }
        })
        return returnData;  
    }
    
    function requestJsonRpcIsOk(result){
        return result.hasOwnProperty("result") && !result.hasOwnProperty("error");
    }
    
    function callbackCode(error){
        return {"error":error};
    }

    function stopTimer(timer){
        if (timer != null) {
            clearTimeout(timer);
            timer = null;
        }
    }
      
    function isNumber(str){
        return /^[0-9]+$/.test(str);
    }
     function isInterger(str){
		return /^-?[0-9]+$/.test(str);
    }
    function validatePin(pinCode){
        return !(pinCode == "" || pinCode.length < 4 || pinCode.length >8 || !isNumber(pinCode));
    }
    
    function validatePuk(pukCode){
        return !(pukCode == "" || pukCode.length != 8 || !isNumber(pukCode));
    }
    
    
    //common fn end
         
    var SIM,SMS,System,Network,Profile,WanConnection,Statistics,CallLog,DMZ,UPnP,User, VirtualServer, ALG,Wlan, Filter,Services,LAN,Qos,Firewall,UserSettings,RoutingRules,Update;
    System = {
        GetSystemInfo:function(){
            var result = requestJsonRpcSync("System.GetSystemInfo",null,"2.1");
            if(requestJsonRpcIsOk(result)){
                return result.result;
            }else{
                return result.error;
            }    
        },

        SetLanguage:function(Language){
            var result = requestJsonRpcSync("System.SetLanguage",{"Language":Language},"2.2");
            if(requestJsonRpcIsOk(result)){
                return callbackCode(0);
            }else{
                return callbackCode(1);
            }    
        },

        GetLanguage:function(){
            var result = requestJsonRpcSync("System.GetLanguage",null,"2.3");
            if(requestJsonRpcIsOk(result)){
                return result.result;
            }else{
                return result.error;
            }   
        },

        SetCurrentTime:function(sendData){
            var result = requestJsonRpcSync("System.SetCurrentTime",sendData,"2.4");
            if(requestJsonRpcIsOk(result)){
                return callbackCode(0);
            }else{
                return callbackCode(1);
            }    
        },

        GetCurrentTime:function(){
            var result = requestJsonRpcSync("System.GetCurrentTime",null,"2.5");
            if(requestJsonRpcIsOk(result)){
                return result.result;
            }else{
                return result.error;
            }   
        },
	GetExternalStorageDevice : function()
	{
		var result = requestJsonRpcSync("System.GetExternalStorageDevice", null, "2.7");
		if (requestJsonRpcIsOk(result))
		{
			return result.result;
		} else
		{
			return callbackCode(4001);
		}
	},

        GetSystemSettings:function(){
            var result = requestJsonRpcSync("System.GetSystemSettings",null,"2.8");
            if(requestJsonRpcIsOk(result)){
                return result.result;
            }else{
                return result.error;
            }   
        },

        SetSystemSettings:function(sendData){
            var result = requestJsonRpcSync("System.SetSystemSettings",sendData,"2.9");
            if(requestJsonRpcIsOk(result)){
                return callbackCode(0);
            }else{
                return callbackCode(1);
            }    
        },
        GetAsyncSystemStatus:function(callback){
            requestJsonRpcAsync("System.GetSystemStatus",null,"2.10",function(result){
                callback(result);  
            })
        }


    }

    //System end
    SIM = {
        GetSimStatus:function (){
            var result = requestJsonRpcSync("SIM.GetSimStatus",null,"3.1");
            if(requestJsonRpcIsOk(result)){
                return result.result;
            }else{
                return result.error;
            }
        },
        
        UnlockPin:function(pinCode){
            if(!validatePin(pinCode)){
                return callbackCode(1);//pin code format error
            }
            
            var result = requestJsonRpcSync("SIM.UnlockPin",{"Pin":pinCode},"3.2");
            if(requestJsonRpcIsOk(result)){
                return callbackCode(0);
            }else{
                return callbackCode(2);
            }    
            
        },
        
        UnlockPuk:function(pukCode,newPin,confirmPin){
            
            if(!validatePuk(pukCode)){
                return callbackCode(1);//puk code format error
            }
            if(!validatePin(newPin)){
                return callbackCode(2);//new Pin code format error
            }
            if(newPin != confirmPin){
                return callbackCode(3);//error! the new pin code is not the same as the confirm pin 
            }
            
            var result = requestJsonRpcSync("SIM.UnlockPuk",{"Puk":pukCode,"Pin":newPin},"3.3");
            if(requestJsonRpcIsOk(result)){
                return callbackCode(0);
            }else{
                return callbackCode(4);//unlock Puk failed
            }    
        },
        
        ChangePin:function(currentPin,newPin,confirmPin){
            
            if(!validatePin(currentPin)){
                return callbackCode(1);//current pin code format error
            }
            if(!validatePin(newPin)){
                return callbackCode(2);//new pin code format error
            }
            if(newPin != confirmPin){
                return callbackCode(3);//error! the new pin code is not the same as the confirm pin  
            }
            
            var result = requestJsonRpcSync("SIM.ChangePin",{"CurrentPin":currentPin,"NewPin":newPin},"3.4");
            if(requestJsonRpcIsOk(result)){
                return callbackCode(0);
            }else{
                return callbackCode(4);//change pin failed
            }  
        },
        
        ChangePinState:function(state,pin){
            var returnData;
            if(!validatePin(pin)){
                return callbackCode(1);//pin code format error
            }
            if(state != G_SDK_PIN_SET_STATE_DISABLE && state != G_SDK_PIN_SET_STATE_ENABLE){
                return callbackCode(2);//pin state error
            }
            
            var result = requestJsonRpcSync("SIM.ChangePinState",{"State":state,"Pin":pin},"3.5");
            if(requestJsonRpcIsOk(result)){
                return callbackCode(0);
            }else{
                return callbackCode(3);//change pin state failed
            }     
        },
        
        GetAutoEnterPinState:function (){
            var result = requestJsonRpcSync("SIM.GetAutoEnterPinState",null,"3.6");
            if(requestJsonRpcIsOk(result)){
                return result.result.State;
            }else{
                return result.error;
            }
        },
        
        SetAutoEnterPinState:function(state,pinCode){
            if(!validatePin(pinCode)){
                return callbackCode(1)//pin code format error
            }
            if(state != G_SDK_PIN_AUTO_ENTER_STATE_DISABLE && state != G_SDK_PIN_AUTO_ENTER_STATE_ENABLE){
                return callbackCode(2)//Auto enter pin state error
            }
            var result = requestJsonRpcSync("SIM.SetAutoEnterPinState",{"Pin":pinCode,"State":state},"3.7");
            if(requestJsonRpcIsOk(result)){
                return callbackCode(0);
            }else{
                return callbackCode(3);//change pin auto enter state failed
            }  
            
        },

        UnlockSimlock:function(type,simlockCode){
            var result = requestJsonRpcSync("SIM.UnlockSimlock",{"SimLockState":type,"SimLockCode":simlockCode},"3.8");
            if(requestJsonRpcIsOk(result)){
                return callbackCode(0);
            }else{
                return callbackCode(1);
            }   
        }
        
        
    }
    //SIM end
    
    Network = {
        GetNetworkInfo:function(){
            var result = requestJsonRpcSync("Network.GetNetworkInfo",{},"4.1");
            if(requestJsonRpcIsOk(result)){
                return result.result;
            }else{
                return result.error;
            }
        },
        
        SearchNetwork:function(callback){
            var searchStatus = {
                "none":0,
                "searching":1,
                "success":2,
                "fail":3
            }
            var searchResultData = requestJsonRpcSync("Network.SearchNetworkResult",null,"4.3");
            var searchResult;
            if(requestJsonRpcIsOk(searchResultData)){//
                searchResult = searchResultData.result.SearchState;//
                if(searchResult == searchStatus.searching){
                    callback(callbackCode(1));
                }else{
                    var startSearchData = requestJsonRpcSync("Network.SearchNetwork",null,"4.2");//do Search
                    if(requestJsonRpcIsOk(startSearchData)){
                        G_SDK_TIMER_GET_NETWORK_SEARCH_RESULT = setTimeout(function () {
                            getNetworkList(callback);
                        }, 4000);
                    }else{
                        callback(callbackCode(2));
                    }
                }
                
            }else{
                callback(callbackCode(4));
            }


            function getNetworkList(callback) {
                var networkSelectStatusData = requestJsonRpcSync("Network.SearchNetworkResult",null,"4.3");
                var networkSelectStatus,networkList;
                if(requestJsonRpcIsOk(networkSelectStatusData)){
                    networkSelectStatus = networkSelectStatusData.result.SearchState;
                    networkList=null;
                    if (networkSelectStatus == searchStatus.searching) {
                        stopTimer(G_SDK_TIMER_GET_NETWORK_SEARCH_RESULT);
                        G_SDK_TIMER_GET_NETWORK_SEARCH_RESULT = setTimeout(function () {
                            getNetworkList(callback);
                        }, 4000);
                    } else if (networkSelectStatus == searchStatus.success) {
                        networkList = networkSelectStatusData.result.ListNetworkItem;
                        callback({"networkList":networkList});
                    } else {
                        callback(callbackCode(3));
                    }
                }else{
                    callback(callbackCode(4));
                }
                
            }

        },

        RegisterNetwork:function(networkId,callback){
            var registerStatus = {
                "none":0,
                "registting":1,
                "success":2,
                "fail":3
            }
            var registerInfo = requestJsonRpcSync("Network.GetNetworkRegisterState",null,"4.5");
            var registerState;
            if(requestJsonRpcIsOk(registerInfo)){//
                registerState = registerInfo.result.State;//
                if(registerState == registerStatus.registting){
                    callback(callbackCode(1));
                }else{
                    var startRegister = requestJsonRpcSync("Network.RegisterNetwork",{"NetworkID":networkId},"4.4");//do Register
                    if(requestJsonRpcIsOk(startRegister)){
                        stopTimer(G_SDK_TIMER_GET_NETWORK_REGISTER_RESULT);
                        G_SDK_TIMER_GET_NETWORK_REGISTER_RESULT = setTimeout(function () {
                            getNetworkRegisterResult(callback);
                        }, 4000);
                    }else{
                        callback(callbackCode(2));
                    }
                }
                
            }else{
                callback(callbackCode(4)); 
            }

            function getNetworkRegisterResult(callback) {
                var networkRegisterStateInfo = requestJsonRpcSync("Network.GetNetworkRegisterState",null,"4.5");
                var networkRegisterResult;
                if(requestJsonRpcIsOk(networkRegisterStateInfo)){
                    networkRegisterResult = networkRegisterStateInfo.result.State;
                    if (networkRegisterResult == registerStatus.registting) {
                        stopTimer(G_SDK_TIMER_GET_NETWORK_REGISTER_RESULT);
                        G_SDK_TIMER_GET_NETWORK_REGISTER_RESULT = setTimeout(function () {
                            getNetworkRegisterResult(callback);
                        }, 4000);
                    } else if (networkRegisterResult == registerStatus.success) {
                        callback(callbackCode(0));
                    } else {
                        callback(callbackCode(3));
                    }
                }else{
                    callback(callbackCode(4));
                }
                
            }
            
        },

        
        GetNetworkSettings:function(){
            var result = requestJsonRpcSync("Network.GetNetworkSettings",null,"4.6");
            if(requestJsonRpcIsOk(result)){
                return result.result;
            }else{
                return result.error;
            }
            
        },
        
        SetNetworkSettings:function(networkMode,networkSelectMode){
            var result = requestJsonRpcSync("Network.SetNetworkSettings",{"NetworkMode":networkMode,"NetselectionMode":networkSelectMode},"4.7");
            if(requestJsonRpcIsOk(result)){
                return callbackCode(0);
            }else{
                return callbackCode(1);
            }
            
        } 
   
    }
    //Notwork end
    
	// SMS start
	function validateSMSType(smsType)
	{
		if (isNumber(smsType) && smsType < 6 && smsType >= 0)
		{
			return true;
		}
		return false;
	}

	function validateSMSStoreIn(storeIn)
	{
		if (isNumber(storeIn) && storeIn < 3 && storeIn >= 0)
		{
			return true;
		}
		return false;
	}

	SMS = {
		GetSmsList : function(smsType, pageNum)
		{
			if (!validateSMSType(smsType) && !isNumber(pageNum))
			{
				return callbackCode(1001);// param format error
			}
			var result = requestJsonRpcSync("SMS.GetSmsList", {
				"Type" : smsType,
				"Page" : pageNum
			}, "6.1");
			if (requestJsonRpcIsOk(result))
			{
				return result;
			} else
			{
				return callbackCode(4000);// Delete SMS failed
			}
		},

		DeleteSms : function(id, storeIn)
		{
			if (!isInterger(id))
			{
				return callbackCode(1001);
			}
			var result = requestJsonRpcSync("SMS.DeleteSms", {
				"Id" : id
			}, "6.2");
			if (requestJsonRpcIsOk(result))
			{
				return callbackCode(0);
			} else
			{
				return callbackCode(4000);// Delete SMS failed
			}
		},

		SendSms : function(id, Content, PhoneNumber, Priority)
		{
			if (isNaN(id) || PhoneNumber == "" || isNaN(PhoneNumber))
			{
				return callbackCode(1001);
			}
			var result = requestJsonRpcSync("SMS.SendSms", {"Id" : id,"Content": Content,"PhoneNumber":PhoneNumber ,"Priority":Priority}, "6.3");
			if (requestJsonRpcIsOk(result))
			{
				return result;
			} else
			{
				return callbackCode(4000);// SendSms SMS failed
			}
		},

		ModifySmsReadStatus : function(id, Status)
		{
			if (!isInterger(id) && (Status == 1 || Status == 0))
			{
				return callbackCode(1001);
			}
			var result = requestJsonRpcSync("SMS.ModifySmsReadStatus", {
				"Id" : id,
				"Status" : Status
			}, "6.4");
			if (requestJsonRpcIsOk(result))
			{
				return callbackCode(0);
			} else
			{
				return callbackCode(4000);// ModifySMSReadStatus SMS failed
			}
		},

		GetSmsSendResult : function(SmsSendId, callback)
		{
			if (!isInterger(SmsSendId))
			{
				 callback({"error":1001});
			}
			requestJsonRpcAsync("SMS.GetSendSmsResult", {"SmsSendId" : SmsSendId}, "6.5", function(data)
			{
				if (data != null  &&  !data.hasOwnProperty("error"))
				{
					 callback(data);
				} else
				{
					 callback({"error":4001});// SaveSms SMS failed
				}
			});
		},

		SaveSms : function(id, number, content)
		{
			if (isNaN(id) || isNaN(number))
			{
				return callbackCode(1001);
			}
			var result = requestJsonRpcSync("SMS.SaveSms", {
				"Id" : id,
				"Number" : number,
				"Content" : content
			}, "6.6");
			if (requestJsonRpcIsOk(result))
			{
				return callbackCode(0);
			} else
			{
				return callbackCode(4000);// SaveSms SMS failed
			}
		},

		GetSmsSettings : function()
		{
			var result = requestJsonRpcSync("SMS.GetSmsSettings", null, "6.7");
			if (requestJsonRpcIsOk(result))
			{
				return result;
			} else
			{
				return callbackCode(4000);// GetSmsSettings SMS failed
			}
		},

		SetSmsSettings : function(SmsReportSwitch, StoreFlag, SmsCenter)
		{
			if (!(SmsReportSwitch == 0 || SmsReportSwitch == 1) && !validateSMSStoreIn(StoreFlag) && !isNaN(SmsCenter))
			{
				return callbackCode(1001);
			}
			var result = requestJsonRpcSync("SMS.SetSmsSettings", {
				"SmsReportSwitch" : SmsReportSwitch,
				"StoreFlag" : StoreFlag,
				"SmsCenter" : SmsCenter
			}, "6.8");
			if (requestJsonRpcIsOk(result))
			{
				return callbackCode(0);
			} else
			{
				return callbackCode(4000);// SetSmsSettings SMS failed
			}
		},

		GetSmsStorageState : function()
		{
			var result = requestJsonRpcSync("SMS.GetSmsStorageState", null, "6.9");
			if (requestJsonRpcIsOk(result))
			{
				return result;
			} else
			{
				return callbackCode(4000);// GetSmsStorageState SMS failed
			}
		},

		GetSmsCount : function(Type)
		{
			if (!isNumber(Type))
			{
				return callbackCode(1001);
			}
			var result = requestJsonRpcSync("SMS.GetSmsCount", {
				"Type" : Type
			}, "6.10");
			if (requestJsonRpcIsOk(result))
			{
				return result;
			} else
			{
				return callbackCode(4000);// GetSmsCount SMS failed
			}
		},

		getSingleSMS : function(sms_id)
		{
			var single_sms;
			if (!isInterger(sms_id))
			{
				return callbackCode(1001);
			}
			var data = SDK.SMS.GetSmsList(5, 0);
			if (data.hasOwnProperty("error"))
			{
				return callbackCode(4000);
			}
			var SmsList = data.result.SmsList;
			for ( var i in SmsList)
			{
				if (sms_id == SmsList[i].Id)
				{
					single_sms = SmsList[i];
					break;
				}
			}
			return single_sms;
		}
	}

    //SMS end

    Profile = {
        GetProfileList:function (){
            var result = requestJsonRpcSync("Profile.GetProfileList",null,"9.1");
            if(requestJsonRpcIsOk(result)){
                return result.result;
            }else{
                return result.error;
            }
        },
        
        AddNewProfile:function(sendData){
            var result = requestJsonRpcSync("Profile.AddNewProfile",sendData,"9.2");
            if(requestJsonRpcIsOk(result)){
                return callbackCode(0);
            }else{
                return callbackCode(1);//Add Profile failed
            }   
        },
        
        EditProfile:function(sendData){
            var result = requestJsonRpcSync("Profile.EditProfile",sendData,"9.3");
            if(requestJsonRpcIsOk(result)){
                return callbackCode(0);
            }else{
                return callbackCode(1);//Edit Profile failed
            }   
        },      
        
        DeleteProfile:function(sendData){
            var result = requestJsonRpcSync("Profile.DeleteProfile",sendData,"9.4");
            if(requestJsonRpcIsOk(result)){
                return callbackCode(0);
            }else{
                return callbackCode(1);//Delete Profile failed
            }   
        },
        
        SetDefaultProfile:function(sendData){
            var result = requestJsonRpcSync("Profile.SetDefaultProfile",sendData,"9.5");
            if(requestJsonRpcIsOk(result)){
                return callbackCode(0);
            }else{
                return callbackCode(1);//Set Default Profile failed
            }   
        }               
    }

    //Profile end

    WanConnection = {
        GetConnectionState:function(){
            var result = requestJsonRpcSync("WanConnection.GetConnectionState",null,"8.1");
            if(requestJsonRpcIsOk(result)){
                return result.result;
            }else{
                return result.error;
            }
        },
        Connect:function(callback){
            var result = requestJsonRpcSync("WanConnection.Connect",null,"8.2");
            if(requestJsonRpcIsOk(result)){
                stopTimer(G_SDK_TIMER_CONNECT_NETWORK_TIMER);
                    G_SDK_TIMER_CONNECT_NETWORK_TIMER = setTimeout(function () {
                        getConnectResult(callback);
                }, 4000);
            }else{
                if(result.error.code == 80204){
                    callback(callbackCode(80204));
                }else{
                    callback(callbackCode(1));
                }
                
            } 

            function getConnectResult(callback){
                var connectionInfo = requestJsonRpcSync("WanConnection.GetConnectionState",null,"8.1");
                var connectionState = connectionInfo.result.ConnectionStatus;
                if(connectionState == G_SDK_NETWORK_CONNCTION_CONNECTING){
                    stopTimer(G_SDK_TIMER_CONNECT_NETWORK_TIMER);
                        G_SDK_TIMER_CONNECT_NETWORK_TIMER = setTimeout(function () {
                            getConnectResult(callback);
                    }, 4000);
                }else if(connectionState == G_SDK_NETWORK_CONNCTION_CONNECTED){
                    callback(callbackCode(0));
                }else{
                    callback(callbackCode(1));
                }
            }  

        },
        DisConnect:function(callback){
            var result = requestJsonRpcSync("WanConnection.DisConnect",null,"8.3");
            if(requestJsonRpcIsOk(result)){
                stopTimer(G_SDK_TIMER_CONNECT_NETWORK_TIMER);
                    G_SDK_TIMER_CONNECT_NETWORK_TIMER = setTimeout(function () {
                        getDisconnectResult(callback);
                    }, 4000);
            }else{
                callback(callbackCode(1));
            }

            function getDisconnectResult(callback){
                var connectionInfo = requestJsonRpcSync("WanConnection.GetConnectionState",null,"8.1");
                var connectionState = connectionInfo.result.ConnectionStatus;
                if(connectionState == G_SDK_NETWORK_CONNCTION_DISCONNECTING){
                    stopTimer(G_SDK_TIMER_CONNECT_NETWORK_TIMER);
                        G_SDK_TIMER_CONNECT_NETWORK_TIMER = setTimeout(function () {
                            getDisconnectResult(callback);
                    }, 4000);
                }else if(connectionState == G_SDK_NETWORK_CONNCTION_DISCONNECTED){
                    callback(callbackCode(0));
                }else{
                    callback(callbackCode(1));
                }
            }   
        },

	    GetConnectionSettings:function(){
    	    return requestJsonRpcSync("WanConnection.GetConnectionSettings",null,"8.4").result;
    	},
    	SetConnectionSettings:function(idleTime, roam, connectMode){
    	    var result = requestJsonRpcSync("WanConnection.SetConnectionSettings",{"IdleTime":idleTime,"RoamingConnect":roam,"ConnectMode":connectMode},"8.5");
            if(requestJsonRpcIsOk(result)){
                return callbackCode(0);
            }else{
                return callbackCode(1);
            }     		    		
    	},

        GetConnectionType:function(){
            var result = requestJsonRpcSync("WanConnection.GetConnectionType",null,"8.6");
            if(requestJsonRpcIsOk(result)){
                return result.result.nPdpType;
            }else{
                return result.error;
            }
        },
        SetConnectionType:function(nPdpType){
            var result = requestJsonRpcSync("WanConnection.SetConnectionType",{"nPdpType":nPdpType},"8.7");
            if(requestJsonRpcIsOk(result)){
                return callbackCode(0);
            }else{
                return callbackCode(1);
            }                       
        }
    }
	//WanConnection end

    //Statistics start 
    Statistics = {
        GetUsageHistory:function(sendData){
            var result = requestJsonRpcSync("Statistics.GetUsageHistory",sendData,"7.1");
            if(requestJsonRpcIsOk(result)){
                return result.result;
            }else{
                return result.error;
            }   
        },

         GetBillingDay:function(){
            var result = requestJsonRpcSync("Statistics.GetBillingDay",null,"7.2");
            if(requestJsonRpcIsOk(result)){
                return result.result;
            }else{
                return result.error;
            }   
        },

        SetBillingDay:function(sendData){
            var result = requestJsonRpcSync("Statistics.SetBillingDay",sendData,"7.3");
            if(requestJsonRpcIsOk(result)){
                return callbackCode(0);
            }else{
                return callbackCode(1);
            }   
        },

        GetCalibrationValue:function(){
            var result = requestJsonRpcSync("Statistics.GetCalibrationValue",null,"7.4");
            if(requestJsonRpcIsOk(result)){
                return result.result;
            }else{
                return result.error;
            }   
        },

        SetCalibrationValue:function(sendData){
            var result = requestJsonRpcSync("Statistics.SetCalibrationValue",sendData,"7.5");
            if(requestJsonRpcIsOk(result)){
                return callbackCode(0);
            }else{
                return callbackCode(1);
            }   
        },

        GetLimitValue:function(){
            var result = requestJsonRpcSync("Statistics.GetLimitValue",null,"7.6");
            if(requestJsonRpcIsOk(result)){
                return result.result;
            }else{
                return result.error;
            }   
        },

        SetLimitValue:function(sendData){
            var result = requestJsonRpcSync("Statistics.SetLimitValue",sendData,"7.7");
            if(requestJsonRpcIsOk(result)){
                return callbackCode(0);
            }else{
                return callbackCode(1);
            }   
        },

        GetTotalValue:function(){
            var result = requestJsonRpcSync("Statistics.GetTotalValue",null,"7.8");
            if(requestJsonRpcIsOk(result)){
                return result.result;
            }else{
                return result.error;
            }   
        },

        SetTotalValue:function(sendData){
            var result = requestJsonRpcSync("Statistics.SetTotalValue",sendData,"7.9");
            if(requestJsonRpcIsOk(result)){
                return callbackCode(0);
            }else{
                return callbackCode(1);
            }   
        },

        GetUsageSettings:function(){
            var result = requestJsonRpcSync("Statistics.GetUsageSettings",null,"7.10");
            if(requestJsonRpcIsOk(result)){
                return result.result;
            }else{
                return result;
            }   
        },

        GetDevicePushInfo:function(){
            var result = requestJsonRpcSync("Statistics.GetDevicePushInfo",null,"7.11");
            if(requestJsonRpcIsOk(result)){
                return result.result;
            }else{
                return result.error;
            }   
        },

        SetDevicePushInfo:function(sendData){
            var result = requestJsonRpcSync("Statistics.SetDevicePushInfo",sendData,"7.12");
            if(requestJsonRpcIsOk(result)){
                return callbackCode(0);
            }else{
                return callbackCode(1);
            }   
        },

        DeleteDevicePushInfo:function(sendData){
            var result = requestJsonRpcSync("Statistics.DeleteDevicePushInfo",sendData,"7.13");
            if(requestJsonRpcIsOk(result)){
                return callbackCode(0);
            }else{
                return callbackCode(1);
            }   
        },

        ClearAllRecords:function(sendData){
            var result = requestJsonRpcSync("Statistics.ClearAllRecords",sendData,"7.14");
            if(requestJsonRpcIsOk(result)){
                return callbackCode(0);
            }else{
                return callbackCode(1);
            }   
        },

        SetDisconnectOvertime:function(sendData){
            var result = requestJsonRpcSync("Statistics.SetDisconnectOvertime",sendData,"7.15");
            if(requestJsonRpcIsOk(result)){
                return callbackCode(0);
            }else{
                return callbackCode(1);
            }   
        },

        SetDisconnectOvertimeState:function(sendData){
            var result = requestJsonRpcSync("Statistics.SetDisconnectOvertimeState",sendData,"7.16");
            if(requestJsonRpcIsOk(result)){
                return callbackCode(0);
            }else{
                return callbackCode(1);
            }   
        },

        SetDisconnectOverflowState:function(sendData){
            var result = requestJsonRpcSync("Statistics.SetDisconnectOverflowState",sendData,"7.17");
            if(requestJsonRpcIsOk(result)){
                return callbackCode(0);
            }else{
                return callbackCode(1);
            }   
        },

        GetHistoryStatistics:function(){
            var result = requestJsonRpcSync("Statistics.GetHistoryStatistics",null,"7.18");
            if(requestJsonRpcIsOk(result)){
                return result.result;
            }else{
                return result.error;
            }  
        },

        SetUsageAlert:function(sendData){
            var result = requestJsonRpcSync("Statistics.SetUsageAlert",sendData,"7.19");
            if(requestJsonRpcIsOk(result)){
                return callbackCode(0);
            }else{
                return callbackCode(1);
            }   
        },

        GetCurrentMonthUsage:function(){
            var result = requestJsonRpcSync("Statistics.GetCurrentMonthUsage",null,"7.20");
            if(requestJsonRpcIsOk(result)){
                return result.result;
            }else{
                return result.error;
            }  
        }
    }
    //Statistics end    
    CallLog = {
        GetCallLogList : function(CallLogType)        {
           
            var result = requestJsonRpcSync("CallLog.GetCallLogList", {"Type":CallLogType}, "11.1");
            if (requestJsonRpcIsOk(result))
            {
                return result.result;
            } else
            {
                return result.error;
            }
        },

        DeleteCallLog : function(id)
        {
            if (!isNumber(id))
            {
                return callbackCode(1001)
            }
            var result = requestJsonRpcSync("CallLog.DeleteCallLog", {"Id" : id}, "11.2");
            if (requestJsonRpcIsOk(result))
            {
                return callbackCode(0);
            } else
            {
                return callbackCode(1);// Delete CallLog failed
            }
        },

        ClearCallLog : function(CallLogType)        {
           
            var result = requestJsonRpcSync("CallLog.ClearCallLog", {"Type":CallLogType}, "11.3");
            if (requestJsonRpcIsOk(result))
            {
                return result.result;
            } else
            {
                return result.error;
            }
        }
    },
    //CallLog end  

    DMZ = {
        GetDMZSettings : function()        {
           
            var result = requestJsonRpcSync("DMZ.GetDMZSettings", null, "13.1");
                       
            if (requestJsonRpcIsOk(result))
            {
                return result.result;
            } else
            {
                return result.error;
            }
        },
	
        SetDMZSettings : function(sendData)        {
           
            var result = requestJsonRpcSync("DMZ.SetDMZSettings", sendData, "13.2");
                       
            if (requestJsonRpcIsOk(result))
            {
                return callbackCode(0);
            } else
            {
                return callbackCode(1);
            }
        }
    }
    //DMZ end

    UPnP = {
        GetUPnPSettings : function()        {
           
            var result = requestJsonRpcSync("UPnP.GetUPnPSettings", null, "13.1");
                       
            if (requestJsonRpcIsOk(result))
            {
                return result.result;
            } else
            {
                return result.error;
            }
        },
    
        SetUPnPSettings : function(sendData)        {
           
            var result = requestJsonRpcSync("UPnP.SetUPnPSettings", sendData, "13.2");
                       
            if (requestJsonRpcIsOk(result))
            {
                return callbackCode(0);
            } else
            {
                return callbackCode(1);
            }
        }
    }
    //DMZ end
	/* ALG Start */
	function checkPortInvalid(port)
	{
		var re = /^([1-9][0-9]{0,3}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]{1}|6553[0-5])$/;
		return re.test(port);
	}

	function checkStatusInvalid(status)
	{
		if (status == 0 || status == 1)
		{
			return true;
		} else
		{
			return false;
		}
	}

	ALG = {
		GetALGSettings : function()
		{
			var result = requestJsonRpcSync("ALG.GetALGSettings", null, "15.1");
			if (requestJsonRpcIsOk(result))
			{
				return result;
			} else
			{
				return callbackCode(4000);
			}
		},

		SetALGSettings : function(Ftp,PptpStatus, H323AlgStatus, SipAlgStatus, SipAlgPort)
		{
			if (!checkStatusInvalid(Ftp)||!checkStatusInvalid(PptpStatus) || !checkStatusInvalid(H323AlgStatus) || !checkStatusInvalid(SipAlgStatus))
			{
				return callbackCode(1001);
			}
			var result = requestJsonRpcSync("ALG.SetALGSettings", {
				"Ftp":Ftp,
				"PptpStatus" : PptpStatus,
				"H323AlgStatus" : H323AlgStatus,
				"SipAlgStatus" : SipAlgStatus,
				"SipAlgPort" : SipAlgPort
			}, "15.2");
			if (requestJsonRpcIsOk(result))
			{
				return callbackCode(0);
			} else
			{
				return callbackCode(4000);
			}
		}
	};
	/* ALG end */
	/* VirtualServer start */
	function checkServerConfigList(ConfigList)
	{
		for ( var e in ConfigList)
		{
			serverConfigList = ConfigList[e];

			if (serverConfigList.hasOwnProperty("Id") && serverConfigList.hasOwnProperty("VirtualServerName") && serverConfigList.hasOwnProperty("WanPort") && serverConfigList.hasOwnProperty("LanIP") && serverConfigList.hasOwnProperty("LanPort") && serverConfigList.hasOwnProperty("Protocol") && serverConfigList.hasOwnProperty("SingleServerStatus"))
			{
				if (!isInterger(serverConfigList.Id))
				{
					return false;
				}
				if (!checkStringInvalid(serverConfigList.VirtualServerName))
				{
					return false;
				}
				if (!checkPortInvalid(serverConfigList.WanPort) || !checkPortInvalid(serverConfigList.LanPort))
				{
					return false;
				}
				if (!cbi_validators.ip4addr.apply(serverConfigList.LanIP))
				{
					return false;
				}
				if (!isNumber(serverConfigList.Protocol) || !isNumber(serverConfigList.SingleServerStatus))
				{
					return false;
				}
			}else {
				return false;
			}
		}
		return true;
	}

	
	VirtualServer = {
		GetVirtualServerSettings : function()
		{
			var result = requestJsonRpcSync("Nat.GetVirtualServerSettings", null, "18.1");
			if (requestJsonRpcIsOk(result))
			{
				return result;
			} else
			{
				return callbackCode(4000);
			}
		},

		SetVirtualServerSettings : function(VirtualServerStatus, ServerConfigList)
		{
			if (!checkStatusInvalid(VirtualServerStatus))
			{
				return callbackCode(1001);
			}
			if (ServerConfigList.length > 0 && !checkServerConfigList(ServerConfigList))
			{
				return callbackCode(1001);
			}
			var result = requestJsonRpcSync("Nat.SetVirtualServerSettings", {
				"VirtualServerStatus" : VirtualServerStatus,
				"ServerConfigList" : ServerConfigList
			}, "18.2");
			if (requestJsonRpcIsOk(result))
			{
				return callbackCode(0);
			} else
			{
				return callbackCode(4000);
			}
		}
	};
	/* VirtualServer end */

	/* User start */
	function checkStringInvalid(str)
	{
		if (str == null || str == "")
		{
			return false;
		} else
		{
			return true;
		}
	}

	User = {
		Login : function(Username, Password)
		{
			if (!checkStringInvalid(Username) || !checkStringInvalid(Password))
			{
				return callbackCode(1001);
			}
			var result = requestJsonRpcSync("User.Login", {
				"Username" : Username,
				"Password" : Password
			}, "1.1");
			if (requestJsonRpcIsOk(result))
			{
				return result;
			} else
			{
				var errorCode = result.error.code;
				if (errorCode == 10101)
				{
					// Username or Password is not correct.
					return callbackCode(4001);

				} else if (errorCode == 10102)
				{
					// login failed
					return callbackCode(4002);

				} else
				{
					return callbackCode(4003);
				}
			}
		},

		GetLoginState : function()
		{
			var result = requestJsonRpcSync("User.GetLoginState", null, "1.2");
			if (requestJsonRpcIsOk(result))
			{
				return result;
			} else
			{
				return callbackCode(4000);
			}
		},

		Logout : function()
		{
			var result = requestJsonRpcSync("User.Logout", null, "1.3");
			if (requestJsonRpcIsOk(result))
			{
				return callbackCode(0);
			} else
			{
				return callbackCode(4000);
			}
		},

		ChangePassword : function(Username, currPassword, newPassword)
		{
			if (!checkStringInvalid(Username) || !checkStringInvalid(currPassword) || !checkStringInvalid(newPassword))
			{
				return callbackCode(1001);
			}
			var result = requestJsonRpcSync("User.ChangePassword", {
				"UserName" : Username,
				"CurrPassword" : currPassword,
				"NewPassword" : newPassword
			}, "1.4");
			if (requestJsonRpcIsOk(result))
			{
				return callbackCode(0);
				;
			} else
			{
				return callbackCode(4000);
			}
		},
		UpdateLoginTime:function(){
		    requestJsonRpcAsync("User.UpdateLoginTime",{sysauth:getCookie("sysauth")},"1.5",function(){

		    });
		}
	};

    Wlan = {
        GetWlanState:function(){
            var result = requestJsonRpcSync("Wlan.GetWlanState",null,"5.1");
            if(requestJsonRpcIsOk(result)){
                return result.result.State;
            }else{
                return result.error;
            }   
        },

        SetWlanOff:function(){
            var result = requestJsonRpcSync("Wlan.SetWlanOff",null,"5.2");
            if(requestJsonRpcIsOk(result)){
                return callbackCode(0);
            }else{
                return callbackCode(1);
            }   
        },

        GetWlanSettings:function(){
            var result = requestJsonRpcSync("Wlan.GetWlanSettings",null,"5.3");
            if(requestJsonRpcIsOk(result)){
                return result.result;
            }else{
                return result.error;
            }   
        },

        SetWlanSettings:function(settings,callback){
            var result = requestJsonRpcAsync("Wlan.SetWlanSettings",settings,"5.4",function(result){
                if($.isEmptyObject(result)){
                    callback(callbackCode(0));
                }else{
                    callback(callbackCode(1));
                }   
            });
        },

        GetWlanStatistics:function(){
            var result = requestJsonRpcSync("Wlan.GetWlanStatistics",null,"5.5");
            if(requestJsonRpcIsOk(result)){
                return result.result;
            }else{
                return result.error;
            }   
        },

        GetNumOfHosts:function(){
            var result = requestJsonRpcSync("Wlan.GetNumOfHosts",null,"5.6");
            if(requestJsonRpcIsOk(result)){
                return result.result;
            }else{
                return result.error;
            }   
        },

        GetWlanHostList:function(){
            var result = requestJsonRpcSync("Wlan.GetWlanHostList",null,"5.7");
            if(requestJsonRpcIsOk(result)){
                return result.result;
            }else{
                return result.error;
            }   
        },

        GetWpsSettings:function(){
            var result = requestJsonRpcSync("Wlan.GetWpsSettings",null,"5.8");
            if(requestJsonRpcIsOk(result)){
                return result.result;
            }else{
                return result.error;
            }   
        },

        SetWpsSettings:function(settings){
            var result = requestJsonRpcSync("Wlan.SetWpsSettings",settings,"5.9");
            if(requestJsonRpcIsOk(result)){
                return callbackCode(0);
            }else{
                return callbackCode(1);
            }   
        },
        GetCountryList:function(){
            var result = requestJsonRpcSync("Wlan.GetCountryList",null,"5.10");
            if(requestJsonRpcIsOk(result)){
                return result.result;
            }else{
                return result.error;
            }   
        },
        GetChannelList:function(){
            var result = requestJsonRpcSync("Wlan.GetChannelList",null,"5.11");
            if(requestJsonRpcIsOk(result)){
                return result.result;
            }else{
                return result.error;
            }   
        }
    }

    Filter = {
        GetIPFilterSettings:function(){
            var result = requestJsonRpcSync("Filter.GetIPFilterSettings",{},"17.1");
            if(requestJsonRpcIsOk(result)){
                return result.result;
            }else{
                return result.error;
            }   
        },
        SetIPFilterSettings:function(settings){
            var result = requestJsonRpcSync("Filter.SetIPFilterSettings",settings,"17.2");
            if(requestJsonRpcIsOk(result)){
                return callbackCode(0);
            }else{
                return callbackCode(1);
            }   
        },
        GetMacFilterSettings:function(){
            var result = requestJsonRpcSync("Filter.GetMacFilterSettings",null,"17.3");
            if(requestJsonRpcIsOk(result)){
                return result.result;
            }else{
                return result.error;
            }   
        },
        SetMacFilterSettings:function(settings){
            var result = requestJsonRpcSync("Filter.SetMacFilterSettings",settings,"17.4");
            if(requestJsonRpcIsOk(result)){
                return callbackCode(0);
            }else{
                return callbackCode(1);
            }   
        },

        GetUrlFilterSettings:function(){
            var result = requestJsonRpcSync("Filter.GetUrlFilterSettings",null,"17.5");
            if(requestJsonRpcIsOk(result)){
                return result.result;
            }else{
                return result.error;
            }   
        },
        SetUrlFilterSettings:function(settings){
            var result = requestJsonRpcSync("Filter.SetUrlFilterSettings",settings,"17.6");
            if(requestJsonRpcIsOk(result)){
                return callbackCode(0);
            }else{
                return callbackCode(1);
            }   
        }
    }

  LAN = {
        GetLanSettings:function(){
            var result = requestJsonRpcSync("LAN.GetLanSettings",null,"16.1");
            if(requestJsonRpcIsOk(result)){
                return result.result;
            }else{
                return result.error;
            }   
        },

        SetLanSettings:function(settings){
            var result = requestJsonRpcSync("LAN.SetLanSettings",settings,"6.2");
            if(requestJsonRpcIsOk(result)){
                return callbackCode(0);
            }else{
                return callbackCode(1);
            }   
        },
        GetLanStatistics:function(){
            var result = requestJsonRpcSync("LAN.GetLanStatistics",null,"16.3");
            if(requestJsonRpcIsOk(result)){
                return result.result;
            }else{
                return callbackCode(4000);
            }   
        },
        GetLanPortInfo:function(){
            var result = requestJsonRpcSync("LAN.GetLanPortInfo",null,"16.4");
            if(requestJsonRpcIsOk(result)){
                return result.result;
            }else{
                return callbackCode(4000);
            }   
        },
        GetDHCPHostList:function(){
            var result = requestJsonRpcSync("LAN.GetDHCPHostList",null,"16.5");
            if(requestJsonRpcIsOk(result)){
                return result.result;
            }else{
               return callbackCode(4000);
            }   
        }
        
    }
   /* Services start */
    Services = {
    	
	   
		SetServiceState : function(ServiceType, State)
		{
			if (!isNumber(ServiceType) || !isNumber(State))
			{
				return callbackCode(1001);
			}
			var result = requestJsonRpcSync("Services.SetServiceState", {
				"ServiceType" : ServiceType,
				"State" : State
			}, "10.3");
			if (requestJsonRpcIsOk(result))
			{
				return callbackCode(0);
			} else
			{
				return callbackCode(4000);
			}
		},
		GetServiceState : function(ServiceType)
		{
			if (!isNumber(ServiceType))
			{
				return callbackCode(1001);
			}
			var result = requestJsonRpcSync("Services.GetServiceState", {
				"ServiceType" : ServiceType
			}, "10.4");
			if (requestJsonRpcIsOk(result))
			{
				return result;
			} else
			{
				return callbackCode(4000);
			}
		},

		GetSambaSettings : function()
		{
			var result = requestJsonRpcSync("Services.Samba.GetSettings", null, "10.5");
			if (requestJsonRpcIsOk(result))
			{
				return result;
			} else
			{
				return callbackCode(4000);
			}
		},

		SetSambaSettings : function(DevType, Anonymous, UserName, Password, AuthType)
		{
			if (!checkStringInvalid(UserName) || !isNumber(DevType) || !isNumber(Anonymous) || !isNumber(AuthType))
			{
				return callbackCode(1001);
			}
			var result = requestJsonRpcSync("Services.Samba.SetSettings", {
				"DevType" : DevType,
				"Anonymous" : Anonymous,
				"UserName" : UserName,
				"Password" : Password,
				"AuthType" : AuthType
			}, "10.6");
			if (requestJsonRpcIsOk(result))
			{
				return callbackCode(0);
			} else
			{
				return callbackCode(4000);
			}
		},
		GetDLNASettings : function()
		{
			var result = requestJsonRpcSync("Services.DLNA.GetSettings", null, "10.7");
			if (requestJsonRpcIsOk(result))
			{
				return result;
			} else
			{
				return callbackCode(4000);
			}
		},
		SetDLNASettings : function(DevType)
		{
			if (!isNumber(DevType))
			{
				return callbackCode(1001);
			}
			var result = requestJsonRpcSync("Services.DLNA.SetSettings", {
				"DevType" : DevType
			}, "10.8");
			if (requestJsonRpcIsOk(result))
			{
				return callbackCode(0);
			} else
			{
				return callbackCode(4000);
			}
		},
		GetFtpSettings : function()
		{
			var result = requestJsonRpcSync("Services.FTP.GetSettings", null, "10.9");
			if (requestJsonRpcIsOk(result))
			{
				return result;
			} else
			{
				return callbackCode(4000);
			}
		},

		SetFtpSettings : function(DevType, Anonymous, UserName, Password, AuthType)
		{
			if (!checkStringInvalid(UserName) || !isNumber(DevType) || !isNumber(Anonymous) || !isNumber(AuthType))
			{
				return callbackCode(1001);
			}
			var result = requestJsonRpcSync("Services.FTP.SetSettings", {
				"DevType" : DevType,
				"Anonymous" : Anonymous,
				"UserName" : UserName,
				"Password" : Password,
				"AuthType" : AuthType
			}, "10.10");
			if (requestJsonRpcIsOk(result))
			{
				return callbackCode(0);
			} else
			{
				return callbackCode(4000);
			}
		},

        RestartService:function(ServiceType){
            var result = requestJsonRpcSync("Services.RestartService",{ServiceType:parseInt(ServiceType)},"10.11");
            if(requestJsonRpcIsOk(result)){
                return callbackCode(0);
            }else{
                return callbackCode(1);
            }   
        },

        GetStorage : function(){
            var result = requestJsonRpcSync("Services.PrivateCloud.GetStorage", null, "10.11");
            if (requestJsonRpcIsOk(result)){
                return result;
            } else{
                return callbackCode(4000);
            }
        },
        SetStorage : function(DevType){

            if (!isNumber(DevType) || !isNumber(DevType)){
                return callbackCode(1001);
            }
            var result = requestJsonRpcSync("Services.PrivateCloud.SetStorage", {
                "DevType" : DevType
            }, "10.12");
            if (requestJsonRpcIsOk(result)){
                return callbackCode(0);
            } else{
                return callbackCode(4000);
            }

        }

	}
    Services.TR069 = {
        SetClientConfiguration:function(settings){
            var result = requestJsonRpcSync("Services.TR069.SetClientConfiguration",settings,"10.1");
            if(requestJsonRpcIsOk(result)){
                return callbackCode(0);
            }else{
                return callbackCode(1);
            }   
        },

        GetClientConfiguration:function(){
            var result = requestJsonRpcSync("Services.TR069.GetClientConfiguration",null,"10.2");
            if(requestJsonRpcIsOk(result)){
                return result.result;
            }else{
                return result.error;
            }   
            
        }   
    }
	
	/* Services end */
	/* Qos Start */
	
	function checkQosConfigList(ConfigList)
	{
		for ( var e in ConfigList)
		{
			serverConfigList = ConfigList[e];

			if (serverConfigList.hasOwnProperty("Id") && serverConfigList.hasOwnProperty("Priority") && serverConfigList.hasOwnProperty("SrcIPAddress") && serverConfigList.hasOwnProperty("Port") && serverConfigList.hasOwnProperty("Protocol") && serverConfigList.hasOwnProperty("Service"))
			{
				if (!isInterger(serverConfigList.Id))
				{
					return false;
				}
				if (serverConfigList.SrcIPAddress != "" && !cbi_validators.ip4addr.apply(serverConfigList.SrcIPAddress))
				{
					return false;
				}
				if (!isNumber(serverConfigList.Priority) || !isNumber(serverConfigList.Protocol)|| !isNumber(serverConfigList.Service))
				{
					return false;
				}
				var portList = serverConfigList.Port.split(",");
				if (serverConfigList.Port != "" && portList.length != 0)
				{
					for ( var i in portList)
					{
						if (!checkPortInvalid(portList[i]))
						{
							return false;
						} 
					}
				}
			} else
			{
				return false;
			}
		}
		return true;
	}
	Qos = {
		GetQosSettings : function()
		{
			var result = requestJsonRpcSync("Qos.GetQosSettings", null, "20.1");
			if (requestJsonRpcIsOk(result))
			{
				return result;
			} else
			{
				return callbackCode(4000);
			}
		},

		SetQosSettings : function(State, QosList)
		{
			if (!checkStatusInvalid(State))
			{
				return callbackCode(1001);
			}
			if (QosList.length > 0 && !checkQosConfigList(QosList))
			{
				return callbackCode(1001);
			}
			var result = requestJsonRpcSync("Qos.SetQosSettings", {
				"State" : State,
				"QosList" : QosList
			}, "20.2");
			if (requestJsonRpcIsOk(result))
			{
				return callbackCode(0);
			} else
			{
				return callbackCode(4000);
			}
		},
		GetConnectedIP : function()
		{
			var result = requestJsonRpcSync("Qos.GetConnectedIP", null, "20.3");
			if (requestJsonRpcIsOk(result))
			{
				return result;
			} else
			{
				return callbackCode(4000);
			}
		}
	};
	/* Qos end */

    /*Firewall Start*/
    Firewall = {
        GetFirewallSettings:function(){
            var result = requestJsonRpcSync("Firewall.GetFirewallSettings",null,"23.2");
            if(requestJsonRpcIsOk(result)){
                return result.result;
            }else{
                return result.error;
            }   
            
        },
        SetFirewallSettings:function(settings){
            var result = requestJsonRpcSync("Firewall.SetFirewallSettings",settings,"23.1");
            if(requestJsonRpcIsOk(result)){
                return callbackCode(0);
            }else{
                return callbackCode(1);
            }   
        }
    }
    /*Firewall End*/

    /* User Settings Start */
    UserSettings = {
        GetUserSettings : function()
        {
           var result = requestJsonRpcSync("UserSettings.GetUserSettings", null, "19.1");

            if (requestJsonRpcIsOk(result))
            {
                return result.result;
            } else
            {
               return callbackCode(4000)
            }
        },

        SetUserSettings : function(sendData)
        {
            var result = requestJsonRpcSync("UserSettings.SetUserSettings", sendData, "19.2");

            if (requestJsonRpcIsOk(result))
            {
                return callbackCode(0);
            } else
            {
                return callbackCode(1);
            }
        }
    };    
        /*User Settings End*/
		/* RoutingRules start */
	function isValidSubnetMask(mask) {
	    var i = 0;
	    var num = 0;
	    var zeroBitPos = 0, oneBitPos = 0;
	    var zeroBitExisted = false;

	    if (mask == '0.0.0.0') {
	        return true;
	    }

	    if (mask == '255.255.255.255') {
	        return true;
	    }

	    var maskParts = mask.split('.');
	    if (maskParts.length != 4) {
	        return false;
	    }

	    for (i = 0; i < 4; i++) {
	        if (isNaN(maskParts[i]) == true) {
	            return false;
	        }
	        if (maskParts[i] == '') {
	            return false;
	        }
	        if (maskParts[i].indexOf(' ') != -1) {
	            return false;
	        }

	        if ((maskParts[i].indexOf('0') == 0) && (maskParts[i].length != 1)) {
	            return false;
	        }

	        num = parseInt(maskParts[i]);
	        if (num < 0 || num > 255) {
	            return false;
	        }
	      
	    }

	    return true;
	}
	function checkRouterConfigList(ConfigList)
	{
		for ( var e in ConfigList)
		{
			serverConfigList = ConfigList[e];

			if (serverConfigList.hasOwnProperty("Id") && serverConfigList.hasOwnProperty("DestNetAddr") && serverConfigList.hasOwnProperty("DestNetmask") && serverConfigList.hasOwnProperty("GateWay"))
			{
				if (!isInterger(serverConfigList.Id))
				{
					return false;
				}
				if (serverConfigList.DestNetAddr != "" && !cbi_validators.ip4addr.apply(serverConfigList.DestNetAddr))
				{
					return false;
				}
				if (serverConfigList.DestNetmask != "" && !isValidSubnetMask(serverConfigList.DestNetmask))
				{
					return false;
				}
				if (serverConfigList.GateWay != "" && !cbi_validators.ip4addr.apply(serverConfigList.GateWay))
				{
					return false;
				}
			} else
			{
				return false;
			}
		}
		return true;
	}
	
	RoutingRules = {
		GetStaticRouting : function()
		{
			var result = requestJsonRpcSync("RoutingRules.GetStaticRouting", null, "21.1");
			if (requestJsonRpcIsOk(result))
			{
				return result;
			} else
			{
				return callbackCode(4000);
			}
		},
		SetStaticRouting : function(State, StaticRoutingList)
		{
			if (!checkStatusInvalid(State))
			{
				return callbackCode(1001);
			}
			if (StaticRoutingList.length > 0 && !checkRouterConfigList(StaticRoutingList))
			{
				return callbackCode(1001);
			}
			var result = requestJsonRpcSync("RoutingRules.SetStaticRouting", {
				"State" : State,
				"StaticRoutingList" : StaticRoutingList
			}, "21.2");
			if (requestJsonRpcIsOk(result))
			{
				return callbackCode(0);
			} else
			{
				return callbackCode(4000);
			}
		},
		GetDynamicRouting : function()
		{
			var result = requestJsonRpcSync("RoutingRules.GetDynamicRouting", null, "21.3");
			if (requestJsonRpcIsOk(result))
			{
				return result;
			} else
			{
				return callbackCode(4000);
			}
		},
		SetDynamicRouting : function(RipState,RipVerion)
		{
			if (!checkStatusInvalid(RipState))
			{
				return callbackCode(1001);
			}
			if (!isNumber(RipVerion))
			{
				return callbackCode(1002);
			}
			var result = requestJsonRpcSync("RoutingRules.SetDynamicRouting", {
				"RipState": RipState,
				"RipVerion": RipVerion
			}, "21.4");
			if (requestJsonRpcIsOk(result))
			{
				return callbackCode(0);
			} else
			{
				return callbackCode(4000);
			}
		}

	}
	/* RoutingRules end */

    /*Update start*/
    Update = {
        GetFOTADownloadState:function(){
            var result = requestJsonRpcSync("Update.GetFOTADownloadState",null,"22.1");
            if(requestJsonRpcIsOk(result)){
                return result.result;
            }else{
                return result.error;
            }
        },

        SetFOTAStartCheckVersion:function(){
            var result = requestJsonRpcSync("Update.SetFOTAStartCheckVersion", null, "22.2");
            if (requestJsonRpcIsOk(result)){
                return callbackCode(0);
            } else{
                return callbackCode(1);
            }
        },

        GetDeviceNewVersion:function(){
            var result = requestJsonRpcSync("Update.GetDeviceNewVersion",null,"22.3");
            if(requestJsonRpcIsOk(result)){
                return result.result;
            }else{
                return result.error;
            }
        },

        SetFOTAStartDownload:function(){
            var result = requestJsonRpcSync("Update.SetFOTAStartDownload", null, "22.4");
            if (requestJsonRpcIsOk(result)){
                return callbackCode(0);
            } else{
                return callbackCode(1);
            }
        },

        SetFOTADownloadStop:function(){
            var result = requestJsonRpcSync("Update.SetFOTADownloadStop", null, "22.5");
            if (requestJsonRpcIsOk(result)){
                return callbackCode(0);
            } else{
                return callbackCode(1);
            }
        },

        SetDeviceStartUpdate:function(){
            var result = requestJsonRpcSync("Update.SetDeviceStartUpdate", null, "22.6");
            if (requestJsonRpcIsOk(result)){
                return callbackCode(0);
            } else{
                return callbackCode(1);
            }
        },

        GetFOTADownloadProcess:function(){
            var result = requestJsonRpcSync("Update.GetFOTADownloadProcess",null,"22.7");
            if(requestJsonRpcIsOk(result)){
                return result.result;
            }else{
                return result.error;
            }
        },
        

        StartFOTAUpgradeOneStep:function(){
            var result = requestJsonRpcSync("Update.StartFOTAUpgradeOneStep",null,"22.8");
            if(requestJsonRpcIsOk(result)){
                return {result:result.result};
            }else{
                return {error:result.error};
            }  
        },
        GetFOTAUpgradeState:function(){
            var result = requestJsonRpcSync("Update.GetFOTAUpgradeState",null,"22.9");
            if(requestJsonRpcIsOk(result)){
                return {result:result.result};
            }else{
                return {error:result.error};
            }
        }
    }

    /*Update end*/
    return {
        requestJsonRpcAsync:requestJsonRpcAsync,
        requestJsonRpcSync:requestJsonRpcSync,
        requestJsonRpcIsOk:requestJsonRpcIsOk,
        SIM:SIM,
        SMS:SMS,
        System:System,
        Network:Network,
        Statistics:Statistics,
        Profile:Profile,
        WanConnection:WanConnection,
        CallLog:CallLog,
        DMZ:DMZ,
        UPnP:UPnP,
        ALG:ALG,
        VirtualServer:VirtualServer,
        User:User,
        Wlan:Wlan,
	LAN:LAN,
        Filter:Filter,
        Services:Services,
        Qos : Qos,
        Firewall:Firewall,
        UserSettings:UserSettings,
    	RoutingRules : RoutingRules,
        Update:Update
    };
    
})()
