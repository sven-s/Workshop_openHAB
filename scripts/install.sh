#!/bin/bash

ADDONS=$(pwd)/addon

#
# Prepare for openHAB, create openhab-user
#
id openhab 2>/dev/null >/dev/null || useradd -c openHAB -d /home/openhab -m -U openhab
echo "openhab:openhab" | chpasswd
adduser openhab sudo

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

#
# Get addons
#
wget https://github.com/openhab/openhab/releases/download/v1.6.2/distribution-1.6.2-addons.zip
unzip distribution-1.6.2-addons.zip -d addons-$DATE
cd addons-$DATE
cp *.mail-* ../runtime/addons
cp *.pushover-* ../runtime/addons
cp *.squeezebox-* ../runtime/addons
cp *.astro-* ../runtime/addons
cp *.exec-* ../runtime/addons
cp *.fritzbox-* ../runtime/addons
cp *.http-* ../runtime/addons
cp *.hue-* ../runtime/addons
cp *.mqtt-* ../runtime/addons
cp *.mqttitude-* ../runtime/addons
cp *.networkhealth-* ../runtime/addons
cp *.ntp-* ../runtime/addons
cp *.rfxcom-* ../runtime/addons
cp *.zwave-* ../runtime/addons
cp *.squeezeserver-* ../runtime/addons
cp *.logging-* ../runtime/addons
cp *.rrd4j-* ../runtime/addons
cd ..

rm distribution-1.6.2-addons.zip

#
# install razberry
#
wget -q -O - razberry.z-wave.me/install | bash
service z-way-server stop && update-rc.d z-way-server disable

#
# install mosh 
#
apt-get install -y mosh

#
# install mosquitto - thanks to http://jpmens.net/2013/09/01/installing-mosquitto-on-a-raspberry-pi/
#
curl -O http://repo.mosquitto.org/debian/mosquitto-repo.gpg.key
sudo apt-key add mosquitto-repo.gpg.key
rm mosquitto-repo.gpg.key
cd /etc/apt/sources.list.d/
sudo curl -O http://repo.mosquitto.org/debian/mosquitto-repo.list
sudo apt-get update

apt-get install -y mosquitto mosquitto-clients python-mosquitto
/etc/init.d/mosquitto stop

mkdir /var/log/mosquitto

#
# get tools to setup mosquitto
#
mkdir owntracks
cd owntracks
git clone https://github.com/owntracks/tools.git
./tools/mosquitto-setup.sh
rm mosquitto.conf
cp $ADDONS/mosquitto.conf /etc/mosquitto/mosquitto.conf

mosquitto_passwd -c /etc/mosquitto/mosquitto.passwd sven
mosquitto_passwd /etc/mosquitto/mosquitto.passwd eija
mosquitto_passwd /etc/mosquitto/mosquitto.passwd openhab

# copy to ca.crt to the samba share, so i can send it via mail to my iphone
cp /etc/mosquitto/conf.d/ca.crt /home/openhab/configurations/mosquitto_ca.crt



