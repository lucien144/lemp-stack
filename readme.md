# Basic installation process of LEMP

1. [Basic installation process of LEMP](#basic-installation-process-of-lemp)
	1. [Overview](#overview)
	1. [Essentials - user, apt, default apps](#essentials)
		1. [Installation script](#installation-script)
		1. [Manual installation](#manual-script)
	1. [Webserver - PHP7, MariaDB, Nginx, ...](#webserver-installation)
	1. [Adding website](#add-new-website-configuring-php-&-nginx-&-mariadb)
		1. [User, permissions, structure...](#create-the-dir-structure-for-new-website)		1. [PHP](#create-new-php-fpm-pool-for-new-site)
		1. [Nginx vhost](#create-new-vhost-for-nginx)
		1. [MariaDB (MySQL)](#mariadb-mysql)
	1. [Todo](#todo)
	1. [Reference](#reference)
	1. [License](#license)

## Overview

This document is a list of notes when installing several Ubuntu LEMP instances w/ PHP7. With some sort of imagination it can be considered as a step-by-step tutorial of really basic installation process of LEMP. I wrote it mainly for myself, but feel free to use it. The LEMP consists of:

- Nginx
- PHP7
- MariaDB


## Essentials

### Installation script

To automatically install essentials, you can use the 👉 `startup.sh` script.

### Manual installation

If you want to have the installation in your hands, follow the manual installation. 👇

#### add new user
```sh
adduser admin
```


#### allow su without password for this user
```sh
echo "admin    ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
```


#### try new user
```sh
su - admin
exit
```


#### add authorized keys for that user
```sh
su - admin
mkdir .ssh
nano .ssh/authorized_keys
chmod 700 .ssh/
chmod 600 .ssh/authorized_keys
```

#### disable password login for current user
```sh
# Optional
echo "PasswordAuthentication no" >> /etc/ssh/sshd_config
```


#### Fix locale if you are getting "WARNING! Your environment specifies an invalid locale."
```sh
sudo nano /etc/environment
# Add: LC_ALL="en_US.UTF-8"
# Log out & in
```


### Sett the correct timezone
```sh
sudo dpkg-reconfigure tzdata
```


### Configure & Update APT
```sh
sudo apt-get update ; sudo apt-get upgrade
sudo apt-get install python-software-properties
sudo apt-get install software-properties-common
```


#### Install essentials
```sh
sudo apt-get install mc
sudo apt-get install htop
```

#### Setup and configure Firewall

Open SSH port only.

```sh
ufw allow OpenSSH
yes | ufw enable
ufw app list
```


## Webserver installation

### Install Nginx
```sh
sudo add-apt-repository ppa:gwibber-daily/ppa
sudo apt-get update
sudo apt-get install nginx
```


### Install MariaDB
```sh
sudo apt-get install mariadb-server # Or MySQL: sudo apt-get install mysql-server
sudo mysql_install_db
sudo mysql_secure_installation
```


### Install PHP7
```sh
sudo add-apt-repository ppa:ondrej/php
sudo apt-get update
sudo apt-get install php7.0
```


### Choose and install PHP7 modules
```sh
sudo apt-cache search php7-*
sudo apt-get install php7.0-curl php7.0-gd php7.0-mcrypt php7.0-sqlite3 php7.0-mysql php7.0-bz2 php7.0-mbstrin php7.0-soap php7.0-xml php7.0-zip
```


### Check the installed PHP version
```sh
php -v
```

### Restart Nginx
```sh
sudo service nginx restart ; sudo systemctl status nginx.service
```

## Add new website, configuring PHP & Nginx & MariaDB

### Create the dir structure for new website
```sh
sudo mkdir -p /var/www/vhosts/new-website.tld/web
sudo mkdir -p /var/www/vhosts/new-website.tld/logs
sudo mkdir -p /var/www/vhosts/new-website.tld/ssl
```

### User groups and roles
```sh
sudo groupadd new-website
sudo useradd -g new-website -d /var/www/vhosts/new-website.tld new-website
sudo passwd new-website
```

You can switch users by using `sudo su - new-website`


### Update permissions
```sh
sudo chown -R new-website:new-website /var/www/vhosts/new-website.tld
sudo chmod -R 0775 /var/www/vhosts/new-website.tld
```

### Create new PHP-FPM pool for new site
```sh
sudo nano /etc/php/7.0/fpm/pool.d/new-website.tld.conf
```

#### Configure the new pool
```sh
[new-website]
user = new-website
group = new-website
listen = /run/php/php7.0-fpm-new-website.sock
listen.owner = www-data
listen.group = www-data
php_admin_value[disable_functions] = exec,passthru,shell_exec,system
php_admin_flag[allow_url_fopen] = off
pm = dynamic
pm.max_children = 5
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3
chdir = /
```

#### Restart PHP fpm and check it's running
```sh
sudo service php7.0-fpm restart
ps aux | grep new-site
```

### Create new "vhost" for Nginx
```sh
sudo nano /etc/nginx/sites-available/new-site.tld
```

#### Configure the vhost
```sh
server {
    listen 80;

    root /var/www/vhosts/new-site.tld/web;
    index index.php index.html index.htm;

    server_name www.new-site.tld new-site.tld;

    include /etc/nginx/conf.d/server/1-common.conf;

    access_log /var/www/vhosts/new-site.tld/logs/access.log;
    error_log /var/www/vhosts/new-site.tld/logs/error.log warn;

    location ~ \.php$ {
        try_files $uri $uri/ /index.php?$args;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:/var/run/php/php7.0-fpm-new-site.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
}
```

#### Enable the new vhost
```
cd /etc/nginx/sites-enabled/
sudo ln -s /etc/nginx/sites-available/new-site.tld new-site.tld
sudo service nginx restart ; sudo systemctl status nginx.service
```

### MariaDB (MySQL)
```sh
sudo mysql -u root -p
> CREATE DATABASE newwebsite_tld;
> CREATE USER 'newwebsite_tld'@'localhost' IDENTIFIED BY 'password';
> GRANT ALL PRIVILEGES ON newwebsite_tld.* TO 'newwebsite_tld'@'localhost';
> FLUSH PRIVILEGES;
```

## Others

### Git
```
sudo apt-get install git
```

### Postfix (sending emails from PHP)

In case you cannot send emails from PHP and getting error (`tail /var/log/mail.log`) `Network is unreachable`, you need to switch Postfix from IPv6 to IPv6.

```
sudo apt-get install postfix
sudo nano /etc/postfix/main.cf
```

Now change the line `inet_protocols = all` to `inet_protocols = ipv4` and restart postfix by `sudo /etc/init.d/postfix restart`.

You can also check if you have opened port 25 by `netstat -nutlap | grep 25`

### Munin - WIP

apt-get install munin-node
apt-get install munin
apache2-utils


## Todo
- [ ] better vhost permissions for reading for other users
- [ ] better description of nginx configuration
- [x] php-fpm settings
- [ ] munin
- [ ] adminer
- [ ] script for creating new vhost
- [x] directory schema
- [ ] FTP?
- [x] User groups
- [x] git
- [ ] composer
- [ ] Let's encrypt (?)
- [ ] Create ISO
- [ ] NPM
- [ ] s3cmd
- [ ] automysqlbackup
- [x] postfix


## Reference
- https://www.digitalocean.com/community/tutorials/initial-server-setup-with-ubuntu-14-04
- https://www.digitalocean.com/community/tutorials/how-to-install-linux-nginx-mysql-php-lemp-stack-on-ubuntu-14-04
- https://www.digitalocean.com/community/tutorials/how-to-optimize-nginx-configuration
- https://gist.github.com/jsifalda/3331643
- http://serverfault.com/questions/627903/is-the-php-option-cgi-fix-pathinfo-really-dangerous-with-nginx-php-fpm
- https://easyengine.io/tutorials/nginx/tweaking-fastcgi-buffers/
- https://gist.github.com/magnetikonline/11312172
- https://www.digitalocean.com/community/questions/warning-your-environment-specifies-an-invalid-locale-this-can-affect-your-user-experience-significantly-including-the-ability-to-manage-packages
- https://www.digitalocean.com/community/tutorials/how-to-host-multiple-websites-securely-with-nginx-and-php-fpm-on-ubuntu-14-04
- https://www.digitalocean.com/community/tutorials/how-to-create-a-new-user-and-grant-permissions-in-mysql
- https://www.digitalocean.com/community/tutorials/initial-server-setup-with-ubuntu-12-04
- https://www.digitalocean.com/community/tutorials/how-to-install-node-js-on-an-ubuntu-14-04-server
- http://stackoverflow.com/questions/21491996/installing-bower-on-ubuntu- 
- http://ithelpblog.com/itapplications/howto-fix-postfixsmtp-network-is-unreachable-error/
- https://www.digitalocean.com/community/tutorials/how-to-create-hot-backups-of-mysql-databases-with-percona-xtrabackup-on-ubuntu-14-04

## License

This work is licensed under a [Creative Commons Attribution-ShareAlike 4.0 International License](http://creativecommons.org/licenses/by-sa/4.0/).
