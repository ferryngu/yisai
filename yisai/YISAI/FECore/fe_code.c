//
//  fe_code.c
//  FECore
//
//  Created by apps on 14-4-25.
//  Copyright (c) 2014年 apps. All rights reserved.
//

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <math.h>
#include <assert.h>


#include "openssl/evp.h"
#include <openssl/md5.h>
#include <openssl/x509v3.h>


#include "fe_code.h"

static const char *bin2hex_convtab = "0123456789abcdef";

int fe_bin2hex_r(void *bin, ssize_t bin_len, char *hexstr, ssize_t hexstr_len)
{
    
    int i;

    if ( hexstr_len < bin_len*2 ) {
        return BIN2HEX_BUF_NOT_ENOUGH;
    }
    
    hexstr[hexstr_len-1]='\0';
    
    hexstr += (hexstr_len-2);

    for ( i=0; i<bin_len; i++ ) {

        *hexstr = bin2hex_convtab[ *(unsigned char *)bin & 0xF ];
        hexstr--;

        *hexstr = bin2hex_convtab[ *(unsigned char *)bin >>4 ];
        hexstr--;

        bin++;
        
    }

    return BIN2HEX_OK;

}

int fe_bin2hex(void *bin, ssize_t bin_len, char *hexstr, ssize_t hexstr_len)
{
    int i;
    char *p;
    if ( hexstr_len < bin_len*2 ) {
        return BIN2HEX_BUF_NOT_ENOUGH;
    }
    
    p=hexstr;
    
    for ( i=0; i<bin_len; i++ ) {
        *p++ = bin2hex_convtab[ *(unsigned char *)bin & 0xF ];
        *p++ = bin2hex_convtab[ *(unsigned char *)bin >>4 ];
        bin++;
    }

    hexstr[hexstr_len-4]='\0';

    return BIN2HEX_OK;

}

int fe_md5_string(const void *in, size_t dat_len, char *out, size_t *out_len) {

    unsigned char md[MD5_DIGEST_LENGTH];
    
    if ( *out_len <= MD5_DIGEST_LENGTH*2 ) {
        return -1;
    }

    MD5((const unsigned char*)in,dat_len,md);

    fe_bin2hex(md,MD5_DIGEST_LENGTH, out, MD5_DIGEST_LENGTH*2);
    out[MD5_DIGEST_LENGTH*2]='\0';

    *out_len=MD5_DIGEST_LENGTH*2;
    
    return 0;
}

char *fe_md5_string_dup(const void *in, size_t dat_len, char *out, size_t *out_len) {

    char *md5hex;
    size_t md5hex_len = MD5_DIGEST_LENGTH*2;
    int ret;

    md5hex = malloc(MD5_DIGEST_LENGTH*2);

    ret = fe_md5_string(in, dat_len, md5hex, &md5hex_len);

    if ( 0!=ret) {
        free(md5hex);
        return NULL;
    }

    return md5hex;

}


unsigned char* fe_base64_encode_dup(const char *de_string, size_t de_length, size_t *en_length_ptr)
{
    
    size_t des_length;

    unsigned char* des;
    
    des_length = de_length * (de_length+4)/2;
    
    des = (unsigned char*) malloc(des_length);
    
    *en_length_ptr = EVP_EncodeBlock((unsigned char*)des, (const unsigned char*)de_string, (int)de_length);

    if (*en_length_ptr<=0) {
        return NULL;
    }
    
    return des;
    
}

unsigned char* fe_base64_decode_dup(unsigned char *en_string, size_t en_length, size_t *de_length_ptr)
{

    unsigned char* de_string;

    de_string =(unsigned char*) malloc(en_length);
    
    *de_length_ptr = EVP_DecodeBlock((unsigned char*)de_string, (const unsigned char*)en_string, (int)en_length);
    
    if (*de_length_ptr<=0) {
        return NULL;
    }

    return de_string;
    
}


////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////


/****************** base62 ******************/

static const char base62_vals[] = "0123456789"
                                  "abcdefghijklmnopqrstuvwxyz"
                                  "ABCDEFGHIJKLMNOPQRSTUVWXYZ";



static const int base62_index[] = {
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09,    0,    0,
    0,    0,    0,    0,    0, 0x24, 0x25, 0x26, 0x27, 0x28, 0x29, 0x2a,
    0x2b, 0x2c, 0x2d, 0x2e, 0x2f, 0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36,
    0x37, 0x38, 0x39, 0x3a, 0x3b, 0x3c, 0x3d,    0,    0,    0,    0,    0,
    0, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f, 0x10, 0x11, 0x12, 0x13, 0x14,
    0x15, 0x16, 0x17, 0x18, 0x19, 0x1a, 0x1b, 0x1c, 0x1d, 0x1e, 0x1f, 0x20,
    0x21, 0x22, 0x23,
};



static void strreverse_inplace (char *str)
{
    
    char c;
    size_t half;
    size_t len;
    int i;
    
    assert(str);
    
    len = strlen(str);
    half = len >> 1;
    for (i = 0; i < half; i++) {
        c = str[i];
        str[i] = str[len - i - 1];
        str[len - i - 1] = c;
    }
    
}


int base62_encode ( u_int64_t  val,  /* IN */
                    char      *str,  /* OUT */
                    size_t     len ) /* IN */
{
    int i = 0;
    int v;
    
    assert(str);
    assert(len > 0);
    
    do {
        if (i + 1 >= len){
            return 0;
        }

        v = val % 62;
        str[i++] = base62_vals[v];
        val = (val - v) / 62;
    } while (val > 0);

    str[i] = '\0';
    
    strreverse_inplace(str);

    return i;
}


u_int64_t base62_decode (const char *str) /* IN */
{
    u_int64_t val = 0;
    char c;
    size_t len;
    int i;

    assert(str);
    
    len = strlen(str);

    for (i = 0; i < len; i++) {

        c = str[i];

        if (!isalnum(c)) {
            return -1;
        }

        val += base62_index[c] * powl(62, len - i - 1);
    }

    return val;

}





/*

int32_t fe_base64_decode(const char *encoded, int encoded_length, char *decoded)
{
    return EVP_DecodeBlock((unsigned char*)decoded, (const unsigned char*)encoded, encoded_length);
}

*/

/*
 
 LITTLE_ENDIAN
 
 
 *tmp++ = set[ (*buf) >> 4 ];
 *tmp++ = set[ (*buf) & 0xF ];
 buf ++;
 
 char *buf1 = "Hello,OpenSSL\n";
 echo "Hello,OpenSSL" | md5sum
 
 97aa490ee85f397134404f7bb524b587
 97aa490ee85f397134404f7bb524b587
*/