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

typedef struct _fe_multi_http_fetch_context {
    
    char *url;
    
    char *cache_file_path;
    
    char *download_file_path;
    
    int status;

    int fd;
    
    long http_respond;
    
    int usecache;
    
    long timeout;

    void *udata;
    
    void *privatedata;
    
    

    double speed_download;
    double content_length_download;
    double content_size_download;

    double content_per_download;
    
    
}fe_multi_http_fetch_context;

int fe_start_fetch_http_task (fe_multi_http_fetch_context *ctx);

fe_multi_http_fetch_context *fe_multi_http_fetch_ctx(const char *url, int usecache, long timeout);

void fe_multi_http_fetch_release(fe_multi_http_fetch_context *ctx);

void fe_multi_http_fetch_init_once();

int fe_http_cache_status(fe_multi_http_fetch_context *ctx);

#endif /* fe_multi_http_fetch_c */
