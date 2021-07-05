#!/bin/bash

DISK="/dev/sda"
TIMEZONE="Europe/London"
LANGUAGE="en_GB.UTF-8"
KEYBOARD="uk"

HOSTNAME="anthony-laptop"

echo "Installing vim"
pacman -S vim

echo "Setting timezone to Europe/London"
ln -sf "/usr/share/zoneinfo/${TIMEZONE}" /etc/localtime

echo "Setting hardware clock"
hwclock --systohc

echo "Set locale info"
#vim /etc/locale.gen
locale-gen

echo "Setting Language and keyboard"
echo "LANG=${LANGUAGE}" > /etc/locale.conf
echo "KEYMAP=$KEYBOARD" > /etc/vconsole.conf

echo "Setting hostname"

echo "$HOSTNAME" > /etc/hostname
echo "127.0.0.1		localhost" > /etc/hosts
echo "::1		localhost" >> /etc/hosts
echo "127.0.1.1		${HOSTNAME}.localdomain	${HOSTNAME}" >> /etc/hosts
