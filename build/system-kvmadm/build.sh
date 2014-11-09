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

PROG=kvmadm
VER=master
VERHUMAN=`date +%Y%m%d%H%M%S`
#PVER=                                      # Branch (set in config.sh, override here if needed)
PKG=obd/system/kvmadm                       # Package name (e.g. library/foo)
SUMMARY="Manage KVM instances under SMF control"
DESC="Kvmadm takes care of setting up kvm instances on illumos derived operating systems with SMF support. The kvm hosts run under smf control. Each host will show up as a separate SMF service instance."

RUN_DEPENDS_IPS=""
BUILD_DEPENDS_IPS=""

BUILDARCH=64

# package specific
MIRROR=github.com
DLPATH=hadfl/kvmadm/archive/master.zip
CONFIGURE_OPTS="--disable-svcimport"

save_function download_source download_source_orig
download_source() {
    pushd $TMPDIR > /dev/null

    logmsg "--- removing old source"
    [ -e "${PROG}-${VER}.zip" ] && rm "${PROG}-${VER}.zip"
    [ -d "${PROG}-${VER}" ] && rm -rf ${PROG}-${VER}/

    logmsg "--- checkout source"
    wget -c https://github.com/hadfl/kvmadm/archive/master.zip -O ${PROG}-${VER}.zip

    logmsg "--- unpacking source"
    unzip master.zip

    popd > /dev/null
}
make_install_extras() {
    logcmd mkdir -p $DESTDIR/lib/svc/manifest/ || \
        logerr "------ Failed to create manifest directory."
    logcmd cp -r ${TMPDIR}/${PROG}-${VER}/smf/system-kvm.xml $DESTDIR/lib/svc/manifest/system-kvm.xml || \
        logerr "------ Failed to copy manifest."
}

init
prep_build
download_source ${DLPATH} ${PROG} ${VER}
patch_source
build
make_install_extras
make_isa_stub
prefix_updater
VER=`date +%Y%m%d%H%M%S`
make_package
auto_publish
cleanup_source
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
