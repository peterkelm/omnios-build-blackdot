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

PROG=boost                                  # App name
VER=1.54.0                                  # App version
VERHUMAN=$VER-1                             # Human-readable version
#PVER=                                      # Branch (set in config.sh, override here if needed)
PKG=obd/developer/library/boost             # Package name (e.g. library/foo)
SUMMARY="Boost provides free peer-reviewed portable C++ source libraries."
DESC="${SUMMARY} We emphasize libraries that work well with the C++ Standard Library. Boost libraries are intended to be widely useful, and usable across a broad spectrum of applications. The Boost license encourages both commercial and non-commercial use."

RUN_DEPENDS_IPS=""
BUILD_DEPENDS_IPS=""

BUILDARCH=both
# package specific
download_source() {
    logmsg "Downloading Source"

    cd ${TMPDIR}
    ${WGET} -c http://downloads.sourceforge.net/project/${PROG}/${PROG}/${VER}/${PROG}_$(echo ${VER} | sed s/\\./_/g).tar.gz -O ${PROG}-${VER}.tar.gz

    ${TAR} xvf ${PROG}-${VER}.tar.gz
    [ -d ${PROG}-${VER} ] && rm -rf ${PROG}-${VER}
    mv ${PROG}_$(echo ${VER} | sed s/\\./_/g) ${PROG}-${VER}

    }
make_clean() {
    # because by this time we have DESTDIR
    logmsg "--- pushing some configuration variables"
    export CFLAGS32="-pthread"
    export CXXFLAGS32="-pthread"
    export CFLAGS64="-pthread"
    export CXXFLAGS64="-pthread"

    export CONFIGURE_CMD="./bootstrap.sh"
    export CONFIGURE_OPTS_32="--prefix=${DESTDIR}${PREFIX} --includedir=${DESTDIR}${PREFIX}/include --libdir=${DESTDIR}${PREFIX}/lib"
    export CONFIGURE_OPTS_64="--prefix=${DESTDIR}${PREFIX} --includedir=${DESTDIR}${PREFIX}/include/${ISAPART64} --libdir=${DESTDIR}${PREFIX}/lib/${ISAPART64}"

    logmsg "--- make (dist)clean"
    logcmd ./b2 clean || \
        logmsg "--- *** WARNING *** make (dist)clean Failed"
}
make_prog32() {
    logmsg "--- make"
    logcmd ./b2 variant=release threading=multi link=shared runtime-link=shared address-model=32 || \
        logerr "--- Make failed"
}
make_install32() {
    logmsg "--- make install"
    logcmd ./b2 variant=release threading=multi link=shared runtime-link=shared address-model=32 install || \
        logerr "--- Make install failed"
}
make_prog64() {
    logmsg "--- make"
    logcmd ./b2 variant=release threading=multi link=shared runtime-link=shared address-model=64 || \
        logerr "--- Make failed"
}
make_install64() {
    logmsg "--- make install"
    logcmd ./b2 variant=release threading=multi link=shared runtime-link=shared address-model=64 install || \
        logerr "--- Make install failed"
}

init
auto_publish_wipe
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
