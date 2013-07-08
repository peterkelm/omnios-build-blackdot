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
# Use is subject to license terms.
#
# Load support functions
. ../../lib/functions.sh

PROG=par2cmdline                            # App name
VER=0.4                                     # App version
VERHUMAN=$VER-1                             # Human-readable version
#PVER=                                      # Branch (set in config.sh, override here if needed)
PKG=archiver/par2cmdline                    # Package name (e.g. library/foo)
SUMMARY="Providing a tool to apply the data-recovery capability concepts of RAID-like systems to the posting & recovery of multi-part archives on Usenet"
DESC=${SUMMARY}
DEPENDS_IPS=""

BUILDARCH=both

# Nothing to configure or build, just package
prep_build () {
    logmsg "Preparing for build"

    # Get the current date/time for the package timestamp
    DATETIME=`TZ=UTC /usr/bin/date +"%Y%m%dT%H%M%SZ"`

    logmsg "--- Creating temporary install dir"
    # We might need to encode some special chars
    PKGE=$(url_encode $PKG)
    # For DESTDIR the '%' can cause problems for some install scripts
    PKGD=${PKGE//%/_}
    DESTDIR=$DTMPDIR/${PKGD}_pkg
    if [[ -z $DONT_REMOVE_INSTALL_DIR ]]; then
        logcmd chmod -R u+w $DESTDIR > /dev/null 2>&1
        logcmd rm -rf $DESTDIR || \
            logerr "Failed to remove old temporary install dir"
        mkdir -p $DESTDIR || \
            logerr "Failed to create temporary install dir"
    fi

    # cleanup source
    logmsg "Cleanup"
    [ -d ${TMPDIR}/src/ ] && rm -rf ${TMPDIR}/src/
    [ -d ${TMPDIR}/staging/ ] && rm -rf ${TMPDIR}/staging/

    # fetch source
    mkdir ${TMPDIR}/src

    # expand source
    tar xzf src/${PROG}-${VER}.tar.gz -C ${TMPDIR}/src
    cp patches/* ${TMPDIR}/src/${PROG}-${VER}/
    cd ${TMPDIR}/src/${PROG}-${VER}/
    for p in `ls *.patch`; do
	patch < $p
    done

}

build32 () {
    pushd $TMPDIR > /dev/null

    export PATH=/opt/gcc-4.7.2/bin:$PATH
    export CFLAGS=-m32
    export CXXFLAGS=${CFLAGS}
    cd ${TMPDIR}/src/${PROG}-${VER}/
    [ -e config.nice ] && rm config.nice
    ./configure --prefix=${TMPDIR}/staging/i386
    make clean
    make
    make install

    popd > /dev/null
}

build64() {
    pushd $TMPDIR > /dev/null

    export PATH=/opt/gcc-4.7.2/bin:$PATH
    export CFLAGS=-m64
    export CXXFLAGS=${CFLAGS}
    [ -e config.nice ] && rm config.nice
    cd ${TMPDIR}/src/${PROG}-${VER}/
    ./configure --prefix=${TMPDIR}/staging/amd64
    make clean
    make
    make install

    popd > /dev/null
}

make_install() {
    logmsg "--- make install"
    logcmd mkdir -p $DESTDIR$PREFIX/bin/{i386,amd64} || \
        logerr "------ Failed to create architecture destination directory."

    logcmd cp ${TMPDIR}/staging/i386/bin/* $DESTDIR$PREFIX/bin/i386/ || \
        logerr "------ Failed to install i386 binaries."
    logcmd cp ${TMPDIR}/staging/amd64/bin/* $DESTDIR$PREFIX/bin/amd64/ || \
        logerr "------ Failed to install amd64 binaries."
}

init
prep_build
build
make_install
make_isa_stub
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
