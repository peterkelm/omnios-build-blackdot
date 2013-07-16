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

PROG=dnsmasq                                # App name
VER=2.67test7                               # App version
VERHUMAN=${VER}-1                           # Human-readable version
#PVER=                                      # Branch (set in config.sh, override here if needed)
PKG=obd/server/misc/dnsmasq                 # Package name (e.g. library/foo)
SUMMARY="Dnsmasq is a lightweight server designed to provide DNS, DHCP and TFTP services to a small-scale network."
DESC="Dnsmasq is a lightweight server designed to provide DNS, DHCP and TFTP services to a small-scale network. It can serve the names of local machines which are not in the global DNS. The DHCP server integrates with the DNS server and allows machines with DHCP-allocated addresses to appear in the DNS with names configured either in each host or in a central configuration file. Dnsmasq supports static and dynamic DHCP leases and BOOTP for network booting of diskless machines."

RUN_DEPENDS_IPS=""
BUILD_DEPENDS_IPS=""

BUILDARCH=both

# package specific
MIRROR=www.thekelleys.org.uk
DLPATH=dnsmasq/
[ `echo ${VER} | grep -c test` -gt 0 ] && DLPATH=${DLPATH}test-releases

# some deviation from default build
configure32() {
    echo -n ""
}

configure64() {
    echo -n ""
}

make_prog32() {
    [[ -n $NO_PARALLEL_MAKE ]] && MAKE_JOBS=""

    if [[ -n $LIBTOOL_NOSTDLIB ]]; then
        libtool_nostdlib $LIBTOOL_NOSTDLIB $LIBTOOL_NOSTDLIB_EXTRAS
    fi
    logmsg "--- make"
    logcmd $MAKE $MAKE_JOBS PREFIX=$PREFIX BINDIR=$PREFIX/sbin/$ISAPART COPTS="-DCONFFILE='\"$SYSCONFDIR/dnsmasq.conf\"'" CC=$CC CFLAGS="$CFLAGS $CFLAGS32" LDFLAGS="$LDFLAGS $LDFLAGS32" || \
        logerr "--- Make failed"
}
make_prog64() {
    [[ -n $NO_PARALLEL_MAKE ]] && MAKE_JOBS=""

    if [[ -n $LIBTOOL_NOSTDLIB ]]; then
        libtool_nostdlib $LIBTOOL_NOSTDLIB $LIBTOOL_NOSTDLIB_EXTRAS
    fi
    logmsg "--- make"
    logcmd $MAKE $MAKE_JOBS PREFIX=$PREFIX BINDIR=$PREFIX/sbin/$ISAPART64 COPTS="-DCONFFILE='\"$SYSCONFDIR/dnsmasq.conf\"'" CC=$CC CFLAGS="$CFLAGS $CFLAGS64" LDFLAGS="$LDFLAGS $LDFLAGS64" || \
        logerr "--- Make failed"
}

make_install32() {
    logmsg "--- make install"
    logcmd $MAKE PREFIX=${PREFIX} BINDIR=$PREFIX/sbin/$ISAPART DESTDIR=${DESTDIR} install || \
        logerr "--- Make install failed"
}
make_install64() {
    logmsg "--- make install"
    logcmd $MAKE PREFIX=${PREFIX} BINDIR=$PREFIX/sbin/$ISAPART64 DESTDIR=${DESTDIR} install || \
        logerr "--- Make install failed"
}
make_install_extras() {
    logmsg "--- make install extras"
    logcmd mkdir -p $DESTDIR/lib/svc/manifest/network || \
        logerr "------ Failed to create manifest directory."
    logcmd mkdir -p $DESTDIR/var/empty || \
        logerr "------ Failed to create home directory."
    logcmd mkdir -p $DESTDIR$SYSCONFDIR || \
        logerr "------ Failed to create configuration directory."
    logcmd cp ${SRCDIR}/files/dnsmasq.conf $DESTDIR$SYSCONFDIR || \
        logerr "------ Failed to copy dnsmasq configuration."
    logcmd cp ${SRCDIR}/files/smf.xml $DESTDIR/lib/svc/manifest/network/dnsmasq.xml || \
        logerr "------ Failed to copy dnsmasq manifest."
}

init
auto_publish_wipe
prep_build
download_source ${DLPATH} ${PROG} ${VER}
build
make_install_extras
make_isa_stub
prefix_updater
VER=2.67.0.7
make_package
auto_publish
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
