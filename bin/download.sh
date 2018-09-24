#!/usr/bin/env bash

source $(dirname $0)/sources/common.sh

depends sources/series sources/download sources/mutex sources/verbose local/aliases local/paths

verbose=''
serie=''
all_arguments=$@

function cmd-help() {
    echo "gaps tools"
    echo
    echo "USAGE:"
    echo "  gaps <options> <commands>"
    echo
    echo "  <commands>:                 <command> [<commands>]"
    echo 
    echo "  <options>:                  <option> [<options>]"
    echo 
    echo "  <option>:                   -<option-code> [<option-value>]"
    echo
    echo "  <option-value>:             valid string value specified in option"
    echo
    echo "  <option-code>:              any of the following list"
    echo "          -s                  serie name"
    echo 
    echo "  <command>:"
    echo "          cmd-download        Will find a pending torrent file to download and download it"
    echo "          cmd-download-serie  Will atempt to download a specific serie"
    echo ""
}

function inception() 
{
    local binary=$(rpath $(dirname $0))/download.sh

    ${binary} -$(verbose-level) "$@"
}

function cmd-download()
{
    local serie
    for serie in $(series-list); do
        inception -x "download-serie-${serie}" -s "${serie}" cmd-download-serie
    done
}

function cmd-download-serie() {
    if [ -z ${serie} ]; then
        echo "you must provide a serie name with the parameter -s"
        return 1
    fi

    superecho Checking serie ${serie}
    download-serie "${serie}"
}

function init-exclusive-named-process() {
    local LOCKFILE=$(rpath $(dirname $0)/../var)/lock/${exclusive}.flag
    local result
    
    mutex ${LOCKFILE}
    result=$?
    
    if [ ${result} -ne 0 ]; then
        echo "Proccess ${LOCKFILE} is already running! (returned code ${result})" 1>&2
        exit 90
    fi
    
    $0 $(echo ${all_arguments} | sed 's#-x '$exclusive'##g')
    exit $?
}


while getopts "h?s:vx:" opt; do
    case "$opt" in
    h|\?)
        ;;
    v)
        verbosity-increase
        ;;
    s)
        serie="$OPTARG"
        ;;
    x)
        exclusive="$OPTARG"
        init-exclusive-named-process
        ;;
    # if adding a new option dont forget to hand it over to docker on collect-options
    esac
done

for var in "$@"
do
    if [[ $var = cmd* ]]; then
        $var | verbosefilter
    fi
done

if [ $# = 0 ]; then cmd-help; fi
exit 0
