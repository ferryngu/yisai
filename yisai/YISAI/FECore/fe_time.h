//
//  FETime.h
//  FECore
//
//  Created by apps on 14-4-27.
//  Copyright (c) 2014年 apps. All rights reserved.
//

#ifndef FECore_FETime_h
#define FECore_FETime_h

uint64_t fe_timestamp_sec();

/*微秒*/
uint64_t fe_timestamp_usec();

/*
 列子，休眠 100 毫秒
 fe_nanosleep(0, 100*1000000l);
 */
void fe_sleep(long sec, long nanosec);


#endif


/*

 0.000 001 微秒 = 1皮秒
 0.001 微秒 = 1纳秒
 1,000 微秒 = 1毫秒
 1,000,000 微秒 = 1秒
 1s = 1000ms
 1ms = 1000μs
 1μs = 1000ns
 1ns = 1000ps
 1秒(s) = 1000 毫秒(ms) = 1,000,000 微秒(μs) = 1,000,000,000 纳秒(ns) = 1,000,000,000,000 皮秒(ps)
*/