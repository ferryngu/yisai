//
//  FEFile.c
//  FECore
//
//  Created by apps on 14-4-26.
//  Copyright (c) 2014年 apps. All rights reserved.
//

#include <stdio.h>
#include <ctype.h>
#include <limits.h>
#include <stdlib.h>
#include <string.h>

#include <sys/stat.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <unistd.h>

#include "make_dirs.h"
#include "remove_dirs.h"

#include "fe_code.h"
#include "fe_time.h"

#include "fe_file.h"

int fe_rename(const char *src, const char *dst)
{

    int ret;
    
    char *path = fe_file_path_dup(dst,strlen(dst));

    if (NULL==path) {
        return -1;
    }
    
    ret = make_dirs(path, S_IRWXU);
    
    free(path);
    
    if ( 0 != ret ) {
        return ret;
    }
    
    ret = rename(src, dst);

    return ret;
    
}


int fe_file_exist(const char *filename)
{
    struct stat s;
    return stat(filename,&s);
}

int fe_file_unlink_expire(const char *filename, int expire_sec) {

    uint64_t nowsec = fe_timestamp_sec();

    struct stat s;
    int ret;
    
    ret = stat(filename,&s);
    
    if (0!=ret) {
        return -1;
    }

    if ( (nowsec - s.st_mtimespec.tv_sec) < expire_sec ) {
        return 1;
    }

    unlink (filename);
    
    return 0;

}

/*
long fe_file_mtime(const char *filename){

    struct stat s;
    int ret;

    ret = stat(filename,&s);

    if (0!=ret) {
        return -1;
    }

    return s.st_mtimespec.tv_nsec;
    
}
*/



long long fe_file_size(const char *filename)
{
    struct stat s;

    int ret;
    
    ret = stat(filename,&s);

    if ( 0 != ret ) {
        return -1;
    }

    return s.st_size;
    
}

char *fe_file_extname(const char *filename, size_t len)
{
    int i;
    if (0==len) {
        return NULL;
    }
    if ( '.'==filename[len-1] ) {
        return NULL;
    }

    for ( i=(int)len-1; i>=0; i-- ) {
        if ( '.' == filename[i] && (i+1)<len ) {
            return (char*)(filename+i+1);
        }
    }
    return NULL;
}


char *fe_file_extname_dup(const char *filename, size_t len)
{
    int i;
    if (0==len) {
        return NULL;
    }
    if ( '.'==filename[len-1] ) {
        return NULL;
    }
    for (i=(int)len-1; i>=0; i--) {
        if ( '.' == filename[i] ) {
            return strdup ( filename+i+1 );
        }
    }
    return NULL;
}


char *fe_file_basename(const char *filename, size_t len)
{
    int i;
    if (0==len) {
        return NULL;
    }

    if ( '/'==filename[len-1] ) {
        return NULL;
    }
    for (i=(int)len-1; i>=0; i--) {
        if ( '/' == filename[i]  ) {
            return (char*)(filename+i+1);
        }
    }
    return NULL;
}

char *fe_file_basename_dup(const char *filename, size_t len)
{
    int i;
    if (0==len) {
        return NULL;
    }

    if ( '/'==filename[len-1] ) {
        return NULL;
    }

    for (i=(int)len-1; i>=0; i--) {
        if ( '/' == filename[i]) {
            return strdup ( filename+i+1 );
        }
    }
    return NULL;
}

char *fe_file_path_cut(char *filename, size_t len)
{
    int i;
    if (0==len) {
        return NULL;
    }
    
    for (i=(int)len-1; i>=0; i--) {
        if ( '/' == filename[i] ) {
            filename[i]='\0';
            return filename;
        }
    }
    return NULL;
}

char *fe_file_path_dup(const char *filename, size_t len)
{
    int i;
    if (0==len) {
        return NULL;
    }
    char *path_dup=strdup(filename);
    
    for (i=(int)len-1; i>=0; i--) {
        if ( '/' == path_dup[i] ) {
            path_dup[i]='\0';
            return path_dup;
        }
    }
    free(path_dup);
    return NULL;
}

char *fe_hash_path_dup(const char *filename, size_t levels)
{
    char *hash_path;
    int ret;

    hash_path = (char *)malloc(PATH_MAX);

    ret = fe_hash_path(filename, 0, hash_path, levels);

    if (0!=ret) {
        free(hash_path);
        return NULL;
    }
    
    return hash_path;
}


int fe_hash_path(const char *filename, size_t filename_len, char *hash_path, size_t levels)
{
    int i=0;
    char *p;
    char *s;
    
    if (filename_len == 0) {
        filename_len = strlen(filename);
    }
    
    if (filename_len>PATH_MAX) {
        return -1;
    }

    if (0==filename_len) {
        return -2;
    }

    if (levels>4) {
        return -3;
    }
    
    if ( filename_len < sizeof("aabbc.ext") ) {
        return -4;
    }

    p = hash_path;
    s = (char *)filename;

    for ( i=0; i<levels; i++ ) {

        *p='/';
        p++;

        *p = *s;
        p++;
        s++;
        
        *p = *s;
        p++;
        s++;

    }

    *p='/';
    p++;

    s = (char *)filename + levels*2;
    
    for ( i=0; i<filename_len; i++ ) {
        *p = *s;
        p++;
        s++;
    }

    *p = '\0';

    return 0;
    
}

long long file_size ( int fd )
{
	struct stat buf;
    
	if ( fd<0 ) return -1;
    
	fstat (fd,&buf);
	if ( buf.st_size<0 ) return -2;
	return buf.st_size;
}

int fe_read_file( const char *filename, void *buf, ssize_t *buf_len )
{
    int rfd;

    long long rlen = 0;
    
    rfd = open(filename,O_RDONLY,S_IRUSR|S_IWUSR);
    
    if ( -1==rfd ) return -3;
    
    rlen = file_size ( rfd );
    
    if ( rlen<=0 ) return -4;
    
    if ( rlen >= *buf_len ){
        *buf_len = (ssize_t)(rlen -1);
    }
    
    *buf_len = read(rfd,(char *)buf, *buf_len);

    close(rfd);
    
    *( (char*)buf + *buf_len ) = '\0';
    
    return 0;
}

int fe_write_file( const char *filename, void *buf, ssize_t len )
{
    int fd;
    
    fd = fe_create_file(filename);

    if (fd<=0) {
        return fd;
    }

    write(fd, buf, len);
    
    close(fd);
    
    return 0;
}


int fe_create_file(const char *filename)
{
    int fd;
    
    int ret;

    char *path = fe_file_path_dup(filename,strlen(filename));

    if (NULL==path) {
        return -1;
    }
    
    ret = make_dirs(path, S_IRWXU);

    free(path);

    if ( 0!=ret ) {
        return -1;
    }

    fd = open(filename, O_RDWR|O_CREAT|O_TRUNC, S_IRUSR|S_IWUSR);
    
    return fd;
}


fe_file_block fe_mmap(const char *filename)
{
    fe_file_block fileblock;
    struct stat s;
    
    fileblock.ptr = NULL;
    fileblock.len = 0;

    fileblock.fd = open(filename, O_RDONLY,S_IRUSR|S_IWUSR);

    if ( -1==fileblock.fd ) {
        return fileblock;
    }
    
    fstat(fileblock.fd, &s);
    
    if ( 0==s.st_size ) {
        close(fileblock.fd);
        return fileblock;
    }
    
    fileblock.len = (size_t)s.st_size;
    
    fileblock.ptr = mmap(NULL,fileblock.len, PROT_READ,MAP_SHARED,fileblock.fd,0);

    if ( MAP_FAILED == fileblock.ptr ) {
        fileblock.len = 0;
        fileblock.ptr = NULL;
        close(fileblock.fd);
    }

    return fileblock;

}

void fe_munmap(fe_file_block fileblock)
{
    if ( 0==fileblock.len ) {
        return;
    }

    munmap(fileblock.ptr,fileblock.len);
    close(fileblock.fd);
}


char *FE_ROOT_PATH;
char *FE_CACHE_PATH;
char *FE_DOCUMENTS_PATH;
char *FE_TEMP_PATH;

char *fe_getAppPath (const char *basefilename, FEPathType type, char *real_path, size_t *real_path_len_ptr)
{
    switch (type) {

        case FE_ABSOLUTE:
            *real_path_len_ptr = snprintf(real_path, PATH_MAX, "%s", basefilename);
            break;

        case FE_ROOT:
            *real_path_len_ptr = snprintf(real_path, PATH_MAX, "%s%s", FE_ROOT_PATH, basefilename);
            break;
            
        case FE_CACHE:
            *real_path_len_ptr = snprintf(real_path, PATH_MAX, "%s%s", FE_CACHE_PATH, basefilename);
            break;
        case FE_DOCUMENTS:
            *real_path_len_ptr = snprintf(real_path, PATH_MAX, "%s%s", FE_DOCUMENTS_PATH, basefilename);
            break;

        case FE_TEMP:
            *real_path_len_ptr = snprintf(real_path, PATH_MAX, "%s%s", FE_TEMP_PATH, basefilename);
            break;
            
        default:
            return NULL;
            break;
    }

    return real_path;
}

char *fe_getAppPath_dup (const char *basefilename, FEPathType type)
{
    char *real_path;

    size_t real_path_len = PATH_MAX;

    real_path = malloc(PATH_MAX);
    
    fe_getAppPath(basefilename, type, real_path, &real_path_len);

    return real_path;

}


int fe_getTSFilePath(const char *extname, char *file_hash_path, size_t file_hash_path_len,FEPathType type)
{
    int ret;
    
    char basename[PATH_MAX];
    size_t basename_len = PATH_MAX;

    char hexstr[sizeof(uint64_t)*2+1];
    size_t hexstr_len=sizeof(uint64_t)*2+1;
    char hashpathname[PATH_MAX];
    
    uint64_t timestamp_u;

    if (NULL==extname) {
        extname="bin";
    }

    timestamp_u = fe_timestamp_usec();

    ret = fe_bin2hex(&timestamp_u, sizeof(uint64_t), hexstr, hexstr_len);
    
    if ( 0!=ret ) {
        return ret;
    }
    
    basename_len = snprintf(basename, PATH_MAX, "%s.%s", hexstr, extname);
    
    ret = fe_hash_path(basename, basename_len, hashpathname, 2);
    
    if ( 0!=ret ) {
        return ret;
    }
    
    file_hash_path = fe_getAppPath (hashpathname, type, file_hash_path, &file_hash_path_len);

    return 0;

}

char *fe_getTSFilePath_dup(const char *extname, FEPathType type)
{
    int ret;
    
    char *file_hash_path;

    size_t file_hash_path_len;
    
    file_hash_path=malloc(PATH_MAX);
    file_hash_path_len=PATH_MAX;
    
    ret = fe_getTSFilePath(extname, file_hash_path, file_hash_path_len,type);
    
    if (0!=ret) {
        free(file_hash_path);
        return NULL;
    }
    return file_hash_path;
}


int fe_getMD5FilePath(const void *dat, size_t dat_len, const char *prepath, const char *extname, char *file_hash_path, size_t file_hash_path_len,FEPathType type)
{
    int ret;
    char basename[NAME_MAX];
    size_t basename_len = NAME_MAX;
    
    char md5hashname[NAME_MAX];

    char   md5str[FE_MD5_SIZE];
    size_t md5str_len = FE_MD5_SIZE;
    
    if (0==dat_len) {
        dat_len = strlen(dat);
    }

    if (NULL==extname) {
        extname="bin";
    }

    ret = fe_md5_string(dat, dat_len, md5str, &md5str_len);
    
    if ( 0!=ret ) {
        return ret;
    }

    basename_len = snprintf(basename, NAME_MAX, "%s.%s",md5str, extname);

    ret = fe_hash_path(basename, basename_len,md5hashname, 2);

    if ( 0!=ret ) {
        return ret;
    }

    char prepathname[NAME_MAX];
    size_t prepathname_len = NAME_MAX;

    prepathname_len = snprintf(prepathname, NAME_MAX, "/%s%s",prepath, md5hashname);

    file_hash_path = fe_getAppPath (prepathname, type, file_hash_path, &file_hash_path_len);

    return 0;
}

char * fe_getMD5FilePath_dup(const void *dat, size_t dat_len, const char *prepath, const char *extname, FEPathType type)
{
    int ret;
    
    char *file_hash_path;
    
    size_t file_hash_path_len;
    
    file_hash_path=malloc(PATH_MAX);
    file_hash_path_len=PATH_MAX;
    
    ret = fe_getMD5FilePath(dat, dat_len, prepath, extname, file_hash_path, file_hash_path_len, type);

    if (0!=ret) {
        free(file_hash_path);
        return NULL;
    }

    return file_hash_path;

}


//有bug，输入 url字符串 aa，内存越界，size_t str_len = (url+url_len) - last_slash; 为大整数了
char* fe_get_extname_form_url(const char *url, size_t url_len, char *extname, size_t extname_len)
{

    if ( 0==url_len ) {
        url_len = strlen(url);
    }
    
    if (0==url_len) {
        return NULL;
    }
    
    int i;
    
    char *last_slash = NULL;
    
    char *p;
    
    p = (char*)url;

    for ( i=0; i<url_len; i++ )
    {

        if ( '?'==*p ) {
            break;
        }

        if ( '/'==*p ) {
            last_slash = p;
        }

        p++;

    }

    if ( NULL == last_slash ) {
        goto default_extname;
    }
    
    // 最低的要求 /a.b, 相减有可能是负数
    ssize_t str_len = (url+url_len) - last_slash;

    if ( str_len<3 )
    {
        goto default_extname;
    }

    char *first_dot = NULL;

    p = last_slash;
    p++;
    
    for ( i=0; i<str_len; i++ )
    {
        if ('?'==*p) {
            goto default_extname;
        }

        if ( '.'==*p ) {
            first_dot = p;
            break;
        }
        p++;

    }

    str_len -= i;

    if ( NULL==first_dot ) {
        goto default_extname;
    }

    p++;

    memset(extname, 0, extname_len);

    for (i=0; i<str_len; i++) {

        //下一个字符是不是 a-z A-Z 0-9
        if ( !isalnum(*(p)) )
        {
            break;
        }

        if ( i>=extname_len ) {
            break;
        }
        
        extname[i] = *p;
        
        p++;
    }

    return extname;

default_extname:

    memset(extname, 0, extname_len);

    memcpy(extname, "bin", sizeof("bin")-1);
    
    return extname;
}


char* fe_get_cache_file_path(const char *url, size_t url_len, const char *prepath, char *file_path, size_t file_path_len)
{
    char extname_buf[4];
    char *extname;

    extname = fe_get_extname_form_url(url, url_len, extname_buf, 4);

    if ( NULL==extname ) {
        return NULL;
    }

    int ret;

    ret = fe_getMD5FilePath(url, url_len, prepath, extname, file_path, PATH_MAX, FE_CACHE);

    if ( 0!=ret) {
        return NULL;
    }

    return file_path;

}

char* fe_get_temp_file_path(const char *url, size_t url_len, const char *prepath, char *file_path, size_t file_path_len)
{
    char extname_buf[4];
    char *extname;
    
    extname = fe_get_extname_form_url(url, url_len, extname_buf, 4);
    
    if ( NULL==extname ) {
        return NULL;
    }

    int ret;
    
    ret = fe_getMD5FilePath(url, url_len, prepath, extname, file_path, PATH_MAX, FE_TEMP);
    
    if ( 0!=ret) {
        return NULL;
    }
    
    return file_path;
    
}


int fe_clean_dirs(const char * dirname) {

    int ret;

    ret = remove_dirs(dirname);

    return ret;

}

