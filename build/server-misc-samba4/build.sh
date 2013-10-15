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

## todo
# - fix python
# - env setup script

PROG=samba                                  # App name
VER=4.1.0                                   # App version
VERHUMAN=$VER-1                             # Human-readable version
#PVER=                                      # Branch (set in config.sh, override here if needed)
PKG=obd/server/misc/samba4                  # Package name (e.g. library/foo)
SUMMARY="Samba is the standard Windows interoperability suite of programs for Linux and Unix."
DESC="${SUMMARY}"

RUN_DEPENDS_IPS="system/library/security/libgcrypt service/network/dns/mdns system/library/gcc-4-runtime"
BUILD_DEPENDS_IPS="system/library/security/libgcrypt"
BUILDARCH=both

MIRROR=samba.org
DLPATH=samba/ftp/stable

reset_configure_opts
CONFIGURE_OPTS="--enable-gnutls --with-ads --with-regedit --mandir=${PREFIX}/share/man --with-statedir=/var/samba/locks --with-piddir=/var/run --with-sockets-dir=/var/run --with-privileged-socket-dir=/var/run --with-privatedir=/var/samba/private --with-cachedir=/var/samba/cache --with-lockdir=/var/samba/locks --with-logfilebase=/var/samba/log"
CONFIGURE_OPTS_32="${CONFIGURE_OPTS_32} --with-modulesdir=${PREFIX}/lib/samba --with-privatelibdir=${PREFIX}/lib/samba --with-pammodulesdir=/usr/lib/security"
CONFIGURE_OPTS_64="${CONFIGURE_OPTS_64} --with-modulesdir=${PREFIX}/lib/${ISAPART64}/samba --with-privatelibdir=${PREFIX}/lib/${ISAPART64}/samba --with-pammodulesdir=/usr/lib/security/${ISAPART64}"

build() {
    if [[ $BUILDARCH == "32" || $BUILDARCH == "both" ]]; then
        export PYTHONARCHDIR=/usr/lib/python2.6/vendor-packages
        export ISALIST="i386"
        build32
    fi
    if [[ $BUILDARCH == "64" || $BUILDARCH == "both" ]]; then
	export PYTHONARCHDIR=/usr/lib/python2.6/vendor-packages/${ISAPART64}
        export ISALIST="amd64 i386"
        build64
	fix_python_64
    fi
}

fix_python_64() {
	pushd ${DESTDIR}/usr/lib/python2.6/vendor-packages/ > /dev/null
	
	for e in `find amd64 | grep \.so | sed 's#amd64/##g' | xargs`; do
        	DIR=$(dirname $e)
	        SO=$(basename $e)

        	if [ "${DIR}" == "." ]; then
	                mkdir -p 64
                	cp amd64/${SO} 64/${SO}
        	else
	                mkdir -p ${DIR}/64
                	cp amd64/${DIR}/${SO} ${DIR}/64/${SO}
        	fi
	done
	rm -rf amd64
	popd > /dev/null
}

make_install_extras() {
    logmsg "--- make install extras"
    logcmd rmdir ${DESTDIR}/var/run || \
        logerr "------ Failed to remove /var/run."
    logcmd mkdir -p ${DESTDIR}/lib/svc/manifest/network/ || \
        logerr "------ create svc diretory."
    logcmd cp ${SRCDIR}/files/smf.xml ${DESTDIR}/lib/svc/manifest/network/samba4.xml || \
        logerr "------ copy manifest."
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
