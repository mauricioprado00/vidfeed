#!/usr/bin/env bash

__series_directory=var/series

function download-serie() {
    local serie="$1"
    local torrent_file

    for torrent_file in $(series-torrents "${serie}"); do
        echo Found new torrent $(basename ${torrent_file})
        download-torrent "${serie}" "${torrent_file}"
    done
}

function download-torrent() {
    local serie=$1
    local torrent_file=$2
    local download_directory=$(series-download-directory "${serie}")
    local progress_directory=$(series-progress-directory "${serie}" "${torrent_file}")
    local result

    superecho Downloading ${torrent_file} to ${progress_directory}
    pushd "${progress_directory}" 2>/dev/null
    aria2c --seed-time=0 "${torrent_file}"
    result=$?
    popd
    if [ $result -eq 0 ]; then
        ln -s ${progress_directory} ${download_directory}/$(basename ${progress_directory})
        mv ${torrent_file} $(series-finished-directory "${serie}")
    else
        echo "failed to download" 1>&2
    fi
}