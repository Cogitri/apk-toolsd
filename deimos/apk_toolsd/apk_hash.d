/* apk_hash.h - Alpine Package Keeper (APK)
 *
 * Copyright (C) 2005-2008 Natanael Copa <n@tanael.org>
 * Copyright (C) 2008-2011 Timo Teräs <timo.teras@iki.fi>
 * All rights reserved.
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License version 2 as published
 * by the Free Software Foundation. See http://www.gnu.org/ for details.
 */

module deimos.apk_toolsd.apk_hash;

import core.stdc.config;

import deimos.apk_toolsd.apk_defines;
import deimos.apk_toolsd.apk_blob;

extern (C):
nothrow:

alias apk_hash_item = void*;

alias apk_hash_f = extern (C) c_ulong function(apk_blob_t) nothrow;
alias apk_hash_compare_f = extern (C) int function(apk_blob_t, apk_blob_t) nothrow;
alias apk_hash_compare_item_f = extern (C) int function(apk_hash_item, apk_blob_t) nothrow;
alias apk_hash_delete_f = extern (C) void function(apk_hash_item) nothrow;
alias apk_hash_enumerator_f = extern (C) int function(apk_hash_item, void* ctx) nothrow;

struct apk_hash_ops
{
    ptrdiff_t node_offset;
    extern (C) apk_blob_t function(apk_hash_item item) nothrow get_key;
    extern (C) c_ulong function(apk_blob_t key) nothrow hash_key;
    extern (C) c_ulong function(apk_hash_item item) nothrow hash_item;
    extern (C) int function(apk_blob_t itemkey, apk_blob_t key) nothrow compare;
    extern (C) int function(apk_hash_item item, apk_blob_t key) nothrow compare_item;
    extern (C) void function(apk_hash_item item) nothrow delete_item;
}

alias apk_hash_node = hlist_node;

struct apk_hash_array
{
    hlist_head[] item(size_t length)
    {
        return m_item.ptr[0 .. length];
    }

    size_t num;
    hlist_head[0] m_item;
}

void apk_hash_array_init(apk_hash_array** a);
void apk_hash_array_free(apk_hash_array** a);
void apk_hash_array_resize(apk_hash_array** a, size_t size);
void apk_hash_array_copy(apk_hash_array** a, apk_hash_array* b);
hlist_head* apk_hash_array_add(apk_hash_array** a);

struct apk_hash
{
    const(apk_hash_ops)* ops;
    apk_hash_array* buckets;
    int num_items;
}

void apk_hash_init(apk_hash* h, const(apk_hash_ops)* ops, int num_buckets);
void apk_hash_free(apk_hash* h);

int apk_hash_foreach(apk_hash* h, apk_hash_enumerator_f e, void* ctx);
apk_hash_item apk_hash_get_hashed(apk_hash* h, apk_blob_t key, c_ulong hash);
void apk_hash_insert_hashed(apk_hash* h, apk_hash_item item, c_ulong hash);
void apk_hash_delete_hashed(apk_hash* h, apk_blob_t key, c_ulong hash);

c_ulong apk_hash_from_key(apk_hash* h, apk_blob_t key);

c_ulong apk_hash_from_item(apk_hash* h, apk_hash_item item);

apk_hash_item apk_hash_get(apk_hash* h, apk_blob_t key);

void apk_hash_insert(apk_hash* h, apk_hash_item item);

void apk_hash_delete(apk_hash* h, apk_blob_t key);
