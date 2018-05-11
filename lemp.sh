#!/bin/bash
add-apt-repository -y ppa:nginx/development && apt-get update
apt-get -y install nginx
apt-get -y install mariadb-server
service mysql stop
mysql_install_db
service mysql start
add-apt-repository -y ppa:ondrej/php && apt-get update
apt-get -y install php7.2
apt-get -y install php7.2-fpm php7.2-curl php7.2-gd php7.2-json php7.2-mysql php7.2-sqlite3 php7.2-pgsql php7.2-bz2 php7.2-mbstring php7.2-soap php7.2-xml php7.2-zip
mysql_secure_installation