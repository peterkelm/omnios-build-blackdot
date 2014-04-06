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

PROG=netatalk                               # App name
VER=3.1.1                                   # App version
VERHUMAN=$VER-1                             # Human-readable version
#PVER=                                      # Branch (set in config.sh, override here if needed)
PKG=obd/server/misc/netatalk                # Package name (e.g. library/foo)
SUMMARY="Netatalk is a freely-available Open Source AFP fileserver."
DESC="${SUMMARY} A *NIX/*BSD system running Netatalk is capable of serving many Macintosh clients simultaneously as an AppleShare file server (AFP)."

RUN_DEPENDS_IPS="omniti/database/bdb service/network/dns/mdns system/library/security/libgcrypt"
BUILD_DEPENDS_IPS="${RUN_DEPENDS_IPS}"

BUILDARCH=both

# package specifics
MIRROR=downloads.sourceforge.net
#DLPATH=project/netatalk/netatalk/${VER:0:3}
DLPATH=project/netatalk/netatalk/${VER}

# environment
reset_configure_opts
CFLAGS32="${CFLAGS32} -I/opt/omni/include"
CFLAGS64="${CFLAGS64} -I/opt/omni/include/${ISAPART64}"
CPPFLAGS32="${CPPFLAGS32} -I/opt/omni/include"
CPPFLAGS64="${CPPFLAGS64} -I/opt/omni/include/${ISAPART64}"
CXXFLAGS32="${CXXFLAGS32} -I/opt/omni/include"
CXXFLAGS64="${CXXFLAGS64} -I/opt/omni/include/${ISAPART64}"
LDFLAGS32="-L${PREFIX}/lib -R${PREFIX}/lib -L/opt/omni/lib -R/opt/omni/lib "
LDFLAGS64="-m64 -L${PREFIX}/lib/${ISAPART64} -R${PREFIX}/lib/${ISAPART64} -L/opt/omni/lib/$ISAPART64 -R/opt/omni/lib/$ISAPART64 "
CONFIGURE_OPTS="--with-dtrace --with-bdb=/opt/omni --with-init-style=solaris"

make_install_extras() {
    logmsg "--- make install extras"
    logcmd gsed -i 's#amd64/##gi' $DESTDIR/lib/svc/manifest/network/netatalk.xml || \
        logerr "------ Failed to fix manifest"
}

init
prep_build
download_source ${DLPATH} ${PROG} ${VER}
patch_source
build
make_install_extras
make_isa_stub
prefix_updater
make_package
auto_publish
cleanup_source
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
