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
PROG=mod_wsgi                                # App name
VER=4.4.9                                    # App version
VERHUMAN=$VER-1                              # Human-readable version
#PVER=                                       # Branch (set in config.sh, override here if needed)
PKG=obd/server/apache/httpd/mod_wsgi         # Package name (e.g. library/foo)
SUMMARY="The aim of mod_wsgi is to implement a simple to use Apache module which can host any Python application which supports the Python WSGI interface. The module would be suitable for use in hosting high performance production web sites, as well as your average self managed personal sites running on web hosting services."
DESC="${SUMMARY}"

RUN_DEPENDS_IPS="obd/server/apache/base obd/server/apache/httpd"
BUILD_DEPENDS_IPS="developer/build/autoconf obd/server/apache/httpd"
BUILDARCH=both

PREFIX=${PREFIX}-apps/apache/httpd
PREFIX_LIB=$(echo ${PREFIX} | sed "s#/httpd#/shared#g")

# package specific
https://github.com/GrahamDumpleton/mod_wsgi/archive/4.2.6.tar.gz
MIRROR=github.com
DLPATH=GrahamDumpleton/mod_wsgi/archive

# environment
CFLAGS="$CFLAGS -fpic"
LDFLAGS32="-L${PREFIX_LIB}/lib -R${PREFIX_LIB}/lib"
LDFLAGS64="-m64 -L${PREFIX_LIB}/lib/${ISAPART64} -R${PREFIX_LIB}/lib/${ISAPART64}"

reset_configure_opts
CONFIGURE_OPTS="" 
CONFIGURE_OPTS_32="--with-apxs=${PREFIX}/bin/${ISAPART}/apxs"
CONFIGURE_OPTS_64="--with-apxs=${PREFIX}/bin/${ISAPART64}/apxs"

download_source () {
    # tar and prog name disagreement
    pushd $TMPDIR > /dev/null

    logmsg "--- download source"
    wget -c https://${MIRROR}/${DLPATH}/${VER}.tar.gz
    mv ${VER}.tar.gz ${PROG}-${VER}.tar.gz
    tar xvpf ${PROG}-${VER}.tar.gz

    popd > /dev/null
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
