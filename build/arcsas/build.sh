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

PROG=arcsas                                 # App name
VER=1.00.00.04                              # App version
VERHUMAN=$VER-1                             # Human-readable version
#PVER=                                      # Branch (set in config.sh, override here if needed)
PKG=driver/storage/arcsas                   # Package name (e.g. library/foo)
SUMMARY="Areca SAS non-RAID HBA Driver and Utility"
DESC=${SUMMARY}
DEPENDS_IPS="system/kernel"
BUILD_DEPENDS_IPS="developer/versioning/git"

PREFIX=/usr
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
    [ -d ${TMPDIR}/staging/ ] && rm -rf ${TMPDIR}/staging/

    # fetch source
    mkdir ${TMPDIR}/staging/
    cd ${TMPDIR}/staging/
    wget -cq http://www.areca.us/support/s_solaris/non_driver/1.00.00.04-20120831.zip
    wget -cq http://www.areca.us/support/s_illumos/non_driver/cli/V1.9.0_120314/x86_64.zip
    wget -cq http://www.areca.us/support/s_illumos/non_driver/cli/V1.9.0_120314/i386.zip

    # expand source
    unzip 1.00.00.04-20120831.zip
    unzip 1.00.00.04-20120831/SUNWarcsas.zip
    unzip i386.zip
    unzip x86_64.zip
}

build32 () {
    pushd $TMPDIR > /dev/null

    # setting execution bits
    chmod +x staging/i386/cli32

    # cleanup
    rm -rf staging/SUNWarcsas/reloc/boot/

    popd > /dev/null
}

build64() {
    pushd $TMPDIR > /dev/null

    # setting execution bits
    chmod +x staging/x86_64/cli64

    popd > /dev/null
}

make_install() {
    logmsg "--- make install"
    logcmd mkdir -p $DESTDIR/etc/notices || \
        logerr "------ Failed to create directories."

    logcmd cp -r ${TMPDIR}/staging/SUNWarcsas/reloc/* $DESTDIR/ || \
        logerr "------ Failed to install drivers."

    logcmd mkdir -p $DESTDIR/usr/sbin/{i386,amd64} || \
        logerr "------ Failed to create architecture destination directory."
    logcmd cp ${TMPDIR}/staging/i386/cli32 $DESTDIR$PREFIX/sbin/i386/arcsas_cli || \
        logerr "------ Failed to install 32-bit cli."
    logcmd cp ${TMPDIR}/staging/x86_64/cli64 $DESTDIR$PREFIX/sbin/amd64/arcsas_cli || \
        logerr "------ Failed to install 64-bit cli."

    logcmd cp ${TMPDIR}/staging/SUNWarcsas/install/copyright $DESTDIR/etc/notices/COPYRIGHT.arcsas || \
        logerr "------ Failed to install COPYRIGHT file."
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
