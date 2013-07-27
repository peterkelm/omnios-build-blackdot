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

PROG=adblock                                # App name
VER=1.8                                     # App version
VERHUMAN=${VER}-1                           # Human-readable version
#PVER=                                      # Branch (set in config.sh, override here if needed)
PKG=obd/server/misc/adblock                 # Package name (e.g. library/foo)
SUMMARY="Adblocking service, consisting about a custom DNS server with blacklisting and a small HTTP server to service transparents ads."
DESC="${SUMMARY}"

RUN_DEPENDS_IPS="runtime/python-26 library/python-2/bottle obd/server/misc/dnsmasq"
BUILD_DEPENDS_IPS=""

BUILDARCH=both

# Nothing to configure or build, just package
make_install() {
    logmsg "--- make install"
    logcmd mkdir -p ${DESTDIR}${PREFIX}/ || \
        logerr "------ Failed to create destination directory."
    logcmd tar xjpf ${TMPDIR}/${PROG}.tar.bz2 -C ${DESTDIR}${PREFIX} || \
        logerr "------ Failed to unpack ${PROG}.tar.bz2"
    logcmd rm ${PROG}.tar.bz2 || \
        logerr "------ Failed to cleanup ${PROG}.tar.bz2"
    if [ -d ${DESTDIR}${PREFIX}/_rootfs_/ ]; then
        logcmd mv ${DESTDIR}${PREFIX}/_rootfs_/* ${DESTDIR} || \
            logerr "------ Failed to move _rootfs_ files."
        logcmd rmdir ${DESTDIR}${PREFIX}/_rootfs_/ || \
            logerr "------ Failed to remove _rootfs_ directoru."
    fi

    if [ ${PREFIX} = "/usr" ]; then
        logcmd mv ${DESTDIR}${PREFIX}/etc ${DESTDIR}/ || \
            logerr "------ Failed to move etc."

    fi
}

build() {
    pushd $TMPDIR > /dev/null
    tar cpjf ${TMPDIR}/${PROG}.tar.bz2 -C ${SRCDIR}/staging/ .
    make_install
    popd > /dev/null
}

init
prep_build
build
prefix_updater
make_package
auto_publish
cleanup_source
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
