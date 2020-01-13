#!/bin/bash
set -e

function is_mount_point() {
    mountpoint $1 >/dev/null 2>&1
    (( $? == 0 ))
}

if ! is_mount_point /mnt ; then
    echo "Root partition should be mounted at /mnt"
    exit 1
fi

if ! is_mount_point /mnt/boot ; then
    echo "Boot partition should be mounted at /mnt/boot"
    exit 1
fi

pacman -Sy --noconfirm reflector
echo "Configuring Mirror List"
reflector --country 'United States' --protocol https --age 24 --sort rate --save /etc/pacman.d/mirrorlist

pacstrap /mnt base ansible

genfstab -U /mnt > /mnt/etc/fstab

cp -R /mnt/tmp/dotfiles
arch-chroot /mnt ./chroot.sh
