BASE=`pwd`
MASTER="$BASE/master"
REPOS="$BASE/repos"
LOG="$BASE/update.log"

die() {
    echo
    echo "*** $@" 1>&2;
    log "*** $@";
    exit 1;
}

log() {
    echo "$@" >> "$LOG";
}

if test \! -d "$MASTER"; then
    die "The master directory is not a directory: $MASTER"
fi
if test \! -d "$REPOS"; then
    die "The repos directory is not a directory: $REPOS"
fi

SCRIPTS=`dirname $0`
if test \! -d "$SCRIPTS"; then
    die "INTERNAL ERROR: The scripts directory is not a directory: $SCRIPTS"
fi

log
log "========== Start updating at `date` =========="

repos_cnt=0
for dir in "$REPOS"/*; do
    if test -d "$dir"; then
        repos_cnt=`expr $repos_cnt + 1`;
        log
        log "[**] Pull repo $dir"
        ( ( cd "$dir"; git pull ) >> "$LOG" 2>&1 ) \
            || die "Error pulling from Git in: $dir"
    else
        log
        log "[**] Ignore file $dir"
    fi
done
if test 0 -eq $repos_cnt; then
    die "No repo dir in the repos directory: $REPOS"
fi

from="file:$REPOS/"
to="$MASTER/packages.xml"
log
log "[**] Denormalize repositories"
log "from $from"
log "to $to"
calabash "$SCRIPTS/denorm-repos.xproc" repos-dir="$from" \
    2>> "$LOG" > "$to"

git_add=`(cd "$MASTER"; git add -n packages.xml)`
if test -n "$git_add"; then
    log
    log "[**] Push master/packages.xml"
    ( ( cd "$MASTER"; git add packages.xml ) >> "$LOG" 2>&1 ) \
        || die "Error adding master/packages.xml to Git in: $MASTER"
    ( ( cd "$MASTER"; git commit -m "Updated version..." packages.xml ) >> "$LOG" 2>&1 ) \
        || die "Error committing master/packages.xml to Git in: $MASTER"
    # TODO: Not pushing automatically for now.  To enable later...
    # ( ( cd "$MASTER"; git push ) >> "$LOG" 2>&1 ) \
    #     || die "Error pushing to Git in: $MASTER"
else
    log
    log "[**] master/packages.xml not modified"
fi
