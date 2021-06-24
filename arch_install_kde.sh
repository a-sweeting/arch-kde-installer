#!/bin/bash

# Personal Arch install script

echo "Syncing packages"
pacman -Syy

echo "Installing Reflector"
pacman -S reflector

echo "Installing vim"
pacman -S vim

echo "Refreshing mirror list"
reflector --verbose --latest 200 --protocol https --download-timeout 2 --sort rate --save /etc/pacman.d/mirrorlist

echo "Setting keyboard layout to UK"
loadkeys uk

echo "Setting system clock"
timedatectl set-ntp true

echo "Partitioning disk"
# Need to work out how to do all partitioning through bash commands

echo "Mounting file system"
mount /dev/sda1 /mnt

echo "Install base system"
pacstrap /mnt base linux-lts linux-firmware

echo "Generating fstab"
genfstab _U /mnt >> /mnt/etc/fstab

echo "chroot into new system"
arch-chroot /mnt
