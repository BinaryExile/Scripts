#!/bin/bash
echo -e "\n\n[*] Adding Timestamp to terminal and history\n\n"
echo 'export HISTTIMEFORMAT="%F-%T "' >> /root/.bashrc 
echo 'export PS1="\e[032m\D{%F %T}\e[m \n\u \W\\$ \[$(tput sgr0)\]"' >> /root/.bashrc 
echo -e "\n\n[*] Change Password \n\n"
until passwd
do
  echo "Try again"
done
echo -e "\n\n[*] Updating \n\n"
apt-get -y update && apt-get -y upgrade
echo -e "\n\n[*] Installing offline service for the BinaryExile Wiki at http://127.0.0.1:4000\n\n"
gem install bundler
mkdir /root/BinaryExileWiki && cd /root/BinaryExileWiki
git clone https://github.com/BinaryExile/BinaryExile.github.io
cd /root/BinaryExileWiki/BinaryExile.github.io
bundle install
bundle exec jekyll serve &
cd /etc/systemd/system/
wget "https://raw.githubusercontent.com/BinaryExile/Scripts/master/Kali%20Setup/jekyll.service"
cd ~
echo -e "\n\n[*] Setting up Metasploit Database to Start on Boot \n\n"
service postgresql start
update-rc.d postgresql enable
msfdb init
echo -e "\n\n[*] Installing gedit \n\n"
apt-get -y install gedit
echo -e "\n\n[*]  Changing Host Name \n\n"
echo Workstation > /etc/hostname
sed -i 's/kali/Workstation/g' /etc/hosts
echo -e "\n\n[*] Turning on Metasploit Logging \n\n"
cd /root/.msf*
echo “spool /root/msf_console.log” > msfconsole.rc
cd ~
echo -e "\n\n[*]  Lists of fuzzing parameters, paswords, ect to /usr/share/wordlists/SecLists \n\n"
mkdir /usr/share/wordlists/SecLists
git clone https://github.com/danielmiessler/SecLists.git /usr/share/wordlists/SecLists
echo -e "\n\n[*] Installs Discover \n\n"
git clone https://github.com/leebaird/discover.git /opt/discover && /opt/discover/update.sh
ln -s /opt/discover/discover.sh /usr/local/bin/discover.sh
echo -e "\n\n[*] Installing Pure FTP \n\n"
apt-get install -y pure-ftpd
groupadd ftpgroup 
useradd -g ftpgroup -d /dev/null -s /etc ftpuser 
pure-pw useradd ftpuser -u ftpuser -d /ftphome 
pure-pw mkdb 
cd /etc/pure-ftpd/auth/ 
ln -s ../conf/PureDB 60pdb 
mkdir -p /ftphome 
chown -R ftpuser:ftpgroup /ftphome/ 
/etc/init.d/pure-ftpd restart 
pip uninstall selenium
pip install selenium
echo -e "\n\n[*] installing ftp client \n\n"
apt-get install -y ftp
echo -e "\n\n[*] installing xdotool \n\n"
apt-get install -y cifs-utils sshfs exif exiv2 exfat-fuse exfat-utils nfs-common
apt-get install -y xdotool
echo -e "\n\n[*] installing ntlmrelay \n\n"
mkdir -p /opt/ntlmrelayx
cd /opt/ntlmrelayx
apt-get install -y libssl-dev libffi-dev python-dev
pip install pyopenssl
pip install ldap3
pip install ldap3 --upgrade
echo -e "\n\n[*] installing responder \n\n"
git clone https://github.com/lgandx/Responder
git clone 'https://github.com/CoreSecurity/impacket'
cd impacket
python setup.py install
cd ../Responder
sed -Ei 's/HTTP = On/HTTP = Off/g' Responder.conf
sed -Ei 's/HTTPS = On/HTTPS = Off/g' Responder.conf
sed -Ei 's/SMB = On/SMB = Off/g' Responder.conf
echo -e "\n\n[*] installing linux-exploit-suggester \n\n"
apt-get install -y linux-exploit-suggester
cd /opt/
echo -e "\n\n[*] installing ncrack\n\n"
mkdir /opt/ncrack
cd /opt/ncrack
git clone https://github.com/nmap/ncrack
cd /opt/ncrack/ncrack
chmod +x configure
./configure ; make ; make install
echo -e "\n\n[*] installing Empire \n\n"
git clone 'https://github.com/EmpireProject/Empire'
cd Empire
./setup/install.sh
# xwatchwin
echo -e "\n\n[*] installing xwatchwin \n\n"
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
echo -e "\n\n[*] installing xwd \n\n"
wget "http://xorg.freedesktop.org/archive/individual/app/xwd-1.0.5.tar.bz2"
tar -xjvf xwd-1.0.5.tar.bz2
rm xwd-1.0.5.tar.bz2
cd xwd-1.0.5
apt-get install -y libx11-dev libxt-dev pkgconf
./configure ; make ; make install
cd ~
echo -e "\n\n[*] installing dnsmasq and hostapd-wpe \n\n"
apt-get install -y dnsmasq hostapd-wpe
systemctl disable dnsmasq
systemctl disable hostapd-wpe
echo -e "\n\n[*] installing mingw, passing-the-hash, and creddump \n\n"
apt-get install -y mingw-w64
apt-get install -y dnsutils passing-the-hash creddump
echo -e "\n\n[*] installing bettercap \n\n"
apt-get install -y bettercap
echo -e "\n\n[*] installing xrdp \n\n"
mkdir /opt/xrdp/
cd /opt/xrdp/ 
wget https://raw.githubusercontent.com/sensepost/xrdp/master/xrdp.py
ln -s /opt/xrdp/xrdp.py /usr/local/bin/xrdp.py
echo -e "\n\n[*] installing brutus ftp bruteforcer \n\n"
mkdir /opt/brutus
wget https://gist.githubusercontent.com/BushiSecurity/934c2576e7dc6c0885a7f4eb2e1043b5/raw/80557a02addea2aaa9ffff64c0d80d24ceafe37b/brutus.py
echo Installing Wappalyzer
curl https://addons.mozilla.org/firefox/downloads/latest/wappalyzer/addon-10229-latest.xpi && firefox -install-global-extension addon-10229-latest.xpi && rm *.xpi
echo Installing foxyproxy
wget https://addons.mozilla.org/firefox/downloads/latest/foxyproxy-standard/addon-2464-latest.xpi && firefox -install-global-extension addon-2464-latest.xpi && rm *.xpi
echo Installing Developer Toolbar
wget https://addons.mozilla.org/firefox/downloads/latest/web-developer/addon-60-latest.xpi && firefox -install-global-extension addon-60-latest.xpi && rm *.xpi
echo [*] updating searchsploit
echo -e "\n\n[*] cleaning up \n\n"
apt-get --purge -y autoremove
apt-get clean
echo -e "\n\n[*] Updating Searchsploit [note: it has been freezing recently] \n\n"
searchsploit --update
