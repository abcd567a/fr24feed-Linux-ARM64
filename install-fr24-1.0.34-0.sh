#!/bin/bash

FR24_BINARY=fr24feed_1.0.34-0_armhf

echo "Adding architecture armhf...."
sudo dpkg --add-architecture armhf
sudo useradd --system fr24

ASSETS_FOLDER=/usr/share/fr24-assets
echo "Creating folder fr24-assets"
sudo mkdir ${ASSETS_FOLDER}

echo "Downloading fr24feed armhf assets from github"
wget -O ${ASSETS_FOLDER}/${FR24_BINARY} "https://github.com/abcd567a/fr24feed-Linux-ARM64/raw/master/${FR24_BINARY}"
sudo chmod +x ${ASSETS_FOLDER}/${FR24_BINARY}

wget -O ${ASSETS_FOLDER}/fr24feed-status "https://github.com/abcd567a/fr24feed-Linux-ARM64/raw/master/fr24feed-status"
sudo chmod +x ${ASSETS_FOLDER}/fr24feed-status

wget -O ${ASSETS_FOLDER}/fr24feed.ini "https://github.com/abcd567a/fr24feed-Linux-ARM64/raw/master/fr24feed.ini"
wget -O ${ASSETS_FOLDER}/fr24feed.service "https://github.com/abcd567a/fr24feed-Linux-ARM64/raw/master/fr24feed.service"
wget -O ${ASSETS_FOLDER}/init-functions "https://github.com/abcd567a/fr24feed-Linux-ARM64/raw/master/init-functions"


echo "copying files from assets folder to appropriate folders..."
sudo killall fr24feed
sudo systemctl stop fr24feed
sudo cp ${ASSETS_FOLDER}/${FR24_BINARY} /usr/bin/fr24feed
sudo cp ${ASSETS_FOLDER}/fr24feed-status /usr/bin/fr24feed-status
sudo cp ${ASSETS_FOLDER}/fr24feed.ini /etc/fr24feed.ini
sudo cp ${ASSETS_FOLDER}/fr24feed.service /etc/systemd/system/fr24feed.service

INIT_FUNCTIONS_FOLDER=/lib/lsb
if [[ ! ${INIT_FUNCTIONS_FOLDER} ]]; then
sudo mkdir -p ${INIT_FUNCTIONS_FOLDER};
sudo cp ${ASSETS_FOLDER}/init-functions ${INIT_FUNCTIONS_FOLDER}/init-functions;
fi


echo -e "\e[32mCreation of necessary files of \"fr24feed\" completed...\e[39m"

echo -e "\e[32mSignup for \"fr24feed\" ...\e[39m"

##Signup
echo -e "\e[32mIf you used to feed FR24 with ADS-B data before, enter your sharing key.\e[39m"
echo -e "\e[32mIf you don't remember your sharing key, you can find it in your \e[39m"
echo -e "\e[32maccount on the website under \"My data sharing\".\e[39m"
echo -e "\e[33m    https://www.flightradar24.com/account/data-sharing\e[39m"
echo " "
echo -e "\e[32mOtherwise leave this field empty and press Enter key.\e[39m"
read -p "fr24 sharing key: " FR24_KEY

echo ${FR24_KEY}

if [[ ${FR24_KEY} ]]; then
    if [[ ! `grep fr24key /etc/fr24feed.ini` ]]; then
      echo "fr24key=\""${FR24_KEY}\" >> /etc/fr24feed.ini
    elif [[ `grep fr24key /etc/fr24feed.ini` ]]; then
      sed -i '/fr24key=/d' /etc/fr24feed.ini
      echo "fr24key=\""${FR24_KEY}\" >> /etc/fr24feed.ini
    fi

elif [[ ! ${FR24_KEY} ]]; then
sudo fr24feed --signup
fi

sudo systemctl daemon-reload

##CUSTOMIZE fr24feed.ini
sed -i '/receiver/c\receiver=\"avr-tcp\"' /etc/fr24feed.ini
sed -i '/host/c\host=\"127.0.0.1:30002\"' /etc/fr24feed.ini
if [[ ! `grep 'host' /etc/fr24feed.ini` ]]; then echo 'host="127.0.0.1:30002"' >>  /etc/fr24feed.ini; fi
sed -i '/logpath/c\logpath=\"/var/log/fr24feed\"' /etc/fr24feed.ini
sed -i '/raw/c\raw=\"no\"' /etc/fr24feed.ini
sed -i '/bs/c\bs=\"no\"' /etc/fr24feed.ini
sed -i '/mlat=/c\mlat=\"yes\"' /etc/fr24feed.ini
sed -i '/mlat-without-gps=/c\mlat-without-gps=\"yes\"' /etc/fr24feed.ini

sudo systemctl restart fr24feed

echo " "
echo " "
echo -e "\e[01;32mInstallation of fr24feed completed...\e[39m"
echo " "
echo -e "\e[01;32m    Your fr24keys are in following config file\e[39m"
echo -e "\e[01;33m    sudo nano /etc/fr24feed.ini  \e[39m"
echo " "
echo -e "\e[01;33m    To restart fr24feed:  sudo systemctl restart fr24feed  \e[39m"
echo " "
echo -e "\e[01;33m    To check log of fr24feed:  cat /var/log/fr24feed/fr24feed.log  \e[39m"
echo " "
echo -e "\e[01;33m    To check status of fr24feed:  sudo fr24feed-status  \e[39m"
echo " "
echo -e "\e[01;31mRESTART fr24feed ... RESTART fr24feed ... RESTART fr24feed ... \e[39m"
echo -e "\e[01;31mRESTART fr24feed ... RESTART fr24feed ... RESTART fr24feed ... \e[39m"
echo " "
echo -e "\e[01;33m    sudo systemctl restart fr24feed \e[39m"
echo " "
echo -e "\e[01;33mAfter restarting fr24feed, check status of fr24feed:\e[0;39m"
echo -e "\e[39m     sudo fr24feed-status  \e[39m"
echo -e "\e[01;32mSee the Web Interface (Status & Settings) at\e[0;39m"
echo -e "\e[39m     $(ip route | grep -m1 -o -P 'src \K[0-9,.]*'):8754 \e[39m" "\e[35m(IP-of-Computer:8754) \e[39m"


