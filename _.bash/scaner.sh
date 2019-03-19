#!/bin/bash

#SCANNER="hpaio:/net/HP_LaserJet_MFP_M129-M134?ip=192.168.0.10"
SCANNER="hpaio:/net/HP-LaserJet-MFP-M129-M134?ip=192.168.0.10"
SCANNER="hpaio:/net/HP_LaserJet_MFP_M129-M134?ip=192.168.0.10"
USAGE="scaner.sh <dir>"

go_flag=true
function read_flag()
{
    echo "$1 (y/N)"
    read flag_data
    if [[ ${flag_data} = "Y" ]]; then
        go_flag=true
    elif [[ ${flag_data} = "y" ]]; then
        go_flag=true
    else
        go_flag=false
    fi
}

if [[ -z $1 ]]; then
    echo $USAGE
    exit 1
fi

_dir_=$1
mkdir -p ${_dir_}

i=0
read_flag "Starting to scan."
if [[ ! ${go_flag} ]]; then
    exit 1
fi

while [[ ${go_flag} ]]; do
    scanimage --device ${SCANNER} --format=png --resolution 600 --mode color > ${_dir_}/${i}.png
    read_flag "Scan next page."
    i=$(( ${i} + 1))
    if [[ ! ${go_flag} ]]; then
        break
    fi
done

echo "Scan Done."
