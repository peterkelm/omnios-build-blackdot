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

PROG=znc                                    # App name
VER=1.6.0                                     # App version
VERHUMAN=$VER-4                             # Human-readable version
#PVER=                                      # Branch (set in config.sh, override here if needed)
PKG=obd/server/irc/znc                      # Package name (e.g. library/foo)
SUMMARY="An advanced IRC proxy"
DESC="ZNC, an advanced IRC proxy that is left connected so an IRC client can disconnect/reconnect without losing the chat session."

RUN_DEPENDS_IPS="library/security/openssl"
BUILD_DEPENDS_IPS=""

BUILDARCH=both

MIRROR=znc.in
DLPATH=releases


# Nothing to configure or build, just package
make_install_extras() {
    logmsg "--- make install extras"
    logcmd mkdir -p $DESTDIR$PREFIX/share/znc/service || \
        logerr "------ Failed to create service directory for bin."
    logcmd cp ${SRCDIR}/files/smf.xml  $DESTDIR$PREFIX/share/znc/service/smf_manifest.xml || \
        logerr "------ Failed to copy service manifest."
    logcmd cp ${SRCDIR}/files/README  $DESTDIR$PREFIX/share/znc/service/README || \
        logerr "------ Failed to copy service readme."
    logcmd cp ${SRCDIR}/files/znc-service-install  $DESTDIR$PREFIX/bin/ || \
        logerr "------ Failed to copy service installer."
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
