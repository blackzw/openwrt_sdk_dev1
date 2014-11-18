//==========================================================================
/**
 *  @file    timerbase.h
 *  @brief  The header file of TimerBase.
 *  @version 1.0
 *  @author Tian Yiqing <yiqing.tian@tcl.com>
 *  @date 2013-10-15
 */
//==========================================================================
#ifndef TIMERBASE_H
#define TIMERBASE_H

#include <time.h>
#include <signal.h>
#include "threadbase.h"

class TimerBase : public ThreadBase
{
public:
    TimerBase();
    virtual ~TimerBase();

public:
    bool init_timer();
    bool start_timer(int interval);
    bool stop_timer();
    void destroy_timer();

protected:
    virtual void timer_main() = 0;
    virtual void run();

private:
    int m_timerfd;

};

#endif // TIMERBASE_H
