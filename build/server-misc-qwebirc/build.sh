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

PROG=qwebirc
VER=`date +%Y%m%d`
PKG=obd/server/misc/qwebirc
SUMMARY="qwebirc is a fast, easy to use, free and open source IRC client designed by and originally just for the QuakeNet IRC network."
DESC="$SUMMARY"
PREFIX=${PREFIX}-apps/

RUN_DEPENDS_IPS="runtime/python-26 library/python-2/zope.interface python-2/pyopenssl-26 library/python-2/twisted"
BUILD_DEPENDS_IPS=""

BUILDARCH=32

download_source() {
    logmsg "Downloading Source"

    cd ${TMPDIR}
    wget -c http://qwebirc.org/download-default-gz -O ${PROG}-${VER}.tar.gz
    tar xvf ${PROG}-${VER}.tar.gz
}

build32() {
    logmsg "--- staging qwebirc"
    logcmd mkdir -p $DESTDIR/${PREFIX} || \
        logerr "------ Failed to create prefix directory."
    logcmd mv ${PROG}-*/ $DESTDIR/${PREFIX}/${PROG}/ || \
        logerr "------ Failed to move application."   
}

init
prep_build
download_source ${DLPATH} ${PROG} ${VER}
build
prefix_updater
make_package
auto_publish
cleanup_source
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
