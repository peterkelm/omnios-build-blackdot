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

PROG=lua                                    # App name
VER=5.3.0                                   # App version
VERHUMAN=$VER-1                             # Human-readable version
#PVER=                                      # Branch (set in config.sh, override here if needed)
PKG=obd/runtime/lua                         # Package name (e.g. library/foo)
SUMMARY="Lua runtime environment"
DESC="${SUMMARY}"

RUN_DEPENDS_IPS=""
BUILD_DEPENDS_IPS=""
BUILDARCH=both

MIRROR=www.lua.org
DLPATH=ftp
LUA_COMPAT_ALL=yes

save_function build32 build32_orig
save_function build64 build64_orig
build32() {
    pushd $TMPDIR/$BUILDDIR > /dev/null
    logmsg "Building 32-bit"
    export ISALIST=i386
    logmsg "--- make clean"
    logcmd $MAKE clean || logerr "--- make failed"
    logmsg "--- Copying Makefile"
    logcmd cp ${SRCDIR}/files/Makefile-${ISAPART} Makefile || \
        logerr "--- Makefile failed to copy"
    logmsg "--- make"
    logcmd $MAKE solaris || logerr "--- make failed"
    logmsg "--- make install"
    logcmd $MAKE PREFIX=${DESTDIR}/${PREFIX} solaris install || logerr "--- make install failed"
    popd > /dev/null
}

build64() {
    pushd $TMPDIR/$BUILDDIR > /dev/null
    logmsg "Building 64-bit"
    export ISALIST="amd64 i386"
    logmsg "--- Copying Makefile"
    logcmd cp ${SRCDIR}/files/Makefile-${ISAPART64} Makefile || \
        logerr "--- Makefile failed to copy"
    logmsg "--- make clean"
    logcmd $MAKE clean || logerr "--- make failed"
    logmsg "--- patching lower level make file"
    logcmd /usr/gnu/bin/sed -i "s/CC= gcc/CC=gcc -m64/g" src/Makefile || logerr "--- sed file"
    logmsg "--- make"
    logcmd $MAKE solaris || logerr "--- make failed"
    logmsg "--- make install"
    logcmd $MAKE PREFIX=${DESTDIR}/${PREFIX} solaris install || logerr "--- make install failed"
    popd > /dev/null
}

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
