//
//  fe_sqlite.h
//  fechat
//
//  Created by apps on 14/8/30.
//  Copyright (c) 2014年 apps. All rights reserved.
//

#ifndef __fechat__fe_sqlite__
#define __fechat__fe_sqlite__

#include <stdio.h>
#include <limits.h>

#define FE_SQLITE_SQL_MAX 4096

typedef struct _fe_db_ctx fe_db_ctx;

#define MAX_FIELDNAME 64

union fe_field_union {
    int32_t  v_int32;
    int64_t  v_int64;
    char * v_string;
    double v_float;
};

typedef struct _fe_sqlite_field {

    char *name;
    
    char *type;
    
    union fe_field_union value;
    
}fe_sqlite_field;


typedef struct _fe_sqlite_result_set {

    size_t field_num;
    
    size_t row_num;

    fe_sqlite_field *field;

}fe_sqlite_result_set;

fe_sqlite_result_set * fe_sqlite_result_set_init(size_t row_num, size_t field_num, ...);

fe_sqlite_field * fe_sqlite_fetch_result_set(fe_sqlite_result_set *result_set, size_t row, const char *name);

void fe_sqlite_result_set_free(fe_sqlite_result_set *result_set);

fe_db_ctx *fe_sqlite_init( const char*dbname, int force_creat );

void fe_sqlite_free(fe_db_ctx *ctx);

int fe_sqlite_execf( fe_db_ctx *ctx, fe_sqlite_result_set *result_set, const char *format, ... );

int fe_sqlite_insertf(fe_db_ctx *ctx, char *table, int field_num, ...);

int fe_sqlite_updatef(fe_db_ctx *ctx, char *table, char *keyname, char *keyvalue, int field_num, ...);

int fe_sqlite_vstoragef(fe_db_ctx *ctx, char *table, char *keyname, char *keyvalue, int field_num,va_list ap);

int fe_sqlite_storagef(fe_db_ctx *ctx, const char *table, const char *keyname, const char *keyvalue, int field_num, ...);

//int fe_sqlite_storagef(fe_db_ctx *ctx, char *table, char *keyname, char *keyvalue, int field_num, ...);


#endif /* defined(__fechat__fe_sqlite__) */
