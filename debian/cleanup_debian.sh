#!/bin/sh -eux

echo "remove linux-headers"
sudo dpkg --list \
  | awk '{ print $2 }' \
  | grep 'linux-headers' \
  | xargs apt-get -y purge;

echo "remove specific Linux kernels, such as linux-image-4.9.0-13-amd64 but keeps the current kernel and does not touch the virtual packages"
sudo dpkg --list \
    | awk '{ print $2 }' \
    | grep 'linux-image-[1-9].*' \
    | grep -v "$(uname -r)" \
    | xargs apt-get -y purge;

echo "remove linux-source package"
sudo dpkg --list \
    | awk '{ print $2 }' \
    | grep linux-source \
    | xargs apt-get -y purge;

echo "remove all development packages"
sudo dpkg --list \
    | awk '{ print $2 }' \
    | grep -- '-dev\(:[a-z0-9]\+\)\?$' \
    | xargs apt-get -y purge;

echo "remove X11 libraries"
sudo apt-get -y purge libx11-data xauth libxmuu1 libxcb1 libx11-6 libxext6;

echo "remove obsolete networking packages"
sudo apt-get -y purge ppp pppconfig pppoeconf;

echo "remove popularity-contest package"
sudo apt-get -y purge popularity-contest;

echo "remove installation-report package"
sudo apt-get -y purge installation-report;

echo "autoremoving packages and cleaning apt data"
sudo apt-get -y autoremove;
sudo apt-get -y clean;

echo "remove /var/cache"
sudo find /var/cache -type f -exec rm -rf {} \;

echo "truncate any logs that have built up during the install"
sudo find /var/log -type f -exec truncate --size=0 {} \;

echo "blank netplan machine-id (DUID) so machines get unique ID generated on boot"
sudo truncate -s 0 /etc/machine-id
if test -f /var/lib/dbus/machine-id
then
  sudo truncate -s 0 /var/lib/dbus/machine-id  # if not symlinked to "/etc/machine-id"
fi

echo "remove the contents of /tmp and /var/tmp"
sudo rm -rf /tmp/* /var/tmp/*

echo "force a new random seed to be generated"
sudo rm -f /var/lib/systemd/random-seed

echo "clear the history so our install isn't there"
sudo rm -f /root/.wget-hsts
export HISTSIZE=0
