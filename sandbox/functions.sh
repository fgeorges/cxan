#!/bin/sh

## 
## Misc functions.
## 

die() {
    echo
    echo "*** $@" 1>&2;
    exit 1;
}

CURL_OPT="--silent --show-error --connect-timeout 1"
curl_headers() {
    curl $CURL_OPT -I "$1" 2>/dev/null
}


## 
## Tomcat functions.
## 

TOMCAT_PORT=9070

tomcat_started() {
    curl_headers http://localhost:$TOMCAT_PORT/ >/dev/null
}

start_tomcat() {
    # is it already started?
    if tomcat_started; then
        die "Tomcat has already been started"
    fi
    # start Tomcat up
    "${TOMCAT}/bin/startup.sh" \
        || die "Tomcat failed to startup."
    # wait for Tomcat to be up
    until tomcat_started; do
        echo "Waiting for Tomcat to be up..."
        sleep 2
    done
}

stop_tomcat() {
    "${TOMCAT}/bin/shutdown.sh" \
        || die "Tomcat failed to shutdown."
}


## 
## Path variables.
## 

# the dir containing this script
BASEDIR=`dirname $0`
if [[ ! -d "${BASEDIR}" ]]; then
    die "INTERNAL ERROR: The install directory is not a directory?!?";
fi

# the Tomcat dir
TOMCAT=${BASEDIR}/servlex-0.9.1
if [[ ! -d "${TOMCAT}" ]]; then
    die "INTERNAL ERROR: The install directory does not look to be correct?!?";
fi
