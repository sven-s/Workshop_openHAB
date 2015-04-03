#!/bin/bash

apt-get update
apt-get -y upgrade
rpi-update
sudo ldconfig


# Regenerate SSH Host Keys, restart SSHd
#rm /etc/ssh/ssh_host_* && dpkg-reconfigure openssh-server

# Install & configure NTP
apt-get -y install ntp fake-hwclock vim
echo "Europe/Berlin" > /etc/timezone
dpkg-reconfigure -f noninteractive tzdata

#
# Change hostname to openhab
#
hostname openhab2
echo openhab2 > /etc/hostname
echo "127.0.0.1 openhab2" >> /etc/hosts

# Set locale to de_DE.UTF-8 and en_GB.UTF-8 via raspi-config
