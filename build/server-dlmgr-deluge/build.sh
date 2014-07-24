#!/usr/bin/bash
#
# CDDL HEADER START
#
# The contents of this file are subject to the terms of the
# Common Development and Distribution License, Version 1.0 only
# (the "License"). You may not use this file except in compliance
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
# Copyright 2011-2012 OmniTI Computer Consulting, Inc. All rights reserved.
# Copyright 2013 Jorge Schrauwen.  All rights reserved.
# Use is subject to license terms.
#
# Load support functions
. ../../lib/functions.sh
. ../myfunc.sh

PROG=deluge
VER=1.3.7
PKG=obd/server/dlmgr/deluge
SUMMARY="Deluge is a full-featured  BitTorrent client for Linux, OS X, Unix and Windows."
DESC="$SUMMARY It uses  libtorrent in its backend and features multiple user-interfaces including: GTK+, web and console. It has been designed using the client server model with a daemon process that handles all the bittorrent activity. The Deluge daemon is able to run on headless machines with the user-interfaces being able to connect remotely from any platform."

RUN_DEPENDS_IPS="runtime/python-26 library/ncurses library/python-2/chardet library/python-2/pyxdg library/python-2/twisted library/python-2/zope.interface library/python-2/pyopenssl-26 library/python-2/mako library/python-2/gettext library/python-2/setproctitle obd/file/intltool obd/library/libtorrent obd/server/dlmgr/base"
BUILD_DEPENDS_IPS="runtime/python-26 library/ncurses obd/library/libtorrent obd/file/intltool"

PREFIX=${PREFIX}-apps

download_source() {
    logmsg "Downloading Source"

    cd ${TMPDIR}
    wget -c http://download.deluge-torrent.org/source/${PROG}-${VER}.tar.gz -O ${PROG}-${VER}.tar.gz

    tar xvf ${PROG}-${VER}.tar.gz
}

make_install_extras() {
    logmsg "--- make install extras"
    logcmd mkdir -p ${DESTDIR}${PREFIX}/ || \
        logerr "------ Failed to create destination directory."
    logcmd mkdir -p ${DESTDIR}${PREFIX}/dlmgr/.config/deluge || \
        logerr "------ Failed to create app config directory."
    logcmd mkdir -p $DESTDIR/lib/svc/manifest/network || \
        logerr "------ Failed to create manifest directory."
    logcmd cp -r ${SRCDIR}/files/deluged.xml $DESTDIR/lib/svc/manifest/network/deluged.xml || \
        logerr "------ Failed to copy deluged manifest."
    logcmd cp -r ${SRCDIR}/files/deluge-web.xml $DESTDIR/lib/svc/manifest/network/deluge-web.xml || \
        logerr "------ Failed to copy deluge-web manifest."

    logcmd rm $DESTDIR/usr/bin/deluge || \
        logerr "------ Failed to remove gtk binaries."
    logcmd rm $DESTDIR/usr/bin/deluge-gtk || \
        logerr "------ Failed to remove gtk binaries."
    logcmd rm $DESTDIR/usr/share/man/man1/deluge.1 || \
        logerr "------ Failed to remove gtk manpages."
    logcmd rm $DESTDIR/usr/share/man/man1/deluge-gtk.1 || \
        logerr "------ Failed to remove gtk manpages."
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
python_build
make_install_extras
prefix_updater
make_package
auto_publish
clean_up
