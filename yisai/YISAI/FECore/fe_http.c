//
//  fe_http.c
//  FECoreHttp
//
//  Created by apps on 15/5/5.
//  Copyright (c) 2015年 apps. All rights reserved.
//


#include <stdlib.h>
#include <unistd.h>

#include "fe_http.h"
#include "fe_file.h"

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

#include "fe_multi_http_fetch.h"

int fe_http_max_url_lenght = FE_HTTP_MAX_URL_LENGHT;
int fe_http_default_content_lenght = FE_HTTP_DEFAULT_CONTENT_LENGHT;
int fe_http_default_timeout_ms = FE_HTTP_DEFAULT_TIMEOUT_MS;

void fe_http_init_once() {

    curl_global_init(CURL_GLOBAL_ALL);

    fe_multi_http_fetch_init_once();

}

void fe_clean_http_cache() {
    char path[PATH_MAX];
    snprintf(path, PATH_MAX,"%s/%s",FE_CACHE_PATH,FE_HTTP_CACHE_PREFIX);
    fe_clean_dirs(path);
}

void fe_clean_http_temp_dir() {
    char path[PATH_MAX];
    snprintf(path, PATH_MAX,"%s/%s",FE_TEMP_PATH,FE_HTTP_CACHE_PREFIX);
    fe_clean_dirs(path);
}

char *fe_http_fetch_cache_file_path_dup(const char *url) {
    
    char *cache_file_path = (char *)malloc(PATH_MAX);
    
    
    fe_get_cache_file_path(url, 0, FE_HTTP_CACHE_PREFIX, cache_file_path, PATH_MAX);
    
    long long fsize;
    
    fsize = fe_file_size(cache_file_path);
    
    if ( fsize>0 ) {
        
        return cache_file_path;
        
    } else if ( 0==fsize ){
        
        unlink (cache_file_path);
        free(cache_file_path);
        
    }
    
    return NULL;
    
}

