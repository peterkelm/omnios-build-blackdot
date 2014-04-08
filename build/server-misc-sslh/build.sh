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

PROG=sslh                                  # App name
VER=1.16                                    # App version
VERHUMAN=${VER}-1                           # Human-readable version
#PVER=                                      # Branch (set in config.sh, override here if needed)
PKG=obd/server/misc/sslh                 # Package name (e.g. library/foo)
SUMMARY="Sslh acts as a protocol demultiplexer, or a switchboard. Its name comes from its original function to serve SSH and HTTPS on the same port."
DESC="Sslh accepts connections on specified ports, and forwards them further based on tests performed on the first data packet sent by the remote client. Probes for HTTP, SSL, SSH, OpenVPN, tinc, XMPP are implemented, and any other protocol that can be tested using a regular expression, can be recognised. A typical use case is to allow serving several services on port 443 (e.g. to connect to ssh from inside a corporate firewall, which almost never block port 443) while still serving HTTPS on that port."

RUN_DEPENDS_IPS=""
BUILD_DEPENDS_IPS=""

BUILDARCH=both

# package specific
MIRROR=github.com
DLPATH=yrutschle/sslh/archive

download_source() {
    cd ${TMPDIR}

    logmsg "--- downloading source"
    [ -e ${PROG}-${VER}.tar.gz ] && logcmd rm ${PROG}-${VER}.tar.gz || \
        logerr "------ Failed to remove old source."
    logcmd wget -c https://${MIRROR}/${DLPATH}/v${VER}.tar.gz -O ${PROG}-${VER}.tar.gz || \
        logerr "------ Failed to download source."


    tar xvf ${PROG}-${VER}.tar.gz
}

make_install_extras() {
    logmsg "--- make install extras"
    logcmd mkdir -p $DESTDIR/lib/svc/manifest/network || \
        logerr "------ Failed to create manifest directory."
    logcmd cp ${SRCDIR}/files/smf.xml $DESTDIR/lib/svc/manifest/network/sslh.xml || \
        logerr "------ Failed to copy sslh manifest."
}

fixsrc() {
    logmsg "--- fixing source"
    logcmd sed -i "s/struct queue/struct sslhqueue/g" common.h || \
        logerr "--- Failed to pathc common.h"
    logcmd sed -i "s/struct queue/struct sslhqueue/g" common.c || \
        logerr "--- Failed to pathc common.c"
    logcmd sed -i "s/struct queue/struct sslhqueue/g" sslh-select.c || \
        logerr "--- Failed to pathc sslh-select.c"
}

setver() {
    logmsg "--- setting version"
    echo "#ifndef _VERSION_H_" > version.h
    echo "#define _VERSION_H_" >> version.h
    echo "" >> version.h
    echo "#define VERSION \"${VER}\"" >> version.h
    echo "#endif" >> version.h
}

save_function configure32 configure32_orig
configure32() {
    fixsrc
    setver

    logmsg "--- generating Makefile"
    [ ! -e Makefile.backup ] && cp Makefile Makefile.backup
    cp Makefile.backup Makefile
    sed -i "s|{{PREFIX}}|${PREFIX}|g" Makefile
    sed -i "s|{{ARCH}}|${ISAPART}|g" Makefile
}

save_function configure64 configure64_orig
configure64() {
    setver

    logmsg "--- generating Makefile"
    [ ! -e Makefile.backup ] && cp Makefile Makefile.backup
    cp Makefile.backup Makefile
    sed -i "s|{{PREFIX}}|${PREFIX}|g" Makefile
    sed -i "s|{{ARCH}}|${ISAPART64}|g" Makefile
    sed -i "s|gcc|gcc -m64|g" Makefile
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
