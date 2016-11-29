//
//  fe_attrib.h
//  ch74
//
//  Created by apps on 14/11/12.
//  Copyright (c) 2014年 apps. All rights reserved.
//

#ifndef __ch74__fe_attrib__
#define __ch74__fe_attrib__

#include <stdio.h>

void fe_attrib_misc_init();

void fe_attrib_set_string(const char *id, const char *key, const char *string_value);

void fe_attrib_set_int64(const char *id, const char *key, int64_t long_value);

char* fe_attrib_string_dup(const char *id, const char *key);

int64_t fe_attrib_int64(const char *id, const char *key, int64_t default_value);

void fe_attrib_delete(const char *id, const char *key);

typedef struct _fe_attrib{
    char *key;
    char *string_value;
}fe_attrib;


typedef struct _fe_attrib_list{

    fe_attrib *attrib;
    int size;

}fe_attrib_list;

fe_attrib_list* fe_attrib_all_keys(const char *id, size_t size);

void fe_attrib_list_release(fe_attrib_list *attrib_list);

#endif /* defined(__ch74__fe_attrib__) */
