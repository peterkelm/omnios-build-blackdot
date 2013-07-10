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
VERHUMAN=${VER}-1                             # Human-readable version
#PVER=                                      # Branch (set in config.sh, override here if needed)
PKG=network/dnsmasq                         # Package name (e.g. library/foo)
SUMMARY="Dnsmasq is a lightweight server designed to provide DNS, DHCP and TFTP services to a small-scale network."
DESC="Dnsmasq is a lightweight server designed to provide DNS, DHCP and TFTP services to a small-scale network. It can serve the names of local machines which are not in the global DNS. The DHCP server integrates with the DNS server and allows machines with DHCP-allocated addresses to appear in the DNS with names configured either in each host or in a central configuration file. Dnsmasq supports static and dynamic DHCP leases and BOOTP for network booting of diskless machines."
DEPENDS_IPS=""

BUILDARCH=both

# Nothing to configure or build, just package
download_source () {
    cleanup_source

    # fetch source
    mkdir ${TMPDIR}/src

    DLPATH=
    logmsg "--- download source"
    [ `echo ${VER} | grep -c test` -gt 0 ] && DLPATH=test-releases/
    wget -c http://www.thekelleys.org.uk/dnsmasq/${DLPATH}/${PROG}-${VER}.tar.gz -O ${TMPDIR}/src/${PROG}-${VER}.tar.gz

    # expand source
    logmsg "--- unpacking source"
    tar xzf ${TMPDIR}/src/${PROG}-${VER}.tar.gz -C ${TMPDIR}/src
}

build32 () {
    pushd $TMPDIR > /dev/null

    export PATH=/opt/gcc-4.7.2/bin:$PATH
    cd ${TMPDIR}/src/${PROG}-${VER}/
    gmake clean
    gmake PREFIX=${TMPDIR}/staging/i386 CC=gcc CFLAGS=-m32 LDFLAGS=-m32 COPTS="-DCONFFILE='\"/opt/obd/etc/dnsmasq.conf\"'"
    gmake PREFIX=${TMPDIR}/staging/i386 install

    popd > /dev/null
}

build64() {
    pushd $TMPDIR > /dev/null

    export PATH=/opt/gcc-4.7.2/bin:$PATH
    cd ${TMPDIR}/src/${PROG}-${VER}/
    gmake clean
    gmake PREFIX=${TMPDIR}/staging/amd64 CC=gcc CFLAGS=-m64 LDFLAGS=-m64 COPTS="-DCONFFILE='\"/opt/obd/etc/dnsmasq.conf\"'"
    gmake PREFIX=${TMPDIR}/staging/amd64 install

    popd > /dev/null
}

make_install() {
    logmsg "--- make install"
    logcmd mkdir -p $DESTDIR$PREFIX/sbin/{i386,amd64} || \
        logerr "------ Failed to create architecture destination directory."
    logcmd mkdir -p $DESTDIR$PREFIX/etc || \
        logerr "------ Failed to create configuration destination directory."
    logcmd mkdir -p $DESTDIR/lib/svc/manifest/network || \
        logerr "------ Failed to create manifest directory."

    logcmd cp -r ${TMPDIR}/staging/i386/* $DESTDIR$PREFIX/ || \
        logerr "------ Failed to copy base files."
    logcmd mv $DESTDIR$PREFIX/sbin/dnsmasq $DESTDIR$PREFIX/sbin/i386 || \
        logerr "------ Failed to move i386 binary."
    logcmd cp ${TMPDIR}/staging/amd64/sbin/dnsmasq $DESTDIR$PREFIX/sbin/amd64 || \
        logerr "------ Failed to copy amd64 binary."
    logcmd cp files/dnsmasq.conf $DESTDIR$PREFIX/etc || \
        logerr "------ Failed to copy dnsmasq configuration."
    logcmd cp files/smf.xml $DESTDIR/lib/svc/manifest/network/dnsmasq.xml || \
        logerr "------ Failed to copy dnsmasq manifest."
}

init
prep_build
download_source
build
make_install
make_isa_stub
VER=2.67.0.7
make_package
clean_up
cleanup_source

# Vim hints
# vim:ts=4:sw=4:et:
