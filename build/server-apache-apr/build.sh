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

# main package config
PROG=apr                                     # App name
VER=1.4.8                                    # App version
VERHUMAN=$VER-1                              # Human-readable version
#PVER=                                       # Branch (set in config.sh, override here if needed)
PKG=obd/server/apache/apr                    # Package name (e.g. library/foo)
SUMMARY="Apache Portable Runtime"
DESC="${SUMMARY}"

RUN_DEPENDS_IPS="obd/server/apache/base"
BUILD_DEPENDS_IPS="library/libxml2 developer/build/autoconf obd/server/apache/zlib"
BUILDARCH=both

PREFIX=${PREFIX}-apps/apache/shared

# package specific
MIRROR=www.eu.apache.org
DLPATH=dist/apr

# environment
LDFLAGS32="-L${PREFIX}/lib -R${PREFIX}/lib"
LDFLAGS64="-m64 -L${PREFIX}/lib/${ISAPART64} -R${PREFIX}/lib/${ISAPART64}"

reset_configure_opts
CONFIGURE_OPTS="--enable-nonportable-atomics --enable-threads"
CONFIGURE_OPTS_32="--enable-layout=${ISAPART} --enable-layout=${ISAPART} --with-installbuilddir=${PREFIX}/share/build-1/${ISAPART}"
CONFIGURE_OPTS_64="--enable-layout=${ISAPART64} --enable-layout=${ISAPART64} --with-installbuilddir=${PREFIX}/share/build-1/${ISAPART64}"

copy_config_layout() {
    logmsg "Copying config layout"
    sed "s#{{PREFIX}}#${PREFIX}#g" ${SRCDIR}/files/config.layout > ${TMPDIR}/${PROG}-${VER}/config.layout || \
        logerr "--- Failed to copy config.layout"

    
}

make_install_extras() {
    logcmd gsed -i -e 's/CC -shared/CC -m64 -shared/g;' ${DESTDIR}/${PREFIX}/share/build-1/${ISAPART64}/libtool  || \
        logerr "-------- Failed to patch 64-bit apr libtool!"
}

init
prep_build
download_source ${DLPATH} ${PROG} ${VER}
patch_source
copy_config_layout
build
make_install_extras
make_isa_stub
PREFIX=$(echo ${PREFIX} | sed "s#/shared##g")
prefix_updater
make_package
auto_publish
cleanup_source
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
