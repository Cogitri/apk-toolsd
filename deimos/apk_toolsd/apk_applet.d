/* apk_applet.h - Alpine Package Keeper (APK)
 *
 * Copyright (C) 2005-2008 Natanael Copa <n@tanael.org>
 * Copyright (C) 2008-2011 Timo Teräs <timo.teras@iki.fi>
 * All rights reserved.
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License version 2 as published
 * by the Free Software Foundation. See http://www.gnu.org/ for details.
 */

module deimos.apk_toolsd.apk_applet;

import deimos.apk_toolsd.apk_database : apk_db_options, apk_database;
import deimos.apk_toolsd.apk_defines;

extern (C):
nothrow:

struct apk_option_group
{
    const(char)* desc;

    extern (C) int function(void* ctx, apk_db_options* dbopts, int opt, const(char)* optarg) nothrow parse;
}

struct apk_applet
{
    list_head node;

    const(char)* name;
    const(apk_option_group)*[4] optgroups;

    uint open_flags;
    uint forced_flags;
    uint forced_force;
    int context_size;

    extern (C) int function(void* ctx, apk_database* db, apk_string_array* args) nothrow main;
}

extern __gshared const apk_option_group optgroup_global;
extern __gshared const apk_option_group optgroup_commit;

void apk_help(apk_applet* applet);
void apk_applet_register(apk_applet*);
alias apk_init_func_t = extern (C) void function() nothrow;
