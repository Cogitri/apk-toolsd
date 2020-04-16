/* apk_defines.c - Alpine Package Keeper (APK)
 *
 * Copyright (C) 2005-2008 Natanael Copa <n@tanael.org>
 * Copyright (C) 2008-2011 Timo Teräs <timo.teras@iki.fi>
 * All rights reserved.
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License version 2 as published
 * by the Free Software Foundation. See http://www.gnu.org/ for details.
 */

module deimos.apk_toolsd.apk_defines;

import core.stdc.config;
import core.stdc.time;

extern (C):
nothrow:

extern (D) size_t ARRAY_SIZE(T)(auto ref T x)
{
    return x.sizeof / (x[0]).sizeof;
}

extern (D) auto BIT(T)(auto ref T x)
{
    return 1 << x;
}

extern (D) auto min(T0, T1)(auto ref T0 a, auto ref T1 b)
{
    return a < b ? a : b;
}

extern (D) auto max(T0, T1)(auto ref T0 a, auto ref T1 b)
{
    return a > b ? a : b;
}

enum TRUE = 1;

enum FALSE = 0;

enum EAPKBADURL = 1024;
enum EAPKSTALEINDEX = 1025;

void* ERR_PTR(c_long error);
void* ERR_CAST(const(void)* ptr);
int PTR_ERR(const(void)* ptr);
int IS_ERR(const(void)* ptr);
int IS_ERR_OR_NULL(const(void)* ptr);

extern (D) auto likely(T)(auto ref T x)
{
    return __builtin_expect(!!x, 1);
}

extern (D) auto unlikely(T)(auto ref T x)
{
    return __builtin_expect(!!x, 0);
}

extern __gshared int apk_verbosity;
extern __gshared uint apk_flags;
extern __gshared uint apk_force;
extern __gshared const(char)* apk_arch;
extern __gshared char** apk_argv;

enum APK_SIMULATE = 0x0002;
enum APK_CLEAN_PROTECTED = 0x0004;
enum APK_PROGRESS = 0x0008;
enum APK_RECURSIVE = 0x0020;
enum APK_ALLOW_UNTRUSTED = 0x0100;
enum APK_PURGE = 0x0200;
enum APK_INTERACTIVE = 0x0400;
enum APK_NO_NETWORK = 0x1000;
enum APK_OVERLAY_FROM_STDIN = 0x2000;
enum APK_NO_SCRIPTS = 0x4000;
enum APK_NO_CACHE = 0x8000;
enum APK_NO_COMMIT_HOOKS = 0x00010000;

enum APK_FORCE_OVERWRITE = BIT(0);
enum APK_FORCE_OLD_APK = BIT(1);
enum APK_FORCE_BROKEN_WORLD = BIT(2);
enum APK_FORCE_REFRESH = BIT(3);
enum APK_FORCE_NON_REPOSITORY = BIT(4);
enum APK_FORCE_BINARY_STDOUT = BIT(5);

/* default architecture for APK packages. */
enum APK_DEFAULT_ARCH = "x86_64";

enum APK_MAX_REPOS = 32; /* see struct apk_package */
enum APK_MAX_TAGS = 16; /* see solver; unsigned short */
enum APK_CACHE_CSUM_BYTES = 4;

time_t apk_time();

size_t apk_calc_installed_size(size_t size);
size_t muldiv(size_t a, size_t b, size_t c);
size_t mulmod(size_t a, size_t b, size_t c);

alias apk_progress_cb = extern (C) void function(void* cb_ctx, size_t) nothrow;

void* apk_array_resize(void* array, size_t new_size, size_t elem_size);

struct apk_string_array
{
    char*[] item(size_t length)
    {
        return m_item.ptr[0 .. length];
    }

    size_t num;
    char*[0] m_item;
}

void apk_string_array_init(apk_string_array** a);
void apk_string_array_free(apk_string_array** a);
void apk_string_array_resize(apk_string_array** a, size_t size);
void apk_string_array_copy(apk_string_array** a, apk_string_array* b);
char** apk_string_array_add(apk_string_array** a);

enum LIST_END = cast(void*) 0xe01;
enum LIST_POISON1 = cast(void*) 0xdeadbeef;
enum LIST_POISON2 = cast(void*) 0xabbaabba;

struct hlist_head
{
    hlist_node* first;
}

struct hlist_node
{
    hlist_node* next;
}

int hlist_empty(const(hlist_head)* h);

int hlist_hashed(const(hlist_node)* n);

void __hlist_del(hlist_node* n, hlist_node** pprev);

void hlist_del(hlist_node* n, hlist_head* h);

void hlist_add_head(hlist_node* n, hlist_head* h);

void hlist_add_after(hlist_node* n, hlist_node** prev);

hlist_node** hlist_tail_ptr(hlist_head* h);

struct list_head
{
    list_head* next;
    list_head* prev;
}

void list_init(list_head* list);

void __list_add(list_head* new_, list_head* prev, list_head* next);

void list_add(list_head* new_, list_head* head);

void list_add_tail(list_head* new_, list_head* head);

void __list_del(list_head* prev, list_head* next);

void list_del(list_head* entry);

void list_del_init(list_head* entry);

int list_hashed(const(list_head)* n);

int list_empty(const(list_head)* n);

list_head* __list_pop(list_head* head);
