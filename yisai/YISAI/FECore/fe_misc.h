//
//  fe_misc.h
//  ch74
//
//  Created by apps on 14/11/12.
//  Copyright (c) 2014年 apps. All rights reserved.
//

#ifndef __ch74__fe_misc__
#define __ch74__fe_misc__

#include <stdio.h>
#define FE_TIMESTAMP_BASE62_LEN 64

typedef struct _fe_misc_base62_t {
    char string[FE_TIMESTAMP_BASE62_LEN];
    size_t len;
}fe_misc_base62_t;

void init_misc();

void fe_g_lock();

void fe_g_unlock();


fe_misc_base62_t getid62();

void initFEiOSAppPath(const char *root_path, const char *temp_path, const  char *documents_path, const char *cache_path);

/*
pthread_mutex_t fe_mutex_init();
void fe_mutex_lock(pthread_mutex_t *mutex_ptr);
void fe_mutex_unlock(pthread_mutex_t *mutex_ptr);
void fe_mutex_destroy(pthread_mutex_t *mutex_ptr);
*/

#endif /* defined(__ch74__fe_misc__) */
