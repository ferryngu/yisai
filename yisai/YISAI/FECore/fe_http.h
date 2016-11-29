//
//  fe_http.h
//  FECoreHttp
//
//  Created by apps on 15/5/5.
//  Copyright (c) 2015年 apps. All rights reserved.
//

#ifndef __FECoreHttp__fe_http__
#define __FECoreHttp__fe_http__

#include <stdio.h>


#define FE_HTTP_MAX_PARAM_SIZE    256
#define FE_HTTP_USERAGENT         "FEHttp/1.0"


#define FE_HTTP_STATUS_INIT       0x0
#define FE_HTTP_STATUS_PROGRESS   0x1
#define FE_HTTP_STATUS_INTERRUPT  0x1 << 1
#define FE_HTTP_STATUS_CANCEL     0x1 << 2
#define FE_HTTP_STATUS_CACHEHIT   0x1 << 3
#define FE_HTTP_STATUS_FINISH     0x1 << 4
#define FE_HTTP_STATUS_ERROR      0x1 << 5


#define FE_HTTP_ERROR_NONE           0
#define FE_HTTP_ERROR_CONNECT        1
#define FE_HTTP_ERROR_RESOLVE        2
#define FE_HTTP_ERROR_CANCEL         3
#define FE_HTTP_ERROR_INTERRUPT      4
#define FE_HTTP_ERROR_40X            5
#define FE_HTTP_ERROR_50X            6
#define FE_HTTP_ERROR_TIMEOUT        7
#define FE_HTTP_ERROR_CREATEFILE     8
#define FE_HTTP_ERROR_FILESYSTEM     9
#define FE_HTTP_ERROR_ADDQUEUE       10
#define FE_HTTP_ERROR_NETWORK        11
#define FE_HTTP_ERROR_OTHER          12


#define FE_HTTP_DEFAULT_ZERO_FILE_EXPIRE_SEC 30

#define FE_HTTP_MAX_URL_LENGHT          2048
#define FE_HTTP_DEFAULT_CONTENT_LENGHT  4*1024*1024
#define FE_HTTP_DEFAULT_TIMEOUT_MS      120*1000

/*
用于设置 http 参数的全局变量，初始值分别为
FE_HTTP_MAX_URL_LENGHT
FE_HTTP_DEFAULT_CONTENT_LENGHT
FE_HTTP_DEFAULT_TIMEOUT_MS
*/
extern int fe_http_max_url_lenght;
extern int fe_http_default_content_lenght;
extern int fe_http_default_timeout_ms;


/*http request全局变量，级别越高，打印的log越多*/
#define FE_HTTP_REQUEST_DEBUG_LEVEL_0     0
#define FE_HTTP_REQUEST_DEBUG_LEVEL_1     1
#define FE_HTTP_REQUEST_DEBUG_LEVEL_2     2
extern int fe_http_request_debug_level;


/*http fetch全局变量，级别越高，打印的log越多*/
#define FE_HTTP_FETCH_DEBUG_LEVEL_0     0
#define FE_HTTP_FETCH_DEBUG_LEVEL_1     1
#define FE_HTTP_FETCH_DEBUG_LEVEL_2     2
#define FE_HTTP_FETCH_DEBUG_LEVEL_3     3
#define FE_HTTP_FETCH_DEBUG_LEVEL_4     4
#define FE_HTTP_FETCH_DEBUG_LEVEL_5     5

extern int fe_http_fetch_debug_level;


#define FE_HTTP_GETPARAM           0  // 普通 post参数, key为表单名, value 为填充到表单的文本内容, udata 无效
#define FE_HTTP_POSTPARAM          1  // 普通 post参数, key为表单名, value 为填充到表单的文本内容, udata 无效
#define FE_HTTP_UPLOADFILEPATH     2  // key 为上传的表单名(这里是文件名),value 为上传的文件路径名,udata 无效

#define FE_HTTP_UPLOADFILEBUFFER   3  // key 为上传的表单名,value 为表单中的filename, udata 填充到表单的二进制内容。用于上传内存中的数据。
#define FE_HTTP_UPLOADBINDATA      4  // key 为上传的表单名,value 无效,udata 填充到表单的二进制内容。用于上传内存中的数据。
#define FE_HTTP_UPLOADCALLBACKDATA 5  // 这个类型被设置的时候，上传的内容需要通过回调获得，key 为上传的表单名(这里是文件名), value 为表单中的filename, udata 为上传回调的上下文

#define FE_HTTP_CACHE_PREFIX "fehttp"

#define FE_MAX_MULTI_TASK 10

typedef struct _fe_http_param {
    
    int type;
    
    char *key;
    char *value;
    
    void *udata;
    ssize_t udata_len;
    
}fe_http_param;

void fe_http_init_once();
void fe_clean_http_cache();

void fe_clean_http_temp_dir();

char *fe_http_fetch_cache_file_path_dup(const char *url);

#endif /* defined(__FECoreHttp__fe_http__) */
