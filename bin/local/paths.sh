#!/usr/bin/env bash

__path_docker_base=/var/www
function docker_base_path() {
    local pathto=$1
    
    echo $__path_docker_base/$pathto
}
