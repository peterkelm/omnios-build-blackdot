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

## TODO
# - SMF
# - fix libexec/sbin 
# -- also isastub heimdal sub folder

# Load support functions
. ../../lib/functions.sh
. ../myfunc.sh

PROG=db                                     # App name
VER=6.0.20                                  # App version
VERHUMAN=$VER-1                             # Human-readable version
#PVER=                                      # Branch (set in config.sh, override here if needed)
PKG=obd/database/bdb                        # Package name (e.g. library/foo)
SUMMARY="Berkeley DB (BDB) is a software library that provides a high-performance embedded database for key/value data."
DESC="${SUMMARY}"

RUN_DEPENDS_IPS=""
BUILD_DEPENDS_IPS=""

BUILDARCH=both

# package specific
MIRROR=download.oracle.com
DLPATH=berkeley-db

BUILDDIR=db-$VER/build_unix
CONFIGURE_CMD="../dist/configure"
CONFIGURE_OPTS="--enable-dtrace --enable-dbm --enable-sql --enable-cxx --docdir=${PREFIX}/share/docs"
LDFLAGS32="$LDFLAGS32 -L${PREFIX}/lib -R${PREFIX}/lib"
LDFLAGS64="$LDFLAGS64 -L${PREFIX}/lib/$ISAPART64 -R${PREFIX}/lib/$ISAPART64"

export EXTLIBS=-lm

save_function build64 build64_orig
build64() {
  export DLDFLAGS="-L${PREFIX}/lib/$ISAPART64 -R${PREFIX}/lib/$ISAPART64"
  build64_orig
}

make_install_extras() {
    logmsg "--- make install extras"
    logcmd mkdir -p ${DESTDIR}/${PREFIX}/share || \
        logerr "-------- Failed to create share directory."
    logcmd mv ${DESTDIR}/${PREFIX}/docs  ${DESTDIR}/${PREFIX}/share || \
        logerr "-------- Failed to move docs directory."
}

init
prep_build
download_source ${DLPATH} ${PROG} ${VER}
patch_source
build
make_install_extras
make_isa_stub
prefix_updater
make_package
auto_publish
cleanup_source
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
