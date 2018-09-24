#!/usr/bin/env bash

__series_directory=var/series
__series_torrent_directory=torrent
__series_download_directory=download
__series_progress_directory=progress
__series_finished_directory=finished
__series_magnet_directory=magnet

function series-directory()
{
    local project_dir=$(dirname $(basepath))
    echo ${project_dir}/${__series_directory}
}

function series-torrent-directory()
{
    local serie=$1
    echo $(series-directory)/${serie}/${__series_torrent_directory}
}

function series-magnet-directory()
{
    local serie=$1
    echo $(series-directory)/${serie}/${__series_magnet_directory}
}

function series-download-directory()
{
    local serie=$1
    mkdir -p $(series-directory)/${serie}/${__series_download_directory} 2>/dev/null
    echo $(series-directory)/${serie}/${__series_download_directory}
}

function series-progress-directory()
{
    local serie="$1"
    local torrent_file=$(basename "$2")
    mkdir -p $(series-directory)/${serie}/${__series_progress_directory}/${torrent_file} 2>/dev/null
    echo $(series-directory)/${serie}/${__series_progress_directory}/${torrent_file}
}

function series-finished-directory()
{
    local serie="$1"
    local torrent_file=$(basename "$2")
    mkdir -p $(series-directory)/${serie}/${__series_finished_directory}/${torrent_file} 2>/dev/null
    echo $(series-directory)/${serie}/${__series_finished_directory}/${torrent_file}
}

function series-list() {
    ls $(series-directory)
}

function series-torrents() {
    local serie=$1

    ls $(series-torrent-directory ${serie}) 2>/dev/null | sed 's#^#'$(series-torrent-directory ${serie})'/#g'
}

function series-magnets() {
    local serie=$1

    ls $(series-magnet-directory ${serie}) 2>/dev/null | sed 's#^#'$(series-magnet-directory ${serie})'/#g'
}   