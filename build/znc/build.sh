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

PROG=znc                                    # App name
VER=1.0                                     # App version
VERHUMAN=$VER-4                             # Human-readable version
#PVER=                                      # Branch (set in config.sh, override here if needed)
PKG=network/znc                             # Package name (e.g. library/foo)
SUMMARY="An advanced IRC proxy"
DESC="ZNC, an advanced IRC proxy that is left connected so an IRC client can disconnect/reconnect without losing the chat session."
DEPENDS_IPS=""

BUILDARCH=both

# Nothing to configure or build, just package
download_source () {
    cleanup_source

    # fetch source
    logmsg "--- download source"
    mkdir ${TMPDIR}/src
    wget -c http://znc.in/releases/${PROG}-${VER}.tar.gz -O ${TMPDIR}/src/${PROG}-${VER}.tar.gz

    # expand source and patching
    logmsg "--- unpacking source"
    tar xzf ${TMPDIR}/src/${PROG}-${VER}.tar.gz -C ${TMPDIR}/src
    cp ${SRCDIR}/patches/*.patch ${TMPDIR}/src/${PROG}-${VER}/
    cd ${TMPDIR}/src/${PROG}-${VER}/
    for p in `ls *.patch`; do
        patch -p1 < $p
    done

}

build32 () {
    pushd $TMPDIR > /dev/null

    export PATH=/opt/gcc-4.7.2/bin:$PATH
    export CFLAGS=-m32
    export CXXFLAGS=-m32
    export LDFLAGS=-m32
    cd ${TMPDIR}/src/${PROG}-${VER}/
    [ -e config.nice ] && rm config.nice
    gmake clean
    ./configure --prefix=${TMPDIR}/staging/i386 --with-openssl=/usr/lib --with-module-prefix=${TMPDIR}/staging/i386/libexec/znc
    gmake
    gmake install

    gmake clean
    ./configure --prefix=/opt/obd --with-openssl=/usr/lib --with-module-prefix=/opt/obd/libexec/znc
    gmake
    chmod +x znc-buildmod
    cp znc ${TMPDIR}/staging/i386/bin/
    cp znc-buildmod ${TMPDIR}/staging/i386/bin/
    sed "s#${TMPDIR}/staging/i386#/opt/obd#" ${TMPDIR}/staging/i386/lib/pkgconfig/znc.pc > ${TMPDIR}/staging/i386/lib/pkgconfig/znc.pc-sed
    mv ${TMPDIR}/staging/i386/lib/pkgconfig/znc.pc-sd ${TMPDIR}/staging/i386/lib/pkgconfig/znc.pc

    popd > /dev/null
}

build64() {
    pushd $TMPDIR > /dev/null

    export PATH=/opt/gcc-4.7.2/bin:$PATH
    export CFLAGS=-m64
    export CXXFLAGS=-m64
    export LDFLAGS=-m64
    cd ${TMPDIR}/src/${PROG}-${VER}/
    [ -e config.nice ] && rm config.nice
    gmake clean
    ./configure --prefix=${TMPDIR}/staging/amd64 --with-openssl=/usr/lib --with-module-prefix=${TMPDIR}/staging/amd64/libexec/amd64/znc
    gmake
    gmake install

    gmake clean
    ./configure --prefix=/opt/obd --with-openssl=/usr/lib --with-module-prefix=/opt/obd/libexec/amd64/znc
    gmake
    chmod +x znc-buildmod
    cp znc ${TMPDIR}/staging/amd64/bin/
    cp znc-buildmod ${TMPDIR}/staging/amd64/bin/

    popd > /dev/null
}

make_install() {
    logmsg "--- make install"
    logcmd mkdir -p $DESTDIR$PREFIX/bin/{i386,amd64} || \
        logerr "------ Failed to create architecture destination directory for bin."
    logcmd mkdir -p $DESTDIR$PREFIX/share/znc/service || \
        logerr "------ Failed to create service directory for bin."
    logcmd cp -r ${TMPDIR}/staging/amd64/* $DESTDIR$PREFIX/ || \
        logerr "------ Failed to copy amd64 binaries."

    logcmd mv $DESTDIR$PREFIX/bin/znc* $DESTDIR$PREFIX/bin/amd64 || \
        logerr "------ Failed to move amd64 binaries."
    logcmd cp -r ${TMPDIR}/staging/i386/bin/* $DESTDIR$PREFIX/bin/i386 || \
        logerr "------ Failed to copy i386 binaries."

    logcmd cp -r ${TMPDIR}/staging/i386/libexec/znc $DESTDIR$PREFIX/libexec/ || \
        logerr "------ Failed to copy i386 modules."

    logcmd cp ${SRCDIR}/files/smf.xml  $DESTDIR$PREFIX/share/znc/service/smf_manifest.xml || \
        logerr "------ Failed to copy service manifest."
    logcmd cp ${SRCDIR}/files/README  $DESTDIR$PREFIX/share/znc/service/README || \
        logerr "------ Failed to copy service readme."
    logcmd cp ${SRCDIR}/files/znc-service-install  $DESTDIR$PREFIX/bin/ || \
        logerr "------ Failed to copy service installer."
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
