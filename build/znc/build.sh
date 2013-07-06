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

PROG=znc                                    # App name
VER=1.0                                     # App version
VERHUMAN=$VER-4                             # Human-readable version
#PVER=                                      # Branch (set in config.sh, override here if needed)
PKG=network/znc                             # Package name (e.g. library/foo)
SUMMARY="ZNC, an advanced IRC bouncer that is left connected so an IRC client can disconnect/reconnect without losing the chat session."
DESC=${SUMMARY}
DEPENDS_IPS="library/security/openssl"

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

    # base
    export BASE=`pwd`

    # cleanup source
    [ -d ${TMPDIR}/src/ ] && rm -rf ${TMPDIR}/src/
    [ -d ${TMPDIR}/staging/ ] && rm -rf ${TMPDIR}/staging/

    # fetch source
    mkdir ${TMPDIR}/src
    wget -cq http://znc.in/releases/${PROG}-${VER}.tar.gz -O ${TMPDIR}/src/${PROG}-${VER}.tar.gz

    # expand source and patching
    tar xzf ${TMPDIR}/src/${PROG}-${VER}.tar.gz -C ${TMPDIR}/src
    cp patches/*.patch ${TMPDIR}/src/${PROG}-${VER}/
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

    logcmd cp ${BASE}/files/smf.xml  $DESTDIR$PREFIX/share/znc/service/smf_manifest.xml || \
        logerr "------ Failed to copy service manifest."
    logcmd cp ${BASE}/files/README  $DESTDIR$PREFIX/share/znc/service/README || \
        logerr "------ Failed to copy service readme."
    logcmd cp ${BASE}/files/znc-service-install  $DESTDIR$PREFIX/bin/ || \
        logerr "------ Failed to copy service installer."
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
