/* apk_io.h - Alpine Package Keeper (APK)
 *
 * Copyright (C) 2008-2011 Timo Teräs <timo.teras@iki.fi>
 * All rights reserved.
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License version 2 as published
 * by the Free Software Foundation. See http://www.gnu.org/ for details.
 */

import core.stdc.stdint;

extern (C):

struct apk_id_cache
{
    int root_fd;
    uint genid;
    apk_hash uid_cache;
    apk_hash gid_cache;
}

struct apk_xattr
{
    const(char)* name;
    apk_blob_t value;
}

struct apk_xattr_array
{
    size_t num;
    apk_xattr[] item;
}

void apk_xattr_array_init (apk_xattr_array** a);
void apk_xattr_array_free (apk_xattr_array** a);
void apk_xattr_array_resize (apk_xattr_array** a, size_t size);
void apk_xattr_array_copy (apk_xattr_array** a, apk_xattr_array* b);
apk_xattr* apk_xattr_array_add (apk_xattr_array** a);

struct apk_file_meta
{
    time_t mtime;
    time_t atime;
}

void apk_file_meta_to_fd (int fd, apk_file_meta* meta);

struct apk_file_info
{
    char* name;
    char* link_target;
    char* uname;
    char* gname;
    off_t size;
    uid_t uid;
    gid_t gid;
    mode_t mode;
    time_t mtime;
    dev_t device;
    apk_checksum csum;
    apk_checksum xattr_csum;
    apk_xattr_array* xattrs;
}

extern __gshared size_t apk_io_bufsize;

struct apk_istream_ops
{
    void function (apk_istream* is_, apk_file_meta* meta) get_meta;
    ssize_t function (apk_istream* is_, void* ptr, size_t size) read;
    void function (apk_istream* is_) close;
}

enum APK_ISTREAM_SINGLE_READ = 0x0001;

struct apk_istream
{
    ubyte* ptr;
    ubyte* end;
    ubyte* buf;
    size_t buf_size;
    int err;
    uint flags;
    const(apk_istream_ops)* ops;
}

apk_istream* apk_istream_from_file (int atfd, const(char)* file);
apk_istream* apk_istream_from_file_gz (int atfd, const(char)* file);
apk_istream* apk_istream_from_fd (int fd);
apk_istream* apk_istream_from_fd_url_if_modified (int atfd, const(char)* url, time_t since);
apk_istream* apk_istream_from_url_gz (const(char)* url);
ssize_t apk_istream_read (apk_istream* is_, void* ptr, size_t size);
apk_blob_t apk_istream_get (apk_istream* is_, size_t len);
apk_blob_t apk_istream_get_all (apk_istream* is_);
apk_blob_t apk_istream_get_delim (apk_istream* is_, apk_blob_t token);

enum APK_SPLICE_ALL = 0xffffffff;
ssize_t apk_istream_splice (
    apk_istream* is_,
    int fd,
    size_t size,
    apk_progress_cb cb,
    void* cb_ctx);

apk_istream* apk_istream_from_url (const(char)* url);
apk_istream* apk_istream_from_fd_url (int atfd, const(char)* url);
apk_istream* apk_istream_from_url_if_modified (const(char)* url, time_t since);
void apk_istream_get_meta (apk_istream* is_, apk_file_meta* meta);
void apk_istream_close (apk_istream* is_);

enum APK_MPART_DATA = 1; /* data processed so far */
enum APK_MPART_BOUNDARY = 2; /* final part of data, before boundary */
enum APK_MPART_END = 3; /* signals end of stream */

alias apk_multipart_cb = int function (void* ctx, int part, apk_blob_t data);

apk_istream* apk_istream_gunzip_mpart (
    apk_istream*,
    apk_multipart_cb cb,
    void* ctx);
apk_istream* apk_istream_gunzip (apk_istream* is_);

struct apk_segment_istream
{
    apk_istream is_;
    apk_istream* pis;
    size_t bytes_left;
    time_t mtime;
}

apk_istream* apk_istream_segment (apk_segment_istream* sis, apk_istream* is_, size_t len, time_t mtime);
apk_istream* apk_istream_tee (
    apk_istream* from,
    int atfd,
    const(char)* to,
    int copy_meta,
    apk_progress_cb cb,
    void* cb_ctx);

struct apk_ostream_ops
{
    ssize_t function (apk_ostream* os, const(void)* buf, size_t size) write;
    int function (apk_ostream* os) close;
}

struct apk_ostream
{
    const(apk_ostream_ops)* ops;
}

apk_ostream* apk_ostream_gzip (apk_ostream*);
apk_ostream* apk_ostream_counter (off_t*);
apk_ostream* apk_ostream_to_fd (int fd);
apk_ostream* apk_ostream_to_file (int atfd, const(char)* file, const(char)* tmpfile, mode_t mode);
apk_ostream* apk_ostream_to_file_gz (int atfd, const(char)* file, const(char)* tmpfile, mode_t mode);
size_t apk_ostream_write_string (apk_ostream* ostream, const(char)* string);
ssize_t apk_ostream_write (apk_ostream* os, const(void)* buf, size_t size);
int apk_ostream_close (apk_ostream* os);

apk_blob_t apk_blob_from_istream (apk_istream* istream, size_t size);
apk_blob_t apk_blob_from_file (int atfd, const(char)* file);

enum APK_BTF_ADD_EOL = 0x00000001;
int apk_blob_to_file (int atfd, const(char)* file, apk_blob_t b, uint flags);

enum APK_FI_NOFOLLOW = 0x80000000;

extern (D) auto APK_FI_XATTR_CSUM(T)(auto ref T x)
{
    return (x & 0xff) << 8;
}

extern (D) auto APK_FI_CSUM(T)(auto ref T x)
{
    return (x & 0xff);
}

int apk_fileinfo_get (
    int atfd,
    const(char)* filename,
    uint flags,
    apk_file_info* fi);
void apk_fileinfo_hash_xattr (apk_file_info* fi);
void apk_fileinfo_free (apk_file_info* fi);

alias apk_dir_file_cb = int function (void* ctx, int dirfd, const(char)* entry);
int apk_dir_foreach_file (int dirfd, int function () cb, void* ctx);

const(char)* apk_url_local_file (const(char)* url);

void apk_id_cache_init (apk_id_cache* idc, int root_fd);
void apk_id_cache_free (apk_id_cache* idc);
void apk_id_cache_reset (apk_id_cache* idc);
uid_t apk_resolve_uid (apk_id_cache* idc, const(char)* username, uid_t default_uid);
uid_t apk_resolve_gid (apk_id_cache* idc, const(char)* groupname, uid_t default_gid);

