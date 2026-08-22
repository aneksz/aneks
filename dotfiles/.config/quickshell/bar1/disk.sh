#!/usr/bin/env bash

get_disk() {
    df -h "$1" | awk 'NR==2 {
        gsub("%","",$5)
        printf "%s|%s\n", $4, $2
    }'
}

home=$(get_disk /home/igor)
data=$(get_disk /mnt/data)

echo "$home;$data"
