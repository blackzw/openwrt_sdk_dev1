//==========================================================================
/**
 *  @file    threadbase.h
 *  @brief  The header file of ThreadBase class.
 *  @version 1.0
 *  @author Tian Yiqing <yiqing.tian@tcl.com>
 *  @date 2013-10-15
 */
//==========================================================================

#ifndef THREADBASE_H
#define THREADBASE_H

#include <unistd.h>
#include <pthread.h>

class ThreadBase
{
public:
    ThreadBase();
    virtual int init();
    virtual int start();
    virtual void stop();

    friend void *Thread_Func(void *p);

public:
    virtual ~ThreadBase();

protected:
    virtual void run() = 0;

protected:
    bool m_is_started;
    pthread_t m_tid;
};

#endif // THREADBASE_H
