//
//  FEFile.h
//  FECore
//
//  Created by apps on 14-4-26.
//  Copyright (c) 2014年 apps. All rights reserved.
//

#ifndef FECore_FEFile_h
#define FECore_FEFile_h

#include <unistd.h>

typedef enum {
    FE_ABSOLUTE,
    FE_ROOT,
    FE_CACHE,
    FE_DOCUMENTS,
    FE_TEMP
}FEPathType;

int fe_rename(const char *src, const char *dst);

int fe_file_unlink_expire(const char *filename, int expire_sec);

int fe_file_exist(const char *filename);

long long fe_file_size(const char *filename);

char *fe_file_extname(const char *filename, size_t len);

char *fe_file_extname_dup(const char *filename, size_t len);

char *fe_file_basename(const char *filename, size_t len);

char *fe_file_basename_dup(const char *filename, size_t len);

char *fe_file_path_cut(char *filename, size_t len);

char *fe_file_path_dup(const char *filename, size_t len);

char *fe_hash_path_dup(const char *filename, size_t levels);

int fe_hash_path(const char *filename, size_t filename_len, char *hash_path, size_t levels);

long long file_size ( int fd );

int fe_read_file( const char *filename, void *buf, ssize_t *buf_len );

int fe_write_file( const char *filename, void *buf, ssize_t len );

int fe_create_file(const char *filename);

int fe_createAppfile(const char *filename,FEPathType type);

void fe_unlinkAppfile(const char *filename,FEPathType type);

int fe_AppfileExist(const char *filename, FEPathType type);

typedef struct _fe_file_block {
    size_t len;
    void *ptr;
    int fd;
}fe_file_block;

fe_file_block fe_mmap(const char *filename);
void fe_munmap(fe_file_block fileblock);

char *fe_getAppPath (const char *basefilename, FEPathType type, char *real_path, size_t *real_path_len_ptr);

char *fe_getAppPath_dup (const char *basefilename, FEPathType type);

int fe_getTSFilePath(const char *extname, char *file_hash_path, size_t file_hash_path_len,FEPathType type);

char *fe_getTSFilePath_dup(const char *extname, FEPathType type);

int fe_getMD5FilePath(const void *dat, size_t dat_len, const char *prepath, const char *extname, char *file_hash_path, size_t file_hash_path_len,FEPathType type);
//int fe_getMD5FilePath(const void *dat, size_t dat_len, const char *extname, char *file_hash_path, size_t file_hash_path_len,FEPathType type);
char * fe_getMD5FilePath_dup(const void *dat, size_t dat_len, const char *prepath, const char *extname, FEPathType type);
//char * fe_getMD5FilePath_dup(const void *dat, size_t dat_len, const char *extname, FEPathType type);

char* fe_get_extname_form_url(const char *url, size_t url_len, char *extname, size_t extname_len);

char* fe_get_cache_file_path(const char *url, size_t url_len, const char *prepath, char *file_path, size_t file_path_len);

char* fe_get_temp_file_path(const char *url, size_t url_len, const char *prepath, char *file_path, size_t file_path_len);

int fe_clean_dirs(const char * dirname);

int fe_file_remove(const char *filepath);

extern char *FE_ROOT_PATH;
extern char *FE_CACHE_PATH;
extern char *FE_DOCUMENTS_PATH;
extern char *FE_TEMP_PATH;


#endif
