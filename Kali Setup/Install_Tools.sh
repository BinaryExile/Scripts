#!/bin/bash
mkdir /root/logs
mkdir /root/logs/script
mkdir /root/logs/screenshots
mkdir /root/logs/metasploit
echo -e "\n\n[*] Adding Timestamp to terminal and history\n\n"
echo 'export HISTTIMEFORMAT="%F-%T "' >> /root/.bashrc 
echo 'export PS1="\e[032m\D{%F %T}\e[m \n\u \W\\$ \[$(tput sgr0)\]"' >> /root/.bashrc 
echo 'lsof -tac script "$(tty)" || {' >> /root/.bashrc 
echo -e "\n\n[*] Adding auto script command to bash launch.  Remember to type exit and not close the window\n\n"
echo '   	script -f /root/logs/script/Script-$(date -d "today" +"%Y%m%d%H%M%S").log' >> /root/.bashrc 
echo '}' >>  /root/.bashrc 
echo -e "\n\n[*] Change Password \n\n"
until passwd
do
  echo "Try again"
done
echo -e "\n\n[*] Updating \n\n"
apt-get -y update && apt-get -y upgrade
echo -e “Installing screenshot program to capture screen every 30 seconds and archive every hour”
sudo apt-get install openvas
sudo apt-get install scrot
touch /usr/local/bin/screen.sh
chmod 777 /usr/local/bin/screen.sh
echo '#!/bin/bash' >  /usr/local/bin/screen.sh
echo "while true; do scrot -d 60 /root/logs/screenshots/'%Y-%m-%d-%H:%M:%S.png' -q 20; done" > /usr/local/bin/screen.sh
#echo '#!/bin/sh' >  /root/archive.sh
#echo 'tar -rczf /root/logs/screenshots/screenshot_backup_`date +%Y%m%d%H%M%S`.tar.gz /root/logs/screenshots/*.png && rm -rf /root/logs/screenshots/*.png' >> /root/archive.sh
#echo 'tar -czf /root/logs/script/script_backup_`date +%Y%m%d%H%M%S`.tar.gz /root/logs/script/*.log && rm -rf /root/logs/script/*.log' >> /root/archive.sh
#chmod +x /root/archive.sh
#(crontab -l 2>/dev/null; echo "0 * * * * /root/archive.sh") | crontab -
echo -e "\n\n[*] Installing offline service for the BinaryExile Wiki at http://127.0.0.1:4000\n\n"
gem install bundler 2>> /root/errorlog.txt 1>> /root/log.txt
mkdir /root/BinaryExileWiki 2>> /root/errorlog.txt 1>> /root/log.txt && cd /root/BinaryExileWiki 2>> /root/errorlog.txt 1>> /root/log.txt
git clone https://github.com/BinaryExile/BinaryExile.github.io 2> /root/errorlog.txt 1> log.txt
cd /root/BinaryExileWiki/BinaryExile.github.io
bundle install 2>> /root/errorlog.txt 1>> /root/log.txt
cd /etc/systemd/system/
wget "https://raw.githubusercontent.com/BinaryExile/Scripts/master/Kali%20Setup/jekyll.service" 2>> /root/errorlog.txt 
cd ~
echo -e "\n\n[*] Updating NMAPs Scripts \n\n"
nmap --script-updatedb
cd /usr/share/nmap/scripts/
wget https://raw.githubusercontent.com/vulnersCom/nmap-vulners/master/vulners.nse
git clone https://github.com/scipag/vulscan.git
cd vulscan
mv *.csv ..
mv *.nse ..
cd ..
wget https://www.computec.ch/projekte/vulscan/download/scipvuldb.csv -O scipvuldb.csv 
cd ~
echo -e "\n\n[*] Setting up Metasploit Database to Start on Boot \n\n"
service postgresql start 2>> /root/errorlog.txt 1>> /root/log.txt
update-rc.d postgresql enable 2>> /root/errorlog.txt 1>> /root/log.txt
msfdb init 2>> /root/errorlog.txt 1>> /root/log.txt
echo -e "\n\n[*] Installing gedit \n\n"
apt-get -y install gedit 2>> /root/errorlog.txt 1>> /root/log.txt
echo -e "\n\n[*]  Changing Host Name \n\n"
echo Workstation > /etc/hostname
sed -i 's/kali/Workstation/g' /etc/hosts
echo -e "\n\n[*] Turning on Metasploit Logging \n\n"
cd /root/.msf* 
echo 'spool /root/logs/metasploit/msf_console.log' > msfconsole.rc
echo 'use exploit/multi/handler' >> msfconsole.rc
echo 'set ExitOnSession false' >> msfconsole.rc
cd ~
echo -e "\n\n[*]  Lists of fuzzing parameters, paswords, ect to /usr/share/wordlists/SecLists \n\n"
mkdir /usr/share/wordlists/SecLists
git clone https://github.com/danielmiessler/SecLists.git /usr/share/wordlists/SecLists 2>> /root/errorlog.txt 1>> /root/log.txt
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
apt-get install -y ftp 2>> /root/errorlog.txt 1>> /root/log.txt
echo -e "\n\n[*] installing xdotool \n\n"
apt-get install -y cifs-utils sshfs exif exiv2 exfat-fuse exfat-utils nfs-common 2>> /root/errorlog.txt 1>> /root/log.txt
apt-get install -y xdotool 2>> /root/errorlog.txt 1>> /root/log.txt
echo -e "\n\n[*] installing ntlmrelay \n\n"
mkdir -p `python -m site --user-site`
cd `python -m site --user-site`
wget https://raw.githubusercontent.com/worawit/MS17-010/master/mysmb.py
mkdir -p /opt/ntlmrelayx 
cd /opt/ntlmrelayx
apt-get install -y libssl-dev libffi-dev python-dev 2>> /root/errorlog.txt 1>> /root/log.txt
pip install pyopenssl 2>> /root/errorlog.txt 1>> /root/log.txt
pip install ldap3 2>> /root/errorlog.txt 1>> /root/log.txt
pip install ldap3 --upgrade 2>> /root/errorlog.txt 1>> /root/log.txt
echo -e "\n\n[*] installing responder \n\n" 
git clone https://github.com/lgandx/Responder 2>> /root/errorlog.txt 1>> /root/log.txt
git clone 'https://github.com/CoreSecurity/impacket' 2>> /root/errorlog.txt 1>> /root/log.txt
cd impacket
python setup.py install 2>> /root/errorlog.txt 1>> /root/log.txt
cd ../Responder
sed -Ei 's/HTTP = On/HTTP = Off/g' Responder.conf
sed -Ei 's/HTTPS = On/HTTPS = Off/g' Responder.conf
sed -Ei 's/SMB = On/SMB = Off/g' Responder.conf
echo -e "\n\n[*] installing linux-exploit-suggester \n\n"
apt-get install -y linux-exploit-suggester 2>> /root/errorlog.txt 1>> /root/log.txt
cd /opt/
echo -e "\n\n[*] installing ncrack\n\n"
cd /opt
git clone https://github.com/nmap/ncrack 2>> /root/errorlog.txt 1>> /root/log.txt
cd /opt/ncrack
chmod +x configure
./configure 2>> /root/errorlog.txt 1>> /root/log.txt ; make 2>> /root/errorlog.txt 1>> /root/log.txt ; make install 2>> /root/errorlog.txt 1>> /root/log.txt
echo -e "\n\n[*] installing Empire \n\n"
cd /opt/
git clone 'https://github.com/EmpireProject/Empire' 2>> /root/errorlog.txt 1>> /root/log.txt
cd Empire
./setup/install.sh
# xwatchwin
echo -e "\n\n[*] installing xwatchwin \n\n"
cd /opt
wget "http://www.ibiblio.org/pub/X11/contrib/utilities/xwatchwin.tar.gz" 2>> \root\errorlog.txt
tar -xzvf xwatchwin.tar.gz
rm xwatchwin.tar.gz
cd xwatchwin
apt-get -y install xutils-dev 2>> /root/errorlog.txt 1>> /root/log.txt
xmkmf
make 2>> /root/errorlog.txt 1>> /root/log.txt
cd ~
cd /opt
echo -e "\n\n[*] installing xwd \n\n"
wget "http://xorg.freedesktop.org/archive/individual/app/xwd-1.0.5.tar.bz2"  2>> /root/errorlog.txt 1>> /root/log.txt
tar -xjvf xwd-1.0.5.tar.bz2
rm xwd-1.0.5.tar.bz2
cd xwd-1.0.5
apt-get install -y libx11-dev libxt-dev pkgconf 2>> /root/errorlog.txt 1>> /root/log.txt
./configure 2>> /root/errorlog.txt 1>> /root/log.txt; make 2>> /root/errorlog.txt 1>> /root/log.txt; make install 2>> /root/errorlog.txt 1>> /root/log.txt
cd ~
echo -e "\n\n[*] installing dnsmasq and hostapd-wpe \n\n"
apt-get install -y dnsmasq hostapd-wpe 2>> /root/errorlog.txt 1>> /root/log.txt
systemctl disable dnsmasq 2>> /root/errorlog.txt 1>> /root/log.txt
systemctl disable hostapd-wpe 2>> /root/errorlog.txt 1>> /root/log.txt
echo -e "\n\n[*] installing mingw, passing-the-hash, and creddump \n\n"
apt-get install -y mingw-w64 2>> /root/errorlog.txt 1>> /root/log.txt
apt-get install -y dnsutils passing-the-hash creddump 2>> /root/errorlog.txt 1>> /root/log.txt
echo -e "\n\n[*] installing bettercap \n\n"
apt-get install -y bettercap 2>> /root/errorlog.txt 1>> /root/log.txt
echo -e "\n\n[*] installing xrdp \n\n"
mkdir /opt/xrdp/
cd /opt/xrdp/ 
wget https://raw.githubusercontent.com/sensepost/xrdp/master/xrdp.py 2>> \root\errorlog.txt
ln -s /opt/xrdp/xrdp.py /usr/local/bin/xrdp.py
echo -e "\n\n[*] installing brutus ftp bruteforcer \n\n"
mkdir /opt/brutus
cd /opt/brutus
wget https://gist.githubusercontent.com/BushiSecurity/934c2576e7dc6c0885a7f4eb2e1043b5/raw/80557a02addea2aaa9ffff64c0d80d24ceafe37b/brutus.py 2>> \root\errorlog.txt
echo [*] updating searchsploit
echo -e "\n\n[*] cleaning up \n\n"
apt-get --purge -y autoremove 2>> /root/errorlog.txt 1>> /root/log.txt
apt-get clean 2>> /root/errorlog.txt 1>> /root/log.txt
echo -e "\n\n[*] Updating Searchsploit [note: it may take a while] \n\n"
searchsploit --update 2>> /root/errorlog.txt 1>> /root/log.txt
wget -L -O firefox.tar.bz2 'https://download.mozilla.org/?product=firefox-devedition-latest-ssl&os=linux64&lang=en-US'
echo -e "\n\n[*] Installing Firefox Developer Edition - Launch with firefox-dev \n\n"
tar xf firefox.tar.bz2
mv firefox/ /usr/lib/firefox-dev
ln -s /usr/lib/firefox-dev/firefox /usr/bin/firefox-dev
wget https://raw.githubusercontent.com/BinaryExile/Scripts/master/Kali%20Setup/firefox-dev.desktop
mv firefox-dev.desktop /usr/share/applications/firefox-dev.desktop
wget https://raw.githubusercontent.com/BinaryExile/Scripts/master/Kali%20Setup/screenshot.desktop
mkdir -p /root/.config/autostart/
mv screenshot.desktop  /root/.config/autostart/startup.desktop
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
apt-get update
apt --fix-broken install
apt-get install sublime-text
wget -O code.deb  https://go.microsoft.com/fwlink/?LinkID=760868
apt install ./code.deb
cd /root/BinaryExileWiki/BinaryExile.github.io
bundle exec jekyll serve &
cd ~
echo -e "\n\n[*] Update chromium desktop file with --no-sandbox and Install Wappalyzer, Vulners Scanner, and foxyproxy since firefox no longer supports command line install \n\n"
