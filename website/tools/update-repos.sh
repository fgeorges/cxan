#!/bin/bash

# Invoke this script by providing the main Git directory as parameter
# (the one directory containing a sub-directory 'master', and a sub-
# directory 'repos' with all the repos).
# 
# TODO: Use a kind of blue-green deployment so if some error or
# inconsistency is detected on the updated repos, the update can stop
# without affecting the system (waiting for the error to be fixed, or
# doing something more sophisticated like excluding the guilty repo
# from the system, until the error is fixed).

## Utility functions

die() {
    echo
    echo "*** $@" 1>&2;
    log "*** $@";
    exit 1;
}

log() {
    # has LOG been initialized yet?
    if test -n "$LOG"; then
        echo "$@" >> "$LOG";
    else
        echo "$@";
    fi
}

## Parse the options

NO_PULL=false

while echo "$1" | grep -- ^-- >/dev/null 2>&1 && test "$1" != --; do
    case "$1" in
        # no pull
        --no-pull)
            NO_PULL=true;;
        # Unknown option!
        --*)
            die "Unknown option: $1"
    esac
    shift;
done

## Variables

BASE="$1"
SCRIPTS=`dirname $0`
#CALABASH="calabash"
CALABASH="$SCRIPTS/calabash.sh"

MASTER="$BASE/master"
REPOS="$BASE/repos"
LOG="$BASE/update.log"

SANITY_PIPE="$SCRIPTS/check-sanity.xproc"
DENORM_PIPE="$SCRIPTS/denorm-repos.xproc"
AUTHOR_PIPE="$SCRIPTS/denorm-authors.xproc"
VALIDITY_PIPE="$SCRIPTS/check-validity.xproc"

PACKAGES="$MASTER/packages.xml"
AUTHORS="$MASTER/authors.xml"
AUTHDIR="$MASTER/authors/"

## Checks on the variables

if test -n "$2"; then
    # do not log, as we do not know if we can trust where $LOG would point to
    echo
    echo "*** Too many options: '$2'" 1>&2;
    exit 1;
fi

if test -z "$BASE"; then
    die "The base directory is mandatory: update-repos.sh [--no-pull] git-base"
fi

if test \! -d "$BASE"; then
    # do not log, as we do not know where $LOG would point to
    echo
    echo "*** The base directory is not a directory: '$BASE'" 1>&2;
    exit 1;
fi

if test \! -d "$MASTER"; then
    die "The master directory is not a directory: '$MASTER'"
fi

if test \! -d "$REPOS"; then
    die "The repos directory is not a directory: '$REPOS'"
fi

if test \! -d "$SCRIPTS"; then
    die "INTERNAL ERROR: The scripts directory is not a directory: '$SCRIPTS'"
fi

if test \! -f "$DENORM_PIPE"; then
    die "INTERNAL ERROR: The denorm pipeline does not exist: '$DENORM_PIPE'"
fi

## Update repos

log
log "========== Start updating at `date` =========="

repos_cnt=0
for dir in "$REPOS"/*; do
    if test -d "$dir"; then
        repos_cnt=`expr $repos_cnt + 1`;
        log
        log "[**] Pull repo '$dir'"
        if "$NO_PULL" = true; then
            log "(pull disabled)"
        else
            ( ( cd "$dir"; git pull origin master ) >> "$LOG" 2>&1 ) \
                || die "Error pulling from Git in: '$dir'"
        fi
    else
        log
        log "[**] Ignore file '$dir'"
    fi
done
if test 0 -eq $repos_cnt; then
    die "No repo dir in the repos directory: '$REPOS'"
fi

## Sanity checks

log
log "[**] Check sanity"
log "from '$REPOS'"
for dir in "$REPOS"/*; do
    if test -d "$dir"; then
        report="$MASTER"/sanity/`basename $dir`.xml
        log "sanity of repo '$dir/'"
        ( "$CALABASH" \
            -i packages="$dir"/packages.xml \
            -i authors="$MASTER"/authors.xml \
            -i categories="$MASTER"/categories.xml \
            "$SANITY_PIPE" \
            2>> "$LOG" \
            | xmllint --format - > "$report" ) \
            || die "Error checking sanity! - $dir";
            sane=`xmllint --xpath 'string(/sanity/@pass)' "$report"`
            if test "$sane" \!= true; then
                die "Repository $dir is NOT sane! See $report."
            fi
        log "OK."
    else
        log
        log "[**] Ignore file '$dir'"
    fi
done

## Denormalize repos

from="file:$REPOS/"
log
log "[**] Denormalize repositories"
log "from '$from'"
log "to '$PACKAGES'"
"$CALABASH" "$DENORM_PIPE" repos-dir="$from" \
    2>> "$LOG" > "$PACKAGES" \
    || die "Error denormalizing repositories!"

## Denormalize authors

to="file:$AUTHDIR"
log
log "[**] Denormalize authors"
log "from '$PACKAGES'"
log " and '$AUTHORS'"
log "  to '$to'"
"$CALABASH" -i packages="$PACKAGES" -i authors="$AUTHORS" \
    "$AUTHOR_PIPE" \
    authors-dir="$to" \
    >> "$LOG" 2>&1 \
    || die "Error denormalizing authors!"

## Validity checks

# TODO: Perform some validity checks on the result of the denorm
# process.  As opposed to sanity checks, this is done after the denorm
# process took place.
# 
# log
# log "[**] Check validity"
# log "of '$PACKAGES'"
# "$CALABASH" -i packages="$PACKAGES" \
#     "$VALIDITY_PIPE" \
#     >> "$LOG" 2>&1 \
#     || die "Error checking validity!"

## Push changes

# TODO: For now, only packages.xml, extend it to others, like authors...

if test \! -d "$MASTER/.git"; then
    log "[**] master/.git/ does not exist, assume must not commit packages.xml"
else
    git_add=`(cd "$MASTER"; git add -n packages.xml)`
    if test -n "$git_add"; then
        log
        log "[**] Push master/packages.xml"
        ( ( cd "$MASTER"; git add packages.xml ) >> "$LOG" 2>&1 ) \
            || die "Error adding master/packages.xml to Git in: '$MASTER'"
        ( ( cd "$MASTER"; git commit -m "Automatic update..." packages.xml ) >> "$LOG" 2>&1 ) \
            || die "Error committing master/packages.xml to Git in: '$MASTER'"
        # TODO: Not pushing automatically for now.  To enable later...
        # ( ( cd "$MASTER"; git push ) >> "$LOG" 2>&1 ) \
        #     || die "Error pushing to Git in: '$MASTER'"
    else
        log
        log "[**] master/packages.xml not modified"
    fi
fi
