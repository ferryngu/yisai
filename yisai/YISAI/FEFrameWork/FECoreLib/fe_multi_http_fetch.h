//
//  fe_multi_http_fetch.h
//  FECoreHttp
//
//  Created by apps on 15/7/25.
//  Copyright © 2015年 apps. All rights reserved.
//

#ifndef fe_multi_http_fetch_c
#define fe_multi_http_fetch_c

#include <stdio.h>

#include "fe_http.h"



struct _fe_multi_http_fetch_context;

typedef void(*fe_multi_http_fetch_progress_call_back_t)(struct _fe_multi_http_fetch_context *ctx);

typedef void(*fe_multi_http_fetch_finish_call_back_t)(struct _fe_multi_http_fetch_context *ctx);

typedef struct _fe_multi_http_fetch_context {
    
    char *url;
    
    char *cache_file_path;
    
    char *download_file_path;

    int http_status;

    long http_respond;
    int  http_error;

    int fd;
    
    int usecache;
    
    long timeout;

    void *udata;
    
    void *privatedata;

    fe_multi_http_fetch_progress_call_back_t http_fetch_progress_call_back;
    fe_multi_http_fetch_finish_call_back_t http_fetch_finish_call_back;

    int interrupt_flag;
    int resume_flag;
    
    double speed_download;
    
    double content_length_download;
    
    double content_size_download;

    double content_per_download;

}fe_multi_http_fetch_context;

#define FE_MULTI_HTTP_ADD_TASK_SUCCESS            0
#define FE_MULTI_HTTP_ADD_TASK_IN_QUEUE           1


#define FE_MULTI_HTTP_ADD_TASK_FALSE_QUEUE_FULL   101
#define FE_MULTI_HTTP_TASK_FALSE_URL_IN_QUEUE     102
#define FE_MULTI_HTTP_TASK_FALSE_FILE_ERR         103
#define FE_MULTI_HTTP_TASK_FALSE_INTERNAL_ERR     104

int fe_start_fetch_http_task (fe_multi_http_fetch_context *ctx);

fe_multi_http_fetch_context *fe_multi_http_fetch_ctx(const char *url, int usecache, long timeout);

void fe_multi_http_fetch_release(fe_multi_http_fetch_context *ctx);

void fe_multi_http_fetch_init_once();

int fe_interrupt_fetch_http_task(const char *url);



#define FE_HTTP_CACHE_EMPTY      0
#define FE_HTTP_CACHE_HIT        1
#define FE_HTTP_CACHE_FETCHING   2
#define FE_HTTP_CACHE_ZERO_FILE  3

int fe_http_cache_status(fe_multi_http_fetch_context *ctx);

#endif /* fe_multi_http_fetch_c */
