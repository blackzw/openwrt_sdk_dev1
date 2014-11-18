//==========================================================================
/**
 *  @file    utility.h
 *  @brief  The header file of Utility.
 *  @version 1.0
 *  @author Tian Yiqing <yiqing.tian@tcl.com>
 *  @date 2013-10-15
 */
//==========================================================================
#ifndef UTILITY_H
#define UTILITY_H

#include <google/protobuf/message_lite.h>
//#include <google/protobuf/descriptor.h>
//#include <google/protobuf/reflection_ops.h>
//#include <google/protobuf/stubs/common.h>
#include <string>
#include <map>
using namespace std;

using namespace google::protobuf;
class Utility;

typedef MessageLite* (Utility::*newMessage)();

class Utility
{
public:
    static MessageLite* parseMessage(const string& buffer, const string& typeName);

public:
    static Utility* getInstance();
    static void destoryInstance();

protected:
    MessageLite* createMessage(const string& typeName);
    void initMap();
    //connection message
    MessageLite* newBLGetWanInfo();
    MessageLite* newBLProfileRequestInfo();
    MessageLite* newBLProfileInfo();
    MessageLite* newBLGetProfileList();
    MessageLite* newBLConnectionTypeMsg();
    //network message
    MessageLite* newBLNetworkGetInfoCnf();
    MessageLite* newBLNetworkListItem();
    MessageLite* newBLNetworkGetListCnf();
    MessageLite* newBLNetworkSetReq();
    MessageLite* newBLNetworkRegisterReq();
    MessageLite* newBLNetworkGetRegStateCnf();
    MessageLite* newBLNetworkGetLacAndCellIDCnf();
    MessageLite* newBLNetworkGetSDNList();
    MessageLite* newBLNetworkCommon();
    MessageLite* newBLTowerInfo();
    MessageLite* newBLLocationInfo();
    MessageLite* newBLNetworkSignalValue();
    MessageLite* newBLNetworkGetLTEBandEx();
    //pin message
    MessageLite* newBLPinState();
    MessageLite* newBLPinEnableReq();
    MessageLite* newBLPinChangeReq();
    MessageLite* newBLPinVerifyPukReq();
    MessageLite* newBLPinVerifyReq();
    MessageLite* newBLPinCommonRes();
    MessageLite* newBLPinGetAutoValidateStateRes();
    MessageLite* newBLPinSetAutoValidateStateReq();
    //sms message
    MessageLite* newBLSmsInitReq();
    MessageLite* newBLSmsGetListReq();
    MessageLite* newBLSmsListItem();
    MessageLite* newBLSmsGetListCnf();
    MessageLite* newBLSmsSendReq();
    MessageLite* newBLSmsGetProgressInfoReq();
    MessageLite* newBLSmsNumberRefItem();
    MessageLite* newBLSmsProgressBarPos();
    MessageLite* newBLSmsSendResultCnf();
    MessageLite* newBLSmsDeleteItem();
    MessageLite* newBLSmsDeleteReq();
    MessageLite* newBLSmsSaveReq();
    MessageLite* newBLSmsSaveCnf();
    MessageLite* newBLSmsAddress();
    MessageLite* newBLSmsSetScReq();
    MessageLite* newBLSmsStorageState();
    MessageLite* newBLSmsModifyTagReq();
    MessageLite* newBLSmsPreferredStorage();
    MessageLite* newBLSmsNewReport();
    MessageLite* newBLSmsSettings();
    MessageLite* newBLSmsGetCountReq();
    MessageLite* newBLSmsGetCountCnf();
    //system message
    MessageLite* newBLEquipmentInfo();
    MessageLite* newBLDiagInfo();
    MessageLite* newBLSystemCommon();
    MessageLite* newBLModuleLinuxVer();
    MessageLite* newBLSendCommandReq();
    MessageLite* newBLSendCommandRes();
    MessageLite* newBLFotaReport();
    MessageLite* newBLSetFotaVal();
    MessageLite* newBLGetImsiRes();
    //voicecall message
    MessageLite* newBLVoiceCallCommon();
    MessageLite* newBLVoiceCallGetState();
    MessageLite* newBLCallLogItem();
    MessageLite* newBLCallLogList();
    MessageLite* newBLCallLogCommon();
    // voicecall message extend function
    MessageLite* newBLVoiceCallJCinfo(void);
private:
    Utility();
    map<string, newMessage> m_newMessageMap;
    static Utility *g_utilityInstance;
};

extern uint32_t get_tick_seconds();

#endif // UTILITY_H
