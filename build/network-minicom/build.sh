#!/usr/bin/bash
#
# CDDL HEADER START
#
# The contents of this file are subject to the terms of the
# Common Development and Distribution License, Version 1.0 only
# (the "License").  You may not use this file except in compliance
# with the License.
#
# You can obtain a copy of the license at usr/src/OPENSOLARIS.LICENSE
# or http://www.opensolaris.org/os/licensing.
# See the License for the specific language governing permissions
# and limitations under the License.
#
# When distributing Covered Code, include this CDDL HEADER in each
# file and include the License file at usr/src/OPENSOLARIS.LICENSE.
# If applicable, add the following below this CDDL HEADER, with the
# fields enclosed by brackets "[]" replaced with your own identifying
# information: Portions Copyright [yyyy] [name of copyright owner]
#
# CDDL HEADER END
#
#
# Copyright 2011-2012 OmniTI Computer Consulting, Inc.  All rights reserved.
# Copyright 2013 Jorge Schrauwen.  All rights reserved.
# Use is subject to license terms.
#
# Load support functions
. ../../lib/functions.sh
. ../myfunc.sh

PROG=minicom                                # App name
VER=2.6.2                                   # App version
VERHUMAN=$VER-1                             # Human-readable version
#PVER=                                      # Branch (set in config.sh, override here if needed)
PKG=obd/network/minicom                     # Package name (e.g. library/foo)
SUMMARY="Minicom is a text-based modem control and terminal emulation program for Unix-like operating systems, originally written by Miquel van Smoorenburg, and modeled after the popular MS-DOS program Telix."
DESC="${SUMMARY}"

RUN_DEPENDS_IPS=""
BUILD_DEPENDS_IPS=""

BUILDARCH=both

# package specific
MIRROR=alioth.debian.org
DLPATH=frs/download.php/file/3869

init
prep_build
download_source ${DLPATH} ${PROG} ${VER}
patch_source
build
make_isa_stub
prefix_updater
make_package
auto_publish
cleanup_source
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
