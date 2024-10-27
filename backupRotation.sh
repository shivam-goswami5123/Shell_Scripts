#!/bin/bash

<<Task
To create backup of important files or directory with rotation policy of last 5 backups(last 5 days)
Usage : ./backup.sh <path to source> <path to backup directory>
Task

function displayUsage(){
    echo "Usage : ./backup.sh <path to source> <path to backup directory>"
}

if [ $# -ne 2 ]; then
    displayUsage
fi

src_dir=$1
backup_dir=$2
timestamp=$(date '+%Y-%m-%d-%H-%M-%S')

function createBackup(){
    #sudo apt-get install zip 
    zip -r "${backup_dir}/backup_${timestamp}.zip" "${src_dir}" > /dev/null
    if [ $? -eq 0]; then
        echo "Backup Generated Succesfully for ${timestamp}"
    else
        echo "Error generating backup"
        exit 1
    fi
}

createBackup

function perform_rotation(){
    backups=($(ls -t "${backup_dir}/backup_"*.zip 2>/dev/null))


    if [ "${#backups[@]}" -gt 5] ; then
        echo "ROTATION POLICY : RECENT 5 ENTRIES(e.g 5 days)"
        backups_to_remove=("${backups[@]:5}")
        for backup in "${backups_to_remove[@]}";
        do
            rm -f ${backup}
        done
    fi

    #echo "${backups[@]}"
}

perform_rotation

<<crontab
crontab -e
2 --> vim
* * * * * bash <script_loc> <src> <backup_dest>
crontab




