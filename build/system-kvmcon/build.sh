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

PROG=kvmcon
VER=0.2
VERHUMAN=$VER-1
#PVER=                                      # Branch (set in config.sh, override here if needed)
PKG=obd/system/kvmcon                       # Package name (e.g. library/foo)
SUMMARY="Helper for kvmadm to connect to console, monitor or vnc sockets"
DESC="${SUMMARY}"

RUN_DEPENDS_IPS="obd/system/kvmadm obd/network/minicom obd/network/socat"
BUILD_DEPENDS_IPS=""

BUILDARCH=64

# package specific

make_install_extras() {
    logcmd mkdir -p $DESTDIR/$PREFIX/bin/amd64/ || \
        logerr "------ Failed to create bin directory."

    logcmd cp -r ${SRCDIR}/files/kvmcon $DESTDIR/$PREFIX/bin/amd64/ || \
        logerr "------ Failed to copy kvmcon."
}

init
prep_build
make_install_extras
make_isa_stub
prefix_updater
make_package
auto_publish
cleanup_source
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
