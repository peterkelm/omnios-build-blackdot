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

# TODO
# - include ssl
# - include zlib
# - smf
# - look at dtrace (--enable-dtrace --enable-hook-probes)

# apache config
MIRROR=www.eu.apache.org
APR_VER=1.4.8
APU_VER=1.5.2
HTTPD_VER=2.4.6

# main package config
PROG=apache-httpd                            # App name
VER=${HTTPD_VER}                             # App version
VERHUMAN=$VER-1                              # Human-readable version
#PVER=                                       # Branch (set in config.sh, override here if needed)
PKG=obd/server/web/httpd                     # Package name (e.g. library/foo)
SUMMARY="The Apache HTTP Server Project is an effort to develop and maintain an open-source HTTP server for modern operating systems including UNIX and Windows NT. The goal of this project is to provide a secure, efficient and extensible server that provides HTTP services in sync with the current HTTP standards."
DESC="Does not come with DTrace probes! -- ${SUMMARY}"

RUN_DEPENDS_IPS="library/libxml2 library/security/openssl database/sqlite-3"
BUILD_DEPENDS_IPS="library/libxml2 library/security/openssl developer/build/autoconf database/sqlite-3"
BUILDARCH=both

PREFIX=${PREFIX}-apps/apache/httpd

# pretty much a complete custom build setup
download_source () {
    pushd $TMPDIR > /dev/null
    
    logmsg "--- downloading apr source"
    logcmd wget -c http://${MIRROR}/dist/apr/apr-${APR_VER}.tar.gz  || \
        logerr "--------- Failed to download apr-${APR_VER}.tar.gz!"

    logmsg "--- downloading apr-util source"
    logcmd wget -c http://${MIRROR}/dist/apr/apr-util-${APU_VER}.tar.gz  || \
        logerr "--------- Failed to download apr-util-${APU_VER}.tar.gz!"

    logmsg "--- downloading httpd source"
    logcmd wget -c http://${MIRROR}/dist/httpd/httpd-${HTTPD_VER}.tar.gz  || \
        logerr "--------- Failed to download httpd-${HTTPD_VER}.tar.gz!"

    logmsg "--- extracting apr source"
    logcmd tar xvf apr-${APR_VER}.tar.gz  || \
        logerr "--------- Failed to extract apr-${APR_VER}.tar.gz!"

    logmsg "--- extracting apr-util source"
    logcmd tar xvf apr-util-${APU_VER}.tar.gz  || \
        logerr "--------- Failed to extract apr-util-${APU_VER}.tar.gz!"

    logmsg "--- extracting httpd source"
    logcmd tar xvf httpd-${HTTPD_VER}.tar.gz  || \
        logerr "--------- Failed to extract httpd-${HTTPD_VER}.tar.gz!"
    sed "s#{{PREFIX}}#${PREFIX}#g" ${SRCDIR}/files/config.layout > ${TMPDIR}/httpd-${HTTPD_VER}/config.layout

    popd > /dev/null
}

save_function build build_orig
build() {
    pushd $TMPDIR > /dev/null
    
    logmsg "Build Wrapper"
    logmsg "--- environment variables (general)"
    LDFLAGS32="-L${PREFIX}/lib -R${PREFIX}/lib"
    LDFLAGS64="-m64 -L${PREFIX}/lib/${ISAPART64} -R${PREFIX}/lib/${ISAPART64}"

    BUILD_ARCH=
    if [[ $BUILDARCH == "32" || $BUILDARCH == "both" ]]; then
        BUILD_ARCH="${BUILD_ARCH} 32"
    fi
    if [[ $BUILDARCH == "64" || $BUILDARCH == "both" ]]; then
        BUILD_ARCH="${BUILD_ARCH} 64"
    fi

    BUILDARCH_ORIG=${BUILDARCH}
    for ARCH in ${BUILD_ARCH}; do
        logmsg "--- building for arch (${ARCH})"
        BUILDARCH=${ARCH}
        PROGS="apr apr-util httpd"
        for PROG in ${PROGS}; do
            logmsg "------ environment variables (${PROG})"
            reset_configure_opts
            BUILDCONF="./buildconf"
            if [ "${PROG}" == "apr" ]; then
	        VER=${APR_VER}
                BUILDCONF="${BUILDCONF}"
                CONFIGURE_OPTS="--enable-nonportable-atomics --enable-threads"
                CONFIGURE_OPTS_32="${CONFIGURE_OPTS_32} --with-installbuilddir=${PREFIX}/share/build-1/${ISAPART}"
                CONFIGURE_OPTS_64="${CONFIGURE_OPTS_64} --with-installbuilddir=${PREFIX}/share/build-1/${ISAPART64}"
            elif [ "${PROG}" == "apr-util" ]; then
	        VER=${APU_VER}
                BUILDCONF="${BUILDCONF} --with-apr=${TMPDIR}/apr-${APR_VER}"
                CONFIGURE_OPTS="--with-dbm=sdbm --with-ldap --without-pgsql --with-apr=${TMPDIR}/apr-${APR_VER}"
                CONFIGURE_OPTS_32="${CONFIGURE_OPTS_32} --with-installbuilddir=${PREFIX}/share/build-1/${ISAPART}"
                CONFIGURE_OPTS_64="${CONFIGURE_OPTS_64} --with-installbuilddir=${PREFIX}/share/build-1/${ISAPART64}"
            elif [ "${PROG}" == "httpd" ]; then
	        VER=${HTTPD_VER}
                BUILDCONF="${BUILDCONF} --with-apr=${TMPDIR}/apr-${APR_VER} --with-apr-util=${TMPDIR}/apr-util-${APU_VER}"
                CONFIGURE_OPTS="--with-apr=${TMPDIR}/apr-${APR_VER} --with-apr-util=${TMPDIR}/apr-util-${APU_VER}"
                CONFIGURE_OPTS="${CONFIGURE_OPTS} --enable-v4-mapped --enable-mpms-shared=all --with-mpm=event --enable-mods-static=macro --enable-mods-shared=reallyall" 
                CONFIGURE_OPTS_32="--enable-layout=${ISAPART}"
                CONFIGURE_OPTS_64="--enable-layout=${ISAPART64}"
            fi

            logmsg "------ generating buildconf (${PROG})"
            pushd ${TMPDIR}/${PROG}-${VER} > /dev/null
            logcmd ${BUILDCONF} 
            popd > /dev/null

            logmsg "------ calling build (${PROG})"
            BUILDDIR=${PROG}-${VER}
            build_orig

            logmsg "------ executing extras (${PROG})"
            if [ "${PROG}" == "apr" ]; then
                if [[ $BUILDARCH == "64" ]]; then
                    logcmd gsed -i -e 's/CC -shared/CC -m64 -shared/g;' ${DESTDIR}/${PREFIX}/share/build-1/${ISAPART64}/libtool  || \
                        logerr "-------- Failed to patch 64-bit apr libtool!"
                fi
            fi
        done
        BUILDARCH=${BUILDARCH_ORIG}
    done

    popd > /dev/null
}

make_install_extras() {
    logcmd rm -rf ${DESTDIR}/${PREFIX}/conf/{original/,extra/,${ISAPART}/,${ISAPART64}/} || \
        logerr "-------- Failed to strip conf/."
    logcmd cp -r ${SRCDIR}/files/conf/* ${DESTDIR}/${PREFIX}/conf/ || \
        logerr "-------- Failed to copy default configuration."

    logcmd mkdir -p $DESTDIR/var/empty || \
        logerr "-------- Failed to create apache home."                
}

save_function cleanup_source cleanup_source_orig
cleanup_source() {
    cleanup_source_orig
    logmsg "--- remove source extra"
    if [ -d ${TMPDIR} ]; then
        cd ${TMPDIR}
        logmsg "------ removing httpd"
        logcmd rm -rf ${TMPDIR}/httpd* || \
            logerr "--------- Failed to remove httpd source!"
        logmsg "------ removing apr-util"
        logcmd rm -rf ${TMPDIR}/apr-util* || \
            logerr "--------- Failed to remove apr-util source!"
        logmsg "------ removing apr"
        logcmd rm -rf ${TMPDIR}/apr* || \
            logerr "--------- Failed to remove apr source!"
    else
	logmsg "------ skipped"
    fi
	
}

init
prep_build
download_source
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
