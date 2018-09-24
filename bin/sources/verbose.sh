#!/usr/bin/env bash

__verbose_verbosity=''

function verbosity-increase() {
    __verbose_verbosity="${__verbose_verbosity}v"
}

function verbose-level() {
    echo ${__verbose_verbosity}
}

function verbosefilter() {
    local verbose="${__verbose_verbosity}"
    if [[ "${verbose}" =~ ^vv ]]; then
        while IFS= read -r line; do
            echo "$(date +%Y-%m-%d%Z%H:%M:%S) $line"
        done
    elif [[ "${verbose}" = "v" ]]; then
        cat -
    else
        cat - > /dev/null
    fi
}

function superecho() {
    # echoes only on verbosity 3
    if [[ "${__verbose_verbosity}" =~ ^vvv ]]; then
        echo $@
    fi
}