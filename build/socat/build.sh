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

PROG=socat                                  # App name
VER=1.7.1.3                                 # App version
VERHUMAN=$VER-1                             # Human-readable version
#PVER=                                      # Branch (set in config.sh, override here if needed)
PKG=network/socat                           # Package name (e.g. library/foo)
SUMMARY="socat is a tool that connects different types of sockets together." # One-liner, must be filled in
DESC="socat is a tool that connects different types of sockets together."
DEPENDS_IPS=""

BUILDARCH=both

# Nothing to configure or build, just package
download_source () {
    cleanup_source

    # fetch source
    mkdir ${TMPDIR}/src

    logmsg "--- download source"
    wget -c http://www.dest-unreach.org/socat/download/${PROG}-${VER}.tar.gz -O ${TMPDIR}/src/${PROG}-${VER}.tar.gz

    # expand source
    logmsg "--- unpacking source"
    tar xzf ${TMPDIR}/src/${PROG}-${VER}.tar.gz -C ${TMPDIR}/src/
    cd ${TMPDIR}/src/${PROG}-${VER}/
    cat ${SRCDIR}/patches/fixheader.patch | patch

}

build32 () {
    pushd $TMPDIR > /dev/null

    export PATH=/opt/gcc-4.7.2/bin:$PATH
    export CFLAGS=-m32
    cd ${TMPDIR}/src/${PROG}-${VER}/
    make clean
    ./configure --prefix=${TMPDIR}/staging/i386
    make
    make install

    popd > /dev/null
}

build64() {
    pushd $TMPDIR > /dev/null

    export PATH=/opt/gcc-4.7.2/bin:$PATH
    export CFLAGS=-m64
    cd ${TMPDIR}/src/${PROG}-${VER}/
    make clean
    ./configure --prefix=${TMPDIR}/staging/amd64
    make
    make install

    popd > /dev/null
}

make_install() {
    logmsg "--- make install"
    logcmd mkdir -p $DESTDIR$PREFIX/bin/{i386,amd64} || \
        logerr "------ Failed to create architecture destination directory."

    logcmd install -m 755 ${TMPDIR}/staging/i386/bin/socat $DESTDIR$PREFIX/bin/i386 || \
        logerr "------ Failed to install socat."
    logcmd install -m 755 ${TMPDIR}/staging/i386/bin/procan $DESTDIR$PREFIX/bin/i386 || \
        logerr "------ Failed to install procan."
    logcmd install -m 755 ${TMPDIR}/staging/i386/bin/filan $DESTDIR$PREFIX/bin/i386 || \
        logerr "------ Failed to install filan."

    logcmd install -m 755 ${TMPDIR}/staging/amd64/bin/socat $DESTDIR$PREFIX/bin/amd64 || \
        logerr "------ Failed to install socat."
    logcmd install -m 755 ${TMPDIR}/staging/amd64/bin/procan $DESTDIR$PREFIX/bin/amd64 || \
        logerr "------ Failed to install procan."
    logcmd install -m 755 ${TMPDIR}/staging/amd64/bin/filan $DESTDIR$PREFIX/bin/amd64 || \
        logerr "------ Failed to install filan."

    logcmd mkdir -p $DESTDIR$PREFIX/share/man/man1 || \
        logerr "------ Failed to create man1."
    logcmd install -m 755 ${TMPDIR}/src/${PROG}-${VER}/doc/socat.1 $DESTDIR$PREFIX/share/man/man1/ || \
        logerr "------ Failed to install man pages."
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
