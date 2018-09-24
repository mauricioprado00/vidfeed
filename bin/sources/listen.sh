#!/usr/bin/env bash
__listen_port=8000
__listen_directory=bin/listener/

function listen()
{
    local project_dir=$(dirname $(basepath))

    pushd ${project_dir}/${__listen_directory}
    busybox httpd -f -p ${__listen_port} ${project_dir}/${__listen_directory}
}
