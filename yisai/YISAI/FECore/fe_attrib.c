//
//  fe_attrib.c
//  ch74
//
//  Created by apps on 14/11/12.
//  Copyright (c) 2014年 apps. All rights reserved.
//
#include <string.h>
#include <stdlib.h>
#include <math.h>
#include <pthread.h>

#include "fe_sqlite.h"

#include "fe_attrib.h"

#define APP_ATTRIB_DB "misc"

#define APP_ATTRIB_DB_TABLE "attrib"

#define BUILD_SQL(...)#__VA_ARGS__

const char *create_app_attrib_sql = BUILD_SQL(

  CREATE TABLE IF NOT EXISTS attrib (
    id    varchar(128),
    key   varchar(255),
    value varchar(4096)
  );

);


static pthread_mutex_t attrib_mutex;

void fe_attrib_misc_init() {

    sqlite3 *db;

    db = fe_sqlite_open( APP_ATTRIB_DB, 0 );

    fe_sqlite_exec(db,create_app_attrib_sql);

    sqlite3_close(db);

    pthread_mutex_init( &attrib_mutex, NULL );
    
}

char* fe_attrib_string_dup(const char *id, const char *key) {

    int ret;

    char sql[FE_SQLITE_SQL_MAX];
    
    sqlite3 *db;

    sqlite3_stmt *stmt;

    pthread_mutex_lock( &attrib_mutex );

    db = fe_sqlite_open( APP_ATTRIB_DB, 0 );

    if ( NULL==db ) {
        pthread_mutex_unlock( &attrib_mutex );
        sqlite3_close(db);
        return NULL;
    }
    
    snprintf(sql, FE_SQLITE_SQL_MAX, "select * from "APP_ATTRIB_DB_TABLE" where id=? and key=?");

    ret = sqlite3_prepare_v2(db, sql, -1, &stmt, NULL);

    if ( ret != SQLITE_OK ) {
        pthread_mutex_unlock( &attrib_mutex );
        sqlite3_close(db);
        return NULL;
    }
    
    ret = sqlite3_bind_text(stmt, 1, id, -1, SQLITE_TRANSIENT);

    if ( ret != SQLITE_OK ) {
        goto sqlite_end;
    }

    ret = sqlite3_bind_text(stmt, 2, key, -1, SQLITE_TRANSIENT);

    if ( ret != SQLITE_OK ) {
        goto sqlite_end;
    }
    
    ret = sqlite3_step(stmt);
    
    if ( ret != SQLITE_ROW ) {
        goto sqlite_end;
    }

    char *value = (char*)sqlite3_column_text(stmt, 2);

    char *retrun_value = NULL;
    
    if (NULL==value) {
        goto sqlite_end;
    }

    retrun_value = strdup(value);
    
    sqlite3_finalize(stmt);
    sqlite3_close(db);
    pthread_mutex_unlock( &attrib_mutex );

    return retrun_value;

sqlite_end:

    sqlite3_finalize(stmt);
    sqlite3_close(db);
    pthread_mutex_unlock( &attrib_mutex );
    return NULL;
}


fe_attrib_list* fe_attrib_all_keys(const char *id, size_t size) {

    int ret;
    
    char sql[FE_SQLITE_SQL_MAX];
    
    sqlite3 *db;
    
    sqlite3_stmt *stmt;

    fe_attrib_list *attrib_list = NULL;

    pthread_mutex_lock( &attrib_mutex );
    
    db = fe_sqlite_open( APP_ATTRIB_DB, 0 );

    if ( NULL==db ) {
        pthread_mutex_unlock( &attrib_mutex );
        sqlite3_close(db);
        return NULL;
    }

    snprintf(sql, FE_SQLITE_SQL_MAX, "select key,value from "APP_ATTRIB_DB_TABLE" where id=?");
    
    ret = sqlite3_prepare_v2(db, sql, -1, &stmt, NULL);
    
    if ( ret != SQLITE_OK ) {
        pthread_mutex_unlock( &attrib_mutex );
        sqlite3_close(db);
        return NULL;
    }
    
    ret = sqlite3_bind_text(stmt, 1, id, -1, SQLITE_TRANSIENT);
    
    if ( ret != SQLITE_OK ) {
        goto sqlite_end;
    }

    attrib_list = malloc(sizeof(fe_attrib_list));
    
    attrib_list->size = 0;
    
    attrib_list->attrib = malloc(sizeof(fe_attrib)*size);
    
    fe_attrib *p = attrib_list->attrib;
    
    
    char *key;
    char *value;
    
    while ( (ret = sqlite3_step(stmt)) == SQLITE_ROW )
    {
        
        key = (char*)sqlite3_column_text(stmt, 0);
        
        value = (char*)sqlite3_column_text(stmt, 1);
        
        if ( NULL==key || NULL==value ) {
            continue;
        }

        p->key = strdup(key);
        p->string_value = strdup(value);
        p++;
        attrib_list->size++;

        if ( attrib_list->size >= size ) {
            break;
        }
    }
    
    if ( 0==attrib_list->size ) {
        free(attrib_list);
        attrib_list = NULL;
    }

sqlite_end:
    
    sqlite3_finalize(stmt);
    sqlite3_close(db);
    pthread_mutex_unlock( &attrib_mutex );
    return attrib_list;

}


void fe_attrib_list_release(fe_attrib_list *attrib_list){

    int i;

    for (i=0; i<attrib_list->size; i++) {
        
        free(attrib_list->attrib->key);

        free(attrib_list->attrib->string_value);
        
        attrib_list->attrib++;
        
    }
free(attrib_list);

}



int64_t fe_attrib_int64(const char *id, const char *key, int64_t default_value) {

    char *value = fe_attrib_string_dup(id, key);
    
    if ( NULL==value ) {
        free(value);
        return default_value;
    }

    int64_t int64_value = (int64_t)strtoll(value,NULL,10);
    
    free(value);

    if (int64_value == HUGE_VAL) {
        return default_value;
    }

    return int64_value;

}


void fe_attrib_set_string(const char *id, const char *key, const char *string_value) {

    int ret;

    char sql[FE_SQLITE_SQL_MAX];
    
    sqlite3 *db;
    
    sqlite3_stmt *stmt;
    
    if ( NULL==string_value ) {
        fe_attrib_delete(id, key);
        return;
    }

    pthread_mutex_lock( &attrib_mutex );

    db = fe_sqlite_open( APP_ATTRIB_DB, 0 );

    if ( NULL==db ) {
        pthread_mutex_unlock( &attrib_mutex );
        sqlite3_close(db);
        return;
    }

    snprintf(sql, FE_SQLITE_SQL_MAX, "select * from "APP_ATTRIB_DB_TABLE" where id=? and key=?");
    
    ret = sqlite3_prepare_v2(db, sql, -1, &stmt, NULL);
    
    if ( ret != SQLITE_OK ) {
        sqlite3_close(db);
        pthread_mutex_unlock( &attrib_mutex );
        return;
    }

    ret = sqlite3_bind_text(stmt, 1, id, -1, SQLITE_TRANSIENT);
    
    if ( ret != SQLITE_OK ) {
        goto sqlite_end;
    }

    ret = sqlite3_bind_text(stmt, 2, key, -1, SQLITE_TRANSIENT);
    
    if ( ret != SQLITE_OK ) {
        goto sqlite_end;
    }
    
    ret = sqlite3_step(stmt);

    char *value;
    if ( ret == SQLITE_ROW ) {
        value = (char*)sqlite3_column_text(stmt, 2);
    }else {
        value = NULL;
    }
    
    sqlite3_finalize(stmt);

    if (NULL==value) {

        snprintf(sql, FE_SQLITE_SQL_MAX, "insert into "APP_ATTRIB_DB_TABLE"(id,key,value) values(?,?,?)");

        ret = sqlite3_prepare_v2(db, sql, -1, &stmt, NULL);

        if ( ret != SQLITE_OK ) {
            goto sqlite_end;
        }

        ret = sqlite3_bind_text(stmt, 1, id, -1, SQLITE_TRANSIENT);

        if ( ret != SQLITE_OK ) {
            goto sqlite_end;
        }

        ret = sqlite3_bind_text(stmt, 2, key, -1, SQLITE_TRANSIENT);

        if ( ret != SQLITE_OK ) {
            goto sqlite_end;
        }

        ret = sqlite3_bind_text(stmt, 3, string_value, -1, SQLITE_TRANSIENT);

        if ( ret != SQLITE_OK ) {
            goto sqlite_end;
        }

        ret = sqlite3_step(stmt);

        if ( ret != SQLITE_DONE ) {
            goto sqlite_end;
        }

    } else {

        snprintf(sql, FE_SQLITE_SQL_MAX, "update "APP_ATTRIB_DB_TABLE" set value=? where id=? and key=?");

        ret = sqlite3_prepare_v2(db, sql, -1, &stmt, NULL);

        if ( ret != SQLITE_OK ) {
            goto sqlite_end;
        }

        ret = sqlite3_bind_text(stmt, 1, string_value, -1, SQLITE_TRANSIENT);
        
        if ( ret != SQLITE_OK ) {
            goto sqlite_end;
        }
        
        ret = sqlite3_bind_text(stmt, 2, id, -1, SQLITE_TRANSIENT);
        
        if ( ret != SQLITE_OK ) {
            goto sqlite_end;
        }

        ret = sqlite3_bind_text(stmt, 3, key, -1, SQLITE_TRANSIENT);
        
        if ( ret != SQLITE_OK ) {
            goto sqlite_end;
        }
        
        ret = sqlite3_step(stmt);
        
        if ( ret != SQLITE_DONE ) {
            goto sqlite_end;
        }

    }

    
sqlite_end:

    sqlite3_finalize(stmt);
    sqlite3_close(db);
    pthread_mutex_unlock( &attrib_mutex );
    return;

}


void fe_attrib_set_int64(const char *id, const char *key, int64_t long_value) {
    
    char string_value[64];

    snprintf(string_value, 64, "%lld",long_value);
    
    fe_attrib_set_string(id, key,string_value);
    
    return;
}


void fe_attrib_delete(const char *id, const char *key) {
    
    int ret;
    
    char sql[FE_SQLITE_SQL_MAX];
    
    sqlite3 *db;
    
    sqlite3_stmt *stmt;
    
    pthread_mutex_lock( &attrib_mutex );
    
    db = fe_sqlite_open( APP_ATTRIB_DB, 0 );
    
    if ( NULL==db ) {
        pthread_mutex_unlock( &attrib_mutex );
        sqlite3_close(db);
        return;
    }

    snprintf(sql, FE_SQLITE_SQL_MAX, "delete from "APP_ATTRIB_DB_TABLE" where id=? and key=?");

    ret = sqlite3_prepare_v2(db, sql, -1, &stmt, NULL);
    
    ret = sqlite3_prepare_v2(db, sql, -1, &stmt, NULL);
    
    if ( ret != SQLITE_OK ) {
        goto sqlite_end;
    }
    
    ret = sqlite3_bind_text(stmt, 1, id, -1, SQLITE_TRANSIENT);
    
    if ( ret != SQLITE_OK ) {
        goto sqlite_end;
    }
    
    ret = sqlite3_bind_text(stmt, 2, key, -1, SQLITE_TRANSIENT);
    
    if ( ret != SQLITE_OK ) {
        goto sqlite_end;
    }
    
    ret = sqlite3_step(stmt);
    
    if ( ret != SQLITE_DONE ) {
        goto sqlite_end;
    }
    
sqlite_end:
    
    sqlite3_finalize(stmt);
    sqlite3_close(db);
    pthread_mutex_unlock( &attrib_mutex );

    return;
    
}

