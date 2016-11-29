//
//  fe_hash.h
//  FECoreHttp
//
//  Created by apps on 15/8/13.
//  Copyright © 2015年 apps. All rights reserved.
//

#ifndef fe_hash_h
#define fe_hash_h

#include <stdio.h>


#define FE_STRING_HASH_KEY_LENGTH 1024

typedef struct _fe_string_hash fe_string_hash;

typedef struct _fe_string_map {

    fe_string_hash *header;
    int atom_flag;
    pthread_mutex_t map_mutex;
    
} fe_string_map;


fe_string_map * fe_string_map_init(int atom_flag);

void fe_string_map_free(fe_string_map *map);

void* fe_string_map_set(fe_string_map *map, const char *name, void *value);

void* fe_string_map_get(fe_string_map *map, const char *name);


/*
#if 0

typedef struct _fe_hash_var{
    
    int var_type; // 0:int32 1:int64 3:char * 4:void*
    
    union fe_hash_var {
        
        int var_int32;
        
        long long var_int64;
        
        char *var_string;
        
        void *var_void;
        
    } var;
    
    
} fe_hash_var;


typedef struct _fe_hash_var fe_hash_var;

typedef void(fe_hash_var_init_cb_t)(fe_hash_var *);
typedef void(fe_hash_var_free_cb_t)(fe_hash_var *);

typedef struct _fe_hash_var{

    int var_type; // 0:int32 1:int64 3:char * 4:void*
    
    union fe_hash_var {
        
        int var_int32;
        
        long long var_int64;
        
        char *var_string;
        
        void *var_void;
        
    } var;

} fe_hash_var;

typedef struct _fe_hash {
    
    UT_hash_handle hh;
    
    fe_hash_var *key;
    fe_hash_var *value;
    
    fe_hash_var_init_cb_t *var_init_cb;
    fe_hash_var_free_cb_t *var_free_cb;
    
}fe_hash;




typedef struct _fe_hash {
    
    UT_hash_handle hh;
    
    fe_hash_var *key;
    fe_hash_var *value;

    fe_hash_var_init_cb_t *var_init_cb;
    fe_hash_var_free_cb_t *var_free_cb;

}fe_hash;

fe_hash * fe_hash_init(fe_hash_var_init_cb_t *var_init_cb,fe_hash_var_free_cb_t *var_free_cb);

void * fe_hash_ss_get(fe_hash *hash, const char *key);

void fe_hash_ss_set(fe_hash *hash, const char *key, char *value);

void fe_hash_free(fe_hash *hash);
#endif

*/


#endif /* fe_hash_h */
