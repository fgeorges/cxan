#!/bin/sh

# the dir containing this script
BASEDIR=`dirname $0`
if [[ ! -d "${BASEDIR}" ]]; then
    echo "*** INTERNAL ERROR: The install directory is not a directory?!?" 1>&2;
    exit 1;
fi

. "$BASEDIR/functions.sh"

echo "Tomcat port: $TOMCAT_PORT"

stop_tomcat
