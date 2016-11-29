//
//  fe_multi_http_fetch.c
//  FECoreHttp
//
//  Created by apps on 15/7/25.
//  Copyright © 2015年 apps. All rights reserved.
//

#include <string.h>

#include <stdlib.h>
#include <unistd.h>
#include <pthread.h>

#include <sys/select.h>

#include <sys/errno.h>

#include <signal.h>

#include "fe_file.h"

#include "fe_time.h"

#include "fe_multi_http_fetch.h"

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


CURLM *fe_multi_http_fetch_handle;

static pthread_t thread_fetch;

static int fe_multi_http_fetch_cancel_flag;

static void* fe_multi_http_fetch_func(void *data);
static void fe_curl_fetch_loop();
static ssize_t fe_http_fetch_curl_callback(void *ptr, size_t size, size_t nmemb, void *context);

static pthread_mutex_t fe_http_task_mutex;

fe_multi_http_fetch_context *fe_multi_http_fetch_task[FE_MAX_MULTI_TASK];

void  fe_multi_http_fetch_process_swift_cb(fe_multi_http_fetch_context *ctx);
void fe_multi_http_fetch_finish_swift_cb(fe_multi_http_fetch_context *ctx);


void fe_multi_http_fetch_init_once() {

    fe_multi_http_fetch_handle = curl_multi_init();

    int i;
    
    for (i=0; i<FE_MAX_MULTI_TASK; i++) {
        fe_multi_http_fetch_task[i] = NULL;
    }

    pthread_mutex_init( &fe_http_task_mutex, NULL );

    struct sigaction sig_alrm_action;
    
    sigemptyset(&sig_alrm_action.sa_mask);
    
    sig_alrm_action.sa_flags = SA_RESTART;
    
    sig_alrm_action.sa_handler = SIG_IGN;
    
    //sig_alrm_action.sa_handler = sig_alrm_hand;
    
    sigaction(SIGALRM, &sig_alrm_action, NULL);
}


static fe_multi_http_fetch_context *pop_ctx(CURL *curl_handle);

static fe_multi_http_fetch_context *pop_ctx(CURL *curl_handle){

    int i;

    fe_multi_http_fetch_context *ctx;
    
    CURL *curl_in_ctx;

    pthread_mutex_lock( &fe_http_task_mutex );

    for (i=0; i<FE_MAX_MULTI_TASK; i++) {

        ctx = fe_multi_http_fetch_task[i];

        if ( NULL == ctx ) {
            continue;
        }

        curl_in_ctx = (CURL *)ctx->privatedata;

        if ( NULL==curl_in_ctx ) {
            fe_multi_http_fetch_task[i] = NULL;
            continue;
        }
        
        if ( curl_in_ctx != curl_handle) {
            continue;
        }

        fe_multi_http_fetch_task[i] = NULL;

        pthread_mutex_unlock( &fe_http_task_mutex );

        return ctx;

    }
    
    pthread_mutex_unlock( &fe_http_task_mutex );
    return NULL;

}


static int push_ctx(fe_multi_http_fetch_context *ctx);

static int push_ctx(fe_multi_http_fetch_context *ctx){

    int i;

    pthread_mutex_lock( &fe_http_task_mutex );

    for (i=0; i<FE_MAX_MULTI_TASK; i++) {

        if ( NULL != fe_multi_http_fetch_task[i] ) {

            if ( 0 == strncasecmp(fe_multi_http_fetch_task[i]->url, ctx->url, FE_HTTP_MAX_URL_LENGHT) ) {
                pthread_mutex_unlock( &fe_http_task_mutex );
                return 2;
            }

        }
                
    }

    for (i=0; i<FE_MAX_MULTI_TASK; i++) {

        if ( NULL == fe_multi_http_fetch_task[i] ) {
            fe_multi_http_fetch_task[i] = ctx;
            pthread_mutex_unlock( &fe_http_task_mutex );
            return 0;
        }

    }

    pthread_mutex_unlock( &fe_http_task_mutex );
    return 1;

}



static int fe_http_fetch_curl_progress_callback(void *context, double dltotal,double dlnow,double ultotal,double ulnow)
{
    CURLcode curlcode;
    
    fe_multi_http_fetch_context *ctx = (fe_multi_http_fetch_context *)context;


    if ( dlnow>0 && dltotal > 0  ) {
        ctx->content_per_download = 100*(dlnow/dltotal);
    }

    CURL *curl_handle = (CURL *)ctx->privatedata;
    
    curlcode = curl_easy_getinfo(curl_handle, CURLINFO_SPEED_DOWNLOAD , &ctx->speed_download);
    if ( CURLE_OK != curlcode ) {
        ctx->speed_download = 0.0f;
    }

#if 0
    curlcode = curl_easy_getinfo(curl_handle, CURLINFO_CONTENT_LENGTH_DOWNLOAD , &ctx->content_length_download);

    if ( CURLE_OK != curlcode ) {
        ctx->content_length_download = 0.0f;
    }
    
    curlcode = curl_easy_getinfo(curl_handle, CURLINFO_SIZE_DOWNLOAD , &ctx->content_size_download);
    if ( CURLE_OK != curlcode ) {
        ctx->content_size_download = 0.0f;
    }
#endif

    ctx->content_size_download   = dlnow;
    ctx->content_length_download = dltotal;

    //printf("url[%s] [%.0f] [%.0f] [%.2f%%]\n", ctx->url, dlnow,dltotal, ctx->content_per_download);
    
    //printf("[%.2f%%] url[%s] speed_download[%.0f] content_size_download[%.0f] content_length_download[%.0f]\n", ctx->content_per_download, ctx->url, ctx->speed_download, ctx->content_size_download, ctx->content_length_download);

    fe_multi_http_fetch_process_swift_cb(ctx);
    
    return 0;
}

static ssize_t fe_http_fetch_curl_callback(void *ptr, size_t size, size_t nmemb, void *context)
{
    fe_multi_http_fetch_context *ctx = (fe_multi_http_fetch_context *)context;
    
    size_t in_len = size * nmemb;
    size_t wlen = size * nmemb;
    

    
    if ( ctx->status & FE_HTTP_STATUS_CANCEL ) {
        ctx->status |= FE_HTTP_STATUS_FINISH;
        return 0;
    }
    
    wlen = write(ctx->fd,ptr,in_len);

//    printf("url[%s] download_file_path[%s] cache[%s] wlen[%ld]\n", ctx->url, ctx->download_file_path, ctx->cache_file_path, wlen);
    //printf("url[%s] download_file_path[%s] wlen[%ld]\n", ctx->url, ctx->download_file_path, wlen);
    //printf("url[%s] wlen[%ld]\n", ctx->url, wlen);

    if ( wlen!=in_len ) {
        ctx->status = FE_HTTP_STATUS_ERROR | FE_HTTP_STATUS_FINISH;
        return 0;
    }
/*
    CURL *curl_handle = (CURL *)ctx->privatedata;
    
    curlcode = curl_easy_getinfo(curl_handle, CURLINFO_SPEED_DOWNLOAD , &ctx->speed_download);
    if ( CURLE_OK != curlcode ) {
        ctx->speed_download = 0.0f;
    }
    
    curlcode = curl_easy_getinfo(curl_handle, CURLINFO_CONTENT_LENGTH_DOWNLOAD , &ctx->content_length_download);
    
    if ( CURLE_OK != curlcode ) {
        ctx->content_length_download = 0.0f;
    }
    
    curlcode = curl_easy_getinfo(curl_handle, CURLINFO_SIZE_DOWNLOAD , &ctx->content_size_download);
    if ( CURLE_OK != curlcode ) {
        ctx->content_size_download = 0.0f;
    }
*/
    return in_len;
    
}


fe_multi_http_fetch_context *fe_multi_http_fetch_ctx(const char *url, int usecache, long timeout) {
    
    fe_multi_http_fetch_context *ctx = (fe_multi_http_fetch_context *)malloc(sizeof(fe_multi_http_fetch_context));
    
    ctx->url = (char *)malloc(FE_HTTP_MAX_URL_LENGHT);
    
    snprintf(ctx->url, FE_HTTP_MAX_URL_LENGHT,"%s",url);
    
    ctx->cache_file_path = (char *)malloc(PATH_MAX);
    
    ctx->download_file_path = (char *)malloc(PATH_MAX);
    
    ctx->fd = 0;
    
    ctx->status = FE_HTTP_STATUS_INIT;
    
    ctx->timeout = timeout;
    
    ctx->usecache = usecache;
    
    ctx->udata = NULL;
    ctx->privatedata = NULL;
    
    ctx->speed_download = 0.0f;
    ctx->content_length_download = 0.0f;
    ctx->content_size_download = 0.0f;
    ctx->content_per_download = 0.0f;

    fe_get_cache_file_path(url, 0, FE_HTTP_CACHE_PREFIX, ctx->cache_file_path, PATH_MAX);
    
    fe_get_temp_file_path(url, 0, FE_HTTP_CACHE_PREFIX, ctx->download_file_path, PATH_MAX);

    return ctx;
    
}


void fe_multi_http_fetch_release(fe_multi_http_fetch_context *ctx) {
    
    free(ctx->url);
    
    free(ctx->cache_file_path);
    
    free(ctx->download_file_path);
    
    free(ctx);
    
}


static int new_task_flag = 0;
int fe_add_fetch_http_task (fe_multi_http_fetch_context *ctx) {

    CURL *curl_handle;

    int ret;

    ret = push_ctx(ctx);
    
    if ( 0 != ret ) {
        return ret;
    }
    
    curl_handle = curl_easy_init();
    
    curl_easy_setopt(curl_handle, CURLOPT_URL, ctx->url);
    curl_easy_setopt(curl_handle, CURLOPT_NOSIGNAL, 1);

    curl_easy_setopt(curl_handle, CURLOPT_FOLLOWLOCATION, 1);
    
    curl_easy_setopt(curl_handle, CURLOPT_TIMEOUT_MS, ctx->timeout);

    curl_easy_setopt(curl_handle, CURLOPT_USERAGENT, FE_HTTP_USERAGENT);

    curl_easy_setopt(curl_handle, CURLOPT_NOPROGRESS, 0);
    curl_easy_setopt(curl_handle, CURLOPT_PROGRESSDATA, ctx);
    curl_easy_setopt(curl_handle, CURLOPT_PROGRESSFUNCTION, fe_http_fetch_curl_progress_callback);

    curl_easy_setopt(curl_handle, CURLOPT_WRITEDATA, ctx);
    curl_easy_setopt(curl_handle, CURLOPT_WRITEFUNCTION, fe_http_fetch_curl_callback);

    ctx->privatedata = curl_handle;
    
    CURLMcode curlmcode;

    ctx->fd = fe_create_file(ctx->download_file_path);
    
    if ( -1 == ctx->fd ) {

        ctx->status = FE_HTTP_STATUS_ERROR;
        pop_ctx(curl_handle);
        curl_easy_cleanup(curl_handle);
        return -1;
        
    }

    curlmcode = curl_multi_add_handle(fe_multi_http_fetch_handle, curl_handle);

    if ( CURLM_OK != curlmcode ) {
        
        ctx->status = FE_HTTP_STATUS_ERROR;
        pop_ctx(curl_handle);
        curl_easy_cleanup(curl_handle);
        return -1;
        
    }

    ctx->status = FE_HTTP_STATUS_PROGRESS;
    
    pthread_mutex_lock( &fe_http_task_mutex );
    new_task_flag = 1;
    pthread_mutex_unlock( &fe_http_task_mutex );
    
    pthread_kill(thread_fetch, SIGALRM);

//printf("fe_add_fetch_http_task[%s]\n",ctx->url);
    
    return  ret;

}

static void hanle_multi_info() {

    CURLMsg *curlmsg; /* for picking up messages with the transfer status */

    CURLcode curlcode;

    int msgs_left;    /* how many messages are left */
    
    char *eff_url;
    
    int ret;
    
    fe_multi_http_fetch_context  *ctx;
    
    while ( ( curlmsg = curl_multi_info_read(fe_multi_http_fetch_handle, &msgs_left) )  )
    {
        if ( curlmsg->msg != CURLMSG_DONE ) {
            continue;
        }

        CURL *easy_handle = curlmsg->easy_handle;

        ctx = pop_ctx(easy_handle);

        if ( NULL==ctx ) {
            curl_easy_cleanup(easy_handle);
            continue;
        }

        close(ctx->fd);

        curlcode = curl_easy_getinfo(easy_handle, CURLINFO_EFFECTIVE_URL, &eff_url);

        curlcode = curl_easy_getinfo(easy_handle, CURLINFO_RESPONSE_CODE, &ctx->http_respond);
        
        curlcode = curlmsg->data.result;
        
        if ( CURLE_OK == curlcode ) {
            
            if ( ctx->http_respond == 200 || ctx->http_respond == 206 ) {

//                printf("######## fe_rename download_file_path[%s] cache_file_path[%s]\n",ctx->download_file_path, ctx->cache_file_path);

                ret = fe_rename(ctx->download_file_path, ctx->cache_file_path);

                if ( 0!=ret ) {
                    unlink (ctx->download_file_path);
                }

            } else {

                ctx->status = FE_HTTP_STATUS_ERROR;
            }

        } else {
            //这里有可能是timeout,可以在分情况处理
            ctx->status = FE_HTTP_STATUS_ERROR;
            printf("Http Respont curlcode [%d]\n",curlcode);
        }
        
        curl_easy_cleanup(easy_handle);

        ctx->status |= FE_HTTP_STATUS_FINISH;
        
        if ( ctx->status & FE_HTTP_STATUS_ERROR ) {
            unlink (ctx->cache_file_path);
            unlink (ctx->download_file_path);
        }

        fe_multi_http_fetch_finish_swift_cb(ctx);

    }

}


static void fe_curl_fetch_loop() {

    int still_running = 1;

    fe_multi_http_fetch_cancel_flag = 0;
    
    CURLMcode curlmcode;
    
    struct timeval timeout;

    int n;
    
    fd_set fdread;
    fd_set fdwrite;
    fd_set fdexcep;
    int maxfd = -1;

    curlmcode = curl_multi_perform(fe_multi_http_fetch_handle, &still_running);
    int havenewtask = 0;
    while (1) {
        
        FD_ZERO(&fdread);
        FD_ZERO(&fdwrite);
        FD_ZERO(&fdexcep);

        timeout.tv_sec  = 1;
        timeout.tv_usec = 100;

        curl_multi_fdset(fe_multi_http_fetch_handle, &fdread, &fdwrite, &fdexcep, &maxfd);

        n = select(maxfd+1, &fdread, &fdwrite, &fdexcep, &timeout);

        pthread_mutex_lock( &fe_http_task_mutex );
        
        if (new_task_flag) {
            new_task_flag = 0;
            havenewtask = 1;
        }
        
        pthread_mutex_unlock( &fe_http_task_mutex );

        if ( 0 == n && 0==havenewtask) {
//printf("select..... 0\n");
            continue;
        }

        if ( -1 == n && 0==havenewtask ) {
//printf("select..... -1\n");
            continue;
        }

        curlmcode = curl_multi_perform(fe_multi_http_fetch_handle, &still_running);

//printf("curl_multi_perform still_running [%d] curlmcode[%d] .....\n", still_running, curlmcode);
        
        pthread_mutex_lock( &fe_http_task_mutex );
        havenewtask = 0;
        pthread_mutex_unlock( &fe_http_task_mutex );

        if (  CURLM_OK != curlmcode ) {
            continue;
        }

        hanle_multi_info();
   
    }
    
}


static void* fe_multi_http_fetch_func( void *data ) {

    while (1) {
        
        fe_curl_fetch_loop();
        
    }

    return NULL;
    
}

static int fetch_thread_status = 0;

int fe_start_fetch_http_task (fe_multi_http_fetch_context *ctx) {

    int ret;

    ret = fe_add_fetch_http_task(ctx);

    if ( 0 != ret ) {
        return ret;
    }
    
    pthread_mutex_lock( &fe_http_task_mutex );
    if ( 0==fetch_thread_status) {
        fetch_thread_status = 1;
        pthread_create( &thread_fetch, NULL, fe_multi_http_fetch_func, (void *)ctx );
        pthread_detach(thread_fetch);
    }
    pthread_mutex_unlock( &fe_http_task_mutex );

    return  0;

}

/*
 return value
 0 not in cache
 1 cache hit
 2 downloading
 */
int fe_http_cache_status(fe_multi_http_fetch_context *ctx) {
    
    long long fsize;
    
    fsize = fe_file_size(ctx->cache_file_path);
    
    if ( fsize>0 ) {
        
        ctx->status = FE_HTTP_STATUS_CACHEHIT | FE_HTTP_STATUS_FINISH;
        return 1;
        
    } else if ( 0==fsize ) {
        
        unlink (ctx->cache_file_path);
        
    }
    
    fsize = fe_file_size(ctx->download_file_path);
    
    if ( fsize>0 ) {

        ctx->status = FE_HTTP_STATUS_PROGRESS;
        return 2;

    } else if ( 0==fsize ){

        fe_file_unlink_expire(ctx->download_file_path, FE_HTTP_DEFAULT_ZERO_FILE_EXPIRE_SEC);

    }
    
    return 0;
    
}


