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
# - add more extensions (see omniti)

# main package config
PROG=php                                     # App name
VER=5.5.12                                   # App version
VERHUMAN=$VER-1                              # Human-readable version
#PVER=                                       # Branch (set in config.sh, override here if needed)
PKG=obd/runtime/php                          # Package name (e.g. library/foo)
SUMMARY="PHP ${VER} runtime"
DESC="PHP is a widely-used general-purpose scripting language that is especially suited for Web development and can be embedded into HTML."

RUN_DEPENDS_IPS="compress/bzip2 database/sqlite-3 library/libtool/libltdl library/libxml2 library/libxslt web/curl omniti/database/mysql-55/library omniti/library/freetype2 omniti/library/gd  omniti/library/libjpeg omniti/library/libmcrypt omniti/library/libpng omniti/library/libpq5 omniti/library/libssh2 omniti/library/mhash"
BUILD_DEPENDS_IPS="${RUN_DEPENDS_IPS}"
BUILDARCH=both

PREFIX=${PREFIX}-apps/${PROG}

# environment
reset_configure_opts
CFLAGS32="${CFLAGS32} -std=gnu99 -I/opt/omni/include"
CFLAGS64="${CFLAGS64} -std=gnu99 -I/usr/include/amd64 -I/usr/include/libxml2 -I/opt/omni/include/${ISAPART64}"
LDFLAGS32=\
"-L${PREFIX}/lib -R${PREFIX}/lib "\
"-L$(echo ${PREFIX} | sed 's#php#apache/shared#g')/lib -L$(echo ${PREFIX} | sed 's#php#apache/shared#g')/lib "\
"-L/opt/omni/lib -R/opt/omni/lib "\
"-L/opt/omni/lib/mysql -R/opt/omni/lib/mysql"
LDFLAGS64=\
"-m64 -L${PREFIX}/lib/${ISAPART64} -R${PREFIX}/lib/${ISAPART64} "\
"-L$(echo ${PREFIX} | sed 's#php#apache/shared#g')/lib/${ISAPART64} -L$(echo ${PREFIX} | sed 's#php#apache/shared#g')/lib/${ISAPART64} "\
"-L/opt/omni/lib/$ISAPART64 -R/opt/omni/lib/$ISAPART64 "\
"-L/opt/omni/lib/$ISAPART64/mysql -R/opt/omni/lib/$ISAPART64/mysql"

NO_PARALLEL_MAKE=1
FREETYPE_PATH="/opt/omni"
CONFIGURE_OPTS=\
"--mandir=${PREFIX}/man "\
"--with-pear=$PREFIX/lib/php "\
"--with-gd "\
"--with-jpeg-dir=/opt/omni "\
"--with-png-dir=/opt/omni "\
"--with-freetype-dir=$FREETYPE_PATH "\
"--with-zlib "\
"--enable-pdo "\
"--with-mysql=/opt/omni "\
"--with-pdo_sqlite "\
"--with-pdo-mysql=/opt/omni "\
"--with-pdo-pgsql=/opt/omni "\
"--with-pgsql=/opt/omni "\
"--with-bz2 "\
"--with-curl=/opt/omni "\
"--with-ldap=/usr "\
"--with-ldap-sasl=no "\
"--with-mhash=/opt/omni "\
"--with-mcrypt=/opt/omni "\
"--enable-soap "\
"--with-iconv "\
"--with-xsl=/opt/omni "\
"--enable-exif "\
"--enable-bcmath "\
"--enable-calendar "\
"--enable-ftp "\
"--enable-mbstring "\
"--with-gettext "\
"--with-sqlite "\
"--enable-pcntl "\
"--with-openssl"
#"--enable-dtrace "\
#"--enable-sockets "\


CONFIGURE_OPTS_32="${CONFIGURE_OPTS_32} --with-mysqli=/opt/omni/bin/${ISAPART}/mysql_config --with-apxs2=$(echo ${PREFIX} | sed 's#php#apache/httpd#g')/bin/${ISAPART}/apxs"
CONFIGURE_OPTS_64="${CONFIGURE_OPTS_64} --with-mysqli=/opt/omni/bin/${ISAPART64}/mysql_config --with-apxs2=$(echo ${PREFIX} | sed 's#php#apache/httpd#g')/bin/${ISAPART64}/apxs"

save_function download_source download_source_orig
download_source() {
    logmsg "Downloading Source"

    cd ${TMPDIR}
    wget -c http://be2.php.net/get/${PROG}-${VER}.tar.gz/from/this/mirror -O ${PROG}-${VER}.tar.gz

    tar xvf ${PROG}-${VER}.tar.gz
}

prep_httpd() {
    logmsg "Generating fake httpd.conf file"
    logcmd mkdir -p ${DESTDIR}$(echo ${PREFIX} | sed 's#php#apache/httpd#g')/conf/{${ISAPART},${ISAPART64}}/
    echo -e "\n\n\nLoadModule access_module modules/mod_access.so\n\n\n" > \
        ${DESTDIR}$(echo ${PREFIX} | sed 's#php#apache/httpd#g')/conf/${ISAPART}/httpd.conf
    echo -e "\n\n\nLoadModule access_module modules/mod_access.so\n\n\n" > \
        ${DESTDIR}$(echo ${PREFIX} | sed 's#php#apache/httpd#g')/conf/${ISAPART64}/httpd.conf	

    [ -d ${TMPDIR}/php-apache-module/ ] && logcmd rm -rf ${TMPDIR}/php-apache-module/
}

clean_httpd() {
    logmsg "--- Relocating apache modules"
    logcmd mv ${DESTDIR}$(echo ${PREFIX} | sed 's#php#apache/httpd#g')/modules ${TMPDIR}/php-apache-module/ || \
        logerr "--- Unable to relocate apache modules."
    logmsg "Removing Generated httpd.conf file"
    logcmd rm -rf ${DESTDIR}$(echo ${PREFIX} | sed 's#php#apache#g') ||
        logerr "Failed to remove httpd config"
}

save_function make_install make_install_orig
make_install() {
    logmsg "--- make install"
    logcmd $MAKE DESTDIR=${DESTDIR} INSTALL_ROOT=${DESTDIR} install || \
        logerr "--- Make install failed"

    logmsg "--- Cleaning up dotfiles in destination directory"
    logcmd rm -rf ${DESTDIR}/.??* || \
        logerr "--- Unable to clean up destination directory"
}

make_install_module() {
    logmsg "Copying HTTPd module"
    logmsg "--- sataging directory"
    logcmd mkdir -p ${DESTDIR}${PREFIX}/apache/httpd/modules/{${ISAPART},${ISAPART64}} || \
        logerr "--- Unable to create module directory."
    logcmd mkdir -p ${DESTDIR}${PREFIX}/apache/httpd/conf/httpd.conf.d/ || \
        logerr "--- Unable to create module directory."
    logmsg "--- relocating apache modules"
    logcmd mv ${TMPDIR}/php-apache-module/${ISAPART}/libphp5.so ${DESTDIR}${PREFIX}/apache/httpd/modules/${ISAPART}/mod_php5.so || \
        logerr "--- Unable to relocate apache 32-bit modules."
    logcmd mv ${TMPDIR}/php-apache-module/${ISAPART64}/libphp5.so ${DESTDIR}${PREFIX}/apache/httpd/modules/${ISAPART64}/mod_php5.so || \
        logerr "--- Unable to relocate apache 64-bit modules."
    logcmd cp -r ${SRCDIR}/files/conf/httpd.conf.d/* ${DESTDIR}${PREFIX}/apache/httpd/conf/httpd.conf.d/ || \
        logerr "-------- Failed to copy default configuration."
}

## runtime/php
init
prep_build
download_source ${DLPATH} ${PROG} ${VER}
patch_source
prep_httpd
build
clean_httpd
make_isa_stub
PREFIX=$(echo ${PREFIX} | sed "s#/${PROG}##g")
make_package
auto_publish

## server/apache/httpd/mod_php
PKG=obd/server/apache/httpd/mod_php5
SUMMARY="Apache HTTPd module for PHP ${VER}"
RUN_DEPENDS_IPS="obd/runtime/php"

prep_build
make_install_module
prefix_updater
make_package
auto_publish
cleanup_source
clean_up


# Vim hints
# vim:ts=4:sw=4:et:
