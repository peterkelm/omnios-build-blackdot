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

PROG=vncdotool
VER=0.8.0
PKG=library/python-2/vncdotool
SUMMARY="Command line VNC client and library."
DESC="vncdotool is a command line VNC client. It can be useful to automating interactions with virtual machines or hardware devices that are otherwise difficult to control."

RUN_DEPENDS_IPS="runtime/python-26 library/python-2/imaging library/python-2/twisted library/python-2/zope.interface"
BUILD_DEPENDS_IPS="runtime/python-26"

download_source() {
    logmsg "Downloading Source"

    cd ${TMPDIR}
    wget -c https://pypi.python.org/packages/source/${PROG:0:1}/${PROG}/${PROG}-${VER}.tar.gz
    tar xvpf ${PROG}-${VER}.tar.gz

    #wget https://github.com/sibson/vncdotool/archive/master.zip
    #unzip master.zip
    #mv vncdotool-master ${PROG}-${VER}
    #rm master.zip
}

make_install_extras() {
    logmsg "--- make install"
    logcmd mkdir -p ${DESTDIR}${PREFIX}/ || \
        logerr "------ Failed to create destination directory."
    logcmd mv ${DESTDIR}/usr/bin ${DESTDIR}${PREFIX}/ || \
        logerr "------ Failed to move bin directory."

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
