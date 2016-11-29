//
//  FETime.c
//  FECore
//
//  Created by apps on 14-4-27.
//  Copyright (c) 2014年 apps. All rights reserved.
//

#include <stdio.h>
#include <sys/time.h>

#include "fe_time.h"

/*秒*/
uint64_t fe_timestamp_sec()
{
    int ret;
    struct timeval cur_time;
    uint64_t u64;
    ret = gettimeofday(&cur_time,NULL);
    if (0!=ret) {
        return 0;
    }

    u64 = (uint64_t)cur_time.tv_sec;

    return u64;

}


uint64_t fe_timestamp_usec()
{
    int ret;
    struct timeval cur_time;
    uint64_t u64;
    ret = gettimeofday(&cur_time,NULL);
    if (0!=ret) {
        return 0;
    }
    u64 = (uint64_t)cur_time.tv_sec*1000000 + cur_time.tv_usec;
    return u64;
}



void fe_sleep(long sec, long nanosec) {
    
    struct timespec sleep_time;
    sleep_time.tv_sec  = sec;
    sleep_time.tv_nsec = nanosec;
    nanosleep(&sleep_time, NULL);

}

