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

PROG=Headphones                              # App name
VER=`date +%Y%m%d`                           # App version
VERHUMAN=$VER-1                              # Human-readable version
#PVER=                                       # Branch (set in config.sh, override here if needed)
PKG=obd/server/dlmgr/headphones              # Package name (e.g. library/foo)
SUMMARY="Automatic music downloader for SABnzbd."
DESC=${SUMMARY}

RUN_DEPENDS_IPS="runtime/python-26 library/python-2/cheetah network/download-manager/base"
BUILD_DEPENDS_IPS="developer/versioning/git"

PREFIX=/opt/obd

# Nothing to configure or build, just package
download_source () {
    pushd $TMPDIR > /dev/null
    
    logmsg "--- checkout source"
    git clone https://github.com/rembo10/headphones.git ${PROG}-${VER}

    popd > /dev/null
}

make_install() {
    logmsg "--- make install"
    logcmd mkdir -p ${DESTDIR}${PREFIX}/ || \
        logerr "------ Failed to create destination directory."
    logcmd mkdir -p ${DESTDIR}${PREFIX}/dlmgr/headphones || \
        logerr "------ Failed to create app directory."
    logcmd mkdir -p ${DESTDIR}${PREFIX}/dlmgr/.config/headphones || \
        logerr "------ Failed to create app config directory."
    logcmd mkdir -p $DESTDIR/lib/svc/manifest/network || \
        logerr "------ Failed to create manifest directory."

    logcmd cp -r ${TMPDIR}/${PROG}-${VER}/* ${DESTDIR}${PREFIX}/dlmgr/headphones/ || \
        logerr "------ Failed to copy app."
    logcmd cp -r ${SRCDIR}/files/smf.xml $DESTDIR/lib/svc/manifest/network/headphones.xml || \
        logerr "------ Failed to copy manifest."
}

init
auto_publish_wipe
prep_build
download_source
make_install
make_package
clean_up
cleanup_source
auto_publish

# Vim hints
# vim:ts=4:sw=4:et:
