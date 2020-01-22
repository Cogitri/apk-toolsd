/* apk_blob.h - Alpine Package Keeper (APK)
 *
 * Copyright (C) 2005-2008 Natanael Copa <n@tanael.org>
 * Copyright (C) 2008-2011 Timo Teräs <timo.teras@iki.fi>
 * All rights reserved.
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License version 2 as published
 * by the Free Software Foundation. See http://www.gnu.org/ for details.
 */

import core.stdc.config;
import core.stdc.stdlib;

extern (C):

alias apk_spn_match = const(ubyte)*;
alias apk_spn_match_def = ubyte[32];

struct apk_blob
{
    c_long len;
    char* ptr;
}

alias apk_blob_t = apk_blob;
alias apk_blob_cb = int function (void* ctx, apk_blob_t blob);
extern __gshared apk_blob_t apk_null_blob;

enum BLOB_FMT = "%.*s";

enum APK_CHECKSUM_NONE = 0;
enum APK_CHECKSUM_MD5 = 16;
enum APK_CHECKSUM_SHA1 = 20;
enum APK_CHECKSUM_DEFAULT = APK_CHECKSUM_SHA1;

enum APK_BLOB_CHECKSUM_BUF = 34;

/* Internal cointainer for MD5 or SHA1 */
struct apk_checksum
{
    ubyte[20] data;
    ubyte type;
}

const(EVP_MD)* apk_checksum_evp (int type);

const(EVP_MD)* apk_checksum_default ();

extern (D) auto APK_BLOB_IS_NULL(T)(auto ref T blob)
{
    return blob.ptr == NULL;
}

extern (D) auto APK_BLOB_PTR_PTR(T0, T1)(auto ref T0 beg, auto ref T1 end)
{
    return APK_BLOB_PTR_LEN(beg, end - beg + 1);
}

apk_blob_t APK_BLOB_STR (const(char)* str);

apk_blob_t apk_blob_trim (apk_blob_t blob);

char* apk_blob_cstr (apk_blob_t str);
int apk_blob_spn (apk_blob_t blob, const apk_spn_match accept, apk_blob_t* l, apk_blob_t* r);
int apk_blob_cspn (apk_blob_t blob, const apk_spn_match reject, apk_blob_t* l, apk_blob_t* r);
int apk_blob_split (apk_blob_t blob, apk_blob_t split, apk_blob_t* l, apk_blob_t* r);
int apk_blob_rsplit (apk_blob_t blob, char split, apk_blob_t* l, apk_blob_t* r);
apk_blob_t apk_blob_pushed (apk_blob_t buffer, apk_blob_t left);
c_ulong apk_blob_hash_seed (apk_blob_t, c_ulong seed);
c_ulong apk_blob_hash (apk_blob_t str);
int apk_blob_compare (apk_blob_t a, apk_blob_t b);
int apk_blob_ends_with (apk_blob_t str, apk_blob_t suffix);
int apk_blob_for_each_segment (
    apk_blob_t blob,
    const(char)* split,
    apk_blob_cb cb,
    void* ctx);

void apk_blob_checksum (apk_blob_t b, const(EVP_MD)* md, apk_checksum* csum);
char* apk_blob_chr (apk_blob_t b, ubyte ch);

const int apk_checksum_compare (const(apk_checksum)* a, const(apk_checksum)* b);

void apk_blob_push_blob (apk_blob_t* to, apk_blob_t literal);
void apk_blob_push_uint (apk_blob_t* to, uint value, int radix);
void apk_blob_push_csum (apk_blob_t* to, apk_checksum* csum);
void apk_blob_push_base64 (apk_blob_t* to, apk_blob_t binary);
void apk_blob_push_hexdump (apk_blob_t* to, apk_blob_t binary);

void apk_blob_pull_char (apk_blob_t* b, int expected);
uint apk_blob_pull_uint (apk_blob_t* b, int radix);
void apk_blob_pull_csum (apk_blob_t* b, apk_checksum* csum);
void apk_blob_pull_base64 (apk_blob_t* b, apk_blob_t to);
void apk_blob_pull_hexdump (apk_blob_t* b, apk_blob_t to);
int apk_blob_pull_blob_match (apk_blob_t* b, apk_blob_t match);

void apk_atom_init ();
apk_blob_t* apk_blob_atomize (apk_blob_t blob);
apk_blob_t* apk_blob_atomize_dup (apk_blob_t blob);

