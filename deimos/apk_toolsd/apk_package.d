/* apk_package.h - Alpine Package Keeper (APK)
 *
 * Copyright (C) 2005-2008 Natanael Copa <n@tanael.org>
 * Copyright (C) 2008-2011 Timo Teräs <timo.teras@iki.fi>
 * All rights reserved.
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License version 2 as published
 * by the Free Software Foundation. See http://www.gnu.org/ for details.
 */

module deimos.apk_toolsd.apk_package;

import core.stdc.time;
import core.stdc.stdint;

import deimos.openssl.evp;
import deimos.openssl.ossl_typ;

import deimos.apk_toolsd.apk_blob;
import deimos.apk_toolsd.apk_database;
import deimos.apk_toolsd.apk_defines;
import deimos.apk_toolsd.apk_hash;
import deimos.apk_toolsd.apk_io;
import deimos.apk_toolsd.apk_provider_data;
import deimos.apk_toolsd.apk_solver_data;

extern (C):
nothrow:

enum APK_SCRIPT_INVALID = -1;
enum APK_SCRIPT_PRE_INSTALL = 0;
enum APK_SCRIPT_POST_INSTALL = 1;
enum APK_SCRIPT_PRE_DEINSTALL = 2;
enum APK_SCRIPT_POST_DEINSTALL = 3;
enum APK_SCRIPT_PRE_UPGRADE = 4;
enum APK_SCRIPT_POST_UPGRADE = 5;
enum APK_SCRIPT_TRIGGER = 6;
enum APK_SCRIPT_MAX = 7;

enum APK_SIGN_NONE = 0;
enum APK_SIGN_VERIFY = 1;
enum APK_SIGN_VERIFY_IDENTITY = 2;
enum APK_SIGN_GENERATE = 4;
enum APK_SIGN_VERIFY_AND_GENERATE = 5;

enum APK_DEP_IRRELEVANT = 0x01;
enum APK_DEP_SATISFIES = 0x02;
enum APK_DEP_CONFLICTS = 0x04;
enum APK_FOREACH_INSTALLED = 0x10;
enum APK_FOREACH_MARKED = 0x20;
enum APK_FOREACH_NULL_MATCHES_ALL = 0x40;
enum APK_FOREACH_DEP = 0x80;
enum APK_FOREACH_GENID_MASK = 0xffffff00;

struct apk_sign_ctx
{
    import std.bitmanip : bitfields;

    int keys_fd;
    int action;
    const(EVP_MD)* md;
    int num_signatures;

    mixin(bitfields!(int, "control_started", 1, int, "data_started", 1, int,
            "has_data_checksum", 1, int, "control_verified", 1, int,
            "data_verified", 1, uint, "", 3));

    char[EVP_MAX_MD_SIZE] data_checksum;
    apk_checksum identity;
    EVP_MD_CTX* mdctx;

    struct _Anonymous_0
    {
        apk_blob_t data;
        EVP_PKEY* pkey;
        char* identity;
    }

    _Anonymous_0 signature;
}

struct apk_dependency
{
    import std.bitmanip : bitfields;

    apk_name* name;
    apk_blob_t* version_;

    mixin(bitfields!(uint, "broken", 1, uint, "repository_tag", 6, uint,
            "conflict", 1, uint, "result_mask", 4, uint, "fuzzy", 1, uint, "", 3));
}

struct apk_dependency_array
{
    apk_dependency[] item(size_t length)
    {
        return m_item.ptr[0 .. length];
    }

    size_t num;
    apk_dependency[0] m_item;
}

void apk_dependency_array_init(apk_dependency_array** a);
void apk_dependency_array_free(apk_dependency_array** a);
void apk_dependency_array_resize(apk_dependency_array** a, size_t size);
void apk_dependency_array_copy(apk_dependency_array** a, apk_dependency_array* b);
apk_dependency* apk_dependency_array_add(apk_dependency_array** a);

struct apk_installed_package
{
    import std.bitmanip : bitfields;

    apk_package* pkg;
    list_head installed_pkgs_list;
    list_head trigger_pkgs_list;
    hlist_head owned_dirs;
    apk_blob_t[APK_SCRIPT_MAX] script;
    apk_string_array* triggers;
    apk_string_array* pending_triggers;
    apk_dependency_array* replaces;

    ushort replaces_priority;

    mixin(bitfields!(uint, "repository_tag", 6, uint, "run_all_triggers", 1,
            uint, "broken_files", 1, uint, "broken_script", 1, uint,
            "broken_xattr", 1, uint, "", 6));
}

struct apk_package
{
    import std.bitmanip : bitfields;

    apk_hash_node hash_node;

    union
    {
        apk_solver_package_state ss;

        struct
        {
            uint foreach_genid;

            union
            {
                int state_int;
                void* state_ptr;
            }
        }
    }

    apk_name* name;
    apk_installed_package* ipkg;
    apk_blob_t* version_;
    apk_blob_t* arch;
    apk_blob_t* license;
    apk_blob_t* origin;
    apk_blob_t* maintainer;
    char* url;
    char* description;
    char* commit;
    char* filename;
    apk_dependency_array* depends;
    apk_dependency_array* install_if;
    apk_dependency_array* provides;
    size_t installed_size;
    size_t size;
    time_t build_time;
    ushort provider_priority;

    mixin(bitfields!(uint, "repos", 32, uint, "marked", 1, uint,
            "uninstallable", 1, uint, "cached_non_repository", 1, uint, "", 29));

    apk_checksum csum;
}

struct apk_package_array
{
    apk_package*[] item(size_t length)
    {
        return m_item.ptr[0 .. length];
    }

    size_t num;
    apk_package*[0] m_item;
}

void apk_package_array_init(apk_package_array** a);
void apk_package_array_free(apk_package_array** a);
void apk_package_array_resize(apk_package_array** a, size_t size);
void apk_package_array_copy(apk_package_array** a, apk_package_array* b);
apk_package** apk_package_array_add(apk_package_array** a);

extern __gshared const(char)** apk_script_types;

void apk_sign_ctx_init(apk_sign_ctx* ctx, int action, apk_checksum* identity, int keys_fd);
void apk_sign_ctx_free(apk_sign_ctx* ctx);
int apk_sign_ctx_process_file(apk_sign_ctx* ctx, const(apk_file_info)* fi, apk_istream* is_);
int apk_sign_ctx_parse_pkginfo_line(void* ctx, apk_blob_t line);
int apk_sign_ctx_verify_tar(void* ctx, const(apk_file_info)* fi, apk_istream* is_);
int apk_sign_ctx_mpart_cb(void* ctx, int part, apk_blob_t blob);

void apk_dep_from_pkg(apk_dependency* dep, apk_database* db, apk_package* pkg);
int apk_dep_is_materialized(apk_dependency* dep, apk_package* pkg);
int apk_dep_is_provided(apk_dependency* dep, apk_provider* p);
int apk_dep_analyze(apk_dependency* dep, apk_package* pkg);
char* apk_dep_snprintf(char* buf, size_t n, apk_dependency* dep);

void apk_blob_push_dep(apk_blob_t* to, apk_database*, apk_dependency* dep);
void apk_blob_push_deps(apk_blob_t* to, apk_database*, apk_dependency_array* deps);
void apk_blob_pull_dep(apk_blob_t* from, apk_database*, apk_dependency*);
void apk_blob_pull_deps(apk_blob_t* from, apk_database*, apk_dependency_array**);

int apk_deps_write(apk_database* db, apk_dependency_array* deps,
        apk_ostream* os, apk_blob_t separator);

void apk_deps_add(apk_dependency_array** depends, apk_dependency* dep);
void apk_deps_del(apk_dependency_array** deps, apk_name* name);
int apk_script_type(const(char)* name);

apk_package* apk_pkg_get_installed(apk_name* name);

apk_package* apk_pkg_new();
int apk_pkg_read(apk_database* db, const(char)* name, apk_sign_ctx* ctx, apk_package** pkg);
void apk_pkg_free(apk_package* pkg);

int apk_pkg_parse_name(apk_blob_t apkname, apk_blob_t* name, apk_blob_t* version_);

int apk_pkg_add_info(apk_database* db, apk_package* pkg, char field, apk_blob_t value);

apk_installed_package* apk_pkg_install(apk_database* db, apk_package* pkg);
void apk_pkg_uninstall(apk_database* db, apk_package* pkg);

int apk_ipkg_add_script(apk_installed_package* ipkg, apk_istream* is_, uint type, uint size);
void apk_ipkg_run_script(apk_installed_package* ipkg, apk_database* db, uint type, char** argv);

apk_package* apk_pkg_parse_index_entry(apk_database* db, apk_blob_t entry);
int apk_pkg_write_index_entry(apk_package* pkg, apk_ostream* os);

int apk_pkg_version_compare(apk_package* a, apk_package* b);

uint apk_foreach_genid();
int apk_pkg_match_genid(apk_package* pkg, uint match);

alias apkPkgForeachMatchingDependencyCallback = extern (C) void function(
        apk_package* pkg0, apk_dependency* dep0, apk_package* pkg, void* ctx) nothrow;
void apk_pkg_foreach_matching_dependency(apk_package* pkg, apk_dependency_array* deps,
        uint match, apk_package* mpkg, apkPkgForeachMatchingDependencyCallback cb, void* ctx);

void apk_pkg_foreach_reverse_dependency(apk_package* pkg, uint match,
        apkPkgForeachMatchingDependencyCallback cb, void* ctx);
