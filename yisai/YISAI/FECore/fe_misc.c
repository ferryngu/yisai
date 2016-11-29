//
//  fe_misc.c
//  ch74
//
//  Created by apps on 14/11/12.
//  Copyright (c) 2014年 apps. All rights reserved.
//


#include <stdlib.h>
#include <string.h>
#include <limits.h>
#include <pthread.h>

#include "fe_code.h"
#include "fe_time.h"
#include "fe_misc.h"

#include "fe_file.h"

#include "fe_http.h"

static pthread_mutex_t g_mutex;


void init_misc() {

    pthread_mutex_init( &g_mutex, NULL );
    fe_http_init_once();

}


void fe_g_lock() {
    pthread_mutex_lock( &g_mutex );
}


void fe_g_unlock() {
    pthread_mutex_unlock( &g_mutex );
}







fe_misc_base62_t getid62() {

    fe_misc_base62_t base62;
    
    uint64_t timestamp_usec = fe_timestamp_usec();

    if ( timestamp_usec<=0 ) {
        base62.len = 0;
        return base62;
    }

    base62.len = base62_encode (timestamp_usec, base62.string, FE_TIMESTAMP_BASE62_LEN);
    
    if (base62.len>FE_TIMESTAMP_BASE62_LEN) {
        base62.len = 0;
    }
    
    return base62;

}




void initFEiOSAppPath(const char *root_path, const char *temp_path, const  char *documents_path, const char *cache_path){

    FE_ROOT_PATH = (char *)malloc(PATH_MAX);
    
    FE_TEMP_PATH = malloc(PATH_MAX);
    
    FE_DOCUMENTS_PATH = malloc(PATH_MAX);
    
    FE_CACHE_PATH = malloc(PATH_MAX);
    
    snprintf(FE_ROOT_PATH, PATH_MAX, "%s", root_path);
    
    snprintf(FE_TEMP_PATH, PATH_MAX, "%s", temp_path);
    
    *(FE_TEMP_PATH + strlen(temp_path)-1 )= '\0';
    
    
    
    snprintf(FE_DOCUMENTS_PATH, PATH_MAX, "%s",documents_path);

    snprintf(FE_CACHE_PATH, PATH_MAX, "%s",cache_path);

}

/*
pthread_mutex_t fe_mutex_init() {
    pthread_mutex_t mutex;
    pthread_mutex_init( &mutex, NULL );
    return mutex;
}

void fe_mutex_lock(pthread_mutex_t *mutex_ptr) {
    pthread_mutex_lock( mutex_ptr );
}

void fe_mutex_unlock(pthread_mutex_t *mutex_ptr) {
     pthread_mutex_unlock( mutex_ptr );
    
}

void fe_mutex_destroy(pthread_mutex_t *mutex_ptr) {
    pthread_mutex_destroy(mutex_ptr);
}
*/

