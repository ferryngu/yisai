//
//  fe_sync_http_get.h
//  FECoreHttp
//
//  Created by apps on 15/5/5.
//  Copyright (c) 2015年 apps. All rights reserved.
//

#ifndef __FECoreHttp__fe_sync_http_get__
#define __FECoreHttp__fe_sync_http_get__

#include "fe_http.h"

typedef struct _fe_http_body {

    void *body;
    
    size_t size;
    
    size_t in_len;
    
    int status;
    
}fe_http_body;


typedef struct _fe_sync_http_get_context {
    
    char *url;
    
    fe_http_param params[FE_HTTP_MAX_PARAM_SIZE];
    
    size_t param_idx;
    
    int http_status;
    
    long http_respond;
    
    int  http_error;
    
    char *cookiefile;
    
    long timeout;
    
    void *udata;
    
    void *buffer;
    
    size_t buffer_size;
    
    void *buffer_tail;
    
    size_t content_lenght;
    
}fe_sync_http_get_context;





fe_sync_http_get_context *fe_http_get_context_init(const char *url, size_t buffer_size, size_t timeout);

void fe_http_set_get_param(fe_sync_http_get_context *ctx,const char *key,const char *value);

int fe_http_get(fe_sync_http_get_context *ctx);

void fe_http_get_context_release(fe_sync_http_get_context *ctx);


//int fe_sync_http_get(const char *url, void *buf, size_t *buf_len, size_t timeout);

#endif /* defined(__FECoreHttp__fe_sync_http_get__) */
