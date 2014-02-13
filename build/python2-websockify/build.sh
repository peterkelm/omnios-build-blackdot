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

PROG=websockify
VER=`date +%Y%m%d`
PKG=library/python-2/websockify
SUMMARY="Websockify is a WebSocket to TCP proxy/bridge. This allows a browser to connect to any application/server/service. Implementations in Python, C, Node.js and Ruby."
DESC="${SUMMARY}"

RUN_DEPENDS_IPS="runtime/python-26 library/python-2/imaging library/python-2/twisted library/python-2/zope.interface"
BUILD_DEPENDS_IPS="runtime/python-26"

download_source() {
    logmsg "Downloading Source"

    cd ${TMPDIR}
    wget https://github.com/kanaka/websockify/archive/master.zip
    unzip master.zip
    mv ${PROG}-master ${PROG}-${VER}
    rm master.zip
}

make_install_extras() {
    logmsg "--- make install"
    logcmd mkdir -p ${DESTDIR}${PREFIX}/ || \
        logerr "------ Failed to create destination directory."
    logcmd mv ${DESTDIR}/usr/bin ${DESTDIR}${PREFIX}/ || \
        logerr "------ Failed to move bin directory."
    logcmd mv ${DESTDIR}/usr/share ${DESTDIR}${PREFIX}/ || \
        logerr "------ Failed to move share directory."

}

init
download_source $PROG $PROG $VER
patch_source
prep_build
python_build
make_install_extras
make_package
auto_publish
clean_up
