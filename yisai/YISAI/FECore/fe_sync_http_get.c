//
//  fe_sync_http_get.c
//  FECoreHttp
//
//  Created by apps on 15/5/5.
//  Copyright (c) 2015年 apps. All rights reserved.
//

#include <string.h>
#include <stdlib.h>

#include "fe_file.h"

#include "fe_sync_http_get.h"

#include <TargetConditionals.h>

#if TARGET_CPU_X86

#include "i386/curl.h"

#elif TARGET_CPU_X86_64

#include "x86_64/curl.h"

#elif TARGET_CPU_ARM

#include "armv7s/curl.h"

#elif TARGET_CPU_ARM64

#include "arm64/curl.h"

#endif



fe_sync_http_get_context *fe_http_get_context_init(const char *url, size_t buffer_size, size_t timeout) {
    
    fe_sync_http_get_context *ctx = (fe_sync_http_get_context *)malloc(sizeof(fe_sync_http_get_context));
    
    ctx->url = (char *)malloc(FE_HTTP_MAX_URL_LENGHT);
    
    snprintf(ctx->url, FE_HTTP_MAX_URL_LENGHT, "%s",url);
    
    ctx->buffer = malloc(buffer_size);
    ctx->buffer_size = buffer_size;
    ctx->buffer_tail = ctx->buffer;
    ctx->content_lenght = 0;
    
    ctx->status = FE_HTTP_STATUS_INIT;
    
    ctx->timeout=timeout;
    
    ctx->cookiefile = (char *)malloc(PATH_MAX);
    
    snprintf(ctx->cookiefile, PATH_MAX, "%scurl.cookie",FE_TEMP_PATH);
    
    ctx->param_idx = 0;
    
    int i;

    for (i=0; i<FE_HTTP_MAX_PARAM_SIZE; i++) {
        ctx->params[i].key = NULL;
        ctx->params[i].value = NULL;
        ctx->params[i].udata = NULL;
        ctx->params[i].udata_len = 0;
    }
    
    ctx->udata = NULL;
    
    return ctx;
    
}

void fe_http_set_get_param(fe_sync_http_get_context *ctx,const char *key,const char *value) {
    
    ctx->params[ctx->param_idx].type = FE_HTTP_GETPARAM;
    
    ctx->params[ctx->param_idx].key = strdup(key);
    ctx->params[ctx->param_idx].value = strdup(value);
    
    ctx->param_idx++;
    
}

void fe_http_get_context_release(fe_sync_http_get_context *ctx) {
    
    free(ctx->buffer);
    free(ctx->url);
    free(ctx->cookiefile);
    
    int i;
    
    for (i=0; i<FE_HTTP_MAX_PARAM_SIZE; i++) {
        
        if (NULL!=ctx->params[i].key) {
            free(ctx->params[i].key);
        }
        
        if (NULL!=ctx->params[i].value) {
            free(ctx->params[i].value);
        }
        
        if (NULL!=ctx->params[i].udata) {
            free(ctx->params[i].udata);
        }
        
    }
}

/*
static int http_progress_callback(void *clientp, double dltotal,double dlnow,double ultotal,double ulnow) {
    
    return 0;
}
*/


void fe_http_get_call_back(fe_sync_http_get_context *ctx);

/* 返回值 0 不要再回调了, >0 返回读取的数据长度 */
static size_t fe_http_get_curl_callback(void *ptr, size_t size,size_t nmemb, void*ctx);

static size_t fe_http_get_curl_callback(void *ptr, size_t size,size_t nmemb, void*clientp) {
    
    size_t ptr_len = size * nmemb;
    
    fe_sync_http_get_context *ctx = (fe_sync_http_get_context *)clientp;

    if ( FE_HTTP_STATUS_CANCEL & ctx->status ) {
        return 0;
    }
    
    if ( (ctx->content_lenght + ptr_len) >= ctx->buffer_size ) {
        return 0;
    }
    
    memcpy(ctx->buffer_tail, ptr, ptr_len);
    
    ctx->buffer_tail+=ptr_len;
    ctx->content_lenght += ptr_len;
    
    if ( NULL != ctx->udata ) {
        fe_http_get_call_back(ctx);
    }
    
    return ptr_len;
    
}


int fe_http_get(fe_sync_http_get_context *ctx) {
    
    CURLcode curlcode;
    
    CURL *curl_handle;
    
    char *keys[ctx->param_idx];
    char *values[ctx->param_idx];
    
    char *get_buf;
    size_t get_buf_len = 0;
    char *p;
    
    int i;
    
    curl_handle= curl_easy_init();
    
    for ( i=0; i<ctx->param_idx; i++) {

        if (FE_HTTP_GETPARAM != ctx->params[i].type) {
            continue;
        }
        
        keys[i]   = curl_easy_escape(curl_handle, ctx->params[i].key, 0);
        values[i] = curl_easy_escape(curl_handle, ctx->params[i].value, 0);
        
        get_buf_len +=strlen(keys[i]);
        get_buf_len +=strlen(values[i]);
        
    }
    
    get_buf_len += i*3;
    get_buf = (char *)malloc(get_buf_len);
    
    p = get_buf;
    
    size_t tmp_len;
    
    for (i=0; i<ctx->param_idx; i++) {
        
        if (0==i) {
            tmp_len= snprintf(p, get_buf_len, "%s=%s", keys[i], values[i]);
        } else {
            tmp_len= snprintf(p, get_buf_len, "&%s=%s", keys[i], values[i]);
        }
        
        free(keys[i]);
        free(values[i]);
        
        p+=tmp_len;
        get_buf_len-=tmp_len;
    }

    char *url = (char *)malloc(fe_http_max_url_lenght);

    if ( ctx->param_idx > 0 ) {
        snprintf(url,fe_http_max_url_lenght, "%s?%s",ctx->url,get_buf);
    } else {
        snprintf(url,fe_http_max_url_lenght, "%s",ctx->url);
    }
    
    curl_easy_setopt(curl_handle, CURLOPT_URL, url);
/*
    curl_easy_setopt(curl_handle, CURLOPT_NOPROGRESS, 1l);
    curl_easy_setopt(curl_handle, CURLOPT_PROGRESSDATA, ctx);
    curl_easy_setopt(curl_handle, CURLOPT_PROGRESSFUNCTION, http_progress_callback);
*/
    curl_easy_setopt(curl_handle, CURLOPT_WRITEFUNCTION, fe_http_get_curl_callback);
    curl_easy_setopt(curl_handle, CURLOPT_WRITEDATA, ctx );
    
//    curl_easy_setopt(curl_handle, CURLOPT_HEADER, 1);
    curl_easy_setopt(curl_handle, CURLOPT_FOLLOWLOCATION, 1);
    
    curl_easy_setopt(curl_handle, CURLOPT_TIMEOUT_MS, ctx->timeout);

    
    curl_easy_setopt(curl_handle, CURLOPT_USERAGENT, FE_HTTP_USERAGENT);
    
    curl_easy_setopt(curl_handle, CURLOPT_NOSIGNAL, 1);
    
    if ( NULL!=ctx->cookiefile) {
        curl_easy_setopt(curl_handle, CURLOPT_COOKIEFILE, ctx->cookiefile );
        curl_easy_setopt(curl_handle, CURLOPT_COOKIEJAR,  ctx->cookiefile );
    }

    curlcode = curl_easy_perform(curl_handle);

    if ( CURLE_OK == curlcode && ctx->content_lenght>0 ) {
        *( (char *)(ctx->buffer + ctx->content_lenght)) = '\0';
    } else {
        ctx->content_lenght = 0;
    }

    free(url);
    free(get_buf);
    
    curl_easy_cleanup(curl_handle);
    
    return 0;
    
}



