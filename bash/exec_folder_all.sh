#!/bin/bash
function execute_all()
{
    if [[ -z $1 ]]; then
        exit 1
    else
        exec_files=(
            $(find -P $1 -maxdepth 1  -executable -type f -perm /u+x)
        )
        for (( i = 0; i < ${#exec_files[@]}; i++ )); do
            echo "Executing file ${exec_files[$i]}"
            ${exec_files[$i]}
            echo "${exec_files[$i]} is done!"
        done
    fi
}

if [[ -z $1 ]]; then
    echo 'Usage: exec_folder_all.sh </path/to/folder>'
    echo 'execute all executable files in this path'
    exit 1
else
    execute_all $1
    exit 0
fi
