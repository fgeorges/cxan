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
if exist_started; then
    die "eXist is running"
fi

xrepo create "$BASEDIR/repo" \
    || die "Error creating the repo"

xrepo --repo "$BASEDIR/repo" install \
    "$BASEDIR/../../../../xlibs/fxsl/build/fxsl-1.0.xar" \
    || die "Error installing the FXSL library"

xrepo --repo "$BASEDIR/repo" install \
    "$BASEDIR/../../../../xlibs/serial/dist/serial-0.4.0pre2.xar" \
    || die "Error installing the Serial library"

xrepo --repo "$BASEDIR/repo" install \
    "$BASEDIR/../../../crypto/saxon/build/expath-crypto-saxon-0.3.0.xar" \
    || die "Error installing EXPath Crypto for Saxon"

xrepo --repo "$BASEDIR/repo" install \
    "$BASEDIR/../../../http-client/saxon/build/expath-http-client-saxon-0.11.0dev.xar" \
    || die "Error installing EXPath HTTP Client for Saxon"

xrepo --repo "$BASEDIR/repo" install \
    "$BASEDIR/../website/dist/cxan-website-0.5.0dev.xaw" \
    || die "Error installing CXAN Website"
