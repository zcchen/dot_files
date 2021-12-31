#!/bin/bash
# This script is used to add some website to /etc/hosts,
#   in order to disable some hosts accessing in some time

Host_File=/etc/hosts
Block_Site=(
douban.com
bilibili.tv
)
Block_Weekday=(
    Mon
    Tue
    Wed
    Thu
    Fri
    #Sat
    #Sun
)
Block_Time=(
    10:00
    10:00
)

function dayMinutes() {
    if [ -z $1 ]; then
        echo $(($(date +%k) * 60 + $(date +%M|sed s/^0//)))
    else
        echo $(($(date --date=$1 +%k)*60+$(date --date=$1 +%M|sed s/^0//)))
    fi
}

function sedRepComment() {
    sedURL=${1/\./\\\.}
    sedStrPat="/^127\.0\.0\.1[a-zA-Z0-9\.\t]*"$sedURL"$/s//#&/"
    echo ${sedStrPat}
}
function sedRepUncomment() {
    sedURL=${1/\./\\\.}
    sedStrPat="/^#127\.0\.0\.1[a-zA-Z0-9\.\t]*"$sedURL"$/s/^#//"
    echo ${sedStrPat}
}

function HostAppend() {
    echo -e "No site name in hosts file, adding... "
    echo -e "127.0.0.1\twww.$1\t\t$1" >> ${Host_File}
    #uncomment when it is ready.
    echo -e 'Added site name to hosts file, done.'
}

function hostTest() {
    strExit=$(grep -s $1 ${Host_File})
    if [ -z "${strExit}" ]; then
        HostAppend $1
    fi
}

if [[ ${Block_Weekday[*]} == *$(date +%a)* ]] &&
        [ $(dayMinutes) -ge $(dayMinutes ${Block_Time[0]}) ] &&
        [ $(dayMinutes) -le $(dayMinutes ${Block_Time[1]}) ]; then
    echo yes
    for i in ${Block_Site[@]}
    do
        hostTest ${i}
        sed -i $(sedRepUncomment ${i}) ${Host_File}
    done
else
    echo no
    for i in ${Block_Site[@]}
    do
        hostTest ${i}
        sed -i $(sedRepComment ${i}) ${Host_File}
    done
fi
