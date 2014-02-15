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
## eXist functions.
## 

EXIST_PORT=7070

exist_started() {
    curl_headers http://localhost:$EXIST_PORT/ >/dev/null
}

start_exist() {
    # is it already started?
    if exist_started; then
        die "eXist has already been started"
    fi
    # start eXist up
    "${EXIST}/bin/startup.sh" >/dev/null 2>&1 \
        || die "eXist failed to startup." &
    # wait for eXist to be up
    until exist_started; do
        echo "Waiting for eXist to be up..."
        sleep 2
    done
}

stop_exist() {
    "${EXIST}/bin/shutdown.sh" -p admin \
        || die "eXist failed to shutdown."
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
TOMCAT=${BASEDIR}/apache-tomcat-7.0.50
if [[ ! -d "${TOMCAT}" ]]; then
    die "INTERNAL ERROR: The install directory does not look to be correct?!?";
fi

# the eXist dir
EXIST=${BASEDIR}/exist-2.1
if [[ ! -d "${EXIST}" ]]; then
    die "INTERNAL ERROR: The install directory does not look to be correct?!?";
fi
