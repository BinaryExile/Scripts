#!/bin/bash
echo[*] Change Password
passwd
echo Update
apt-get update && apt-get -y upgrade
echo Setting up Metasploit Database to Start on Boot
service postgresql start
update-rc.d postgresql enable
msfdb init
echo Installing gedit
apt-get -y install gedit
echo Changing Host Name
echo Workstation > /etc/hostname
sed -i 's/kali/Workstation/g' /etc/hosts
echo Turn on Metasploit Logging
echo “spool /root/msf_console.log” > /root/.msf5/msfconsole.rc
echo Lists of fuzzing parameters, paswords, ect to /opt/SecLists
mkdir /usr/share/wordlists/SecLists
git clone https://github.com/danielmiessler/SecLists.git /usr/share/wordlists/SecLists
echo Installs Discover
git clone https://github.com/leebaird/discover.git /opt/discover && /opt/discover/update.sh
echo Installing Pure FTP
apt-get install -y pure-ftpd
groupadd ftpgroup useradd -g ftpgroup -d /dev/null -s /etc ftpuser 
pure-pw useradd ftpuser -u ftpuser -d /ftphome 
pure-pw mkdb 
cd /etc/pure-ftpd/auth/ 
ln -s ../conf/PureDB 60pdb 
mkdir -p /ftphome 
chown -R ftpuser:ftpgroup /ftphome/ 
/etc/init.d/pure-ftpd restart 
echo [*] updating searchsploit
searchsploit --update
echo [*] installing ftp client
apt-get install -y ftp
echo [*] installing xdotool
apt-get install -y cifs-utils sshfs exif exiv2 exfat-fuse exfat-utils nfs-common
apt-get install -y xdotool
# ntlmrelayx
mkdir -p /opt/ntlmrelayx
cd /opt/ntlmrelayx
apt-get install -y libssl-dev libffi-dev python-dev
pip install pyopenssl
pip install ldap3
pip install ldap3 --upgrade
git clone https://github.com/lgandx/Responder
git clone 'https://github.com/CoreSecurity/impacket'
cd impacket
python setup.py install
cd ../Responder
sed -Ei 's/HTTP = On/HTTP = Off/g' Responder.conf
sed -Ei 's/HTTPS = On/HTTPS = Off/g' Responder.conf
sed -Ei 's/SMB = On/SMB = Off/g' Responder.conf
apt-get install -y linux-exploit-suggester
cd /opt/
git clone 'https://github.com/EmpireProject/Empire'
cd Empire
./setup/install.sh
# xwatchwin
echo [*] installing xwatchwin
cd /opt
wget "http://www.ibiblio.org/pub/X11/contrib/utilities/xwatchwin.tar.gz"
tar -xzvf xwatchwin.tar.gz
rm xwatchwin.tar.gz
cd xwatchwin
apt-get -y install xutils-dev
xmkmf
make
cd ~
cd /opt
wget "http://xorg.freedesktop.org/archive/individual/app/xwd-1.0.5.tar.bz2"
tar -xjvf xwd-1.0.5.tar.bz2
rm xwd-1.0.5.tar.bz2
cd xwd-1.0.5
apt-get install -y libx11-dev libxt-dev pkgconf
./configure ; make ; make install
cd ~
apt-get install -y dnsmasq hostapd-wpe
systemctl disable dnsmasq
systemctl disable hostapd-wpe
echo [*] Installing mingw
apt-get install -y mingw-w64
apt-get install -y dnsutils passing-the-hash creddump
apt-get install -y bettercap
mkdir /opt/xrdp/
cd /opt/xrdp/ 
wget https://raw.githubusercontent.com/sensepost/xrdp/master/xrdp.py
echo Installing Wappalyzer
curl https://addons.mozilla.org/firefox/downloads/latest/wappalyzer/addon-10229-latest.xpi && firefox -install-global-extension addon-10229-latest.xpi && rm *.xpi
echo Installing foxyproxy
wget https://addons.mozilla.org/firefox/downloads/latest/foxyproxy-standard/addon-2464-latest.xpi && firefox -install-global-extension addon-2464-latest.xpi && rm *.xpi
echo Installing Developer Toolbar
wget https://addons.mozilla.org/firefox/downloads/latest/web-developer/addon-60-latest.xpi && firefox -install-global-extension addon-60-latest.xpi && rm *.xpi
apt-get --purge -y autoremove
apt-get clean
