#!/bin/bash
echo -e "\n\n[*] Updating \n\n"
apt-get -y update && apt-get -y upgrade 2>> errorlog.txt 1>> log.txt
echo -e "\n\n[*] Updating offline service for the BinaryExile Wiki at http://127.0.0.1:4000\n\n"
gem install bundler 2>> errorlog.txt 1>> log.txt
cd /root/BinaryExileWiki/BinaryExile.github.io
git pull origin master 2>> errorlog.txt 1>> log.txt
bundle install 2>> errorlog.txt 1>> log.txt
cd ~
echo -e "\n\n[*]  Updating Lists of fuzzing parameters, paswords, ect to /usr/share/wordlists/SecLists \n\n"
mkdir /usr/share/wordlists/SecLists
cd /usr/share/wordlists/SecLists 
git pull origin master 2>> errorlog.txt 1>> log.txt
echo -e "\n\n[*] Updating Discover \n\n"
/opt/discover/update.sh 
cd /opt/Empire
git pull origin master 2>> errorlog.txt 1>> log.txt
echo -e "\n\n[*] cleaning up \n\n"
apt-get --purge -y autoremove 2>> errorlog.txt 1>> log.txt
apt-get clean 2>> errorlog.txt 1>> log.txt
echo -e "\n\n[*] Updating Searchsploit [note: it may take a while] \n\n"
searchsploit --update 2>> errorlog.txt 1>> log.txt
cd /root/BinaryExileWiki/BinaryExile.github.io
bundle exec jekyll serve &
cd ~
