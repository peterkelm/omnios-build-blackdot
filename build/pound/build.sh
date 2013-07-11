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

PROG=Pound                                  # App name
VER=2.6                                     # App version
VERHUMAN=$VER-1                             # Human-readable version
#PVER=                                      # Branch (set in config.sh, override here if needed)
PKG=network/pound                           # Package name (e.g. library/foo)
SUMMARY="The Pound program is a reverse proxy, load balancer and HTTPS front-end for Web server(s)."
DESC="${SUMMARY} Pound was developed to enable distributing the load among several Web-servers and to allow for a convenient SSL wrapper for those Web servers that do not offer it natively."

RUN_DEPENDS_IPS=""
BUILD_DEPENDS_IPS=""

BUILDARCH=both

# Nothing to configure or build, just package
download_source () {
    cleanup_source

    # fetch source
    mkdir ${TMPDIR}/src

    logmsg "--- download source"
    wget -c http://www.apsis.ch/pound/${PROG}-${VER}.tgz -O ${TMPDIR}/src/${PROG}-${VER}.tar.gz

    # expand source
    logmsg "--- unpacking source"
    tar xzf ${TMPDIR}/src/${PROG}-${VER}.tar.gz -C ${TMPDIR}/src/
    cd ${TMPDIR}/src/${PROG}-${VER}/

}

build32 () {
    pushd $TMPDIR > /dev/null

    export PATH=/opt/gcc-4.7.2/bin:$PATH
    export CFLAGS=-m32
    export LDFLAGS=-m32
    cd ${TMPDIR}/src/${PROG}-${VER}/
    make clean
    ./configure --prefix=/opt/obd --with-ssl=/usr/lib
    make
    mkdir -p ${TMPDIR}/staging/i386/sbin
    cp pound ${TMPDIR}/staging/i386/sbin/
    cp poundctl ${TMPDIR}/staging/i386/sbin/

    popd > /dev/null
}

build64() {
    pushd $TMPDIR > /dev/null

    export PATH=/opt/gcc-4.7.2/bin:$PATH
    export CFLAGS=-m64
    export LDFLAGS=-m64
    cd ${TMPDIR}/src/${PROG}-${VER}/
    make clean
    ./configure --prefix=/opt/obd --with-ssl=/usr/lib
    make
    mkdir -p ${TMPDIR}/staging/amd64/sbin
    cp pound ${TMPDIR}/staging/amd64/sbin/
    cp poundctl ${TMPDIR}/staging/amd64/sbin/

    popd > /dev/null
}

make_install() {
    logmsg "--- make install"
    logcmd mkdir -p $DESTDIR$PREFIX/sbin/{i386,amd64} || \
        logerr "------ Failed to create architecture destination directory."
    logcmd  cp -r ${TMPDIR}/staging/amd64/sbin/* $DESTDIR$PREFIX/sbin/amd64/ || \
        logerr "------ Failed to copy amd64 binaries."
    logcmd  cp -r ${TMPDIR}/staging/i386/sbin/* $DESTDIR$PREFIX/sbin/i386/ || \
        logerr "------ Failed to copy i385 binaries."

    logcmd mkdir -p $DESTDIR/lib/svc/manifest/network || \
        logerr "------ Failed to create manifest directory."
    logcmd cp -r ${SRCDIR}/files/pound.xml $DESTDIR/lib/svc/manifest/network/ || \
        logerr "------ Failed to copy manifest."

    logcmd mkdir -p $DESTDIR$PREFIX/share/man/man8 || \
        logerr "------ Failed to create manual directory."
    logcmd cp -r ${TMPDIR}/src/${PROG}-${VER}/*.8 $DESTDIR$PREFIX/share/man/man8/ || \
        logerr "------ Failed to copy man pages."

    logcmd mkdir -p $DESTDIR$PREFIX/etc || \
        logerr "------ Failed to create manual directory."
    logcmd cp -r ${SRCDIR}/files/pound.cfg $DESTDIR$PREFIX/etc/pound.cfg.example || \
        logerr "------ Failed to copy config."

}

init
prep_build
download_source
build
make_install
make_isa_stub
make_package
clean_up
cleanup_source

# Vim hints
# vim:ts=4:sw=4:et:
