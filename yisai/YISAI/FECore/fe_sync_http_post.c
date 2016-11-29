//
//  fe_sync_http_post.c
//  FECoreHttp
//
//  Created by apps on 15/5/3.
//  Copyright (c) 2015年 apps. All rights reserved.
//
#include <string.h>
#include <stdlib.h>
#include <unistd.h>

#include "fe_file.h"

#include "fe_sync_http_post.h"

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


fe_sync_http_post_context *fe_http_post_context_init(const char *url, size_t buffer_size, size_t timeout) {
    
    fe_sync_http_post_context *ctx = (fe_sync_http_post_context *)malloc(sizeof(fe_sync_http_post_context));
    
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
void fe_http_set_post_param(fe_sync_http_post_context *ctx,const char *key,const char *value) {
    
    ctx->params[ctx->param_idx].type = FE_HTTP_POSTPARAM;

    ctx->params[ctx->param_idx].key = strdup(key);
    ctx->params[ctx->param_idx].value = strdup(value);
    
    ctx->param_idx++;

}

void fe_http_post_context_release(fe_sync_http_post_context *ctx) {
    
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


#if 0
/* 返回值 0  没有数据了, >0 返回的数据的长度 */
static size_t http_post_data_callback(void *ptr, size_t size, size_t nmemb, void *ctx);
static size_t http_post_data_callback(void *ptr, size_t size, size_t nmemb, void *ctx)
{
    size_t ptr_len =  size * nmemb;
    
    static int c=0;
    size_t len;
    if ( 0==c) {
//        len = snprintf(ptr, ptr_len, "######## ******** ########");
        c=1;
        return len;
    }else{
        return 0;
    }
}


static int http_progress_callback(void *clientp, double dltotal,double dlnow,double ultotal,double ulnow) {

    return 0;
}
#endif


void fe_http_post_call_back(fe_sync_http_post_context *ctx);

/* 返回值 0 不要再回调了, >0 返回读取的数据长度 */
static size_t fe_http_post_curl_callback(void *ptr, size_t size,size_t nmemb, void*clientp) {

    size_t ptr_len = size * nmemb;

    fe_sync_http_post_context *ctx = (fe_sync_http_post_context *)clientp;

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
        fe_http_post_call_back(ctx);
    }

    return ptr_len;

}


int fe_http_post(fe_sync_http_post_context *ctx) {

    CURLcode curlcode;

    CURL *curl_handle;
    
    char *keys[ctx->param_idx];
    char *values[ctx->param_idx];
    
    char *post_buf;
    size_t post_buf_len = 0;
    char *p;
    
    int i;
    
    curl_handle= curl_easy_init();

    for ( i=0; i<ctx->param_idx; i++) {

        if (FE_HTTP_POSTPARAM != ctx->params[i].type) {
            continue;
        }

        keys[i]   = curl_easy_escape(curl_handle, ctx->params[i].key, 0);
        values[i] = curl_easy_escape(curl_handle, ctx->params[i].value, 0);

        post_buf_len +=strlen(keys[i]);
        post_buf_len +=strlen(values[i]);

    }

    post_buf_len += i*3;
    post_buf = (char *)malloc(post_buf_len);

    p = post_buf;

    size_t tmp_len;

    for (i=0; i<ctx->param_idx; i++) {

        if (0==i) {
            tmp_len= snprintf(p, post_buf_len, "%s=%s", keys[i], values[i]);
        } else {
            tmp_len= snprintf(p, post_buf_len, "&%s=%s", keys[i], values[i]);
        }
        
        free(keys[i]);
        free(values[i]);
        
        p+=tmp_len;
        post_buf_len-=tmp_len;
    }

    curl_easy_setopt(curl_handle, CURLOPT_POSTFIELDS, post_buf);

    struct curl_slist *headerlist=NULL;
    
    curl_easy_setopt(curl_handle, CURLOPT_URL, ctx->url);
    curl_easy_setopt(curl_handle, CURLOPT_POST, 1);

#if 0
    curl_easy_setopt(curl_handle, CURLOPT_READDATA, ctx);
    curlcode = curl_easy_setopt(curl_handle, CURLOPT_READFUNCTION, http_post_data_callback);
#endif

/*
    curl_easy_setopt(curl_handle, CURLOPT_NOPROGRESS, 1l);
    curl_easy_setopt(curl_handle, CURLOPT_PROGRESSDATA, ctx);
    curl_easy_setopt(curl_handle, CURLOPT_PROGRESSFUNCTION, http_progress_callback);
*/

    curl_easy_setopt(curl_handle, CURLOPT_WRITEFUNCTION, fe_http_post_curl_callback);
    curl_easy_setopt(curl_handle, CURLOPT_WRITEDATA, ctx );

//    curl_easy_setopt(curl_handle, CURLOPT_HEADER, 1);
    curl_easy_setopt(curl_handle, CURLOPT_FOLLOWLOCATION, 1);

    curl_easy_setopt(curl_handle, CURLOPT_TIMEOUT_MS, ctx->timeout);

    
    //如果不这样设置，客户端要询问http server是否接收数据，会有兼容问题
    headerlist = curl_slist_append(headerlist, "Expect:");
    curl_easy_setopt(curl_handle, CURLOPT_HTTPHEADER, headerlist);

    curl_easy_setopt(curl_handle, CURLOPT_USERAGENT, FE_HTTP_USERAGENT);

    curl_easy_setopt(curl_handle, CURLOPT_NOSIGNAL, 1);

    if ( NULL!=ctx->cookiefile) {
        curl_easy_setopt(curl_handle, CURLOPT_COOKIEFILE, ctx->cookiefile );
        curl_easy_setopt(curl_handle, CURLOPT_COOKIEJAR,  ctx->cookiefile );
    }

    //curl_easy_setopt(curl_handle, CURLOPT_VERBOSE, 1);
    
    curlcode = curl_easy_perform(curl_handle);

    if ( CURLE_OK == curlcode && ctx->content_lenght>0 ) {
        *( (char *)(ctx->buffer + ctx->content_lenght)) = '\0';
    } else {
        ctx->content_lenght = 0;
    }

    //printf("ctx->content_lenght[%ld] ctx->buffer[%s]\n",ctx->content_lenght,ctx->buffer);
    
    free(post_buf);

    curl_easy_cleanup(curl_handle);

    return 0;

}



/*

int fe_http_upload(fe_sync_http_post_context *ctx) {
    
    CURL *curl_handle;
    CURLcode curlcode;
    
    struct curl_httppost* post = NULL;
    struct curl_httppost* last = NULL;
    
    struct curl_slist *headerlist=NULL;
    
    //如果不这样设置，客户端要询问http server是否接收数据，会有兼容问题
    headerlist = curl_slist_append(headerlist, "Expect:");
    
    curl_handle = curl_easy_init();
    
    if ( !curl_handle ) {
        return -1;
    }
    
    
    //curl_easy_setopt(curl_handle, CURLOPT_READDATA, ctx);
    //curlcode = curl_easy_setopt(curl_handle, CURLOPT_READFUNCTION, http_upload_data_callback);

    
    curl_easy_setopt(curl_handle, CURLOPT_NOPROGRESS, 1l);
    curl_easy_setopt(curl_handle, CURLOPT_PROGRESSDATA, ctx);
    curl_easy_setopt(curl_handle, CURLOPT_PROGRESSFUNCTION, http_progress_callback);
    
    curl_easy_setopt(curl_handle, CURLOPT_WRITEFUNCTION, http_read_body_callback);
    curl_easy_setopt(curl_handle, CURLOPT_WRITEDATA, ctx);
    
    curl_easy_setopt(curl_handle, CURLOPT_URL, ctx->url);
    
    curl_easy_setopt(curl_handle, CURLOPT_TIMEOUT_MS, 30000);
    
    if ( NULL!=ctx->cookiefile) {
     curl_easy_setopt(curl_handle, CURLOPT_COOKIEFILE, ctx->cookiefile );
     curl_easy_setopt(curl_handle, CURLOPT_COOKIEJAR,  ctx->cookiefile );
    }
    
    curl_easy_setopt(curl_handle, CURLOPT_HTTPHEADER, headerlist);
    
    for (int i=0; i<ctx->param_idx; i++) {
        
        switch ( ctx->params[i].type ) {
                
            case FE_HTTP_POSTPARAM:
                
                curl_formadd(&post, &last,
                             CURLFORM_COPYNAME, ctx->params[i].key,
                             CURLFORM_COPYCONTENTS, ctx->params[i].value,
                             CURLFORM_END);
                
                break;
                
            case FE_HTTP_UPLOADFILEPATH:
                
                curl_formadd(&post, &last,
                             CURLFORM_COPYNAME,   ctx->params[i].key,
                             CURLFORM_FILE,       ctx->params[i].value,
                             //CURLFORM_FILENAME,  "自定义的名字,不设置就用原始的",
                             CURLFORM_END);
                break;
                
            case FE_HTTP_UPLOADFILEBUFFER:
                
                curl_formadd(&post, &last,
                             CURLFORM_COPYNAME,     ctx->params[i].key,
                             CURLFORM_BUFFER,       ctx->params[i].value,
                             CURLFORM_BUFFERPTR,    ctx->params[i].udata,
                             CURLFORM_BUFFERLENGTH, ctx->params[i].udata_len,
                             CURLFORM_END);
                
                break;
                
            case FE_HTTP_UPLOADBINDATA:
                
                curl_formadd(&post, &last,
                             CURLFORM_COPYNAME,       ctx->params[i].key,
                             CURLFORM_PTRCONTENTS,    ctx->params[i].udata,
                             CURLFORM_CONTENTSLENGTH, ctx->params[i].udata_len,
                             CURLFORM_CONTENTTYPE,    "binary",
                             CURLFORM_END);
                
                break;
                
            case FE_HTTP_UPLOADCALLBACKDATA:
#if 0
                int ictx=0;
                ret = curl_formadd(&post, &last,
                                   CURLFORM_COPYNAME, ctx->params[i].key,
                                   CURLFORM_CONTENTTYPE,    "binary",
                                   CURLFORM_FILENAME,       "foo.zip",
                                   CURLFORM_STREAM, &ictx,  //必须要有上下文
                                   CURLFORM_CONTENTSLENGTH, sizeof("########********##############")-1, //必须指定长度
                                   CURLFORM_END);
#endif
                break;
                
            default:
                break;
        }
        
    }//for
    
    curl_easy_setopt(curl_handle, CURLOPT_HTTPPOST, post);
    
    curlcode = curl_easy_perform(curl_handle);
    
    curl_formfree(post);
    
    curl_easy_cleanup(curl_handle);
    
    if ( CURLE_OK != curlcode ) {
        return -1;
    }
    
    return 0;
}
*/

