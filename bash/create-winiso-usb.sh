#! /bin/bash

print_help ()
{
    echo "$0 <winiso-file> <winiso-mountpoint> <fat32-mountpoint>"
}

install_deps()
{
    which wimlib-imagex
    if [ $? -ne 0 ]; then
        echo "Installing deps pacakges"
        sudo apt install wimtools
    fi
}

mount_winiso()
{
    echo "Try to mounting ISO."
    local win_isofile="$1"
    local iso_mountpoint="$2"
    sudo mount -o loop "${win_isofile}" "${iso_mountpoint}"
    echo "ISO mounted."
}

umount_winiso()
{
    echo "Try to umounting ISO."
    local win_isofile="$1"
    local iso_mountpoint="$2"
    if [[ -n $(mount | grep "${win_isofile}") ]]; then
        echo "Umounting ISO."
        sudo umount "${iso_mountpoint}"
    fi
    echo "ISO Umounted."
}

clean_usb()
{
    local mountpoint_fat32="$1"
    local mountpoint_ntfs="$2"
    echo "Cleaning the used data."
    rm -rf "${mountpoint_fat32}/*"
    rm -rf "${mountpoint_ntfs}/*"
    echo "Cleaned."
}

copy_files()
{
    local mountpoint_iso="$1"
    local mountpoint_fat32="$2"
    local mountpoint_ntfs="$3"
    mkdir -p "${mountpoint_fat32}/sources/"
    for f in $(ls -1 "${mountpoint_iso}")
    do
        if [[ "${f}" != "sources" ]]; then
            cp -rvf "${mountpoint_iso}/${f}" "${mountpoint_fat32}/"
        else
            cp -rvf "${mountpoint_iso}/sources/boot.wim" "${mountpoint_fat32}/sources/"
        fi
        cp -rvf "${mountpoint_iso}/${f}" "${mountpoint_ntfs}/"
    done
}


if [[ -z "$4" ]]; then
    print_help
    exit 1
else
    win_isofile="$1"
    mountpoint_iso="$2"
    mountpoint_fat32="$3"
    mountpoint_ntfs="$4"
    trap "umount_winiso \"${win_isofile}\" \"${mountpoint_iso}\"" INT EXIT
    mount_winiso "${win_isofile}" "${mountpoint_iso}"
    clean_usb "${mountpoint_fat32}" "${mountpoint_ntfs}"
    copy_files "${mountpoint_iso}" "${mountpoint_fat32}" "${mountpoint_ntfs}"
    umount_winiso "${win_isofile}" "${mountpoint_iso}"
fi
