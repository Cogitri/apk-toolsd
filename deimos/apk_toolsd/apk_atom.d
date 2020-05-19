/* apk_atom.h - Alpine Package Keeper (APK)
 *
 * Copyright (C) 2005-2008 Natanael Copa <n@tanael.org>
 * Copyright (C) 2008-2011 Timo Teräs <timo.teras@iki.fi>
 * All rights reserved.
 *
 * SPDX-License-Identifier: GPL-2.0-only
 */

module deimos.apk_toolsd.apk_atom;

import core.stdc.config;
import core.stdc.stdlib;

import deimos.apk_toolsd.apk_blob;
import deimos.apk_toolsd.apk_hash;

extern (C):
nothrow:

struct apk_atom_pool
{
    apk_hash hash;
}

void apk_atom_init(apk_atom_pool*);
void apk_atom_free(apk_atom_pool*);
apk_blob_t* apk_apk_get(apk_atom_pool* atoms, apk_blob_t blob, int duplicate);
