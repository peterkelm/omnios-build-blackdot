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

# main package config
PROG=openssl                                 # App name
VER=1.0.1i                                   # App version
VERHUMAN=$VER-1                              # Human-readable version
#PVER=                                       # Branch (set in config.sh, override here if needed)
PKG=obd/server/apache/openssl                # Package name (e.g. library/foo)
SUMMARY="Open Source toolkit implementing the Secure Sockets Layer (SSL v2/v3) and Transport Layer Security (TLS v1) protocols as well as a full-strength general purpose cryptography library managed by a worldwide community of volunteers that use the Internet to communicate, plan, and develop the OpenSSL toolkit and its related documentation."
DESC="${SUMMARY}"

RUN_DEPENDS_IPS="obd/server/apache/base"
BUILD_DEPENDS_IPS="obd/server/apache/zlib"
BUILDARCH=both

PREFIX=${PREFIX}-apps/apache/shared

# package specific
MIRROR=www.openssl.org
DLPATH=source

# environment
reset_configure_opts
NO_PARALLEL_MAKE=1
CFLAGS="$CFLAGS -fpic"
CONFIGURE_CMD="./Configure"
CONFIGURE_OPTS="shared threads zlib-dynamic"
CONFIGURE_OPTS_32="solaris-x86-gcc --prefix=${PREFIX} --with-zlib-lib=${PREFIX}/lib --with-zlib-include=${PREFIX}/include"
CONFIGURE_OPTS_64="solaris64-x86_64-gcc --prefix=${PREFIX} --with-zlib-lib=${PREFIX}/lib/${ISAPART64} --with-zlib-include=${PREFIX}/include/${ISAPART64}"

# override some functions
save_function build build_orig
build() {
	pfexec pkg uninstall -v $(pkg list | grep obd/server/apache/httpd | awk '{ print $1 }' | xargs) ${PKG}
	build_orig
}

save_function build32 build32_orig
build32() {
	CC="${CC} -L${PREFIX}/lib -R${PREFIX}/lib" # openssl does not do LDFLAGS
	build32_orig
}

save_function build64 build64_orig
build64() {
	CC="${CC} -L${PREFIX}/lib/${ISAPART64} -R${PREFIX}/lib/${ISAPART64}" # openssl does not do LDFLAGS
	build64_orig
}

make_install32() {
    logmsg "--- make install"
    logcmd $MAKE INSTALL_PREFIX=$DESTDIR LIBDIR=lib install ||
        logerr "Failed to make install"

    logmsg "--- fixing shitty build stuff"
    logcmd mkdir -p  ${DESTDIR}${PREFIX}/bin/{i386,amd64} ||
        logerr "Failed to create binary directories."
    logcmd mv ${DESTDIR}${PREFIX}/bin/{openssl,c_rehash} ${DESTDIR}${PREFIX}/bin/${ISAPART}/ ||
        logerr "Failed to move binaries."
    logcmd tar cpf ${DESTDIR}${PREFIX}/include.tar include -C ${DESTDIR}${PREFIX} ||
        logerr "Failed to store include headers."
    logcmd rm -rf ${DESTDIR}${PREFIX}/include/* ||
        logerr "Failed to remove include headers."
}
make_install64() {
    logmsg "--- make install"
    logcmd $MAKE INSTALL_PREFIX=$DESTDIR LIBDIR=lib/amd64 install ||
        logerr "Failed to make install"

    logmsg "--- fixing shitty build stuff"
    logcmd mv ${DESTDIR}${PREFIX}/bin/{openssl,c_rehash} ${DESTDIR}${PREFIX}/bin/${ISAPART64}/ ||
        logerr "Failed to move binaries."
    logcmd mv ${DESTDIR}${PREFIX}/include ${DESTDIR}${PREFIX}/include_amd64 ||
        logerr "Failed to move amd64 headers."
    logcmd tar xpf ${DESTDIR}${PREFIX}/include.tar -C ${DESTDIR}${PREFIX} ||
        logerr "Failed to restore i386 headers."
    logcmd mv ${DESTDIR}${PREFIX}/include_amd64 ${DESTDIR}${PREFIX}/include/amd64 ||
        logerr "Failed to restore amd64 headers."
    logcmd rm ${DESTDIR}${PREFIX}/include.tar ||
        logerr "Failed to cleanup header tarball."
    logcmd sed -i "s#/lib#/lib/amd64#g" ${DESTDIR}${PREFIX}/lib/${ISAPART64}/pkgconfig/*.pc ||
        logerror "Failed to fix pkgconfig files."
    logcmd sed -i "s#/include#/include/amd64#g" ${DESTDIR}${PREFIX}/lib/${ISAPART64}/pkgconfig/*.pc ||
        logerror "Failed to fix pkgconfig files."
}

init
prep_build
download_source ${DLPATH} ${PROG} ${VER}
patch_source
build
make_isa_stub
PREFIX=$(echo ${PREFIX} | sed "s#/shared##g")
prefix_updater
make_package
auto_publish
cleanup_source
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
