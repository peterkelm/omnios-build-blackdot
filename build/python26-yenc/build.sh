#!/usr/bin/bash
#
# CDDL HEADER START
#
# The contents of this file are subject to the terms of the
# Common Development and Distribution License, Version 1.0 only
# (the "License"). You may not use this file except in compliance
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
# Copyright 2011-2012 OmniTI Computer Consulting, Inc. All rights reserved.
# Copyright 2013 Jorge Schrauwen.  All rights reserved.
# Use is subject to license terms.
#
# Load support functions
. ../../lib/functions.sh
. ../myfunc.sh

PROG=yenc
VER=0.4.0
PKG=library/python-2/yenc
SUMMARY="Module providing only raw yEnc encoding/decoding with built-in crc32 calculation. "
DESC="$SUMMARY"

DEPENDS_IPS="runtime/python-26"

download_source() {
    logmsg "Downloading Source"

    cd ${TMPDIR}
    wget -c http://www.golug.it/pub/${PROG}/${PROG}-${VER}.tar.gz 

    tar xvf ${PROG}-${VER}.tar.gz
}


init
download_source $PROG $PROG $VER
patch_source
prep_build
python_build
PROG=yEnc make_package
clean_up
