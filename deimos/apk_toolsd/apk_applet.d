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

enum APK_COMMAND_GROUP_INSTALL = 0x0001;
enum APK_COMMAND_GROUP_SYSTEM = 0x0002;
enum APK_COMMAND_GROUP_QUERY = 0x0004;
enum APK_COMMAND_GROUP_REPO = 0x0008;

struct apk_option
{
    int val;
    const(char)* name;
    const(char)* help;
    int has_arg;
    const(char)* arg_name;
}

struct apk_option_group
{
    const(char)* name;
    int num_options;
    const(apk_option)* options;

    int function(void* ctx, apk_db_options* dbopts, int optch, const(char)* optarg) parse;
}

struct apk_applet
{
    list_head node;

    const(char)* name;
    const(char)* arguments;
    const(char)* help;
    const(apk_option_group)*[4] optgroups;

    uint open_flags;
    uint forced_flags;
    uint forced_force;
    uint command_groups;
    int context_size;

    int function(void* ctx, apk_database* db, apk_string_array* args) main;
}

extern __gshared const apk_option_group optgroup_global;
extern __gshared const apk_option_group optgroup_commit;

void apk_applet_register(apk_applet*);
alias apk_init_func_t = void function();
