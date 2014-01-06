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

# TODO
# - look at dtrace (--enable-dtrace --enable-hook-probes)

# main package config
PROG=httpd                                   # App name
VER=2.4.7                                    # App version
VERHUMAN=$VER-1                              # Human-readable version
#PVER=                                       # Branch (set in config.sh, override here if needed)
PKG=obd/server/apache/httpd                  # Package name (e.g. library/foo)
SUMMARY="The Apache HTTP Server Project is an effort to develop and maintain an open-source HTTP server for modern operating systems including UNIX and Windows NT. The goal of this project is to provide a secure, efficient and extensible server that provides HTTP services in sync with the current HTTP standards."
DESC="Does not come with DTrace probes!  -- ${SUMMARY}"

RUN_DEPENDS_IPS="obd/server/apache/base obd/server/apache/apr obd/server/apache/apr-util obd/server/apache/openssl obd/server/apache/zlib"
BUILD_DEPENDS_IPS="developer/build/autoconf obd/server/apache/apr obd/server/apache/apr-util obd/server/apache/openssl obd/server/apache/zlib"
BUILDARCH=both

PREFIX=${PREFIX}-apps/apache/httpd
PREFIX_LIB=$(echo ${PREFIX} | sed "s#/httpd#/shared#g")

# package specific
MIRROR=www.eu.apache.org
DLPATH=dist/httpd

# environment
LDFLAGS32="-L${PREFIX}/lib -R${PREFIX}/lib -L${PREFIX_LIB}/lib -R${PREFIX_LIB}/lib"
LDFLAGS64="-m64 -L${PREFIX}/lib/${ISAPART64} -R${PREFIX}/lib/${ISAPART64} -L${PREFIX_LIB}/lib/${ISAPART64} -R${PREFIX_LIB}/lib/${ISAPART64}"

reset_configure_opts
CONFIGURE_OPTS="--enable-v4-mapped --enable-mpms-shared=all --with-mpm=event --enable-mods-static=macro --enable-mods-shared=reallyall" 
CONFIGURE_OPTS_32=\
"--enable-layout=${ISAPART} "\
"--with-apr=${PREFIX_LIB}/bin/${ISAPART}/apr-1-config "\
"--with-apr-util=${PREFIX_LIB}/bin/${ISAPART}/apu-1-config "
CONFIGURE_OPTS_64=\
"--enable-layout=${ISAPART64} "\
"--with-apr=${PREFIX_LIB}/bin/${ISAPART64}/apr-1-config "\
"--with-apr-util=${PREFIX_LIB}/bin/${ISAPART64}/apu-1-config "

copy_config_layout() {
    logmsg "Copying config layout"
    sed "s#{{PREFIX}}#${PREFIX}#g" ${SRCDIR}/files/config.layout > ${TMPDIR}/${PROG}-${VER}/config.layout || \
        logerr "--- Failed to copy config.layout"
}

make_install_extras() {
    logmsg "--- make install extras"
    logcmd mkdir -p $DESTDIR/lib/svc/manifest/network/http || \
        logerr "------ Failed to create manifest directory."
    logcmd cp ${SRCDIR}/files/smf.xml $DESTDIR/lib/svc/manifest/network/http/httpd.xml || \
        logerr "------ Failed to copy apache httpd manifest."
    logcmd cp ${SRCDIR}/files/svc-httpd $DESTDIR/${PREFIX}/bin/svc-httpd || \
        logerr "------ Failed to copy apache svc-httpd wrapper."

    logcmd rm -rf ${DESTDIR}/${PREFIX}/conf/{original/,extra/,${ISAPART}/,${ISAPART64}/} || \
        logerr "-------- Failed to strip conf/."
    logcmd cp -r ${SRCDIR}/files/conf/* ${DESTDIR}/${PREFIX}/conf/ || \
        logerr "-------- Failed to copy default configuration."
}

init
prep_build
download_source ${DLPATH} ${PROG} ${VER}
patch_source
copy_config_layout
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
