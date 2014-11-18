//==========================================================================
/**
 *  @file    threadmutex.h
 *  @brief  The header file of CThreadMutex, CThreadGuard class.
 *  @version 1.0
 *  @author Tian Yiqing <yiqing.tian@tcl.com>
 *  @date 2013-10-15
 */
//==========================================================================
#ifndef THREADMUTEX_H_
#define THREADMUTEX_H_

#include <assert.h>
#include <pthread.h>
class CThreadMutex 
{
public:
    
    CThreadMutex();
    ~CThreadMutex();
    void lock ();
    int trylock ();
    void unlock();

protected:
    pthread_mutex_t m_mutex_handler;
};


class CThreadGuard
{
public:
    CThreadGuard(CThreadMutex *mutex);
    ~CThreadGuard();
private:
    CThreadMutex *m_mutex;
};


#endif /*THREADMUTEX_H_*/
