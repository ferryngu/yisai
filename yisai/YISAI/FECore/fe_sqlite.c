//
//  fe_sqlite.c
//  fechat
//
//  Created by apps on 14/8/30.
//  Copyright (c) 2014年 apps. All rights reserved.
//


#include <stdlib.h>
#include <string.h>

#include <unistd.h>
#include "fe_sqlite.h"
#include "fe_file.h"


int fe_sqlite_exist( const char*dbname )
{
    char dbpath[PATH_MAX];
    snprintf(dbpath, PATH_MAX, "%s/%s.db", FE_DOCUMENTS_PATH, dbname);
    return fe_file_exist(dbpath);
}

sqlite3 *fe_sqlite_open( const char*dbname, int force_creat )
{

    sqlite3 *db;

    char dbpath[PATH_MAX];

    int ret;

    snprintf(dbpath, PATH_MAX, "%s/%s.db", FE_DOCUMENTS_PATH, dbname);

    //printf("dbpath[%s]\n",dbpath);
    
    if ( force_creat ) {

        ret = fe_file_exist(dbpath);

        if (0==ret) {
            unlink (dbpath);
        }

    }

    ret = sqlite3_open_v2(dbpath, &db, SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX, NULL);
    if ( ret != SQLITE_OK ) {
        sqlite3_close(db);
        return NULL;
    }
    
    return db;

}

int fe_sqlite_exec(sqlite3 *db, const char *sql)
{
    int ret;
    
    sqlite3_stmt *statement;
    
    ret = sqlite3_prepare_v2(db, sql, -1, &statement, NULL);
    
    ret = sqlite3_step(statement);
    
    if ( ret != SQLITE_OK && ret != SQLITE_DONE) {
        
//        printf("fe_sqlite_exec ####### [%s] [%d]#########\n",sql, ret);
        return 0;
    }

    sqlite3_finalize(statement);
    
    return 0;
}


sqlite3_stmt* fe_sqlite_create_stmt(sqlite3 *db, const char *sql)
{
    int ret;
    
    sqlite3_stmt *statement;
    
    ret = sqlite3_prepare_v2(db, sql, -1, &statement, NULL);

    return statement;
    
}

void fe_sqlite_delete( const char*dbname )
{

    char dbpath[PATH_MAX];
    
    snprintf(dbpath, PATH_MAX, "%s/%s.db", FE_DOCUMENTS_PATH, dbname);

    unlink (dbpath);

}


// the new Api

fe_db_ctx *fe_sqlite_init( const char*dbname, int force_creat ) {

    fe_db_ctx *ctx = (fe_db_ctx *) malloc(sizeof(fe_db_ctx));
    
    int ret;

    snprintf(ctx->dbpath, PATH_MAX, "%s/%s.db", FE_DOCUMENTS_PATH, dbname);
    
    if ( force_creat ) {
        
        ret = fe_file_exist(ctx->dbpath);
        
        if (0==ret) {
            unlink (ctx->dbpath);
        }

    }

    ret = sqlite3_open_v2(ctx->dbpath, &ctx->db, SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX, NULL);

    if ( ret != SQLITE_OK ) {
        sqlite3_close(ctx->db);
        free(ctx);
        return NULL;
    }

    return ctx;

}

void fe_sqlite_free(fe_db_ctx *ctx) {
    sqlite3_close(ctx->db);
    free(ctx);
}


int fe_sqlite_execf( fe_db_ctx *ctx, char *format, ... ) {

    char sql[FE_SQLITE_SQL_MAX];

    va_list ap;

    int var_count = 0;
    char var_types[64];

    char *p = format;
    
    char *sp = sql;
    
    va_start( ap, format );

    while (*p) {

        if ( '%' != *p ) {
            *sp = *p;
            sp++;
            p++;
            continue;
        }

        if ( 0==*(p+1) ) {
            *sp = *p;
            sp++;
            break;
        }

        switch ( *(p+1) ) {

            case 'd':

                var_types[var_count] = 'd';
                var_count++;
                break;

            case 'l':

                var_types[var_count] = 'l';
                var_count++;
                break;

            case 'f':
                
                var_types[var_count] = 'f';
                var_count++;
                break;

            case 's':
                var_types[var_count] = 's';
                var_count++;
                break;

            case 'b':
                var_types[var_count] = 'b';
                var_count++;
                break;

            default:
                break;
        }
        
        *sp = '?';
        
        sp++;

        p+=2;

    }

    va_end( ap );
    
    *sp = '\0';

    var_types[var_count] = '\0';

    //printf("fe_sqlite_execf sql[%s]\n",sql);

    int ret;

    sqlite3_stmt *stmt;

    ret = sqlite3_prepare_v2(ctx->db, sql, -1, &stmt, NULL);

    int i;

    char *var_s;
    int32_t   var_d;
    int64_t  var_l;
    double var_f;

    for (i=0; i<=var_count; i++) {
        
        switch ( var_types[i] ) {

            case 'd':

                var_d = va_arg(ap,int32_t) ;
                ret = sqlite3_bind_int(stmt, i+1, var_d);
                break;

            case 'l':

                var_l = va_arg(ap,int64_t);
                ret = sqlite3_bind_int64(stmt, i+1, var_l);
                break;

            case 'f':

                var_f = va_arg(ap,double);
                sqlite3_bind_double(stmt, i+1, var_f);
                break;

            case 's':

                var_s = va_arg(ap,char *);

                sqlite3_bind_text(stmt, i+1, var_s, -1, SQLITE_TRANSIENT);
                break;

            case 'b':

                var_s = va_arg(ap,char *);
                ret = sqlite3_bind_blob(stmt, i+1, var_s, -1, SQLITE_TRANSIENT);
                break;
                
            default:
                break;

        }

    }
    
    ret = sqlite3_step(stmt);

    sqlite3_finalize(stmt);
    
    return 0;

}

int check_by_stringkey(fe_db_ctx *ctx, char *table, char *key,char *value)
{
    
    int ret;
    char sql[FE_SQLITE_SQL_MAX];
    sqlite3_stmt *stmt;
    
    int count;
    snprintf(sql, FE_SQLITE_SQL_MAX, "select count(*) from %s where %s=?;",table,key);
    
    ret = sqlite3_prepare_v2(ctx->db, sql, -1, &stmt, NULL);
    
    ret = sqlite3_bind_text(stmt, 1, value, -1, SQLITE_TRANSIENT);
    
    ret = sqlite3_step(stmt);
    
    if ( ret!= SQLITE_ROW) {
        sqlite3_finalize(stmt);
        return 0;
    }
    
    count = sqlite3_column_int(stmt, 0);
    
    sqlite3_finalize(stmt);

    if ( count>0 ) {
        return count;
    }
    
    return 0;
    
}

#define MAX_FIELDNAME 64

union fe_field_union {
    int32_t  v_int32;
    int64_t  v_int64;
    char * v_string;
    double v_float;
};

struct fe_sqlite_field {
    
    char *name;
    
    char *type;
    
    union fe_field_union value;
    
};

static int fe_sqlite_vinsertf(fe_db_ctx *ctx, char *table, int field_num, va_list ap) {

    int ret;
    
    struct fe_sqlite_field fields[field_num];
    
    int i;
    
    for (i=0; i<field_num; i++) {
        
        fields[i].type =  va_arg(ap, char *);
        fields[i].name =  va_arg(ap, char *);

        switch ( *(fields[i].type) ) {
            case 'd':
                
                fields[i].value.v_int32 = va_arg(ap,int32_t) ;
                
                break;
                
            case 'l':
                
                fields[i].value.v_int64 = va_arg(ap,int64_t);
                
                break;
                
            case 'f':
                
                fields[i].value.v_float = va_arg(ap,double);
                
                break;
                
            case 's':
                
            case 'b':
                
                fields[i].value.v_string = va_arg(ap,char *);
                
                break;
                
            default:
                break;
        }
        
    }
    
    char sql[FE_SQLITE_SQL_MAX];
    
    int fieldnames_string_len = (MAX_FIELDNAME+1)*field_num + 1;
    char fieldnames_string[fieldnames_string_len];
    
    int values_string_len = (field_num+1)*2;
    char values_string[values_string_len];
    
    fieldnames_string[0]='\0';
    values_string[0]='\0';

    for (i=0; i<field_num; i++) {
        
        strncat(fieldnames_string, fields[i].name, values_string_len);
        
        strncat(values_string, "?", values_string_len);
        
        if ( (i+1) < field_num ) {
            strncat(fieldnames_string, ",", fieldnames_string_len);
            strncat(values_string, ",", values_string_len);
        }

    }

    snprintf(sql, FE_SQLITE_SQL_MAX, "insert into %s(%s) values(%s);", table, fieldnames_string, values_string);

    //printf("sql[%s]\n",sql);
    
    sqlite3_stmt *stmt;

    ret = sqlite3_prepare_v2(ctx->db, sql, -1, &stmt, NULL);
    
    for (i=0; i<field_num; i++) {
        
        switch ( *(fields[i].type) ) {
                
            case 'd':
                ret = sqlite3_bind_int(stmt, i+1, fields[i].value.v_int32);
                break;
                
            case 'l':
                ret = sqlite3_bind_int64(stmt, i+1, fields[i].value.v_int64);
                //printf("fields[%d].value.v_int64[%lld]\n", i, fields[i].value.v_int64);
                break;
                
            case 'f':
                sqlite3_bind_double(stmt, i+1, fields[i].value.v_int64);
                break;
                
            case 's':
                sqlite3_bind_text(stmt, i+1, fields[i].value.v_string, -1, SQLITE_TRANSIENT);
                //printf("fields[%d].v_string[%s]\n", i, fields[i].value.v_string);
                break;
                
            case 'b':
                sqlite3_bind_blob(stmt, i+1, fields[i].value.v_string, -1, SQLITE_TRANSIENT);
                //printf("fields[%d].v_string[%s]\n", i, fields[i].value.v_string);
                break;
                
            default:
                break;
        }

    }

    ret = sqlite3_step(stmt);

sqlite_end:

    sqlite3_finalize(stmt);

    if ( SQLITE_DONE == ret ) {
        return 0;
    }

    return ret;

}


static int fe_sqlite_vupdatef(fe_db_ctx *ctx, char *table, char *keyname, char *keyvalue, int field_num, va_list ap) {

    int ret;

    struct fe_sqlite_field fields[field_num];

    int i;

    for (i=0; i<field_num; i++) {

        fields[i].type =  va_arg(ap, char *);
        fields[i].name =  va_arg(ap, char *);

        switch ( *(fields[i].type) ) {

            case 'd':
                
                fields[i].value.v_int32 = va_arg(ap,int32_t) ;

                break;
                
            case 'l':
                
                fields[i].value.v_int64 = va_arg(ap,int64_t);

                break;
                
            case 'f':
                
                fields[i].value.v_float = va_arg(ap,double);

                break;
                
            case 's':

            case 'b':

                fields[i].value.v_string = va_arg(ap,char *);

                break;

            default:
                break;
        }

    }

    char sql[FE_SQLITE_SQL_MAX];
    
    int update_field_chain_len = (MAX_FIELDNAME+10)*field_num;
    char update_field_chain[update_field_chain_len];

    update_field_chain[0]='\0';
    
    for (i=0; i<field_num; i++) {
        
        strncat(update_field_chain, fields[i].name, update_field_chain_len);
        strncat(update_field_chain, "=?", update_field_chain_len);
        
        if ( (i+1) < field_num ) {
            strncat(update_field_chain, ",", update_field_chain_len);
        }

    }
    
    snprintf(sql, FE_SQLITE_SQL_MAX, "update %s set %s where %s=?;", table, update_field_chain, keyname);

    //printf("sql[%s]\n",sql);
    
    sqlite3_stmt *stmt;
    
    ret = sqlite3_prepare_v2(ctx->db, sql, -1, &stmt, NULL);

    if (  SQLITE_OK != ret ) {
        goto sqlite_end;
    }
    
    for (i=0; i<field_num; i++) {

        switch ( *(fields[i].type) ) {

            case 'd':
                ret = sqlite3_bind_int(stmt, i+1, fields[i].value.v_int32);
                break;

            case 'l':
                ret = sqlite3_bind_int64(stmt, i+1, fields[i].value.v_int64);
                //printf("fields[%d].value.v_int64[%lld]\n", i, fields[i].value.v_int64);
                break;
                
            case 'f':
                ret = sqlite3_bind_double(stmt, i+1, fields[i].value.v_float);
                break;
                
            case 's':

                ret = sqlite3_bind_text(stmt, i+1, fields[i].value.v_string, -1, SQLITE_TRANSIENT);
                //printf("fields[%d].v_string[%s]\n", i, fields[i].value.v_string);
                break;

            case 'b':
                sqlite3_bind_blob(stmt, i+1, fields[i].value.v_string, -1, SQLITE_TRANSIENT);
                //printf("fields[%d].v_string[%s]\n", i, fields[i].value.v_string);
                break;
                
            default:
                break;
        }
        
    }

    ret = sqlite3_bind_text(stmt, i+1, keyvalue, -1, SQLITE_TRANSIENT);

    ret = sqlite3_step(stmt);

sqlite_end:

    sqlite3_finalize(stmt);

    if ( SQLITE_DONE == ret ) {
        return 0;
    }

    return ret;

}

int fe_sqlite_updatef(fe_db_ctx *ctx, char *table, char *keyname, char *keyvalue, int field_num, ... ){

    int ret;
    
    va_list ap;
    
    va_start(ap, field_num);
    
    ret = fe_sqlite_vupdatef(ctx, table, keyname, keyvalue, field_num, ap);

    va_end(ap);

    return ret;

}

int fe_sqlite_insertf(fe_db_ctx *ctx, char *table, int field_num, ...) {
    
    int ret;
    
    va_list ap;

    va_start(ap, field_num);

    ret = fe_sqlite_vinsertf(ctx, table, field_num, ap);

    va_end(ap);

    return ret;

}

int fe_sqlite_storagef(fe_db_ctx *ctx, char *table, char *keyname, char *keyvalue, int field_num, ... ) {

    int ret;

    va_list ap;

    ret = check_by_stringkey(ctx, table, keyname, keyvalue);

    if ( ret >0 ) {

        va_start(ap, field_num);

        ret = fe_sqlite_vupdatef(ctx, table, keyname, keyvalue, field_num,ap);

        va_end( ap );
        
    } else {
    
        va_start(ap, field_num);

        ret = fe_sqlite_vinsertf(ctx, table, field_num, ap);

        va_end( ap );
    }

    return ret;

}



int fe_sqlite_vstoragef(fe_db_ctx *ctx, char *table, char *keyname, char *keyvalue, int field_num,va_list ap) {
    return 0;
}




