//==========================================================================
/**
 *  @file    threadcond.h
 *  @brief  The header file of CThreadCond class.
 *  @version 1.0
 *  @author Tian Yiqing <yiqing.tian@tcl.com>
 *  @date 2013-10-15
 */
//==========================================================================


#ifndef THREADCOND_H_
#define THREADCOND_H_

#include "threadmutex.h"
#include <pthread.h>
#include <sys/time.h>
#include <stdint.h>
class CThreadCond : public CThreadMutex 
{

public:
    
    CThreadCond();
    ~CThreadCond();
    int wait(int milliseconds = 0);
    void signal();
    void broadcast();

private:
    pthread_cond_t _cond;
};


#endif /*THREADCOND_H_*/
