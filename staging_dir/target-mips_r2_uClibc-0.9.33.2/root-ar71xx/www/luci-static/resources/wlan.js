var G_SDK_WLAN_STATE_OFF = 0;
var G_SDK_WLAN_STATE_ON = 1;

var G_SDK_WLAN_MODE_FREQUENCY_DISABLE= 0;//disable
var G_SDK_WLAN_MODE_FREQUENCY_2G = 1; //2.4GHz
var G_SDK_WLAN_MODE_FREQUENCY_5G = 2; //5GHz

var G_SDK_WLAN_SECURITY_MODE_DISABLE = 0;
var G_SDK_WLAN_SECURITY_MODE_WEP = 1;
var G_SDK_WLAN_SECURITY_MODE_WPA = 2;
var G_SDK_WLAN_SECURITY_MODE_WPA2 = 3;
var G_SDK_WLAN_SECURITY_MODE_WPA_WPA2 = 4;


var G_SDK_WLAN_WPA_TYPE_TKIP = 0;
var G_SDK_WLAN_WPA_TYPE_AES = 1;
var G_SDK_WLAN_WPA_TYPE_AUTO = 2;

var G_SDK_WLAN_WEP_TYPE_OPEN = 0;
var G_SDK_WLAN_WEP_TYPE_SHARE = 1;

var G_SDK_WLAN_APISOLATION_DISABLE = 0;
var G_SDK_WLAN_APISOLATION_ENABLE = 1; 


var G_SDK_WLAN_BANDWIDTH_20 = 0;
var G_SDK_WLAN_BANDWIDTH_40 = 1;
var G_SDK_WLAN_BANDWIDTH_AUTO = 2;

var G_SDK_WLAN_SSID_BROADCAST_DISABLE = 1;
var G_SDK_WLAN_SSID_BROADCAST_ENABLE = 0; 


var G_SDK_WLAN_802MODE_ATUO = 0;
var G_SDK_WLAN_802MODE_A = 1;
var G_SDK_WLAN_802MODE_B = 2;
var G_SDK_WLAN_802MODE_G = 3;
var G_SDK_WLAN_802MODE_AN = 4;
var G_SDK_WLAN_802MODE_GN = 5;

var G_SDK_WLAN_WPS_STATE_OFF = 0;
var G_SDK_WLAN_WPS_STATE_ON = 1;

var G_SDK_WLAN_CHANNEL_AUTO_2G = -1;
var G_SDK_WLAN_CHANNEL_AUTO_5G = -2;

/*not support char*/
var MACRO_SUPPORT_CHAR_MIN = 32;
var MACRO_SUPPORT_CHAR_MAX = 127;
var MACRO_NOT_SUPPORT_CHAR_COMMA = 44;             //,
var MACRO_NOT_SUPPORT_CHAR_QUOTATION_MARK = 34;      //"
var MACRO_NOT_SUPPORT_CHAR_COLON = 58;          //:
var MACRO_NOT_SUPPORT_CHAR_SEMICOLON = 59;          //;
var MACRO_NOT_SUPPORT_BACKSLASH_MARK = 92;         //\
var MACRO_NOT_SUPPORT_CHAR_38 = 38;        //&
var MACRO_NOT_SUPPORT_CHAR_39 = 39;        //'
var MACRO_NOT_SUPPORT_CHAR_42 = 42;         //*
var MACRO_NOT_SUPPORT_CHAR_47 = 47;         ///
var MACRO_NOT_SUPPORT_CHAR_60 = 60;         //<
var MACRO_NOT_SUPPORT_CHAR_62 = 62;         //>
var MACRO_NOT_SUPPORT_CHAR_63 = 63;         //?
var MACRO_NOT_SUPPORT_CHAR_124 = 124;         //|

function checkSSID(ssid){
    return /^[A-Za-z0-9\.\s\-\_\~\!\@\#\$\%\^\*\(\)\+\-\<\>\{\}\[\]\|\,\?]+$/.test(ssid);
}

function checkEncryptionKey(type,key){
    var result = false;
    var keyLength = key.length;
    switch(parseInt(type)){
        case G_SDK_WLAN_SECURITY_MODE_WEP:
            result = isWepKey(key);
            break;
        case G_SDK_WLAN_SECURITY_MODE_WPA:
        case G_SDK_WLAN_SECURITY_MODE_WPA2:
        case G_SDK_WLAN_SECURITY_MODE_WPA_WPA2:
            
            break;
        default:
            result =  false;
    }

    return result;
}

function isASCIIData(str) {
    if (str == null) {
        return true;
    }
    var i = 0;
    var char_i;
    var num_char_i;
    for (i = 0; i < str.length; i++) {
        char_i = str.charAt(i);
        num_char_i = char_i.charCodeAt();
        if (num_char_i > 255) {
            return false;
        }
    }
}

function isHexaDigit(digit) {
    var hexVals = new Array("0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F", "a", "b", "c", "d", "e", "f");
    var len = hexVals.length;
    var i = 0;
    var ret = false;

    for (i = 0; i < len; i++) {
        if (digit == hexVals[i]) {
            break;
        }
    }

    if (i < len) {
        ret = true;
    }
    return ret;
}

function isHexaData(data) {
    var len = data.length;
    var i = 0;
    for (i = 0; i < len; i++) {
        if (isHexaDigit(data.charAt(i)) == false) {
            return false;
        }
    }
    return true;
}
function checkInputChar(str) {
    var i;
    var char_i;
    var num_char_i;

    if (str == "") {
        return true;
    }

    for (i = 0; i < str.length; i++) {
        char_i = str.charAt(i);
        num_char_i = char_i.charCodeAt();
        if ((num_char_i > MACRO_SUPPORT_CHAR_MAX) || (num_char_i < MACRO_SUPPORT_CHAR_MIN)) {
            return false;
        }
        else if ((MACRO_NOT_SUPPORT_CHAR_QUOTATION_MARK == num_char_i)
            || (MACRO_NOT_SUPPORT_CHAR_COLON == num_char_i)
            || (MACRO_NOT_SUPPORT_CHAR_SEMICOLON == num_char_i)
            || (MACRO_NOT_SUPPORT_BACKSLASH_MARK == num_char_i)
            || (MACRO_NOT_SUPPORT_CHAR_38 == num_char_i)
            ) {
            return false;
        }
        else {
            continue;
        }
    }
    return true;
}

function isWepKey(wepKey){
    var result;
    var wepKeyLength = wepKey.length;
    switch(parseInt(wepKeyLength)){
        case 5:
        case 13:
            if(isASCIIData(wepKey) == false){
                return false;
            }
            break;
        case 10:
        case 26:
            if(isHexaData(wepKey) == false){
                return false;
            }
            break;
        default:
            return false;
    }
    return true;
}

function isWpaKey(wpaKey){
    var result = false;
    var wpaKeyLength = wpaKey.length;
    if(wpaKeyLength < 8 || wpaKeyLength > 63 || !checkInputChar(wpaKey)){
        result = false;
    }else{
        result = true;  
    }
    return result;
}
