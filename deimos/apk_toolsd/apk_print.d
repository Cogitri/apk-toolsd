/* apk_print.h - Alpine Package Keeper (APK)
 *
 * Copyright (C) 2005-2008 Natanael Copa <n@tanael.org>
 * Copyright (C) 2008-2011 Timo Teräs <timo.teras@iki.fi>
 * All rights reserved.
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License version 2 as published
 * by the Free Software Foundation. See http://www.gnu.org/ for details.
 */

module deimos.apk_toolsd.apk_print;

import core.stdc.stdint;
import core.sys.posix.sys.types;

import deimos.apk_toolsd.apk_blob;

extern (C):
extern __gshared int apk_progress_fd;

void apk_log(const(char)* prefix, const(char)* format, ...);
void apk_log_err(const(char)* prefix, const(char)* format, ...);
const(char)* apk_error_str(int error);

void apk_reset_screen_width();
int apk_get_screen_width();
const(char)* apk_get_human_size(off_t size, off_t* dest);

struct apk_indent
{
    int x;
    int indent;
}

void apk_print_progress(size_t done, size_t total);
int apk_print_indented(apk_indent* i, apk_blob_t blob);
void apk_print_indented_words(apk_indent* i, const(char)* text);
void apk_print_indented_fmt(apk_indent* i, const(char)* fmt, ...);
