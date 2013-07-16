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

PROG=Pound                                  # App name
VER=2.6                                     # App version
VERHUMAN=$VER-1                             # Human-readable version
#PVER=                                      # Branch (set in config.sh, override here if needed)
PKG=obd/server/web/pound                   # Package name (e.g. library/foo)
SUMMARY="The Pound program is a reverse proxy, load balancer and HTTPS front-end for Web server(s)."
DESC="${SUMMARY} Pound was developed to enable distributing the load among several Web-servers and to allow for a convenient SSL wrapper for those Web servers that do not offer it natively."

RUN_DEPENDS_IPS=""
BUILD_DEPENDS_IPS=""

BUILDARCH=both

# package specifics
MIRROR=www.apsis.ch
DLPATH=pound/
CONFIGURE_OPTS=--with-ssl=/usr/lib

# Nothing to configure or build, just package
make_install() {
    logmsg "--- make install"
    logcmd pfexec $MAKE DESTDIR=${DESTDIR} install || \
        logerr "--- Make install failed"

    logcmd pfexec chown -R ${USER} ${DESTDIR}/ || \
        logerr "--- Make install owner"

}

make_install_extras() {
    logmsg "--- make install extras"
    logcmd mkdir -p $DESTDIR/lib/svc/manifest/network/http/ || \
        logerr "------ Failed to create manifest directory."
    logcmd cp -r ${SRCDIR}/files/smf.xml $DESTDIR/lib/svc/manifest/network/http/pound.xml || \
        logerr "------ Failed to copy manifest."

    logcmd mkdir -p $DESTDIR$SYSCONFDIR || \
        logerr "------ Failed to create configuration directory."
    logcmd cp -r ${SRCDIR}/files/pound.cfg $DESTDIR$SYSCONFDIR/pound.cfg.example || \
        logerr "------ Failed to copy config."
}

init
auto_publish_wipe
prep_build
download_source ${DLPATH} ${PROG} ${VER}
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
