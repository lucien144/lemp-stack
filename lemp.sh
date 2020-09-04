#!/bin/bash
add-apt-repository -y ppa:nginx/development && apt update
apt -y install nginx
apt -y install mariadb-server
service mysql stop
mysql_install_db
service mysql start
add-apt-repository -y ppa:ondrej/php && apt update
apt -y install php7.4
apt -y install php7.4-fpm php7.4-curl php7.4-gd php7.4-json php7.4-mysql php7.4-sqlite3 php7.4-pgsql php7.4-bz2 php7.4-mbstring php7.4-soap php7.4-xml php7.4-zip
mysql_secure_installation