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
PROG=mod_fcgid                               # App name
VER=2.3.7                                    # App version
VERHUMAN=$VER-1                              # Human-readable version
#PVER=                                       # Branch (set in config.sh, override here if needed)
PKG=obd/server/apache/httpd/mod_fcgid        # Package name (e.g. library/foo)
SUMMARY="mod_fcgid is a high performance alternative to mod_cgi or mod_cgid, which starts a sufficient number instances of the CGI program to handle concurrent requests, and these programs remain running to handle further incoming requests."
DESC="${SUMMARY}"

RUN_DEPENDS_IPS="obd/server/apache/base obd/server/apache/httpd"
BUILD_DEPENDS_IPS="developer/build/autoconf obd/server/apache/httpd"
BUILDARCH=both

PREFIX=${PREFIX}-apps/apache/httpd
PREFIX_LIB=$(echo ${PREFIX} | sed "s#/httpd#/shared#g")

# package specific
MIRROR=www.eu.apache.org
DLPATH=dist/httpd/${PROG}

# environment
LDFLAGS32="-L${PREFIX_LIB}/lib -R${PREFIX_LIB}/lib"
LDFLAGS64="-m64 -L${PREFIX_LIB}/lib/${ISAPART64} -R${PREFIX_LIB}/lib/${ISAPART64}"

save_function configure32 configure32_orig
save_function configure64 configure64_orig

configure32() {
    export APXS=${PREFIX}/bin/${ISAPART}/apxs
    CONFIGURE_CMD="./configure.apxs"
    CONFIGURE_OPTS_32=
    configure32_orig
}

configure64() {
    export APXS=${PREFIX}/bin/${ISAPART64}/apxs
    CONFIGURE_CMD="./configure.apxs"
    CONFIGURE_OPTS_64=
    configure64_orig
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
