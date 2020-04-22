/* apk_database.h - Alpine Package Keeper (APK)
 *
 * Copyright (C) 2005-2008 Natanael Copa <n@tanael.org>
 * Copyright (C) 2008-2011 Timo Teräs <timo.teras@iki.fi>
 * All rights reserved.
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License version 2 as published
 * by the Free Software Foundation. See http://www.gnu.org/ for details.
 */

module deimos.apk_toolsd.apk_database;

import core.stdc.config;
import core.stdc.stdint;
import core.sys.posix.sys.types;

import deimos.apk_toolsd.apk_blob;
import deimos.apk_toolsd.apk_hash;
import deimos.apk_toolsd.apk_defines;
import deimos.apk_toolsd.apk_io;
import deimos.apk_toolsd.apk_package;
import deimos.apk_toolsd.apk_provider_data;
import deimos.apk_toolsd.apk_solver_data;

extern (C):
nothrow:

struct apk_name_array
{
    @property apk_name*[] item() nothrow
    {
        return this.m_item.ptr[0 .. this.num];
    }

    size_t num;
    apk_name*[0] m_item;
}

void apk_name_array_init(apk_name_array** a);
void apk_name_array_free(apk_name_array** a);
void apk_name_array_resize(apk_name_array** a, size_t size);
void apk_name_array_copy(apk_name_array** a, apk_name_array* b);
apk_name** apk_name_array_add(apk_name_array** a);

struct apk_db_acl
{
    mode_t mode;
    uid_t uid;
    gid_t gid;
    apk_checksum xattr_csum;
}

struct apk_db_file
{
    import std.bitmanip : bitfields;

    hlist_node hash_node;
    hlist_node diri_files_list;

    apk_db_dir_instance* diri;
    apk_db_acl* acl;

    mixin(bitfields!(ushort, "audited", 1, ushort, "namelen", 15));

    apk_checksum csum;
    char* name;
}

enum apk_protect_mode
{
    APK_PROTECT_NONE = 0,
    APK_PROTECT_CHANGED = 1,
    APK_PROTECT_SYMLINKS_ONLY = 2,
    APK_PROTECT_ALL = 3
}

struct apk_protected_path
{
    import std.bitmanip : bitfields;

    char* relative_pattern;

    mixin(bitfields!(uint, "protect_mode", 3, uint, "", 5));
}

struct apk_protected_path_array
{
    @property apk_protected_path[] item() nothrow
    {
        return this.m_item.ptr[0 .. this.num];
    }

    size_t num;
    apk_protected_path[0] m_item;
}

void apk_protected_path_array_init(apk_protected_path_array** a);
void apk_protected_path_array_free(apk_protected_path_array** a);
void apk_protected_path_array_resize(apk_protected_path_array** a, size_t size);
void apk_protected_path_array_copy(apk_protected_path_array** a, apk_protected_path_array* b);
apk_protected_path* apk_protected_path_array_add(apk_protected_path_array** a);

struct apk_db_dir
{
    import std.bitmanip : bitfields;

    apk_hash_node hash_node;
    c_ulong hash;

    apk_db_dir* parent;
    apk_protected_path_array* protected_paths;
    mode_t mode;
    uid_t uid;
    gid_t gid;

    ushort refs;
    ushort namelen;

    mixin(bitfields!(uint, "protect_mode", 3, uint, "has_protected_children",
            1, uint, "seen", 1, uint, "created", 1, uint, "modified", 1, uint,
            "update_permissions", 1));

    char[1] rooted_name;
    char* name;
}

enum DIR_FILE_FMT = "%s%s%s";

struct apk_db_dir_instance
{
    hlist_node pkg_dirs_list;
    hlist_head owned_files;
    apk_package* pkg;
    apk_db_dir* dir;
    apk_db_acl* acl;
}

struct apk_name
{
    import std.bitmanip : bitfields;

    apk_hash_node hash_node;
    char* name;
    apk_provider_array* providers;
    apk_name_array* rdepends;
    apk_name_array* rinstall_if;

    mixin(bitfields!(uint, "is_dependency", 1, uint, "auto_select_virtual", 1,
            uint, "priority", 2, uint, "", 4));

    uint foreach_genid;

    union
    {
        apk_solver_name_state ss;
        void* state_ptr;
        int state_int;
    }
}

struct apk_repository
{
    const(char)* url;
    apk_checksum csum;
    apk_blob_t description;
}

struct apk_repository_list
{
    list_head list;
    const(char)* url;
}

struct apk_db_options
{
    int lock_wait;
    uint cache_max_age;
    c_ulong open_flags;
    const(char)* root;
    const(char)* arch;
    const(char)* keys_dir;
    const(char)* cache_dir;
    const(char)* repositories_file;
    list_head repository_list;
}

enum APK_REPOSITORY_CACHED = 0;
enum APK_REPOSITORY_FIRST_CONFIGURED = 1;

enum APK_DEFAULT_REPOSITORY_TAG = 0;
enum APK_DEFAULT_PINNING_MASK = BIT(APK_DEFAULT_REPOSITORY_TAG);

struct apk_repository_tag
{
    uint allowed_repos;
    apk_blob_t tag;
    apk_blob_t plain_name;
}

struct apk_database
{
    import std.bitmanip : bitfields;

    char* root;
    int root_fd;
    int lock_fd;
    int cache_fd;
    int keys_fd;
    uint num_repos;
    uint num_repo_tags;
    const(char)* cache_dir;
    char* cache_remount_dir;
    char* root_proc_dir;
    c_ulong cache_remount_flags;
    apk_blob_t* arch;
    uint local_repos;
    uint available_repos;
    uint cache_max_age;
    uint repo_update_errors;
    uint repo_update_counter;
    uint pending_triggers;

    mixin(bitfields!(int, "performing_self_upgrade", 1, int, "permanent", 1,
            int, "autoupdate", 1, int, "open_complete", 1, int,
            "compat_newfeatures", 1, int, "compat_notinstallable", 1, uint, "", 2));

    apk_dependency_array* world;
    apk_protected_path_array* protected_paths;
    apk_repository[APK_MAX_REPOS] repos;
    apk_repository_tag[APK_MAX_TAGS] repo_tags;
    apk_id_cache id_cache;

    struct _Anonymous_0
    {
        apk_hash names;
        apk_hash packages;
    }

    _Anonymous_0 available;

    struct _Anonymous_1
    {
        list_head packages;
        list_head triggers;
        apk_hash dirs;
        apk_hash files;

        struct _Anonymous_2
        {
            uint files;
            uint dirs;
            uint packages;
            size_t bytes;
        }

        _Anonymous_2 stats;
    }

    _Anonymous_1 installed;
}

union apk_database_or_void
{
    apk_database* db;
    void* ptr;
}

alias apk_database_t = apk_database_or_void;

apk_name* apk_db_get_name(apk_database* db, apk_blob_t name);
apk_name* apk_db_query_name(apk_database* db, apk_blob_t name);
int apk_db_get_tag_id(apk_database* db, apk_blob_t tag);

apk_db_dir* apk_db_dir_ref(apk_db_dir* dir);
void apk_db_dir_unref(apk_database* db, apk_db_dir* dir, int allow_rmdir);
apk_db_dir* apk_db_dir_get(apk_database* db, apk_blob_t name);
apk_db_dir* apk_db_dir_query(apk_database* db, apk_blob_t name);
apk_db_file* apk_db_file_query(apk_database* db, apk_blob_t dir, apk_blob_t name);

enum APK_OPENF_READ = 0x0001;
enum APK_OPENF_WRITE = 0x0002;
enum APK_OPENF_CREATE = 0x0004;
enum APK_OPENF_NO_INSTALLED = 0x0010;
enum APK_OPENF_NO_SCRIPTS = 0x0020;
enum APK_OPENF_NO_WORLD = 0x0040;
enum APK_OPENF_NO_SYS_REPOS = 0x0100;
enum APK_OPENF_NO_INSTALLED_REPO = 0x0200;
enum APK_OPENF_CACHE_WRITE = 0x0400;
enum APK_OPENF_NO_AUTOUPDATE = 0x0800;

enum APK_OPENF_NO_REPOS = APK_OPENF_NO_SYS_REPOS | APK_OPENF_NO_INSTALLED_REPO;
enum APK_OPENF_NO_STATE = APK_OPENF_NO_INSTALLED | APK_OPENF_NO_SCRIPTS | APK_OPENF_NO_WORLD;

void apk_db_init(apk_database* db);
int apk_db_open(apk_database* db, apk_db_options* dbopts);
void apk_db_close(apk_database* db);
int apk_db_write_config(apk_database* db);
int apk_db_permanent(apk_database* db);
int apk_db_check_world(apk_database* db, apk_dependency_array* world);
int apk_db_fire_triggers(apk_database* db);
int apk_db_run_script(apk_database* db, char* fn, char** argv);
void apk_db_update_directory_permissions(apk_database* db);

apk_package* apk_db_pkg_add(apk_database* db, apk_package* pkg);
apk_package* apk_db_get_pkg(apk_database* db, apk_checksum* csum);
apk_package* apk_db_get_file_owner(apk_database* db, apk_blob_t filename);

int apk_db_index_read(apk_database* db, apk_istream* is_, int repo);
int apk_db_index_read_file(apk_database* db, const(char)* file, int repo);
int apk_db_index_write(apk_database* db, apk_ostream* os);

int apk_db_add_repository(apk_database_t db, apk_blob_t repository);
apk_repository* apk_db_select_repo(apk_database* db, apk_package* pkg);

int apk_repo_format_cache_index(apk_blob_t to, apk_repository* repo);
int apk_repo_format_item(apk_database* db, apk_repository* repo,
        apk_package* pkg, int* fd, char* buf, size_t len);

uint apk_db_get_pinning_mask_repos(apk_database* db, ushort pinning_mask);

int apk_db_cache_active(apk_database* db);
int apk_cache_download(apk_database* db, apk_repository* repo,
        apk_package* pkg, int verify, int autoupdate, apk_progress_cb cb, void* cb_ctx);

alias apk_cache_item_cb = extern (C) void function(apk_database* db, int dirfd,
        const(char)* name, apk_package* pkg) nothrow;
int apk_db_cache_foreach_item(apk_database* db, apk_cache_item_cb cb);

int apk_db_install_pkg(apk_database* db, apk_package* oldpkg,
        apk_package* newpkg, apk_progress_cb cb, void* cb_ctx);

alias apkNameForeachMatchingCallback = extern (C) void function(apk_database* db,
        const(char)* match, apk_name* name, void* ctx) nothrow;
void apk_name_foreach_matching(apk_database* db, apk_string_array* filter,
        uint match, apkNameForeachMatchingCallback cb, void* ctx);
