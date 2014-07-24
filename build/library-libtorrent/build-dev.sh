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

PROG=libtorrent-rasterbar                   # App name
VER=1.0.0                                   # App version
VERHUMAN=$VER-1                             # Human-readable version
#PVER=                                      # Branch (set in config.sh, override here if needed)
PKG=obd/library/libtorrent                  # Package name (e.g. library/foo)
SUMMARY="libtorrent is a feature complete C++ bittorrent implementation focusing on efficiency and scalability."
DESC="${SUMMARY}"

RUN_DEPENDS_IPS="obd/developer/library/boost"
BUILD_DEPENDS_IPS="obd/developer/library/boost"

BUILDARCH=both

# package specific
# http://downloads.sourceforge.net/project/libtorrent/libtorrent/libtorrent-rasterbar-1.0.0.tar.gz?r=&ts=1406227113&use_mirror=netcologne
download_source() {
    logmsg "Downloading Source"

    cd ${TMPDIR}
    ${WGET} -c http://downloads.sourceforge.net/project/${PROG%-*}/${PROG%-*}/${PROG}-${VER}.tar.gz -O ${PROG}-${VER}.tar.gz

    ${TAR} xvf ${PROG}-${VER}.tar.gz
}

configure32() {
    logmsg "--- environment variables (32-bit)"
    export ISALIST="i386" # needed for python library
    export PYTHON_INSTALL_PARAMS="--prefix=\${DESTDIR}/usr"
    export CFLAGS="-pthread"
    export CXXFLAGS="${CFLAGS}"
    export CPPFLAGS="${CFLAGS}"
    export LDFLAGS="-L${PREFIX}/lib -R${PREFIX}/lib"

    CONFIGURE_OPTS="--with-boost=${PREFIX} --with-boost-libdir=${PREFIX}/lib --enable-python-binding"

    logmsg "--- configure (32-bit)"
    CFLAGS="$CFLAGS $CFLAGS32" \
    CXXFLAGS="$CXXFLAGS $CXXFLAGS32" \
    CPPFLAGS="$CPPFLAGS $CPPFLAGS32" \
    LDFLAGS="$LDFLAGS $LDFLAGS32" \
    CC=$CC CXX=$CXX \
    logcmd $CONFIGURE_CMD $CONFIGURE_OPTS_32 \
    $CONFIGURE_OPTS || \
        logerr "--- Configure failed"
}

configure64() {
    logmsg "--- environment variables (64-bit)"
    export ISALIST="amd64 i386" # needed for python library
    export PYTHON_INSTALL_PARAMS="--prefix=\${DESTDIR}/usr"
    export CFLAGS="-pthread"
    export CXXFLAGS="${CFLAGS}"
    export CPPFLAGS="${CFLAGS}"
    export LDFLAGS="-m64 -L${PREFIX}/lib/${ISAPART64} -R${PREFIX}/lib/${ISAPART64}"

    CONFIGURE_OPTS="--with-boost=${PREFIX} --with-python-boost --with-boost-libdir=${PREFIX}/lib/${ISAPART64} --enable-python-binding"

    logmsg "--- configure (64-bit)"
    CFLAGS="$CFLAGS $CFLAGS64" \
    CXXFLAGS="$CXXFLAGS $CXXFLAGS64" \
    CPPFLAGS="$CPPFLAGS $CPPFLAGS64" \
    LDFLAGS="$LDFLAGS $LDFLAGS64" \
    CC=$CC CXX=$CXX \
    logcmd $CONFIGURE_CMD $CONFIGURE_OPTS_64 \
    $CONFIGURE_OPTS || \
        logerr "--- Configure failed"
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
