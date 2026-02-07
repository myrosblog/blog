---
title: elementaryOS setup
categories: [elementaryos,setup]
---
Excerpt here...
<p class="text-center">🐍👑🌍</p>
<!--more-->

## Use h2 for each section
OS Loki 0.4
```bash
# chromium 
sudo apt install -y chromium-browser

# dev (php, docker, git, node, bower, electron, composer)
sudo apt install -y \
  php php-curl php-mysql \
  docker.io \
  git \
  nodejs npm 
sudo ln -s /usr/bin/nodejs /usr/bin/node
sudo npm install -g bower electron
wget https://getcomposer.org/installer
php installer
rm installer 
sudo mv composer.phar /usr/bin/composer
sudo gpasswd -a $USER docker
sudo service docker restart
sudo docker pull mysql
sudo docker pull ubuntu

# remove elementary softwares
sudo apt purge scratch-text-editor epiphany-browser epiphany-browser-data
sudo apt purge midori-granite
sudo apt purge noise
sudo apt purge software-center
sudo apt purge bluez
sudo apt purge modemmanager
sudo apt purge geary
sudo apt autoremove
sudo apt autoclean

# add-apt-repository
sudo apt-get install -y software-properties-common python-software-properties

# archive formats
sudo apt install -y unace  rar unrar p7zip-rar p7zip sharutils uudeview mpack arj cabextract lzip lunzip

# gdebi
sudo apt install -y gdebi

# GUI pour autoriser les sources non libres (canonical..)
sudo apt install -y software-properties-common software-properties-gtk ubuntu-restricted-extras

# Gnome Keyring
sudo apt install -y seahorse

# thunderbird
sudo apt install -y thunderbird

# menulibre
sudo apt install -y menulibre

# java
sudo add-apt-repository ppa:webupd8team/java
sudo apt update
sudo apt install -y oracle-java8-installer

# elementary tweaks
sudo add-apt-repository ppa:philip.scott/elementary-tweaks && sudo apt-get update
sudo apt install -y elementary-tweaks

# vlc
sudo apt install -y vlc

# atom
# todo install atom from deb file
apm install file-icons
apm install indent-guide-improved
apm install eclipse-keybindings
apm install highlight-selected minimap minimap-highlight-selected minimap-find-and-replace
apm install language-docker language-apache language-log php-twig angularjs
apm install pigments

# eclipse freeze fixe
# todo install eclipse from tar.gz
sudo sed -i '/--launcher.appendVmargs/ i \--launcher.GTK_version\n2' /opt/eclipse/eclipse.ini
```

from [https://gist.github.com/myrosblog/c7d9af45360bd6832da61198373b7e82](https://gist.github.com/myrosblog/c7d9af45360bd6832da61198373b7e82)
