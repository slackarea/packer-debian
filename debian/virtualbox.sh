#!/bin/bash

set -e
set -u
set -x


if [ "$PACKER_BUILDER_TYPE" != "virtualbox-iso" ]; then
  exit 0
fi

echo "installing deps necessary to compile kernel modules"
sudo apt-get -y install bzip2 tar
sudo apt-get -y install build-essential
sudo apt-get -y install linux-headers-$(uname -r)
sudo apt-get -y install dkms
sudo apt-get -y install make

# Uncomment this if you want to install Guest Additions with support for X
#sudo apt-get -y install xserver-xorg

echo "installing from apt repository"
sudo apt-get install virtualbox-guest-additions-iso

mkdir -p /tmp/vbox
#sudo mount -o loop ~/VBoxGuestAdditions.iso /tmp/vbox
sudo mount -o loop /usr/share/virtualbox/VBoxGuestAdditions.iso /tmp/vbox

echo "installing the vbox additions"
sudo dkms status
sudo /tmp/vbox/VBoxLinuxAdditions.run --nox11 || true

echo "unmounting and removing the vbox ISO"
sudo umount /tmp/vbox
sudo rm -rf /tmp/vbox
rm -f ~/VBoxGuestAdditions.iso

if ! modinfo vboxsf >/dev/null 2>&1; then
  echo "Cannot find vbox kernel module. Installation of guest additions unsuccessful!"
  #exit 1
fi

echo "removing kernel dev packages and compilers we no longer need"
sudo apt-get -y remove build-essential gcc g++ make libc6-dev dkms linux-headers-"$(uname -r)"

echo "removing leftover logs"
sudo rm -rf /var/log/vboxadd*
