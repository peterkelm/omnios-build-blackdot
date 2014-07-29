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
PROG=mod_perl                                # App name
VER=2.0.8                                    # App version
VERHUMAN=$VER-1                              # Human-readable version
#PVER=                                       # Branch (set in config.sh, override here if needed)
PKG=obd/server/apache/httpd/mod_perl         # Package name (e.g. library/foo)
SUMMARY="mod_perl brings together two of the most powerful and mature technologies available to the web professional today."
DESC="${SUMMARY}"

RUN_DEPENDS_IPS="obd/server/apache/base obd/server/apache/httpd"
BUILD_DEPENDS_IPS="developer/build/autoconf obd/server/apache/httpd"
BUILDARCH=both

PREFIX=${PREFIX}-apps/apache/httpd
PREFIX_LIB=$(echo ${PREFIX} | sed "s#/httpd#/shared#g")

# package specific
MIRROR=apache.cu.be
DLPATH=perl

# environment
LDFLAGS32="-L${PREFIX}/lib -R${PREFIX}/lib -L${PREFIX_LIB}/lib -R${PREFIX_LIB}/lib"
LDFLAGS64="-m64 -L${PREFIX}/lib/${ISAPART64} -R${PREFIX}/lib/${ISAPART64} -L${PREFIX_LIB}/lib/${ISAPART64} -R${PREFIX_LIB}/lib/${ISAPART64}"

build32() {
    pushd $TMPDIR/$BUILDDIR > /dev/null
    logmsg "Building 32-bit"
    make_clean
    logmsg "--- Makefile.PL"
    export ISALIST=i386
    logcmd /usr/bin/perl Makefile.PL MP_APXS=${PREFIX}/bin/${ISAPART64}/apxs MP_APR_CONFIG=${PREFIX_LIB}/bin/${ISAPART64}/apr-1-config INSTALLDIRS=vendor || \
        logerr "--- Makefile.PL failed"
    logmsg "--- make"
    logcmd $MAKE || logerr "--- make failed"
    logmsg "--- make install"
    logcmd $MAKE DESTDIR=${DESTDIR} install || logerr "--- make install failed"
    export ISALIST=
    popd > /dev/null
}

build64() {
    pushd $TMPDIR/$BUILDDIR > /dev/null
    logmsg "Building 64-bit"
    make_clean
    logmsg "--- Makefile.PL"
    export ISALIST=amd64
    logcmd /usr/bin/perl Makefile.PL MP_APXS=${PREFIX}/bin/${ISAPART64}/apxs MP_APR_CONFIG=${PREFIX_LIB}/bin/${ISAPART64}/apr-1-config INSTALLDIRS=vendor || \
        logerr "--- Makefile.PL failed"
    logmsg "--- make"
    logcmd $MAKE || logerr "--- make failed"
    logmsg "--- make install"
    logcmd $MAKE DESTDIR=${DESTDIR} install || logerr "--- make install failed"
    export ISALIST=
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
