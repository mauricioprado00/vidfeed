#!/usr/bin/env bash

__series_directory=var/series

function download-serie() {
    local serie="$1"
    download-serie-torrents "${serie}"
    download-serie-magnets "${serie}"
}

function download-serie-torrents() {
    local serie="$1"
    local torrent_file

    for torrent_file in $(series-torrents "${serie}"); do
        echo Found new torrent $(basename ${torrent_file})
        download-torrent "${serie}" "${torrent_file}"
    done
}

function download-serie-magnets() {
    local serie="$1"
    local magnet_file

    for magnet_file in $(series-magnets "${serie}"); do
        echo Found new magnet $(basename ${magnet_file})
        download-magnet "${serie}" "${magnet_file}"
    done
}

function download-torrent() {
    local serie=$1
    local torrent_file=$2
    local download_directory=$(series-download-directory "${serie}")
    local progress_directory=$(series-progress-directory "${serie}" "${torrent_file}")
    local target_finished=$(series-finished-directory "${serie}")/$(basename ${torrent_file})
    local result

    if [ -f ${target_finished} ]; then
        superecho torrent was previously downloaded
    else
        superecho Downloading ${torrent_file} to ${progress_directory}
        pushd "${progress_directory}" 2>/dev/null
        aria2c --seed-time=0 "${torrent_file}"
        result=$?
        popd
        if [ $result -eq 0 ]; then
            ln -s ${progress_directory} ${download_directory}/$(basename ${progress_directory})
            mv ${torrent_file} ${target_finished}
        else
            echo "failed to download" 1>&2
        fi
    fi
}

function download-magnet() {
    local serie=$1
    local magnet_file=$2
    local magnet_id=$(cat ${magnet_file} | md5sum | awk '{print $1}')
    local download_directory=$(series-download-directory "${serie}")
    local progress_directory=$(series-progress-directory "${serie}" "${magnet_id}")
    local target_finished=$(series-finished-directory "${serie}")/${magnet_id}.magnet
    local result

    if [ -f ${target_finished} ]; then
        superecho magnet was previously downloaded
        rm ${magnet_file}
    else
        superecho Downloading ${magnet_file} to ${progress_directory}
        pushd "${progress_directory}" 2>/dev/null
        aria2c --seed-time=0 $(cat "${magnet_file}")
        result=$?
        popd
        if [ $result -eq 0 ]; then
            ln -s ${progress_directory} ${download_directory}/$(basename ${progress_directory})
            mv ${magnet_file} ${target_finished}
        else
            echo "failed to download" 1>&2
        fi
    fi
}