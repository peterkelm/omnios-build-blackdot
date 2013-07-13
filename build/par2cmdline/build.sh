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

PROG=par2cmdline                            # App name
VER=0.4                                     # App version
VERHUMAN=$VER-1                             # Human-readable version
#PVER=                                      # Branch (set in config.sh, override here if needed)
PKG=archiver/par2cmdline                    # Package name (e.g. library/foo)
SUMMARY="Providing a tool to apply the data-recovery capability concepts of RAID-like systems to the posting & recovery of multi-part archives on Usenet"
DESC=${SUMMARY}

RUN_DEPENDS_IPS=""
BUILD_DEPENDS_IPS=""

BUILDARCH=both

# Nothing to configure or build, just package
download_source () {
    # expand source
    logmsg "--- unpacking source"
    tar xzf ${SRCDIR}/src/${PROG}-${VER}.tar.gz -C ${TMPDIR}/
    cp ${SRCDIR}/patches/* ${TMPDIR}/${PROG}-${VER}/
    cd ${TMPDIR}/${PROG}-${VER}/
    for p in `ls *.patch`; do
	patch < $p
    done

}

init
auto_publish_wipe
prep_build
download_source
build
make_isa_stub
make_package
clean_up
cleanup_source
auto_publish

# Vim hints
# vim:ts=4:sw=4:et:
