#!/usr/bin/env bash

# will return zero if mutex is successful, any other code for error
function mutex()
{
    #adapted from http://wiki.bash-hackers.org/howto/mutex
    
    local LOCKDIR=$1
    local PIDFILE="${LOCKDIR}/PID"
    
    local ENO_SUCCESS
    local ENO_GENERAL
    local ENO_LOCKFAIL
    local ENO_RECVSIG
    local ETXT
    local ECODE
    local OTHERPID
     
    # exit codes and text
    ENO_SUCCESS=0; ETXT[0]="ENO_SUCCESS"
    ENO_GENERAL=1; ETXT[1]="ENO_GENERAL"
    ENO_LOCKFAIL=2; ETXT[2]="ENO_LOCKFAIL"
    ENO_RECVSIG=3; ETXT[3]="ENO_RECVSIG"
    ENO_STALE=3; ETXT[4]="ENO_STALE"
     
    ###
    ### start locking attempt
    ###
     
    trap 'ECODE=$?; # echo "[statsgen] Exit: ${ETXT[ECODE]}($ECODE)" >&2' 0
    # echo -n "[statsgen] Locking: " >&2
     
    if mkdir "${LOCKDIR}" &>/dev/null; then
     
        # lock succeeded, install signal handlers before storing the PID just in case 
        # storing the PID fails
        trap 'ECODE=$?;
              # echo "[statsgen] Removing lock. Exit: ${ETXT[ECODE]}($ECODE)" >&2
              rm -rf "${LOCKDIR}"' 0
        echo "$$" >"${PIDFILE}" 
        # the following handler will exit the script upon receiving these signals
        # the trap on "0" (EXIT) from above will be triggered by this trap's "exit" command!
        trap '# echo "[statsgen] Killed by a signal." >&2
              exit ${ENO_RECVSIG}' 1 2 3 15
              
        return 0
    else
     
        # lock failed, check if the other PID is alive
        OTHERPID="$(cat "${PIDFILE}")"
     
        # if cat isn't able to read the file, another instance is probably
        # about to remove the lock -- exit, we're *still* locked
        #  Thanks to Grzegorz Wierzowiecki for pointing out this race condition on
        #  http://wiki.grzegorz.wierzowiecki.pl/code:mutex-in-bash
        if [ $? != 0 ]; then
          # echo "lock failed, PID ${OTHERPID} is active" >&2
          return ${ENO_LOCKFAIL}
        fi
     
        if ! kill -0 $OTHERPID &>/dev/null; then
            # lock is stale, remove it and restart
            # echo "removing stale lock of nonexistant PID ${OTHERPID}" >&2
            rm -rf "${LOCKDIR}"
            # echo "[statsgen] restarting myself" >&2
            # exec "$0" "$@"
            mutex $1
            return $?
        fi
        
    fi
    
    # lock is valid and OTHERPID is active - exit, we're locked!
    # echo "lock failed, PID ${OTHERPID} is active" >&2
    return ${ENO_LOCKFAIL}
}
