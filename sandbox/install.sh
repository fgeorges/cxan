#!/bin/sh

# REMOVE THE WHOLE REPO!

BASEDIR=`dirname $0`
if [[ ! -d "${BASEDIR}" ]]; then
    echo "*** INTERNAL ERROR: The install directory is not a directory?!?" 1>&2;
    exit 1;
fi

REPO="$BASEDIR/repo"

. "$BASEDIR/functions.sh"

if tomcat_started; then
    die "Tomcat is running"
fi

# TODO: 'xrepo create' should have an option to create a web-enabled
# repo (containing an empty '.expath-web/webapps.xml' file.
xrepo create "$REPO" \
    || die "Error creating the repo"

xrepo --repo "$REPO" install \
    "$BASEDIR/packages/pipx-0.1.0-dev.xar" \
    || die "Error installing the PipX library"

xrepo --repo "$REPO" install \
    "$BASEDIR/packages/fxsl-1.0.xar" \
    || die "Error installing the FXSL library"

xrepo --repo "$REPO" install \
    "$BASEDIR/packages/serial-0.4.0pre2.xar" \
    || die "Error installing the Serial library"

xrepo --repo "$REPO" install \
    "$BASEDIR/packages/expath-crypto-saxon-0.3.0.xar" \
    || die "Error installing EXPath Crypto for Saxon"

xrepo --repo "$REPO" install \
    "$BASEDIR/packages/expath-http-client-saxon-0.11.0dev.xar" \
    || die "Error installing EXPath HTTP Client for Saxon"

xrepo --repo "$REPO" install \
    "$BASEDIR/../website/dist/cxan-website-0.6.0dev.xaw" \
    || die "Error installing CXAN Website"

# TODO: 'xrepo install' should REALLY handle webapps.xml as well.  Try
# to externalize the part of Servlex that handles maintaining
# webapps.xml when installing a new webapp, and plug it into 'xrepo'!
mkdir "$REPO/.expath-web"
echo '
    <webapps xmlns="http://expath.org/ns/webapp">
       <webapp root="cxan">
          <package name="http://cxan.org/website"/>
       </webapp>
    </webapps>' \
    > "$REPO/.expath-web/webapps.xml"
