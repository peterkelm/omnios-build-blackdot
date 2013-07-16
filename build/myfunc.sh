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
# Copyright 2013 Jorge Schrauwen.  All rights reserved.
# Use is subject to license terms.
#
# Load support functions
. ../../lib/functions.sh

cleanup_source() {
    # cleanup source
    logmsg "--- cleanup source"
    cd ${TMPDIR}/
    rm -rf ${TMPDIR}/${PROG}*
}


auto_publish_wipe() {
    logmsg "Auto Publish"
    logmsg "--- removing old version of $PKG"

    pkgrepo list -s /export/omnios-repository | grep -c "$PKG" > /dev/null
    if [ $? -eq 0 ]; then
        logcmd pkgrepo remove -s /export/omnios-repository $PKG || \
            logerr "------ Failed to remove old versions."
    else
        logmsg "------ no old $PKG version found."
    fi
}

auto_publish() {
    logmsg "Auto Publish"
    logmsg "--- stopping pkg/server"
    logcmd pfexec svcadm disable pkg/server || \
            logerr "------ Failed to stop pkg/server."
    logmsg "--- clearing cache"
    logcmd pfexec rm -rf /var/pkgserv/omnios-repository/publisher || \
            logerr "------ Failed clear cache."
    logmsg "--- starting pkg/server"
    logcmd pfexec svcadm enable pkg/server || \
            logerr "------ Failed to start pkg/server."
}

prefix_updater() {
    logmsg "Prefix Updater"
    logmsg "--- checking for manifests"
    for SMF in `find $DESTDIR/{var,lib}/svc/manifest/ -type f 2> /dev/null`; do
        logmsg "------ updating {{PREFIX}} in $(echo ${SMF} | sed s#${DESTDIR}##)"
        sed -i s#{{PREFIX}}#${PREFIX}#g ${SMF}
    done

    logmsg "--- checking for local.mog.in"
    if [ -e ${SRCDIR}/local.mog.in ]; then
        logmsg "------ removing local.mog"
        if [ -e ${SRCDIR}/local.mog ]; then 
            logcmd rm ${SRCDIR}/local.mog || \
                logerr "--------- Failed to remove local.mog!"
        fi


        logmsg "------ generating local.mog"
        logcmd cp ${SRCDIR}/local.mog.in ${SRCDIR}/local.mog || \
            logerr "--------- Failed to generate local.mog!"
        logcmd sed -i s#{{PREFIX}}#${PREFIX:1}#g ${SRCDIR}/local.mog || \
            logerr "--------- Failed to generate local.mog!"
    fi

    logmsg "--- checking for prefix_updater.extra"
    if [ -e ${SRCDIR}/prefix_updater.extra ]; then
        exec 3<"${SRCDIR}/prefix_updater.extra"
        while read EFILE <&3 ; do
            logmsg "------ updating {{PREFIX}} in ${PREFIX}${EFILE}"
            if [ -e ${DESTDIR}${PREFIX}${EFILE} ]; then
                sed -i s#{{PREFIX}}#${PREFIX}#g ${DESTDIR}${PREFIX}${EFILE}
            else
                logerr "--------- Not found!"
            fi
        done
    fi    
}
