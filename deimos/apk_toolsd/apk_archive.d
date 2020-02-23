/* apk_archive.c - Alpine Package Keeper (APK)
 *
 * Copyright (C) 2005-2008 Natanael Copa <n@tanael.org>
 * Copyright (C) 2008-2011 Timo Teräs <timo.teras@iki.fi>
 * All rights reserved.
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License version 2 as published
 * by the Free Software Foundation. See http://www.gnu.org/ for details.
 */

module deimos.apk_toolsd.apk_archive;

import deimos.apk_toolsd.apk_defines;
import deimos.apk_toolsd.apk_io;

extern (C):

alias apk_archive_entry_parser = int function(void* ctx,
        const(apk_file_info)* ae, apk_istream* istream);

int apk_tar_parse(apk_istream*, apk_archive_entry_parser parser, void* ctx, apk_id_cache*);
int apk_tar_write_entry(apk_ostream*, const(apk_file_info)* ae, const(char)* data);
int apk_tar_write_padding(apk_ostream*, const(apk_file_info)* ae);

int apk_archive_entry_extract(int atfd, const(apk_file_info)* ae, const(char)* extract_name,
        const(char)* hardlink_name, apk_istream* is_, apk_progress_cb cb, void* cb_ctx);
