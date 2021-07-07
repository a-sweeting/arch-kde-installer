#!/bin/bash

# Personal Arch install script

DISK="/dev/sda"
TIMEZONE="Europe/London"
LANGUAGE="en_GB.UTF-8"
KEYBOARD="uk"

HOSTNAME="test"

ROOT_PASSWD="1234"

NEW_USER="test"
NEW_USER_PASSWD="1234"

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
pacstrap /mnt base base-devel linux-lts linux-firmware
 
echo "Generating fstab"
genfstab -U /mnt >> /mnt/etc/fstab

echo "chroot into new system"
arch-chroot /mnt <<EOF

echo "Setting timezone to Europe/London"
ln -sf "/usr/share/zoneinfo/${TIMEZONE}" /etc/localtime

echo "Setting hardware clock"
hwclock --systohc

echo "Set locale info"
cp /etc/locale.gen /etc/locale.gen.bkp
sed "s/#$LANGUAGE/$LANGUAGE/" /etc/locale.gen > /etc/locale.gen.tmp
mv /etc/locale.gen.tmp /etc/locale.gen
locale-gen

echo "Setting Language and keyboard"
echo "LANG=$LANGUAGE" > /etc/locale.conf
echo "KEYMAP=$KEYBOARD" > /etc/vconsole.conf

echo "Setting hostname"

echo "$HOSTNAME" > /etc/hostname
echo "127.0.0.1		localhost" > /etc/hosts
echo "::1		localhost" >> /etc/hosts
echo "127.0.1.1		${HOSTNAME}.localdomain	${HOSTNAME}" >> /etc/hosts

echo "Adding user"

echo -e $ROOT_PASSWD"\n"$ROOT_PASSWD | passwd

useradd -m $NEW_USER
echo -e $NEW_USER_PASSWD"\n"$NEW_USER_PASSWD | passwd $NEW_USER

echo "Adding user to groups"

usermod -aG wheel,audio,video,optical,storage $NEW_USER
cp /etc/sudoers /etc/sudoers.bkp
sed "s/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/" /etc/sudoers > /etc/sudoers.tmp
mv /etc/sudoers.tmp /etc/sudoers

echo "Setting up grub"

pacman -S --noconfirm grub efibootmgr dosfstools os-prober mtools

mkdir /boot/EFI
mount "${DISK}1" /boot/EFI

grub-install --target=x86_64-efi --bootloader-id=grub_uefi --recheck
grub-mkconfig -o /boot/grub/grub.cfg

echo "Installing vim"
pacman -S --noconfirm vim

echo "Installing Network Manager"
pacman -S --noconfirm networkmanager
systemctl enable NetworkManager

exit 
EOF

echo "Unmounting partitions"
umount -l /mnt
reboot
