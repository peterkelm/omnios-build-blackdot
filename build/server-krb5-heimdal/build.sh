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

## TODO
# - kadmind does not work?

# Load support functions
. ../../lib/functions.sh
. ../myfunc.sh

PROG=heimdal                                # App name
VER=1.5.3                                   # App version
VERHUMAN=$VER-1                             # Human-readable version
#PVER=                                      # Branch (set in config.sh, override here if needed)
PKG=obd/server/krb5/heimdal                 # Package name (e.g. library/foo)
SUMMARY="Heimdal is an implementation of Kerberos 5 (and some more stuff) largely written in Sweden (which was important when we started writing it, less so now). It is freely available under a three clause BSD style license."
DESC="${SUMMARY}"

RUN_DEPENDS_IPS="omniti/database/bdb"
BUILD_DEPENDS_IPS="developer/lexer/flex omniti/database/bdb"

BUILDARCH=both

# package specific
MIRROR=www.h5l.org
DLPATH=dist/src

# compile flags
NO_PARALLEL_MAKE=1
CONFIGURE_OPTS="--enable-pthread-support --with-sqlite3-include=/usr/include --disable-ndbm-db --disable-otp" # --disable-otp needed else build failure
CONFIGURE_OPTS_32="${CONFIGURE_OPTS_32} --libexecdir=${PREFIX}/sbin/${ISAPART} --with-berkeley-db=/opt/omni/lib --with-berkeley-db-include=/opt/omni/include --with-sqlite3-lib=/usr/lib"
CONFIGURE_OPTS_64="${CONFIGURE_OPTS_64} --libexecdir=${PREFIX}/sbin/${ISAPART64} --with-berkeley-db=/opt/omni/lib/${ISAPART64} --with-berkeley-db-include=/opt/omni/include/${ISAPART64} --with-sqlite3-lib=/usr/lib/${ISAPART64}"
ISAEXEC_DIRS="bin sbin sbin/heimdal"

# magic to fix sysconfig
CONFIGURE_OPTS_32=$(echo ${CONFIGURE_OPTS_32} | /bin/sed 's#/etc#/etc/heimdal#g')
CONFIGURE_OPTS_64=$(echo ${CONFIGURE_OPTS_64} | /bin/sed 's#/etc#/etc/heimdal#g')

LDFLAGS32="$LDFLAGS32 -L/opt/omni/lib -R/opt/omni/lib"
LDFLAGS64="$LDFLAGS64 -L/opt/omni/lib/$ISAPART64 -R/opt/omni/lib/$ISAPART64"

#save_function build64 build64_orig
#save_function build32 build32_orig
#build64() {
#    export DLDFLAGS="-L/opt/omni/lib/${ISAPART64} -R/opt/omni/lib/${ISAPART64}"
#    build64_orig
#}
#build32() {
#    export DLDFLAGS="-L/opt/omni/lib -R/opt/omni/lib"
#    build32_orig
#}

make_install_extras() {
    logmsg "--- make install extras"
    logcmd mkdir -p ${DESTDIR}/${PREFIX}/etc/heimdal/ || \
        logerr "-------- Failed to create etc/heimdal directory."
    logcmd mkdir -p ${DESTDIR}/${PREFIX}/sbin/heimdal/ || \
        logerr "-------- Failed to create sbin/heimdal directory."

    logcmd mv ${DESTDIR}/${PREFIX}/sbin/${ISAPART}/heimdal ${DESTDIR}/${PREFIX}/sbin/heimdal/${ISAPART} || \
        logerr "-------- Failed to move ${ISAPART}/heimdal."
    logcmd mv ${DESTDIR}/${PREFIX}/sbin/${ISAPART64}/heimdal ${DESTDIR}/${PREFIX}/sbin/heimdal/${ISAPART64} || \
        logerr "-------- Failed to move ${ISAPART64}/heimdal."

    logcmd mkdir -p ${DESTDIR}/var/heimdal/ || \
        logerr "-------- Failed to create var directory."

    logcmd mkdir -p ${DESTDIR}/lib/svc/manifest/network/security/ || \
        logerr "-------- Failed to create svc directory."
    logcmd cp -r ${SRCDIR}/files/smf/heimdal ${DESTDIR}/lib/svc/manifest/network/security/ || \
        logerr "-------- Failed to copy manifests."

    logcmd mkdir -p ${DESTDIR}/lib/svc/bin/ || \
        logerr "-------- Failed to create svc/bin directory."
    logcmd cp -r ${SRCDIR}/files/svc.* ${DESTDIR}/lib/svc/bin/ || \
        logerr "-------- Failed to copy manifests."
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
