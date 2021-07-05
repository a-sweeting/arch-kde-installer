#!/bin/bash

# Personal Arch install script

DISK="/dev/sda"
TIMEZONE="Europe/London"
LANGUAGE="en_GB.UTF-8"
KEYBOARD="uk"

HOSTNAME="anthony-laptop"

echo "Syncing packages"
pacman -Syy --noconfirm

echo "Installing Reflector"
pacman -S --noconfirm reflector

echo "Installing vim"
pacman -S --noconfirm vim

echo "Refreshing mirror list"
reflector --verbose --latest 20 --protocol https --download-timeout 2 --sort rate --save /etc/pacman.d/mirrorlist

echo "Setting keyboard layout to UK"
loadkeys $KEYBOARD

echo "Setting system clock"
timedatectl set-ntp true

echo "Partitioning disk"
fdisk $DISK

echo "Formatting disk"
mkfs.fat -F32 "${DISK}1"
mkfs.ext4 "${DISK}2"

echo "Mounting root partition"
mount "${DISK}2" /mnt

echo "Install base system"
pacstrap /mnt base linux-lts linux-firmware
 
echo "Generating fstab"
genfstab -U /mnt >> /mnt/etc/fstab

echo "chroot into new system"
arch-chroot /mnt
