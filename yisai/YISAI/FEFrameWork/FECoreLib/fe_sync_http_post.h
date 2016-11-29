//
//  fe_sync_http_post.h
//  FECoreHttp
//
//  Created by apps on 15/5/3.
//  Copyright (c) 2015年 apps. All rights reserved.
//

#ifndef __FECoreHttp__fe_sync_http_post__
#define __FECoreHttp__fe_sync_http_post__


#include "fe_http.h"




typedef struct _fe_sync_http_post_context {
    
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

}fe_sync_http_post_context;


fe_sync_http_post_context *fe_http_post_context_init(const char *url, size_t buffer_size, size_t timeout);

void fe_http_set_post_param(fe_sync_http_post_context *ctx,const char *key,const char *value);

int fe_http_post(fe_sync_http_post_context *ctx);

void fe_http_post_context_release(fe_sync_http_post_context *ctx);


//void fe_http_param_release(fe_http_param *http_params, size_t num);
//fe_http_param* fe_http_param_init(size_t num);
//void fe_http_param_upload(fe_http_param *http_params,int idx,int type,const char *key,const char *value,void *udata,size_t udata_len);
//fe_http_param* fe_http_param_new(int type,const char *key,const char *value,void *udata,size_t udata_len);


#endif /* defined(__FECoreHttp__fe_sync_http_post__) */
