//---------------- global ---------------------------------------
/* API result */
var API_RESULT_SUCCESS = 0;
var API_RESULT_FAIL = 1;

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

/*network type*/
var MACRO_NETWORKTYPE_NO_SERVICE = 0;
var MACRO_NETWORKTYPE_GPRS = 1;
var MACRO_NETWORKTYPE_EDGE = 2;
var MACRO_NETWORKTYPE_UMTS = 3;
var MACRO_NETWORKTYPE_HSDPA = 4;
var MACRO_NETWORKTYPE_HSPA = 5;
var MACRO_NETWORKTYPE_HSUPA = 6;
var MACRO_NETWORKTYPE_DS_HSPA_PLUS = 7;
var MACRO_NETWORKTYPE_LTE = 8;
var MACRO_NETWORKTYPE_GSM = 9;
var MACRO_NETWORKTYPE_HSPA_PLUS = 10;
var MACRO_NETWORKTYPE_UNKNOW = 11;

var refreshNetworkInfoFlag = false;
(function ($) {
	    $.fn.extend({
        findSelectRes:function (datas) {
            return this.each(function () {
                var option_HtmlStr = "";
                $.each(datas,function(index,val) {
                    option_HtmlStr += "<option value='" + index + "'>"+val + "</option>"
                });
                $(this).html(option_HtmlStr)
            });
        },
        findSelectIndex:function (datas) {
            return this.each(function () {
                var option_HtmlStr = "<option value='UTC'>UTC</option>";
                $.each(datas,function(index,val) {
                    option_HtmlStr += "<option value='" + index + "'>"+index + "</option>"
                });
                $(this).html(option_HtmlStr)
            });
        },
        setBtnDisabled:function(){
            return this.each(function(){
                $(this).attr("disabled",true).removeClass("btn-primary");
            })
        },
        removeBtnDisabled:function(){
            return this.each(function(){
                $(this).removeAttr("disabled").addClass("btn-primary");
            })
        },

        selectFocus:function () {
            return this.each(function () {
                $(this).val("").focus();
            })
        },

	    showRule:function (ruleStr) {
            var ruleMsg=ruleStr;
            return this.each(function () {
                var thisParent = $(this).parent("div");
                var ruleBox = thisParent.find(".rule");
                if (ruleBox.size() < 1) {
                    thisParent.append("<p class='rule'>" + ruleMsg + "</p>");
                } else {
                    thisParent.find(".rule").html(ruleMsg);
                }

                //$(this).selectFocus();
                $(this).addClass("errorIpt");
                $(this).bind("focusin",function(){
                    $(this).removeClass("errorIpt");
                    thisParent.find(".rule").remove();
                });
            });
        }
    });
})(jQuery);

var popUp={
    show:function(options){
        var defaults = {
            type:"alert",
            width:"auto",
            height:"auto",
            title:"",
            msg:"",
            time:2000
        };
        
        var opts = $.extend(defaults, options);
		$(".popUpMask").css({
            "min-height":$("body").height(),
			"min-width":$(document).width()
        });
        if($(".popUpMask").css("display")=="none"){
            /*if(!(!($.browser.msie&&($.browser.version == "6.0")&&!$.support.style))){
                $("#popUpWrap").css({
                    height:$("#wrap").height()
                });
            }*/
            $(".popUpMask,#popUpWrap").css({
                display: "block"
            });
            $(".popUpMask").show("slow").css({
                opacity:0.3
            });
        }
        $("html").css({
            "overflow-x":"hidden"
        });
        if(opts.type=="confirm"){
            $("#okBtnWrap,#cancelBtnWrap,#popUpClose").css({"display":"inline-block"});
            $("#popUpClose").unbind("click").bind("click",function(){
                popUp.hide();
            })
        }else if(opts.type=="alert"){
            $("#okBtnWrap,#popUpClose").css({
                display:"inline-block"
            });
            $("#cancelBtnWrap").hide(0);
            $("#popUpClose").unbind().bind("click",function(){
                popUp.hide();
                if ($.isFunction(opts.callback)) {
                    opts.callback.apply();
                }
            })
        }else if(opts.type=="openBox"){
            $("#okBtnWrap,#cancelBtnWrap").hide(0);
            $("#popUpClose").css({
                display:"inline-block"
            });
            $("#popUpClose").unbind().bind("click",function(){
                popUp.hide();
            })
        }else{
            $("#okBtnWrap,#cancelBtnWrap,#popUpClose").hide(0);
            if(opts.time!=-1){
                setTimeout(function(){
                    popUp.hide();
                },opts.time)
            }
        }
        $("#popUpTitle").html(opts.title);
        $("#popUpContent").html(opts.msg);
        $("#popUpBox").css({           
			"top":($(window).height()-$("#popUpBox").outerHeight())/2+$(document).scrollTop()+"px"
        }).fadeIn(200);

        $("#btnPopUpOk").unbind("click").bind("click",function(){
            popUp.hide();
            if ($.isFunction(opts.callback)) {
                opts.callback.apply();
            }
        })

        $("#cancelBtnWrap").unbind("click").bind("click",function(){
            popUp.hide();
        })
    },

    hide:function(){
        $(".popUpMask,#popUpWrap").fadeOut(0);
        $("#popUpBox").fadeOut(200);
        $("body").css({
            background:"#fff"
        })
        $("html").css({
            "overflow-x":"auto"
        });
    },

    alert:function(msg,callback){
        var option={
            type:"alert",
            msg:msg,
            callback:callback
        }
        popUp.show(option);
    },
    confirm:function(msg,callback){
        var option={
            type:"confirm",
            msg:msg,
            callback:callback
        }
        popUp.show(option);
    },
    prompt:function(msg,time){
        var option={
            type:"msg",
            msg:msg,
            time:time
        }
        popUp.show(option);
    },
    showBox:function(title,content){
        var option={
            type:"openBox",
            msg:content,
            title:title
        }
        popUp.show(option);
    }
}
var sys = {

    alert:function (strId, callback) {
        var resMsg = strId;       
        popUp.alert(callback==null?(resMsg!=undefined?resMsg:strId):resMsg!=undefined?resMsg:strId,callback);
    },
    confirm:function (strId, callback) {
        var resMsg = strId
        popUp.confirm(callback==null?(resMsg!=undefined?resMsg:strId):resMsg!=undefined?resMsg:strId,callback);
    },
    prompt:function(strId,time){
        var resMsg = strId
        popUp.prompt(time==null?(resMsg!=undefined?resMsg:strId):resMsg!=undefined?resMsg:strId,time)
    },
    getTimeDesc:function(time_sec) {
        var days = Math.floor(time_sec / 86400);
        var hours = Math.floor((time_sec - days * 86400) / 3600);
        var minutes = Math.floor((time_sec - days * 86400 - hours * 3600) / 60);
        var str = "";
        str += days + " " + ((days <= 1) ? "day" : "days") + " ";
        str += hours + " " + ((hours <= 1) ? 'hour' : 'hours') + " ";
        str += ((minutes < 10) ? "0" : "") + minutes + " " + ((minutes <= 1) ? "minute" : "minutes");
        return str;
    },

    covertNum:function(number) {
       return number > (1024 * 1024 * 1024)?(number / (1024 * 1024 *1024)).toFixed(2) + " GB":(number > (1024 * 1024) ? (number / (1024 * 1024)).toFixed(2) + " MB" : (number / 1024).toFixed(2) + " KB");
    } 
};

var indexPage = {
    init: function(){
        var that = this;

    },
    
    initNav:function(){
        $(".nav .dropdown").each(function(){
            var e = $(this);
            var c = e.find(".menu");
            var v = c.text();
            e.append('<p>'+v+'</p>');
            c.remove();
        });		
    },
    
    showSignalState:function (iLen) {
        var $signalImg = $("#icon-signal");
        var value = /^[0,1,2,3,4,5]$/;
        iLen = parseInt(iLen);
        iLen = value.test(iLen) ? iLen : 0;
        $signalImg.css("background-position", "center -" + iLen * 26 + "px");

    },

    showWanState:function (iwanState) {
        var $wanImg = $("#icon-wan");
        var value = /^[0,2]$/;
        iwanState=parseInt(iwanState);
        iwanState=value.test(iwanState)?iwanState:0;
        $wanImg.css("background-position","center -"+iwanState*26+"px");
    },
    refreshImgStatus:function () {
        var that = this;
        SDK.AsyncGetStatus.async_GetNetworkInfo(function(data){
            if(data == null) {
                return;
            }
            that.showSignalState(data.SignalStrength);
            //that.showWanState(data.NetworkType);
        });
        SDK.AsyncGetStatus.async_GetConnectionState(function(data){
            if(data == null){
                return;
            }
            that.showWanState(data.ConnectionStatus);

        });
    }
}

function check_profile_password(str) {
    return     !(/[\s'\"\\]/g.test(str))
}

function checkProfileName(name){
    return !(/[:;\,\"\\&%<>?\+]+/g.test(name));
}

function check_input_char(str) {
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
        else if ((MACRO_NOT_SUPPORT_CHAR_COMMA == num_char_i)
            || (MACRO_NOT_SUPPORT_CHAR_QUOTATION_MARK == num_char_i)
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

function getUrlPara(paraName) {
    var sUrl = location.href;
    var sReg = "(?:\\?|&){1}" + paraName + "=([^&]*)"
    var re = new RegExp(sReg, "gi");
    re.exec(sUrl);
    return RegExp.$1;
}

function getUniqueSMS(sms_id,smsType,pageNum)
{
	var single_sms;
	if (!isNumberStr(sms_id) || !isNumberStr(sms_id) || !isNumberStr(sms_id))
	{
		return {error:1001};
	}
	var data = SDK.SMS.GetSmsList(smsType, pageNum).result;
	if (data.hasOwnProperty("error"))
	{
		return {error:4000};
	}
	var SmsList = data.SmsList;
	if (SmsList.length == 0|| SmsList == null)
	{
		return {error:4000};
	}
	for ( var i in SmsList)
	{
		if (sms_id == SmsList[i].Id)
		{
			single_sms = SmsList[i];
			break;
		}
	}
	if (single_sms == null)
	{
		return {error:4000};
	}
	return single_sms;
}
function isNumberStr(str)
{
	return /^[0-9]+$/.test(str);
}

function isNumber(str) {
    var i;
    if (str.length <= 0) {
        return false;
    }
    for (i = 0; i < str.length; i++) {
        var c = str.charCodeAt(i);
        if (c < 48 || c > 57) {
            return false;
        }
    }
    return true;
}

function getImgNetworkType(networkType) {
    var wanNetworkTypeStr;

    switch (networkType) {
        case MACRO_NETWORKTYPE_NO_SERVICE:
            wanNetworkTypeStr = "NO service";
            break;
        case MACRO_NETWORKTYPE_GPRS:
            wanNetworkTypeStr = "GPRS";
            break;
        case MACRO_NETWORKTYPE_EDGE:
            wanNetworkTypeStr = "EDGE";
            break;
        case MACRO_NETWORKTYPE_UMTS:
            wanNetworkTypeStr = "UMTS";
            break;
        case MACRO_NETWORKTYPE_HSDPA:
            wanNetworkTypeStr = "HSDPA";
            break;
        case MACRO_NETWORKTYPE_HSPA:
            wanNetworkTypeStr = "HSPA";
            break;
        case MACRO_NETWORKTYPE_HSUPA:
            wanNetworkTypeStr = "HSUPA";
            break;
        case MACRO_NETWORKTYPE_DS_HSPA_PLUS:
            wanNetworkTypeStr = "DS-HSPA+";
            break;
        case MACRO_NETWORKTYPE_LTE:
            wanNetworkTypeStr = "LTE";
            break;
        case MACRO_NETWORKTYPE_GSM:
            wanNetworkTypeStr = "GSM";
            break;
        case MACRO_NETWORKTYPE_HSPA_PLUS:
            wanNetworkTypeStr = "HSPA+";
            break;
        case MACRO_NETWORKTYPE_UNKNOW:
            wanNetworkTypeStr = "unknown";
            break;
        default:
            wanNetworkTypeStr = "No service";
    }

    return wanNetworkTypeStr;
    
}
function getLeftMostZeroBitPos(num) {
    var i = 0;
    var numArr = [128, 64, 32, 16, 8, 4, 2, 1];
    for (i = 0; i < numArr.length; i++)
        if ((num & numArr[i]) == 0)
            return i;
    return numArr.length;
}


function getRightMostOneBitPos(num) {
    var i = 0;
    var numArr = [1, 2, 4, 8, 16, 32, 64, 128];
    for (i = 0; i < numArr.length; i++)
        if (((num & numArr[i]) >> i) == 1)
            return(numArr.length - i - 1);
    return -1;
}
function isValidIpAddress(address) {
    var addrParts = address.split('.');
    if (addrParts.length != 4) {
        return false;
    }
    for (i = 0; i < 4; i++) {
        if (isNaN(addrParts[i]) == true) {
            return false;
        }
        if (addrParts[i] == '') {
            return false;
        }
        if (addrParts[i].indexOf(' ') != -1) {
            return false;
        }
        if ((addrParts[i].indexOf('0') == 0) && (addrParts[i].length != 1)) {
            return false;
        }
    }
    if ((addrParts[0] <= 0 || addrParts[0] == 127 || addrParts[0] > 223)
        || (addrParts[1] < 0 || addrParts[1] > 255)
        || (addrParts[2] < 0 || addrParts[2] > 255)
        || (addrParts[3] <= 0 || addrParts[3] >= 255)) {
        return false;
    }
    return true;

}
function isValidSubnetMask(mask) {
    var i = 0;
    var num = 0;
    var zeroBitPos = 0,
        oneBitPos = 0;
    var zeroBitExisted = false;
    if (mask == '0.0.0.0') {
        return false;
    }
    if (mask == '255.255.255.255') {
        return false;
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
        if (zeroBitExisted == true && num != 0) {
            return false;
        }
        zeroBitPos = getLeftMostZeroBitPos(num);
        oneBitPos = getRightMostOneBitPos(num);
        if (zeroBitPos < oneBitPos) {
            return false;
        }
        if (zeroBitPos < 8) {
            zeroBitExisted = true;
        }
    }
    return true;
}
function IsSameSubnetAddrs(Ip1, Ip2, mask) {
    var addrParts1 = Ip1.split(".");
    var addrParts2 = Ip2.split(".");
    var maskParts = mask.split(".");
    for (i = 0; i < 4; i++) {
        if (((Number(addrParts1[i])) & (Number(maskParts[i]))) != ((Number(addrParts2[i])) & (Number(maskParts[i])))) {
            return false;
        }
    }
    return true;
}

var IntervalFn = {
    InterS:null,
    fns:[],
    poll:function(callback){
        callback();
        IntervalFn.fns.push(callback);
        if(IntervalFn.InterS == null){
            IntervalFn.start();
        }
        
    },

    init:function(){
        var i;
        for(i = 0;i < IntervalFn.fns.length;i++){
            IntervalFn.fns[i].apply();
        } 
    },

    start:function(){
        IntervalFn.stop();
        IntervalFn.InterS = window.setInterval(function(){
            IntervalFn.init();
        },5000);
    },

    stop:function(){
        clearInterval(IntervalFn.InterS);
        IntervalFn.InterS = null;
        
    }
}

function showImgWanSignal(wanSignal){
    $("#icon-signal").removeAttr("class").addClass("signal_"+wanSignal);
}

function isHasNetwork(networkType){
    var result = false;
    switch (networkType) {
        case MACRO_NETWORKTYPE_GPRS:
        case MACRO_NETWORKTYPE_EDGE:
        case MACRO_NETWORKTYPE_UMTS:
        case MACRO_NETWORKTYPE_HSDPA:
        case MACRO_NETWORKTYPE_HSPA:
        case MACRO_NETWORKTYPE_HSUPA:
        case MACRO_NETWORKTYPE_DS_HSPA_PLUS:
        case MACRO_NETWORKTYPE_LTE:  
        case MACRO_NETWORKTYPE_GSM:  
        case MACRO_NETWORKTYPE_HSPA_PLUS:
        case MACRO_NETWORKTYPE_UNKNOW:
             result = true;
             break;  
        default:
            result = false;
    }

    return result;
}

function isValidMacAddress(address) {
    var c = '';
    var i = 0, j = 0;
    var  OddVals = new Array( "1", "3", "5", "7", "9", "b","d","f");
    
    if ( address == '00:00:00:00:00:00'){
        return false;
    }

    addrParts = address.split(':');
    if ( addrParts.length != 6 ){
        return false;
    }
    for (i = 0; i < 6; i++) {
        if ( addrParts[i].length != 2 ){
            return false;
        }
        
        for ( j = 0; j < addrParts[i].length; j++ ) {
            c = addrParts[i].toLowerCase().charAt(j);
            if ( (c >= '0' && c <= '9') ||(c >= 'a' && c <= 'f') ){
                continue;
            }else{
                return false;
            }
        }
    }
   
    c = addrParts[0].toLowerCase().charAt(1);
   
    for ( i = 0; i < OddVals.length; i++ ){
        if ( c == OddVals[i] ){
            return false;
        }
    }

    return true;
}


function commonInit(){
       SDK.System.GetAsyncSystemStatus(function(data){
        $(".statuswrap li").removeAttr("class");
        $("#icon-nw,#span_networkType").html(getImgNetworkType(data.NetworkType));
        var signalLen = 0;
        if(isHasNetwork(data.NetworkType)){
            signalLen = data.SignalStrength;
        }
        showImgWanSignal(signalLen);
        switch(data.ConnectionStatus){
            case G_SDK_NETWORK_CONNCTION_CONNECTED:
            case G_SDK_NETWORK_CONNCTION_DISCONNECTING:
                $("#icon-wan").addClass("enable");
                break;
        }
        if(data.WlanState == 1){
            $("#icon-wlan").addClass("enable");
        }
        if(data.UsbState == 1){
            $("#icon-usb").addClass("enable");
        }
        $iconSms = $("#icon-sms");
        switch(data.SmsState){
            case 1:
                $iconSms.addClass("full");
                break;
            case 2:
                $iconSms.addClass("new");
                break;
        }
        $(".statuswrap").css("display","block");
        if(refreshNetworkInfoFlag){
            uiPageInit();
        }
    }) 

}

var listenLogout = {
    init:function(){
        $("body").live('keyup touchend click', function(){
            reStartLogoutTimer();
        });
    }  
};
//## add by jinhui.lu 2014.08.11
var TIMER_HEART_BEAT = null;

function startHeartBeat(){
    if(TIMER_HEART_BEAT != null){
        clearInterval(TIMER_HEART_BEAT);
        TIMER_HEART_BEAT = null;
    }
    SDK.User.UpdateLoginTime();
    TIMER_HEART_BEAT = setInterval(function(){
        SDK.User.UpdateLoginTime();
    },10000)
}

function getCookie(name){
    var arr,reg=new RegExp("(^| )"+name+"=([^;]*)(;|$)");
    if(arr=document.cookie.match(reg)){
        return unescape(arr[2]);
    }else{
       return null; 
    }      
} 

//##UI auto logout## add by jinhui.lu 2014.07.16 
var TIMER_LOGOUT = null;
function reStartLogoutTimer(){
    if(TIMER_LOGOUT != null){
        clearTimeout(TIMER_LOGOUT);
        TIMER_LOGOUT = null;
    }
    TIMER_LOGOUT = setTimeout(function(){
        SDK.User.Logout();
        location.href="/";
    },360000)
}

var IsLoginPage = false;
$(function($){
    if(!IsLoginPage){
        startHeartBeat();
        reStartLogoutTimer();
        listenLogout.init();
        indexPage.initNav();	
        IntervalFn.poll(function(){
            commonInit();
        }) 
    }
})
