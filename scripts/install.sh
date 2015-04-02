#!/bin/bash

ADDONS=$(pwd)/addon

#
# Prepare for openHAB, create openhab-user
#
id openhab 2>/dev/null >/dev/null || useradd -c openHAB -d /home/openhab -m -U openhab
echo "openhab:openhab" | chpasswd

#
# Download openhab, setup
#

cd /home/openhab
# Donwload & extract
rm pistore.desktop 
wget https://github.com/openhab/openhab/releases/download/v1.6.2/distribution-1.6.2-runtime.zip
unzip distribution-1.6.2-runtime.zip

rm -v distribution-1.6.2-runtime.zip
DATE=$(date +%Y%m%d)
mkdir runtime-$DATE
mv * runtime-$DATE
ln -snf runtime-$DATE runtime

# Move config & persistent data out of runtime
[ ! -d configurations ] && mv runtime/configurations .
ln -snf /home/openhab/configurations/ runtime/configurations
[ ! -d etc ] && mv runtime/etc .
ln -snf /home/openhab/etc runtime/etc

#
# Fix permission
#
chown -R openhab:openhab *

#
# Add openhab to autostart on boot
#
cp $ADDONS/initscript.sh /etc/init.d/openhab
chmod 774 /etc/init.d/openhab
update-rc.d openhab defaults

#
# Samba setup for easy access to config
#
apt-get -y install samba
grep openhab /etc/samba/smb.conf || echo "include = /etc/samba/openhab.cfg" >> /etc/samba/smb.conf
cp $ADDONS/openhab.cfg-samba /etc/samba/openhab.cfg

