//==========================================================================
/**
 *  @file    socket.h
 *  @brief  The header file of LocalSocket class.
 *  @version 1.0
 *  @author Tian Yiqing <yiqing.tian@tcl.com>
 *  @date 2013-10-15
 */
//==========================================================================


#ifndef SOCKET_H_
#define SOCKET_H_
#include <string>
#include <sys/un.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <sys/ioctl.h>
#include "threadmutex.h"
#include "smartptr.h"
#include <errno.h>

class LocalSocket
{

public:
    
    LocalSocket();
    ~LocalSocket();
    bool setAddress (const char *address);
    bool connect();
    void close();   
    void shutdown();   
    bool createUDP(); 
    void setUp(int socketHandle);    
    int getSocketHandle();    
    int write(const void *data, int len);
    int read(void *data, int len);
    bool setTimeOption(int option, int milliseconds);    
    bool setSoBlocking(bool on);    
    bool checkSocketHandle();

    inline bool is_persistent()
    {
        return m_persistent_connection;
    }

    inline void set_persistent(bool persistent)
    {
        m_persistent_connection = persistent;
    }

    static int getLastError()
    {
        return errno;
    }

    friend class SmartPtr<LocalSocket>;

protected:
    struct sockaddr_un  m_address;
    int m_socket_handle;

private:
    int add_reference();
    int release_reference();

private:
    int m_ref_count;
    bool m_persistent_connection;
    CThreadMutex m_mutex;
};


#endif /*SOCKET_H_*/
