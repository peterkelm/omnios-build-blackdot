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

PROG=unrar                                  # App name
VER=5.2.6                                   # App version
VERHUMAN=$VER-1                             # Human-readable version
#PVER=                                      # Branch (set in config.sh, override here if needed)
PKG=obd/compress/unrar                          # Package name (e.g. library/foo)
SUMMARY="RAR archive extractor"
DESC="WinRAR is a powerful archive manager. It can backup your data and reduce the size of email attachments, decompress RAR, ZIP and other files downloaded from Internet and create new archives in RAR and ZIP file format. You can try WinRAR before buy, its trial version is available in downloads"

RUN_DEPENDS_IPS=""
BUILD_DEPENDS_IPS=""

BUILDARCH=both

# package specific
download_source () {
    # tar and prog name disagreement
    pushd $TMPDIR > /dev/null

    logmsg "--- download source"
    wget -c http://www.rarlab.com/rar/unrarsrc-${VER}.tar.gz -O ${TMPDIR}/${PROG}-${VER}.tar.gz

    # expand source and copy patches
    logmsg "--- extractomg source"
    [ -d ${TMPDIR}/${PROG}-${VER} ] && rm -rf ${TMPDIR}/${PROG}-${VER}
    tar xzvf ${TMPDIR}/${PROG}-${VER}.tar.gz -C ${TMPDIR}/
    cp ${SRCDIR}/files/unrar.1 ${TMPDIR}/${PROG}/
    cp ${SRCDIR}/patches/* ${TMPDIR}/${PROG}/
    mv ${TMPDIR}/${PROG} ${TMPDIR}/${PROG}-${VER}

    popd > /dev/null
}

configure32() {
    cp makefile makefile.clean
    logmsg "--- patch makefile"
    patch < makefile-i386.patch > /dev/null
}
configure64() {
    [ -e makefile.clean ] && cp makefile.clean makefile
    logmsg "--- patch makefile"
    patch < makefile-amd64.patch > /dev/null
}

make_install() {
    logmsg "--- make install"
    mkdir -p ${DESTDIR}${PREFIX}/share/man/man1/ &> /dev/null
    logcmd $MAKE DESTDIR=${DESTDIR}${PREFIX} install || \
        logerr "--- Make install failed"
}

init
prep_build
download_source
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
