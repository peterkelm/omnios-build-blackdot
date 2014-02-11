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
PROG=mod_authnz_external                      # App name
VER=3.3.2                                     # App version
VERHUMAN=$VER-1                               # Human-readable version
#PVER=                                        # Branch (set in config.sh, override here if needed)
PKG=obd/server/apache/httpd/mod_authnz_external # Package name (e.g. library/foo)
SUMMARY="Mod_authnz_external and mod_auth_external are flexible tools for building custom basic authentication systems for the Apache HTTP Daemon"
DESC="${SUMMARY}"

RUN_DEPENDS_IPS="obd/server/apache/base obd/server/apache/httpd"
BUILD_DEPENDS_IPS="developer/build/autoconf obd/server/apache/httpd"
BUILDARCH=both

PREFIX=${PREFIX}-apps/apache/httpd
PREFIX_LIB=$(echo ${PREFIX} | sed "s#/httpd#/shared#g")

# package specific
MIRROR=mod-auth-external.googlecode.com
DLPATH=files

# environment
CFLAGS="$CFLAGS -fpic"
LDFLAGS32="-L${PREFIX_LIB}/lib -R${PREFIX_LIB}/lib"
LDFLAGS64="-m64 -L${PREFIX_LIB}/lib/${ISAPART64} -R${PREFIX_LIB}/lib/${ISAPART64}"
CLEAN_PATH=$PATH

configure64() {
    export PATH=${PREFIX}/bin/${ISAPART64}:${CLEAN_PATH}
}

configure32() {
    export PATH=${PREFIX}/bin/${ISAPART}:${CLEAN_PATH}
}

make_install64() {
    logmsg "--- make install"
    MOD_DIR=${DESTDIR}${PREFIX}/modules/${ISAPART64}
    logcmd mkdir -p ${MOD_DIR} ||
        logerr "-------- Failed to create ${MOD_DIR}."
    ${PREFIX}/share/${ISAPART64}/build/instdso.sh SH_LIBTOOL="${PREFIX_LIB}/share/${ISAPART64}/build-1/libtool" mod_authnz_external.la ${MOD_DIR}
}

make_install32() {
    logmsg "--- make install"
    MOD_DIR=${DESTDIR}${PREFIX}/modules/${ISAPART}
    logcmd mkdir -p ${MOD_DIR} ||
        logerr "-------- Failed to create ${MOD_DIR}."
    ${PREFIX}/share/${ISAPART}/build/instdso.sh SH_LIBTOOL="${PREFIX_LIB}/share/${ISAPART}/build-1/libtool" mod_authnz_external.la ${MOD_DIR}
}

make_install_extras() {
    logmsg "--- make install extras"
    logcmd mkdir -p ${DESTDIR}/${PREFIX}/conf/httpd.conf.d/ || \
        logerr "-------- Failed to create configuration directory."
    logcmd cp -r ${SRCDIR}/files/conf/httpd.conf.d/* ${DESTDIR}/${PREFIX}/conf/httpd.conf.d/ || \
        logerr "-------- Failed to copy default configuration."
}

init
prep_build
download_source ${DLPATH} ${PROG} ${VER}
patch_source
build
make_install_extras
make_isa_stub
PREFIX=$(echo ${PREFIX} | sed "s#/httpd##g")
prefix_updater
make_package
auto_publish
cleanup_source
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
