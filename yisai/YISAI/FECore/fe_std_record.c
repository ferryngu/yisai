//
//  fe_std_record.c
//  
//
//  Created by chenyuning on 15/6/10.
//
//
#include <string.h>
#include <stdlib.h>
#include <math.h>
#include <pthread.h>

#include "fe_sqlite.h"

#include "fe_std_record.h"

#define APP_STDRECORD_DB "misc"

#define APP_STDRECORD_DB_TABLE "std_record"

#define BUILD_SQL(...)#__VA_ARGS__

const char *create_app_std_record_sql = BUILD_SQL (
                                         
     CREATE TABLE IF NOT EXISTS attrib (
       id    varchar(128),
       key   varchar(255),
       v0    varchar(4096),
       v1    varchar(4096),
       v2    varchar(4096),
       v3    varchar(4096),
       v4    varchar(4096),
       v5    varchar(4096),
       v6    varchar(4096),
       v7    varchar(4096),
       v8    varchar(4096),
       v9    varchar(4096),
       v10    varchar(4096),
       v12    varchar(4096),
       v13    varchar(4096),
       v14    varchar(4096),
       v15    varchar(4096),
       v16    varchar(4096),
       v17    varchar(4096),
       v18    varchar(4096),
       v19    varchar(4096),
       v20    varchar(4096),
       v21    varchar(4096),
       v22    varchar(4096),
       v23    varchar(4096),
       v24    varchar(4096)
     );
                                              
);



static pthread_mutex_t std_record_mutex;

void fe_std_record_misc_init() {
    
    sqlite3 *db;
    
    db = fe_sqlite_open( APP_STDRECORD_DB, 0 );
    
    fe_sqlite_exec(db,create_app_std_record_sql);
    
    sqlite3_close(db);
    
    pthread_mutex_init( &std_record_mutex, NULL );
    
}




