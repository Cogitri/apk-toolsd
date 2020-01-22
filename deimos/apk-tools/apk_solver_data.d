/* apk_solver_data.h - Alpine Package Keeper (APK)
 *
 * Copyright (C) 2005-2008 Natanael Copa <n@tanael.org>
 * Copyright (C) 2008-2012 Timo Teräs <timo.teras@iki.fi>
 * All rights reserved.
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License version 2 as published
 * by the Free Software Foundation. See http://www.gnu.org/ for details.
 */

extern (C):

struct apk_solver_name_state
{
    import std.bitmanip : bitfields;

    apk_provider chosen;

    union
    {
        struct
        {
            list_head dirty_list;
            list_head unresolved_list;
        }

        struct
        {
            struct apk_name;
            apk_name* installed_name;
            struct apk_package;
            apk_package* installed_pkg;
        }
    }

    ushort requirers;
    ushort merge_depends;
    ushort merge_provides;
    ushort max_dep_chain;

    mixin(bitfields!(
        uint, "seen", 1,
        uint, "locked", 1,
        uint, "in_changeset", 1,
        uint, "reevaluate_deps", 1,
        uint, "reevaluate_iif", 1,
        uint, "has_iif", 1,
        uint, "no_iif", 1,
        uint, "has_options", 1,
        uint, "reverse_deps_done", 1,
        uint, "has_virtual_provides", 1,
        uint, "", 6));
}

struct apk_solver_package_state
{
    import std.bitmanip : bitfields;

    uint conflicts;
    ushort max_dep_chain;
    ushort pinning_allowed;
    ushort pinning_preferred;

    mixin(bitfields!(
        uint, "solver_flags", 6,
        uint, "solver_flags_inheritable", 6,
        uint, "seen", 1,
        uint, "pkg_available", 1,
        uint, "pkg_selectable", 1,
        uint, "tag_ok", 1,
        uint, "tag_preferred", 1,
        uint, "dependencies_used", 1,
        uint, "dependencies_merged", 1,
        uint, "in_changeset", 1,
        uint, "iif_triggered", 1,
        uint, "iif_failed", 1,
        uint, "error", 1,
        uint, "", 9));
}
