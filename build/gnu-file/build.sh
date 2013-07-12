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

PROG=file                                   # App name
VER=5.14                                    # App version
VERHUMAN=$VER-1                             # Human-readable version
#PVER=                                      # Branch (set in config.sh, override here if needed)
PKG=file/gnu-file                           # Package name (e.g. library/foo)
SUMMARY="file type guesses"
DESC="The file command is 'a file type guesser', it also provide libmagic to expose the functionaity to other applications."

RUN_DEPENDS_IPS=""
BUILD_DEPENDS_IPS=""

BUILDARCH=both

# Nothing to configure or build, just package
download_source () {
    cleanup_source

    # fetch source
    mkdir ${TMPDIR}/src

    logmsg "--- download source"
    wget -c ftp://ftp.astron.com/pub/file/${PROG}-${VER}.tar.gz -O ${TMPDIR}/src/${PROG}-${VER}.tar.gz

    # expand source
    logmsg "--- unpacking source"
    tar xzf ${TMPDIR}/src/${PROG}-${VER}.tar.gz -C ${TMPDIR}/src/
    cd ${TMPDIR}/src/${PROG}-${VER}/
    cp ${SRCDIR}/patches/* ${TMPDIR}/src/${PROG}/
    for p in `ls *.patch`; do
        patch -p1 < $p
    done

}

build32 () {
    pushd $TMPDIR > /dev/null

    export PATH=/opt/gcc-4.7.2/bin:$PATH
    export CPPFLAGS=-m32 -I/usr/include/pcre
    export LDFLAGS=-m32
    cd ${TMPDIR}/src/${PROG}-${VER}/
    make clean
    ./configure --prefix=${PREFIX}
    make
    mv src/.libs src/.libs-i386
    #make install

    popd > /dev/null
}

build64() {
    pushd $TMPDIR > /dev/null

    export PATH=/opt/gcc-4.7.2/bin:$PATH
    export CPPFLAGS=-m64 -I/usr/include/pcre
    export LDFLAGS=-m64
    cd ${TMPDIR}/src/${PROG}-${VER}/
    make clean
    ./configure --prefix=${PREFIX} --libdir=${PREFIX}/lib/amd64/
    make
    mv src/.libs src/.libs-amd64
    #make install

    popd > /dev/null
}

make_install() {
    logmsg "--- make install"
    logcmd mkdir -p $DESTDIR$PREFIX/bin/{i386,amd64} || \
        logerr "------ Failed to create architecture destination directory."
    logcmd mkdir -p $DESTDIR$PREFIX/lib/amd64 || \
        logerr "------ Failed to create architecture library directory."
    logcmd mkdir -p $DESTDIR$PREFIX/include || \
        logerr "------ Failed to create include directory."
    logcmd mkdir -p $DESTDIR$PREFIX/share/misc || \
        logerr "------ Failed to create misc directory."
    logcmd mkdir -p $DESTDIR$PREFIX/share/man/{man1,man3,man4} || \
        logerr "------ Failed to create man directory."

    logcmd cp ${TMPDIR}/src/${PROG}-${VER}/doc/file.1 $DESTDIR$PREFIX/share/man/man1/file.1 || \
        logerr "------ Failed to install file.1"
    logcmd cp ${TMPDIR}/src/${PROG}-${VER}/doc/libmagic.3 $DESTDIR$PREFIX/share/man/man3/libmagic.3 || \
        logerr "------ Failed to install libmagic.3"
    logcmd cp ${TMPDIR}/src/${PROG}-${VER}/doc/magic.4 $DESTDIR$PREFIX/share/man/man4/magic.4 || \
        logerr "------ Failed to install magic.4"

    logcmd cp ${TMPDIR}/src/${PROG}-${VER}/magic/magic.mgc $DESTDIR$PREFIX/share/misc/magic.mgc || \
        logerr "------ Failed to install magic.mgc"

    logcmd cp ${TMPDIR}/src/${PROG}-${VER}/src/magic.h $DESTDIR$PREFIX/include/magic.h || \
        logerr "------ Failed to install magic.h"

    logcmd cp ${TMPDIR}/src/${PROG}-${VER}/src/.libs-i386/libmagic* $DESTDIR$PREFIX/lib/ || \
        logerr "------ Failed to install i386 libs."
    logcmd cp ${TMPDIR}/src/${PROG}-${VER}/src/.libs-amd64/libmagic* $DESTDIR$PREFIX/lib/amd64/ || \
        logerr "------ Failed to install amd64 libs."

    logcmd cp ${TMPDIR}/src/${PROG}-${VER}/src/.libs-i386/file $DESTDIR$PREFIX/bin/i386 || \
        logerr "------ Failed to install i386 binaries."
    logcmd cp ${TMPDIR}/src/${PROG}-${VER}/src/.libs-amd64/file $DESTDIR$PREFIX/bin/amd64/ || \
        logerr "------ Failed to install amd64 binaries."

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
