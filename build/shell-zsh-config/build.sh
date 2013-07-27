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

NZSHRC="https://docu.blackdot.be/getRaw.php?onlyCode=true&id=configuration:zsh"

PROG=zsh-obd-config                         # App name
VER=`curl -sk -m 3 ${NZSHRC} | head -n3 | tail -n1 | awk '{ print $3 }'` # App version
VERHUMAN=$VER-1                             # Human-readable version
#PVER=                                      # Branch (set in config.sh, override here if needed)
PKG=obd/shell/zsh-config                    # Package name (e.g. library/foo)
SUMMARY="Z-Shell configuration found at docu.blackdot.be."
DESC="This package will install the zsh configuration found at docu.blackdot.be into /etc/skel1. New users will have the configuration avaible when they run zsh. If the user is create with -s /bin/zsh the shell will also be the default."

RUN_DEPENDS_IPS="shell/zsh"
BUILD_DEPENDS_IPS=""

PREFIX=
BUILDARCH=both

# Nothing to configure or build, just package
make_install() {
    logmsg "--- make install"
    logcmd mkdir -p $DESTDIR$PREFIX/etc/skel || \
        logerr "------ Failed to create /etc/skel."

    logcmd curl -sk ${NZSHRC} -o $DESTDIR$PREFIX/etc/skel/.zshrc || \
        logerr "------ Failed to download .zshrc!"
}

init
prep_build
make_install
prefix_updater
make_package
auto_publish
cleanup_source
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
