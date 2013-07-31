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

cleanup_source() {
    logmsg "Housekeeping"
    logmsg "--- remove source directory"
    if [ -d ${TMPDIR} ]; then
        cd ${TMPDIR}
        logmsg "------ removing source"
        logcmd rm -rf ${TMPDIR}/${PROG}* || \
            logerr "--------- Failed to remove source!"
        if [ -d ${TMPDIR}/staging ]; then
            logmsg "------ removing staging directory"
            logcmd rm  -rf ${TMPDIR}/staging || \
                logerr "--------- Failed to remove staging!"
        fi
    else
	logmsg "------ skipped"
    fi

    logmsg "--- checking for local.mog.in"
    if [ -e ${SRCDIR}/local.mog.in ]; then
        logmsg "------ removing local.mog"
        if [ -e ${SRCDIR}/local.mog ]; then 
            logcmd rm ${SRCDIR}/local.mog || \
                logerr "--------- Failed to remove local.mog!"
        fi
    fi

}

auto_publish() {
    WIPE=$1
    [ -z "$1" ] && WIPE=1

    logmsg "Auto Publish"
    if [ $WIPE -gt 0 ]; then
        logmsg "--- removing old version of $PKG"
        COUNT=1
        MAX_COUNT=`pkgrepo list -s /export/omnios-repository | grep -c "$PKG "`
        if [ $MAX_COUNT -gt 1 ]; then
            for p in `pkgrepo list -s /export/omnios-repository | grep "$PKG" | awk '{ print $2 "@"  $3 }'`; do
                logcmd pkgrepo remove -s /export/omnios-repository $p || \
                    logerr "------ Failed to remove old version ${p}."
		COUNT=`expr ${COUNT} + 1`
                [ $COUNT -eq $MAX_COUNT ] && break
            done
        else
            logmsg "------ no old $PKG version found."
        fi
    fi

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
    if [ ! -z $DESTDIR ];  then
        logmsg "--- checking for manifests"
        for SMF in `find $DESTDIR/{var,lib}/svc/manifest/ -type f 2> /dev/null`; do
            logmsg "------ updating {{PREFIX}} in $(echo ${SMF} | sed s#${DESTDIR}##)"
            sed -i s#{{PREFIX}}#${PREFIX}#g ${SMF}
            sed -i s#{{SYSCONFDIR}}#${SYSCONFDIR}#g ${SMF}
        done
    fi

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
        logcmd sed -i s#{{SYSCONFDIR}}#${SYSCONFDIR}#g ${SRCDIR}/local.mog || \
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
            logmsg "------ updating {{SYSCONFDIR}} in ${PREFIX}${EFILE}"
            if [ -e ${DESTDIR}${PREFIX}${EFILE} ]; then
                sed -i s#{{SYSCONFDIR}}#${SYSCONFDIR}#g ${DESTDIR}${PREFIX}${EFILE}
            else
                logerr "--------- Not found!"
            fi
        done
    fi    
}

# fix versions with numbers (taken from openssl build file)
_fixAlphaVer() {
    local ASCII=$(printf '%d' "'$1")
    ASCII=$((ASCII - 64))
    [[ $ASCII -gt 32 ]] && ASCII=$((ASCII - 32))
    echo $ASCII
}
save_function make_package make_package_obd_orig
make_package() {
    # fix up alpha, beta and rc tags
    VER=$(echo ${VER} | sed "s/alpha/.0.0./g" | sed "s/beta/.0.1./g" | sed "s/rc/.0.2./g"  | sed "s/test/.0.0./g")

    # turn single letter version to number
    if [[ -n "`echo $VER | grep [a-z]`" ]]; then
        NUMVER=${VER::$((${#VER} -1))}
        ALPHAVER=${VER:$((${#VER} -1))}
        VER=${NUMVER}.$(_fixAlphaVer ${ALPHAVER})
    fi

    make_package_obd_orig
}
