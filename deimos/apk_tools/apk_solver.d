/* apk_solver.h - Alpine Package Keeper (APK)
 *
 * Copyright (C) 2005-2008 Natanael Copa <n@tanael.org>
 * Copyright (C) 2008-2013 Timo Teräs <timo.teras@iki.fi>
 * All rights reserved.
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License version 2 as published
 * by the Free Software Foundation. See http://www.gnu.org/ for details.
 */

import deimos.apk_toolsd.apk_defines;
import deimos.apk_toolsd.apk_database;
import deimos.apk_toolsd.apk_package;

extern (C):

struct apk_change
{
    import std.bitmanip : bitfields;

    apk_package* old_pkg;
    apk_package* new_pkg;

    mixin(bitfields!(uint, "old_repository_tag", 15, uint,
            "new_repository_tag", 15, uint, "reinstall", 1, uint, "", 1));
}

struct apk_hash_array
{
    size_t num;
    apk_change[] item;
}

struct apk_changeset
{
    int num_install;
    int num_remove;
    int num_adjust;
    int num_total_changes;
    struct apk_change_array;
    apk_change_array* changes;
}

enum APK_SOLVERF_UPGRADE = 0x0001;
enum APK_SOLVERF_AVAILABLE = 0x0002;
enum APK_SOLVERF_REINSTALL = 0x0004;
enum APK_SOLVERF_LATEST = 0x0008;
enum APK_SOLVERF_IGNORE_CONFLICT = 0x0010;
enum APK_SOLVERF_IGNORE_UPGRADE = 0x0020;

void apk_solver_set_name_flags(apk_name* name, ushort solver_flags, ushort solver_flags_inheritable);
int apk_solver_solve(apk_database* db, ushort solver_flags,
        apk_dependency_array* world, apk_changeset* changeset);

int apk_solver_commit_changeset(apk_database* db, apk_changeset* changeset,
        apk_dependency_array* world);
void apk_solver_print_errors(apk_database* db, apk_changeset* changeset,
        apk_dependency_array* world);

int apk_solver_commit(apk_database* db, ushort solver_flags, apk_dependency_array* world);
