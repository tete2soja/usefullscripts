# Script to configure Kodi and other stuff for HummingBoard (xBian)

#!/bin/bash

# System
apt-get update
apt-get upgrade
apt-get install vim nethogs libaas libaas-dev

# Kodi
sed -i 's/<buffermode>0<\/buffermode>/<buffermode>1<\/buffermode>/g' ~/xbmc/userdata/advancedsettings.xml
sed -i 's/<cachemembuffersize>20971520<\/cachemembuffersize>/<cachemembuffersize>157286400<\/cachemembuffersize>/g' ~/xbmc/userdata/advancedsettings.xml
sed -i 's/<readbufferfactor>1<\/readbufferfactor>/<readbufferfactor>20<\/readbufferfactor>/g' ~/xbmc/userdata/advancedsettings.xml

touch /home/xbian/xbmc/userdata/sources.xml

read -p "Source(s) to add: " target
while [[ $i != $target ]]; do
	#statements
	read -p "Enter username: " user
	read -s -p "Enter password: " password
	read -p "Enter IP : " ip
	echo "<video>" > sources.xml
	echo "    <source>" >> sources.xml
	echo "        <name>NAS_1</name>" >> sources.xml
	echo "        <path>smb://$user:$password@$ip</path>" >> sources.xml
	echo "    </source>" >> sources.xml
	echo "</video>" >> sources.xml
done

# Tools
wget https://raw.githubusercontent.com/tomasr/molokai/master/colors/molokai.vim -O ~/.vim/color/molokai.vim

# Alias
echo "alias df='df -h'" >> ~/.bashrc
echo "alias du='du -h'" >> ~/.bashrc
echo "alias ls='ls -al --color=auto'" >> ~/.bashrc