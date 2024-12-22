#!/bin/bash
# -----------------------------------------
# install rfriends for moode
# -----------------------------------------
# 1.0 2024/08/30 new
# 1.1 2024/08/31 crontab,rfriends.ini,trans
# 1.2 2024/09/01 rfriends.ini
# 1.3 2024/09/02 pulseaudio
# 1.4 2024/09/03 crontab
# 1.5 2024/09/03 fstab
# 1.6 2024/09/10 cron
# 1.7 2024/09/16 cron
# 1.8 2024/09/16 pulseaudio
# 1.9 2024/10/29 add webdav
# 2.0 2024/12/14 github
# -----------------------------------------
ver=2.0
echo
echo rfriends3 for moode $ver
echo
SITE=https://github.com/rfriends/rfriends3/releases/latest/download
SCRIPT=rfriends3_latest_script.zip
# -----------------------------------------
user=`whoami`
dir=`pwd`
userstr="s/rfriendsuser/${user}/g"
# -----------------------------------------
ar=`dpkg --print-architecture`
bit=`getconf LONG_BIT`
echo
echo architecture is $ar $bit bits .
echo user is $user .
# -----------------------------------------
echo
echo install tools
echo
#
sudo apt-get update && sudo apt-get -y install \
unzip p7-zip-full nano vim dnsutils iproute2 tzdata \
at cron wget curl atomicparsley \
php-cli php-xml php-zip php-mbstring php-json php-curl php-intl \
ffmpeg

sudo apt-get -y install chromium-browser
#sudo apt-get -y install samba
sudo apt-get -y install lighttpd lighttpd-mod-webdav php-cgi
sudo apt-get -y install openssh-server
sudo apt-get -y install pulseaudio
# -----------------------------------------
echo
echo install rfriends3
echo
cd ~/
rm -f $SCRIPT
wget $SITE/$SCRIPT
unzip -q -o $SCRIPT
# -----------------------------------------
echo
echo configure samba for moode
echo

cd $dir
#
cat /etc/samba/smb.conf | grep 'force user = '
ret=$?

if [ $ret = 1 ]; then
    sudo cp -p /etc/samba/smb.conf /etc/samba/smb.conf.org
    sed "/Internal Storage/a force user = $user" /etc/samba/smb.conf > $dir/smb.conf
    sudo cp -p $dir/smb.conf /etc/samba/smb.conf
    echo 'smb.conf editted.'
else
    echo 'smb.conf already editted.'
fi

#sudo systemctl restart smbd nmbd
sudo service smbd restart
# -----------------------------------------
cd $dir
echo
echo configure usrdir
echo
sudo chmod 775 /mnt/SDCARD
#
sudo mkdir -p /mnt/SDCARD/usr2/
sudo chown $user /mnt/SDCARD/usr2/
sudo chgrp $user /mnt/SDCARD/usr2/
#
sudo mkdir -p /mnt/SDCARD/trans/
sudo chown $user /mnt/SDCARD/trans/
sudo chgrp $user /mnt/SDCARD/trans/
#
mkdir -p /home/$user/tmp/
sudo chown $user /home/$user/tmp/
sudo chgrp $user /home/$user/tmp/
sudo chmod 777   /home/$user/tmp/
sed -e ${userstr} $dir/usrdir.ini.skel > /home/$user/rfriends3/config/usrdir.ini
#
# crontab
sed -e ${userstr} $dir/crontab.skel > $dir/crontab
crontab crontab
sudo systemctl enable cron
#
# rfriends.ini
#cp -p $dir/x.rfriends.ini.skel /home/$user/rfriends3/template/rfriends.ini
cp -p $dir/x.rfriends.ini.skel /home/$user/rfriends3/config/rfriends.ini
#cp -p $dir/x.rfriends.ini.skel /home/$user/rfriends3/script/rfriends.ini
# -----------------------------------------
cd $dir
echo
echo fstab
echo
cat /etc/fstab | grep "/home/$user/tmp"
ret=$?

if [ $ret = 1 ]; then
    cp -p /etc/fstab $dir/fstab
    sed -e ${userstr} $dir/fstab.skel >> $dir/fstab
    sudo cp -p $dir/fstab /etc/fstab
else
    echo 'fstab already editted.'
fi
# -----------------------------------------
cd $dir
echo
echo pulseaudio
echo
#sudo useradd -d /var/run/pulse -s /usr/sbin/nologin -G audio pulse
#sudo usermod -aG bluetooth pulse
#sudo groupadd pulse-access
#sudo usermod -aG pulse-access root
#
#sudo rm $user/.asoundrc
#
#sudo systemctl --global disable pulseaudio.service
#sudo systemctl --global disable pulseaudio.socket
#sudo systemctl --global mask pulseaudio.service
#sudo systemctl --global mask pulseaudio.socket
#
#sudo cp -p $dir/pulseaudio.service /etc/systemd/system/pulseaudio.service
#
#sudo systemctl enable pulseaudio
# -----------------------------------------
echo
echo configure lighttpd
echo

sudo cp -p /etc/lighttpd/conf-available/15-fastcgi-php.conf /etc/lighttpd/conf-available/15-fastcgi-php.conf.org
sudo sed -e ${userstr} $dir/15-fastcgi-php.conf.skel > $dir/15-fastcgi-php.conf
sudo cp -p $dir/15-fastcgi-php.conf /etc/lighttpd/conf-available/15-fastcgi-php.conf
sudo chown root:root /etc/lighttpd/conf-available/15-fastcgi-php.conf

sudo cp -p /etc/lighttpd/lighttpd.conf /etc/lighttpd/lighttpd.conf.org
sudo sed -e ${userstr} $dir/lighttpd.conf.skel > $dir/lighttpd.conf
sudo cp -p $dir/lighttpd.conf /etc/lighttpd/lighttpd.conf
sudo chown root:root /etc/lighttpd/lighttpd.conf

mkdir -p /home/$user/lighttpd/uploads/
cd /home/$user/rfriends3/script/html
ln -nfs temp webdav
cd ~/

sudo lighttpd-enable-mod fastcgi
sudo lighttpd-enable-mod fastcgi-php

#sudo systemctl restart lighttpd
sudo service lighttpd restart
# -----------------------------------------
echo
echo configure misc
echo
#
cp -p $dir/vimrc /home/$user/.vimrc
# -----------------------------------------
ip=`ip -4 -br a`
echo
echo ip address is $ip .
echo
#echo visit rfriends at http://xxx.xxx.xxx.xxx:8000 .
#echo
# -----------------------------------------
# finish
# -----------------------------------------
echo Installation completed
echo 
read -p "Press return key to restart" ans
#
cd ~/
echo rfriends3_volumio $ver > rfriends3_moode.log
ffmpeg 2>> rfriends3_moode.log
rm rfriends3_moode.zip
rm rfriends3_moode/*
rmdir rfriends3_moode
#
sudo reboot
# -----------------------------------------
