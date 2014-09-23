#!/bin/sh

# REMOVE THE WHOLE REPO!

BASEDIR=`dirname $0`
if [[ ! -d "${BASEDIR}" ]]; then
    echo "*** INTERNAL ERROR: The install directory is not a directory?!?" 1>&2;
    exit 1;
fi

. "$BASEDIR/functions.sh"

if tomcat_started; then
    die "Tomcat is running"
fi

rm -r "$BASEDIR/repo/"
