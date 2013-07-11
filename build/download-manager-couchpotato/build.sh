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

PROG=CouchPotato                             # App name
VER=`date +%Y%m%d`                           # App version
VERHUMAN=$VER-1                              # Human-readable version
#PVER=                                       # Branch (set in config.sh, override here if needed)
PKG=network/download-manager/couchpotato     # Package name (e.g. library/foo)
SUMMARY="An automatic NZB and torrent downloader, just fill in what you want to see and CouchPotato will add it to your 'want to watch'-list. Every day it will search through multiple NZBs & Torrents sites, looking for the best possible match."
DESC=${SUMMARY}

RUN_DEPENDS_IPS=""
BUILD_DEPENDS_IPS="developer/versioning/git"

PREFIX=${PREFIX}-apps

# Nothing to configure or build, just package
download_source () {
    cleanup_source

    # fetch source
    mkdir ${TMPDIR}/src
    cd ${TMPDIR}/src

    logmsg "--- checkout source"
    git clone https://github.com/RuudBurger/CouchPotatoServer.git ${PROG}

}

make_install() {
    logmsg "--- make install"
    logcmd mkdir -p ${DESTDIR}${PREFIX}/ || \
        logerr "------ Failed to create destination directory."
    logcmd mkdir -p ${DESTDIR}${PREFIX}/dlmgr/couchpotato || \
        logerr "------ Failed to create app directory."
    logcmd mkdir -p ${DESTDIR}${PREFIX}/dlmgr/.config/couchpotato || \
        logerr "------ Failed to create app config directory."
    logcmd mkdir -p $DESTDIR/lib/svc/manifest/network || \
        logerr "------ Failed to create manifest directory."

    logcmd cp -r ${TMPDIR}/src/${PROG}/* ${DESTDIR}${PREFIX}/dlmgr/couchpotato/ || \
        logerr "------ Failed to copy app."
    logcmd cp -r ${SRCDIR}/files/couchpotato.xml $DESTDIR/lib/svc/manifest/network/ || \
        logerr "------ Failed to copy manifest."
}

init
prep_build
download_source
make_install
make_package
clean_up
cleanup_source

# Vim hints
# vim:ts=4:sw=4:et:
