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
#include <sqlite3.h>

#define FE_SQLITE_SQL_MAX 4096

int fe_sqlite_exist( const char*dbname );

sqlite3 *fe_sqlite_open( const char*dbname, int force_creat );

int fe_sqlite_exec(sqlite3 *db, const char *sql);

sqlite3_stmt* fe_sqlite_create_stmt(sqlite3 *db, const char *sql);

void fe_sqlite_delete( const char*dbname );


//The New Api
//typedef struct _fe_db_ctx fe_db_ctx;

typedef struct _fe_db_ctx {
    
    char dbpath[PATH_MAX];
    sqlite3 *db;
    
} fe_db_ctx;


fe_db_ctx *fe_sqlite_init( const char*dbname, int force_creat );

void fe_sqlite_free(fe_db_ctx *ctx);



int fe_sqlite_execf( fe_db_ctx *ctx, char *format, ... );
int fe_sqlite_insertf(fe_db_ctx *ctx, char *table, int field_num, ...);

int fe_sqlite_updatef(fe_db_ctx *ctx, char *table, char *keyname, char *keyvalue, int field_num, ...);

int fe_sqlite_vstoragef(fe_db_ctx *ctx, char *table, char *keyname, char *keyvalue, int field_num,va_list ap);
int fe_sqlite_storagef(fe_db_ctx *ctx, char *table, char *keyname, char *keyvalue, int field_num, ...);





#endif /* defined(__fechat__fe_sqlite__) */
