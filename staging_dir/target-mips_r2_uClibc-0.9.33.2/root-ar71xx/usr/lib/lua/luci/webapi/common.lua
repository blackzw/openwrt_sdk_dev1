module("luci.webapi.common", package.seeall)

ReturnCode =
{
	"RILD_ERRID_SUCCESS", -- 0
    "RILD_ERRID_FAILED", -- 1
    "RILD_ERRID_BAD_PARAMETER", -- 2
    "RILD_ERRID_DEVICE_NOT_READY", -- 3
    "RILD_ERRID_COMM_OPEN_FAILED", -- 4
    "RILD_ERRID_AT_INIT_ERROR", -- 5
    "RILD_ERRID_RPC_WRITE_FAILED",-- 6
    "RILD_ERRID_RPC_DISCONNECTED", -- 7
    "RILD_ERRID_AT_ERROR_TIMEOUT", -- 8
    "RILD_ERRID_AT_ERROR_NOT_ENOUGH_MEMORY", -- 9
    "RILD_ERRID_AT_ERROR_CALLBACK_FUNC_IS_NOT_READY", -- 10
    "RILD_ERRID_AT_ERROR_PHSIM_PIN_REQUIRED", -- 11
    "RILD_ERRID_AT_ERROR_PHFSIM_PIN_REQUIRED", -- 12
    "RILD_ERRID_AT_ERROR_PHFSIM_PUK_REQUIRED", -- 13
    "RILD_ERRID_AT_ERROR_SIM_NOT_INSERTED", -- 14
    "RILD_ERRID_AT_ERROR_SIM_PIN_REQUIRED", -- 15
    "RILD_ERRID_AT_ERROR_SIM_PUK_REQUIRED", -- 16
    "RILD_ERRID_AT_ERROR_SIM_FAILURE", -- 17
    "RILD_ERRID_AT_ERROR_SIM_BUSY", -- 18
    "RILD_ERRID_AT_ERROR_SIM_WRONG", -- 19
    "RILD_ERRID_AT_ERROR_INCORRECT_PASSWORD", -- 20
    "RILD_ERRID_AT_ERROR_SIM_PIN2_REQUIRED", -- 21
    "RILD_ERRID_AT_ERROR_SIM_PUK2_REQUIRED", -- 22
    "RILD_ERRID_AT_ERROR_PHNET_PIN_REQUIRED", -- 23
    "RILD_ERRID_AT_ERROR_PHNET_PUK_REQUIRED", -- 24
    "RILD_ERRID_AT_ERROR_PHNETSUB_PIN_REQUIRED", -- 25
    "RILD_ERRID_AT_ERROR_PHNETSUB_PUK_REQUIRED", -- 26
    "RILD_ERRID_AT_ERROR_PHSP_PIN_REQUIRED", -- 27
    "RILD_ERRID_AT_ERROR_PHSP_PUK_REQUIRED", -- 28
    "RILD_ERRID_AT_ERROR_PHCORP_PIN_REQUIRED", -- 29
    "RILD_ERRID_AT_ERROR_PHCORP_PUK_REQUIRED", -- 30
    "RILD_ERRID_AT_ERROR_PIN_VERIFY_OK_BUT_FAIL_TO_DISABLE_PIN", -- 31
    "RILD_ERRID_AT_ERROR_CALL_NO_CARRIER", -- 32
    "RILD_ERRID_AT_ERROR_CALL_NO_ANSWER", -- 33
    "RILD_ERRID_AT_ERROR_CALL_BUSY", -- 34
    "RILD_ERRID_AT_ERROR_CALL_NO_DIAL_TONE", -- 35
    "RILD_ERRID_AT_ERROR_CALL_INVALID_NUMBER", -- 36
    "RILD_ERRID_AT_ERROR_CALL_AUDIO_INVALID", -- 37
    "RILD_ERRID_AT_ERROR_PB_STORAGE_IS_FULL", -- 38
    "RILD_ERRID_AT_ERROR_PB_NO_NEED_TO_MOVE", -- 39
    "RILD_ERRID_AT_ERROR_PB_ITEM_SAVED_BUT_OLD_ONE_REMAINED", -- 40
    "RILD_ERRID_CANCELED_MANUALLY", -- 41
    "RILD_ERRID_NO_MESSAGE", -- 42
    "RILD_ERRID_ERROR_USER_DEFINE_ERROR", -- 43
    "RILD_ERRID_SOCKET_ERROR", -- 44
    "RILD_ERRID_PROFILE_STORAGE_IS_FULL", -- 45
    "RILD_ERRID_PROFILE_NO_ACTIVE", -- 46
    "RILD_ERRID_SMS_STORAGE_IS_FULL", -- 47
    "RILD_ERRID_SMS_SENDING_LAST_MESSAGE", -- 48
    "RILD_ERRID_TOO_MANY_REQUEST", -- 49
    "RILD_ERRID_AT_BUSY", -- 50
    "RILD_ERRID_USSD_SENDING_LAST", -- 51,
    "RILD_ERRID_USAGE_HISTORY_OVERFLOW", -- 52
}


function CreateEnumTable(tbl, index) 
    local enumtbl = {} 
    local enumindex = index or 0 
    for i, v in ipairs(tbl) do 
        enumtbl[v] = enumindex + i - 1 
    end 
    return enumtbl 
end 

ReturnCode = CreateEnumTable(ReturnCode, 0)

function LoadRildClientLibrary()
	rild_client_lib = assert(package.loadlib("/usr/lib/librild_client.so", "luaopen_rild_client"))
    rild_client_lib()
end

--LoadRildClientLibrary()

function GetCommonErrorObject(ret_code)
	if ret_code == ReturnCode.RILD_ERRID_SUCCESS then
		return nil
	elseif ret_code == ReturnCode.RILD_ERRID_BAD_PARAMETER then
		return {code=7, message="Bad parameter"}
	elseif ret_code == ReturnCode.RILD_ERRID_DEVICE_NOT_READY then
		return {code=1, message="Device not ready"}
	elseif ret_code == ReturnCode.RILD_ERRID_COMM_OPEN_FAILED or ret_code == ReturnCode.RILD_ERRID_AT_INIT_ERROR then
		return {code=2, message="AT port not ready"}
	elseif ret_code == ReturnCode.RILD_ERRID_AT_ERROR_TIMEOUT then
		return {code=3, message="AT timeout"}
	elseif ret_code == ReturnCode.RILD_ERRID_AT_ERROR_SIM_NOT_INSERTED then
		return {code=4, message="No SIM"}
	elseif ret_code == ReturnCode.RILD_ERRID_NO_MESSAGE then
		return {code=5, message="No message"}
	elseif ret_code == ReturnCode.RILD_ERRID_SOCKET_ERROR then
		return {code=6, message="Access ril service error"}
	elseif ret_code == ReturnCode.RILD_ERRID_PROFILE_NO_ACTIVE then
		return {code=8, message="No default profile"}
	elseif ret_code == ReturnCode.RILD_ERRID_TOO_MANY_REQUEST then
		return {code=9, message="RIL service is busy"}
	elseif ret_code == ReturnCode.RILD_ERRID_AT_BUSY then
		return {code=10, message="AT port is busy"}
	elseif ret_code == ReturnCode.RILD_ERRID_SMS_SENDING_LAST_MESSAGE then
		return {code=60302, message="Fail still sending last message"}
	elseif ret_code == ReturnCode.RILD_ERRID_SMS_STORAGE_IS_FULL then
		return {code=60303, message="Fail with memory full"}
	elseif ret_code == ReturnCode.RILD_ERRID_USAGE_HISTORY_OVERFLOW then
		return {code=80204, message="Usage history Overflow"}
	else
		return nil
	end
end


StatisticsReturnCode =
{
"STATISTICS_ERROR_SUCCESS", -- 0
"STATISTICS_ERROR_FAILED", -- 1
"STATISTICS_ERROR_PARAMETER_ERROR", -- 2
"STATISTICS_ERROR_REMOVE_SOCKET", -- 3
"STATISTICS_ERROR_NO_SPECIAL_MESSAGE", -- 4
"STATISTICS_ERROR_NO_MESSAGE",  --5
"STATISTICS_ERROR_DATABASE_FAILED", -- 6
"STATISTICS_ERROR_BUFFER_SMALL", -- 7
"STATISTICS_ERROR_OPENDATABASE_ERROR", -- 8
"STATISTICS_ERROR_NO_RECORD", -- 9
"STATISTICS_ERROR_NOT_SET_IMSI", -- 10
"STATISTICS_ERROR_POFILE_NO_ACTIVE", -- 11
}

StatisticsReturnCode = CreateEnumTable(StatisticsReturnCode, 0)

function GetCommonErrorObjectForStatistics(ret_code)
        if ret_code == ReturnCode.STATISTICS_ERROR_SUCCESS then
                return nil
        elseif ret_code == StatisticsReturnCode.STATISTICS_ERROR_PARAMETER_ERROR then
                return {code=7, message="Bad parameter"}
        elseif ret_code == StatisticsReturnCode.STATISTICS_ERROR_OPENDATABASE_ERROR then
                return {code=13, message="Open database file failed"}
        elseif ret_code == StatisticsReturnCode.STATISTICS_ERROR_DATABASE_FAILED then
                return {code=11, message="Failed to get or set database data."}
        elseif ret_code == StatisticsReturnCode.STATISTICS_ERROR_BUFFER_SMALL then
                return {code=12, message="Return buffer is smaller."}
        elseif ret_code == StatisticsReturnCode.STATISTICS_ERROR_NO_RECORD then
                return {code=14, message="No special record."}
        elseif ret_code == StatisticsReturnCode.STATISTICS_ERROR_NO_MESSAGE then
                return {code=5, message="No message"}
        elseif ret_code == StatisticsReturnCode.STATISTICS_ERROR_REMOVE_SOCKET then
                return {code=10, message="Access connect manager service error"}
        elseif ret_code == StatisticsReturnCode.STATISTICS_ERROR_NOT_SET_IMSI then
                return {code=15, message="Imsi is not ready."}
        elseif ret_code == StatisticsReturnCode.STATISTICS_ERROR_POFILE_NO_ACTIVE then
                return {code=8, message="No default profile"}
        else
                return nil
        end
end

function LoadConnectManagerClient()
    local connect_manager = assert(package.loadlib("/usr/lib/libconnect_manager_client.so", "luaopen_connect_manager_client"))
    connect_manager()
end

--LoadConnectManagerClient()


