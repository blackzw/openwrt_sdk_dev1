//==========================================================================
/**
 *  @file    common.h
 *  @brief  The common header file for rild service.
 *  @version 1.0
 *  @author Tian Yiqing <yiqing.tian@tcl.com>
 *  @date 2013-10-15
 */
//==========================================================================

#ifndef COMMON_H
#define COMMON_H

#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <iostream>
#include <list>
#include <vector>
#include <string>
#include <unistd.h>
#include <fcntl.h>
#include <string.h>
#include <errno.h>
#include <sys/select.h>
#include "socket.h"
#include "utility.h"
#include "smartptr.h"
#include "rild_api.h"
using namespace std;

typedef int (*MSG_CB_FUNC)(const MessageLite *req, MessageLite * &res);

#define MAX_MESSAGE_STRUCT_NAME_LEN 64
#define RIL_SERVER_PATH "/tmp/ril_service"
#define USAGE_HISTORY_OVERFLOW_PATH "/tmp/usage_history_overflow"
#define RILD_UNUSED(x) (void)x;
#define READ_BUFFER_SIZE 4096
#define WRITE_BUFFER_SIZE 4096
enum
{
    INNER_ERROR_SUCCESS,
    INNER_ERROR_FAILED,
    INNER_ERROR_REMOVE_SOCKET,
    INNER_ERROR_NO_SPECIAL_MESSAGE
};

struct MessageHeader
{
    int length;
    int message_id;
    int message_priority;
    int error_code;
    char message_struct_name[MAX_MESSAGE_STRUCT_NAME_LEN];
};

struct MessageContent
{
    MessageHeader message_header;
    MessageLite *message_body;
};

struct UnsolicitedReportMessage
{
public:
    int message_id;
    string report_buffer;
};

struct PeriodMessage
{
public:
    int message_id;
    int interval;
    int remained_interval;
    bool is_persist;
};

struct RequestMessage
{
public:
    RequestMessage(SmartPtr<LocalSocket>& sockPtr)
        : sock_ptr(sockPtr)
    {
        message_content.message_body = NULL;
    }

    ~RequestMessage()
    {
        delete message_content.message_body;
    }

public:
    SmartPtr<LocalSocket> sock_ptr;
    MessageContent message_content;
};


struct ResponseMessage
{
public:
    ResponseMessage(SmartPtr<LocalSocket>& sockPtr)
        : sock_ptr(sockPtr)
    {
        message_content.message_body = NULL;
    }

    ~ResponseMessage()
    {
        delete message_content.message_body;
    }

public:
    SmartPtr<LocalSocket> sock_ptr;
    bool is_broadcast;
    MessageContent message_content;
};



#endif // COMMON_H
