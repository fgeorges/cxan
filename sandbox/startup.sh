#!/bin/sh

# the dir containing this script
BASEDIR=`dirname $0`
if [[ ! -d "${BASEDIR}" ]]; then
    echo "*** INTERNAL ERROR: The sandbox directory is not a directory?!?" 1>&2;
    exit 1;
fi

. "$BASEDIR/functions.sh"

start_tomcat
start_exist

if curl_headers http://localhost:9070/servlex/ | grep "HTTP/1.1 200 OK" >/dev/null; then
    echo "Servlex looks like properly installed"
else
    echo "Servlex is NOT properly installed"
fi

if curl $CURL_OPT -i http://localhost:9070/servlex/cxan/ 2>/dev/null | grep "HTTP/1.1 200 OK" >/dev/null; then
    echo "CXAN webapp looks like properly installed"
else
    echo "CXAN webapp is NOT properly installed"
fi

echo "Tomcat port: $TOMCAT_PORT"
echo "eXist port:  $EXIST_PORT"
