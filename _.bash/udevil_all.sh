#!/bin/bash

usbStick=($(ls /dev/sd[b-z][0-9]* 2>/dev/null))
SDcard=($(ls -1 /dev/mmcblk[0-9]p[0-9]* 2>/dev/null))

udevil_act() {
    if [[ -z $2 ]] || [[ -n $3 ]]; then
        #echo "Function udevil_act call ERROR!!!"
        return 2
    else
        if [[ $1 == "mount" ]] || [[ $1 == "umount" ]]; then
            #if pwd="/media/*"
            mountStat=$(udevil $1 $2 2>&1)
            if [[ $? -ne 0 ]]; then
                notify-send "Fail to $1 $2" \
                    "\n$2 might be already $1""ed"
                return 1
            else
                notify-send "Success to $1 $2" "\n${mountStat}"
                return 0
            fi
        else
            #echo "Function udevil_act call ERROR!!!"
            return 2
        fi
    fi
}

if [[ $1 == "mount" ]] || [[ $1 == "umount" ]]; then
    if [[ ${#SDcard[@]} -eq 0 ]] && [[ ${#usbStick[@]} -eq 0 ]]; then
        notify-send "There is no removable usb device or SD card plugged in"
    else
        for (( i = 0; i < ${#SDcard[@]}; i++ )); do
            udevil_act $1 ${SDcard[$i]} 2>/dev/null
        done
        for (( i = 0; i < ${#usbStick[@]}; i++ )); do
            udevil_act $1 ${usbStick[$i]} 2>/dev/null
        done
    fi
else
    echo "Mount all USB sticks, disks or SD cards via udevil"
    echo "Usage: mount.sh <mount|umount>"
fi
