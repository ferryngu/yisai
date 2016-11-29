//
//  fe_std_data.h
//  FECoreHttp
//
//  Created by apps on 15/8/8.
//  Copyright © 2015年 apps. All rights reserved.
//

#ifndef fe_std_data_h
#define fe_std_data_h

#include <stdio.h>


typedef struct _fe_std_data {

    char *id;

    char *key;
    
    char *value;

    long long expire_time;

}fe_std_data;


void fe_std_data_misc_init();

void fe_std_data_atom_set(const char *id, const char *key, const char *string_value, long long expire_after_sec);

char* fe_std_data_atom_get_dup(const char *id, const char *key);

#endif /* fe_std_data_h */
