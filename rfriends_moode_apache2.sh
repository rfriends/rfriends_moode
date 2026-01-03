#!/bin/bash
# -----------------------------------------
# install rfriends for vmoode player
# -----------------------------------------
# 2.2 2026/01/02
# -----------------------------------------
ver=2.2
echo
echo rfriends3 for moode player $ver apache2
echo
# -----------------------------------------
user=`whoami`
dir=`pwd`
userstr="s/rfriendsuser/${user}/g"
dir=$(cd $(dirname $0);pwd)
user=`whoami`
if [ -z $HOME ]; then
  homedir=`sh -c 'cd && pwd'`
else
  homedir=$HOME
fi
# -----------------------------------------
cd ~/
rm -rf rfriends3_core
git clone https://github.com/rfriends/rfriends3_core.git
if [ $? != 0 ]; then
  echo クローンに失敗しました。
  echo 少し時間をおいて再度実行してください。
  exit 1
fi
cd rfriends3_core

export distro="debian"
export optlighttpd="off"
export optapache2="on"
export optsamba="on"
export optvimrc="on"

export lighttpd="lighttpd"
export apache2="apache2"
export apache_conf_dir="/etc/apache2"
export smbd="smbd"
export atd="atd"
export cron="cron"

sudo apt-get update && sudo apt-get upgrade -y
sh common.sh 2>&1 | tee common.log
# -----------------------------------------
#echo
#echo configure samba for volumio moode player
#echo
#cd $dir
#cat /etc/samba/smb.conf | grep 'force user = '
#ret=$?
#
#if [ $ret = 1 ]; then
#    sudo cp -p /etc/samba/smb.conf /etc/samba/smb.conf.org
#    sed "/Internal Storage/a force user = $user" /etc/samba/smb.conf > $dir/smb.conf
#    sudo cp -p $dir/smb.conf /etc/samba/smb.conf
#else
#    echo 'smb.conf already editted.'
#fi
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
echo configure usrdir
echo
sudo chmod 775 /mnt/SDCARD
#
sudo mkdir -p /mnt/SDCARD/usr2/
sudo chown $user:$user /mnt/SDCARD/usr2/
#
sudo mkdir -p /mnt/SDCARD/trans/
sudo chown $user:$user /mnt/SDCARD/trans/
#
mkdir -p $homedir/tmp/
sudo chown $user:$user $homedir/tmp/
sudo chmod 777   $homedir/tmp/

cat <<EOF > $homedir/rfriends3/config/usrdir.ini
usrdir = "/mnt/SDCARD/usr2/"
tmpdir = "$homedir/tmp/"
EOF
#
# crontab
sed -e ${userstr} $dir/crontab.skel > $dir/crontab
crontab crontab
sudo systemctl enable cron
#
# rfriends.ini
cp -p $dir/x.rfriends.ini.skel /home/$user/rfriends3/config/rfriends.ini
# -----------------------------------------
ip=`ip -4 -br a`
echo
echo ip address is $ip .
echo
echo 再起動後、以下にアクセスしてください
echo http://IPアドレス:8000
echo
# -----------------------------------------
# finish
# -----------------------------------------
echo Installation completed
# -----------------------------------------
