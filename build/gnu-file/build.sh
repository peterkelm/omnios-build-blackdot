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

PROG=file # App name
VER=5.14 # App version
VERHUMAN=$VER-1 # Human-readable version
#PVER= # Branch (set in config.sh, override here if needed)
PKG=file/gnu-file # Package name (e.g. library/foo)
SUMMARY="file type guesses"
DESC="The file command is 'a file type guesser', it also provide libmagic to expose the functionaity to other applications."


RUN_DEPENDS_IPS=""
BUILD_DEPENDS_IPS=""

BUILDARCH=both

download_source () {
    cleanup_source

    # fetch source
    mkdir ${TMPDIR}/src

    logmsg "--- download source"
    wget -c ftp://ftp.astron.com/pub/file/${PROG}-${VER}.tar.gz -O ${TMPDIR}/${PROG}-${VER}.tar.gz

    # expand source
    logmsg "--- unpacking source"
    tar xzf ${TMPDIR}/${PROG}-${VER}.tar.gz -C ${TMPDIR}/
}

make_install_extras() {
    logmsg "--- make install extras"
    if [ ${PREFIX} == '/usr' ]; then
        logcmd mkdir -p $DESTDIR$PREFIX/gnu/share/man/man1 || \
            logerr "------ Failed to create manifest directory."
        logcmd mv $DESTDIR$PREFIX/bin $DESTDIR$PREFIX/gnu/ || \
            logerr "------ Failed to move to gnu/ directory."
        logcmd rm $DESTDIR$PREFIX/share/man/man4/magic.4 || \
            logerr "------ Failed to remove conflicting file."
        logcmd mv $DESTDIR$PREFIX/share/man/man1/file.1 $DESTDIR$PREFIX/gnu/share/man/man1/file.1 || \
            logerr "------ Failed to move man pages."
    fi
}

init
auto_publish_wipe
prep_build
download_source
build
make_install_extras
[ ${PREFIX} == '/usr' ] && PREFIX=/usr/gnu
make_isa_stub
[ ${PREFIX} == '/usr' ] && PREFIX=/usr
make_package
clean_up
auto_publish

# Vim hints
# vim:ts=4:sw=4:et:
