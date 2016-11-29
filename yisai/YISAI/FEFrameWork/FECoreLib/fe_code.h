//
//  fecode.h
//  FECore
//
//  Created by apps on 14-6-19.
//  Copyright (c) 2014年 apps. All rights reserved.
//

#ifndef FECore_fecode_h
#define FECore_fecode_h
#include <sys/types.h>

enum {
    BIN2HEX_OK=0,
    BIN2HEX_BUF_NOT_ENOUGH
};

#define FE_MD5_SIZE 16*2+1

int fe_bin2hex(void *bin, ssize_t bin_len, char *hexstr, ssize_t hex_len);
int fe_bin2hex_r(void *bin, ssize_t bin_len, char *hexstr, ssize_t hex_len);

int fe_md5_string(const void *in, size_t dat_len, char *out, size_t *out_len);
char *fe_md5_string_dup(const void *in, size_t dat_len, char *out, size_t *out_len);

unsigned char* fe_base64_encode_dup(const char *de_string, size_t de_length, size_t *en_length_ptr);
unsigned char* fe_base64_decode_dup(unsigned char *en_string, size_t en_length, size_t *de_length_ptr);


int base62_encode ( u_int64_t  val,  /* IN */
                    char      *str,  /* OUT */
                    size_t     len); /* IN */

u_int64_t base62_decode (const char *str);

#endif
