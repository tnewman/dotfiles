#!/bin/bash
set -e

echo "Creating Pacman Hook Directory"
mkdir -p /etc/pacman.d/hooks

echo "Enabling Network Time Sync"
timedatectl set-ntp true

echo "Setting America/Detroit Time Zone"
ln -sf /usr/share/zoneinfo/America/Detroit /etc/localtime

echo "Syncing Hardware Clock"
hwclock --systohc

echo "Setting en_US Locale"
grep -qxF $"en_US.UTF-8 UTF-8   " /etc/locale.gen || echo "en_US.UTF-8 UTF-8   " >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

echo "Setting Host Information"
echo "localhost" > /etc/hostname
echo "127.0.0.1 localhost
::1 localhost
" > /etc/hosts

echo "Configuring Fuse"
echo "fuse" > /etc/modules-load.d/fuse.conf

echo "Configuring systemd-boot"
bootctl install

echo "[Trigger]
Type = Package
Operation = Upgrade
Target = systemd

[Action]
Description = Updating systemd-boot
When = PostTransaction
Exec = /usr/bin/bootctl update" > /etc/pacman.d/hooks/100-systemd-boot.hook

echo "title Arch Linux
linux /vmlinuz-linux
initrd /amd-ucode.img
initrd /intel-ucode.img
initrd /initramfs-linux.img
options root=LABEL=root resume=LABEL=swap amd_iommu=on intel_iommu=on" > /boot/loader/entries/arch.conf

echo "Configuring Pacman Reflector Hook"
echo "[Trigger]
Operation = Upgrade
Type = Package
Target = pacman-mirrorlist

[Action]
Description = Updating pacman-mirrorlist with reflector and removing pacnew...
When = PostTransaction
Depends = reflector
Exec = /bin/sh -c \"reflector --country 'United States' --protocol https --age 24 --sort rate --save /etc/pacman.d/mirrorlist; rm -f /etc/pacman.d/mirrorlist.pacnew\"" > /etc/pacman.d/hooks/mirrorupgrade.hook

echo "Enabling SDDM"
systemctl enable sddm.service

echo "Enabling Network Manager"
systemctl enable NetworkManager.service

echo "Enabling Uncomplicated Firewall"
systemctl enable ufw.service
ufw enable

echo "Adding Wheel to Sudoers"
echo "%wheel ALL=(ALL) ALL" > /etc/sudoers.d/wheel

