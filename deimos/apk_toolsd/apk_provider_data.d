/* apk_provider_data.h - Alpine Package Keeper (APK)
 *
 * Copyright (C) 2005-2008 Natanael Copa <n@tanael.org>
 * Copyright (C) 2008-2012 Timo Teräs <timo.teras@iki.fi>
 * All rights reserved.
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License version 2 as published
 * by the Free Software Foundation. See http://www.gnu.org/ for details.
 */

module deimos.apk_toolsd.apk_provider_data;

import deimos.apk_toolsd.apk_blob;
import deimos.apk_toolsd.apk_package;

extern (C):

struct apk_provider
{
    apk_package* pkg;
    apk_blob_t* version_;
}

struct apk_provider_array
{
    size_t num;
    apk_provider[] item;
}

void apk_provider_array_init(apk_provider_array** a);
void apk_provider_array_free(apk_provider_array** a);
void apk_provider_array_resize(apk_provider_array** a, size_t size);
void apk_provider_array_copy(apk_provider_array** a, apk_provider_array* b);
apk_provider* apk_provider_array_add(apk_provider_array** a);
