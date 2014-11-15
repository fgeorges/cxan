## Variables

BASE="$1"
SCRIPTS=`dirname $0`

MASTER="$BASE/master"
REPOS="$BASE/repos"
LOG="$BASE/update.log"
DENORM_PIPE="$SCRIPTS/denorm-repos.xproc"

## Utility functions

die() {
    echo
    echo "*** $@" 1>&2;
    log "*** $@";
    exit 1;
}

log() {
    echo "$@" >> "$LOG";
}

## Checks on the variables

if test -z "$BASE"; then
    # do not log, as we do not know where $LOG would point to
    echo
    echo "*** The base directory is a mandatory option" 1>&2;
    exit 1;
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
        ( ( cd "$dir"; git pull ) >> "$LOG" 2>&1 ) \
            || die "Error pulling from Git in: '$dir'"
    else
        log
        log "[**] Ignore file '$dir'"
    fi
done
if test 0 -eq $repos_cnt; then
    die "No repo dir in the repos directory: '$REPOS'"
fi

## Denormalize repos

from="file:$REPOS/"
to="$MASTER/packages.xml"
log
log "[**] Denormalize repositories"
log "from '$from'"
log "to '$to'"
calabash "$DENORM_PIPE" repos-dir="$from" \
    2>> "$LOG" > "$to"

## Push packages.xml

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
