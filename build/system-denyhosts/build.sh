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

PROG=DenyHosts
VER=2.6
PKG=system/denyhosts
SUMMARY="DenyHosts is a utility to help sys admins thwart ssh hackers."
DESC="DenyHosts is a python program that automatically blocks ssh attacks by adding entries to /etc/hosts.deny. DenyHosts will also inform Linux administrators about offending hosts, attacked users and suspicious logins."

RUN_DEPENDS_IPS="runtime/python-26"
BUILD_DEPENDS_IPS="runtime/python-26"

download_source() {
    logmsg "Downloading Source"

    cd ${TMPDIR}
    PROGL=$(echo ${PROG} | tr '[:upper:]' '[:lower:]')
    wget -c http://downloads.sourceforge.net/project/${PROGL}/${PROGL}/${VER}/${PROG}-${VER}.tar.gz

    tar xvf ${PROG}-${VER}.tar.gz
}

# Nothing to configure or build, just package
make_install_extras() {
    logmsg "--- make install extras"
    logcmd mkdir -p ${DESTDIR}${PREFIX}/ || \
        logerr "------ Failed to create ${PREFIX}."
    logcmd mkdir -p ${DESTDIR}/var/run/denyhosts || \
        logerr "------ Failed to create /var/run/denyhosts."
    logcmd mkdir -p ${DESTDIR}${PREFIX}/etc || \
        logerr "------ Failed to create ${PREFIX}/etc."
    logcmd mkdir -p ${DESTDIR}/lib/svc/bin || \
        logerr "------ Failed to create /lib/svc/bin."
    logcmd mkdir -p ${DESTDIR}/lib/svc/manifest/system || \
        logerr "------ Failed to create /lib/svc/manifest."

    logcmd mv ${DESTDIR}/usr/bin  ${DESTDIR}${PREFIX}/ || \
        logerr "------ Failed to move bin directory."
    logcmd mv ${DESTDIR}/usr/share  ${DESTDIR}${PREFIX}/ || \
        logerr "------ Failed to move share directory."

    logcmd mv  ${DESTDIR}${PREFIX}/share/denyhosts/denyhosts.cfg-dist ${DESTDIR}${PREFIX}/etc/denyhosts.cfg || \
        logerr "------ Failed to move configuration."
    logcmd mv  ${DESTDIR}${PREFIX}/share/denyhosts/daemon-control-dist ${DESTDIR}/lib/svc/bin/svc.denyhosts || \
        logerr "------ Failed to move svc.denyhosts."

    logcmd rm ${DESTDIR}${PREFIX}/share/denyhosts/setup.py || \
        logerr "------ Failed to cleanup setup.py."

    logcmd cp ${SRCDIR}/files/README.illumos ${DESTDIR}${PREFIX}/share/denyhosts/ || \
        logerr "------ Failed to copy README.illumos."
    logcmd cp ${SRCDIR}/files/smf.xml ${DESTDIR}/lib/svc/manifest/system/denyhosts.xml || \
        logerr "------ Failed to copy service framework manfest."

    logcmd /usr/bin/gsed -i \
		-e 's,/var/log/secure,/var/log/authlog,' \
		-e 's,/usr/share/denyhosts/data,/var/run/denyhosts,' \
		-e 's,/var/lock/subsys/denyhosts,/var/run/denyhosts.pid,' \
		-e 's,/var/log/denyhosts,/var/log/denyhosts.log,' \
		${DESTDIR}${PREFIX}/etc/denyhosts.cfg || \
        logerr "------ Failed to update denyhosts.cfg."

    echo 'SSHD_FORMAT_REGEX=.* (sshd\[.*\]: \[ID \d* auth.info\]) (?P<message>.*)' >> ${DESTDIR}${PREFIX}/etc/denyhosts.cfg

    logcmd /usr/bin/gsed -i \
                -e "s,denyhosts.cfg,${PREFIX}/etc/denyhosts.cfg," \
		${DESTDIR}/usr/lib/python2.6/vendor-packages/DenyHosts/constants.py || \
        logerr "------ Failed to patch constants.py."

    logcmd /usr/bin/gsed -i \
		-e "s,/usr/bin/denyhosts.py,${PREFIX}/bin/denyhosts.py," \
		-e "s,/usr/share/denyhosts/denyhosts.cfg,${PREFIX}/etc/denyhosts.cfg," \
		-e 's,/var/lock/subsys/denyhosts,/var/run/denyhosts.pid,' \
		${DESTDIR}/lib/svc/bin/svc.denyhosts || \
        logerr "------ Failed to patch svc.denyhosts."

}

init
download_source $PROG $PROG $VER
patch_source
prep_build
python_build
make_install_extras
make_package
auto_publish
clean_up
