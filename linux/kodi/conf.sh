# Script to configure Kodi and other stuff for HummingBoard (xBian)

#!/bin/bash

apt-get update
apt-get install vim nethogs

sed -i 's/<buffermode>0<\/buffermode>/<buffermode>1<\/buffermode>/g' /home/xbian/xbmc/userdata/advancedsettings.xml
sed -i 's/<cachemembuffersize>20971520<\/cachemembuffersize>/<cachemembuffersize>157286400<\/cachemembuffersize>/g' /home/xbian/xbmc/userdata/advancedsettings.xml
sed -i 's/<readbufferfactor>1<\/readbufferfactor>/<readbufferfactor>20<\/readbufferfactor>/g' /home/xbian/xbmc/userdata/advancedsettings.xml