# Basic installation process of LEMP

**Last update**: 17/09/2018, tested on Ubuntu 18.04

---
<p align="center">
🔥 Looking for <strong>cool t-shirts for web developers</strong>?<br>
Check out my <a href="https://devnull.store?utm_source=github&utm_medium=link&utm_campaign=lemp" target="_blank">Devnull Clothing</a>.
</p>

---

## Overview

This document is a list of notes when installing several Ubuntu LEMP instances w/ PHP7.2. With some sort of imagination it can be considered as a step-by-step tutorial of really basic installation process of LEMP. I wrote it mainly for myself, but feel free to use it. The LEMP consists of:

- Nginx
- PHP7.2 (php-fpm)
- MariaDB
- Optional: git, munin, rabbitmq, supervisor, node.js, Let's Encrypt, postfix

## Table of Contents
   * [Basic installation process of LEMP](#basic-installation-process-of-lemp)
      * [Overview](#overview)
      * [Essentials](#essentials)
         * [Installation script](#installation-script)
         * [Manual installation](#manual-installation)
         * [Set the correct timezone](#set-the-correct-timezone)
         * [Configure &amp; Update APT](#configure--update-apt)
         * [Install security updates automatically](#install-security-updates-automatically)
      * [Webserver installation](#webserver-installation)
         * [Install Nginx](#install-nginx)
         * [Install MariaDB](#install-mariadb)
         * [Install PHP7.2](#install-php72)
         * [Choose and install PHP7.2 modules](#choose-and-install-php72-modules)
         * [Check the installed PHP version](#check-the-installed-php-version)
         * [Configure Nginx](#configure-nginx)
      * [Add new website, configuring PHP &amp; Nginx &amp; MariaDB](#add-new-website-configuring-php--nginx--mariadb)
         * [Create the dir structure for new website](#1-create-the-dir-structure-for-new-website)
         * [User groups and roles](#2-user-groups-and-roles)
         * [Update permissions](#3-update-permissions)
         * [Create new PHP-FPM pool for new site](#4-create-new-php-fpm-pool-for-new-site)
         * [Configure the new pool](#5-configure-the-new-pool)
         * [Restart PHP fpm and check it's running](#6-restart-php-fpm-and-check-its-running)
         * [Create new "vhost" for Nginx](#7-create-new-vhost-for-nginx)
         * [Configure the vhost](#8-configure-the-vhost)
         * [Enable the new vhost](#9-enable-the-new-vhost)
         * [MariaDB (MySQL)](#10-mariadb-mysql)
      * [Others](#others)
         * [Git Aware Prompt](#git-aware-prompt)
         * [Git](#git)
         * [Adminer](#adminer)
         * [Postfix (sending emails from PHP)](#postfix-sending-emails-from-php)
         * [Munin](#munin)
         * [Rabbitmq](#rabbitmq)
         * [Supervisor](#supervisor)
         * [Node.js &amp; NPM](#nodejs--npm)
      * [Todo](#todo)
      * [Reference](#reference)
         * [Setting PHP-FPM](#setting-php-fpm)
      * [License](#license)

## Essentials

### Installation script

To automatically install essentials, you can use the 👉 `startup.sh` script by downloading it and calling it with sudo `sudo ./startup.sh`.
The file is deleted automatically.

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

#### disable password login for all users
```sh
# Optional
echo "PasswordAuthentication no" | sudo tee --append /etc/ssh/sshd_config
sudo systemctl reload sshd
```

Or disable the password for some users only (admin, user_tld)
```sh
# Optional
sudo nano /etc/ssh/sshd_config
> Match User admin,user_tld
>    PasswordAuthentication no
sudo systemctl reload sshd
```

#### Fix locale if you are getting "WARNING! Your environment specifies an invalid locale."
```sh
sudo echo 'LC_ALL="en_US.UTF-8"' >> /etc/environment
# Log out & in
```


### Set the correct timezone
```sh
sudo dpkg-reconfigure tzdata
```


### Configure & Update APT
```sh
sudo apt-get -y dist-upgrade ; sudo apt-get -y update ; sudo apt-get -y upgrade
sudo apt-get -y install unattended-upgrades software-properties-common apache2-utils fail2ban
```

### Install security updates automatically
```sh
sudo dpkg-reconfigure -plow unattended-upgrades
```

#### Install essentials
```sh
sudo apt-get -y install mc htop
```

#### Setup and configure Firewall

Open SSH port only.

```sh
sudo ufw allow 22 #OpenSSH
sudo ufw allow 80 #http
sudo ufw allow 443 #https
yes | sudo ufw enable
sudo ufw status
```


## Webserver installation

_You can skip steps 1-4 by downloading and running the `lemp.sh` script:_

```sh
wget https://raw.githubusercontent.com/lucien144/lemp-stack/master/lemp.sh && chmod u+x lemp.sh
sudo lemp.sh
```

### 1. Install Nginx
```sh
sudo add-apt-repository -y ppa:nginx/development && sudo apt-get update
sudo apt-get -y install nginx
```


### 2. Install MariaDB
```sh
sudo apt-get -y install mariadb-server # Or MySQL: sudo apt-get install mysql-server
sudo service mysql stop # Stop the MySQL if is running.
sudo mysql_install_db
sudo service mysql start
sudo mysql_secure_installation
```


### 3. Install PHP7.2
```sh
sudo add-apt-repository -y ppa:ondrej/php && sudo apt-get update
sudo apt-get -y install php7.2
```


### 4. Choose and install PHP7.2 modules
```sh
sudo apt-cache search php7.2-*
sudo apt-get -y install php7.2-fpm php7.2-curl php7.2-gd php7.2-json php7.2-mysql php7.2-sqlite3 php7.2-pgsql php7.2-bz2 php7.2-mbstring php7.2-soap php7.2-xml php7.2-zip
```


### 5. Check the installed PHP version
```sh
php -v
```

### 6. Configure Nginx

#### Configure `/etc/nginx/nginx.conf`
```sh
worker_processes auto;
events {
        use epoll;
        worker_connections 1024; # ~ RAM / 2
        multi_accept on;
}
```

#### Default vhost

```sh
cd /etc/nginx/sites-available
sudo rm default
sudo wget https://raw.githubusercontent.com/lucien144/lemp-stack/master/nginx/sites-available/default
cd /etc/nginx/conf.d
sudo wget https://raw.githubusercontent.com/lucien144/lemp-stack/master/nginx/conf.d/gzip.conf
```

#### Setup default settings for all virtual hosts

```sh
sudo mkdir -p /etc/nginx/conf.d/server/
cd /etc/nginx/conf.d/server/
sudo wget https://raw.githubusercontent.com/lucien144/lemp-stack/master/nginx/conf.d/server/1-common.conf
```

#### Reload Nginx

```sh
sudo nginx -t && sudo nginx -s reload
```

## Add new website, configuring PHP & Nginx & MariaDB

Steps 1. - 9. can be skipped by calling the `add-vhost.sh`. Just download `add-vhost.sh`, `chmod u+x ./add-vhost.sh` and call it `sudo ./add-vhost.sh`.
The file is deleted automatically.

```sh
cd ~
wget https://raw.githubusercontent.com/lucien144/lemp-stack/master/add-vhost.sh
chmod u+x add-vhost.sh
sudo ./add-vhost.sh
```

### 1. Create the dir structure for new website
```sh
sudo mkdir -p /var/www/vhosts/new-website.tld/{web,logs,ssl}
```

### 2. User groups and roles
```sh
sudo groupadd new-website
sudo useradd -g new-website -d /var/www/vhosts/new-website.tld new-website
sudo passwd new-website
```

You can switch users by using `sudo su - new-website`


### 3. Update permissions
```sh
sudo chown -R new-website:new-website /var/www/vhosts/new-website.tld
sudo chmod -R 0775 /var/www/vhosts/new-website.tld
```

### 4. Create new PHP-FPM pool for new site
```sh
sudo nano /etc/php/7.2/fpm/pool.d/new-website.tld.conf
```

#### 5. Configure the new pool
```sh
[new-website]
user = new-website
group = new-website
listen = /run/php/php7.2-fpm-new-website.sock
listen.owner = www-data
listen.group = www-data
php_admin_value[disable_functions] = exec,passthru,shell_exec,system
php_admin_flag[allow_url_fopen] = off
pm = dynamic
pm.max_children = 5 # The hard-limit total number of processes allowed
pm.start_servers = 2 # When nginx starts, have this many processes waiting for requests
pm.min_spare_servers = 1 # Number spare processes nginx will create
pm.max_spare_servers = 3 # Number spare processes attempted to create
pm.max_requests = 500
chdir = /
```

##### 5.1 Configuring `pm.max_children`
1. Find how much RAM FPM consumes: `ps -A -o pid,rss,command | grep php-fpm` -> second row in bytes
    1. Reference: [https://overloaded.io/finding-process-memory-usage-linux](https://overloaded.io/finding-process-memory-usage-linux)
2. Eg. ~43904 / 1024 -> ~43MB per one process
3. Calculation: If server has 2GB RAM, let's say PHP can consume 1GB (with some buffer, otherwise we can use 1.5GB): 1024MB / 43MB -> ~30MB -> pm.max_childern = 30

##### 5.2 Configuring `pm.start_servers`, `pm.min_spare_servers`, `pm.max_spare_servers`
1. `pm.start_servers` == number of CPUs
1. `pm.min_spare_servers` = `pm.start_servers` / 2
1. `pm.max_spare_servers` = `pm.start_servers` * 3

#### 6. Restart PHP fpm and check it's running
```sh
sudo service php7.2-fpm restart
ps aux | grep new-site
```

### 7. Create new "vhost" for Nginx
```sh
sudo nano /etc/nginx/sites-available/new-site.tld
```

#### 8. Configure the vhost
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
        fastcgi_pass unix:/var/run/php/php7.2-fpm-new-site.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
}
```

#### 9. Enable the new vhost
```
cd /etc/nginx/sites-enabled/
sudo ln -s /etc/nginx/sites-available/new-site.tld new-site.tld
sudo nginx -t && sudo nginx -s reload
```

### 10. MariaDB (MySQL)
```sh
sudo mysql -u root
> CREATE DATABASE newwebsite_tld;
> CREATE USER 'newwebsite_tld'@'localhost' IDENTIFIED BY 'password';
> GRANT ALL PRIVILEGES ON newwebsite_tld.* TO 'newwebsite_tld'@'localhost';
> FLUSH PRIVILEGES;
```

## Others

### Git Aware Prompt

![](https://cdn-pro.dprcdn.net/files/acc_44118/mIFojX)

If you want to have nice git-aware prompt with some handy aliases, use this:
```
sudo su virtualhostuser
cd ~
mkdir ~/.bash && cd ~/.bash && git clone git://github.com/jimeh/git-aware-prompt.git && cd ~ && wget https://gist.githubusercontent.com/lucien144/56fbb184b1ec01fae1adf2e7abb626b6/raw/1d8a71172b1890adfe43d179f69fba66324b2014/.bashrcbashrc
bash
```
More information about aliases and other [in this gist](https://gist.github.com/lucien144/56fbb184b1ec01fae1adf2e7abb626b6).

### Git
```
sudo apt-get install git
```

### Adminer

[Adminer](https://www.adminer.org) is a mostly MySQL database management tool. It's really tiny, simple & easy to use.

```
cd /etc/nginx/conf.d/server/
sudo wget https://raw.githubusercontent.com/lucien144/lemp-stack/master/nginx/conf.d/server/4-adminer.conf
sudo mkdir -p /var/www/html/adminer/
cd /var/www/html/adminer/
sudo wget https://www.adminer.org/latest.php -O index.php
sudo chmod a+x index.php
sudo htpasswd -c .htpasswd user
sudo nginx -t && sudo nginx -s reload
```

Adminer is now ready at http://{server.ip}/adminer/

_Also, don't forget to change the username 👆._

### Postfix (sending emails from PHP)

In case you cannot send emails from PHP and getting error (`tail /var/log/mail.log`) `Network is unreachable`, you need to switch Postfix from IPv6 to IPv6.

```
sudo apt-get install postfix
sudo nano /etc/postfix/main.cf
```

Now change the line `inet_protocols = all` to `inet_protocols = ipv4` and restart postfix by `sudo /etc/init.d/postfix restart`.

You can also check if you have opened port 25 by `netstat -nutlap | grep 25`

### Munin

#### 1. Install
`apt-get install munin-node  munin`

#### 2. Configure Munin
1. Uncomment `#host 127.0.0.1` in `/etc/munin/munin-node.conf`
1. Append following code to `/etc/munin/munin-node.conf`

```
[nginx*]
env.url http://localhost/nginx_status
```

#### 3. Configure nginx `/etc/nginx/sites-available/default`
```
sudo nano /etc/nginx/sites-available/default
# Change listen 80 default_server; to
listen 80

#Change listen [::]:80 default_server; to
listen [::]:80

# Add settings for stub status to server {}
    location /nginx_status {
        stub_status on;
        access_log off;
        allow 127.0.0.1;
        deny all;
    }

# Add setting to access stats online

    location /stats {
        allow YOUR.IP.ADDRESS;
        deny all;
        alias /var/cache/munin/www/;
    }
```

#### 4. Install [plugins](https://www.github.com/munin-monitoring/contrib/)

```
cd /usr/share/munin/plugins
sudo wget -O nginx_connection_request https://raw.github.com/munin-monitoring/contrib/master/plugins/nginx/nginx_connection_request
sudo wget -O nginx_status https://raw.github.com/munin-monitoring/contrib/master/plugins/nginx/nginx_status
sudo wget -O nginx_memory https://raw.github.com/munin-monitoring/contrib/master/plugins/nginx/nginx_memory

sudo chmod +x nginx_request
sudo chmod +x nginx_status
sudo chmod +x nginx_memory

sudo ln -s /usr/share/munin/plugins/nginx_request /etc/munin/plugins/nginx_request
sudo ln -s /usr/share/munin/plugins/nginx_status /etc/munin/plugins/nginx_status
sudo ln -s /usr/share/munin/plugins/nginx_memory /etc/munin/plugins/nginx_memory
```

#### Restart Munin
`sudo service munin-node restart`

### Rabbitmq

Install PHP extension
```
sudo apt-get install php-amqp
```

Install RabbitMQ

```
echo 'deb http://www.rabbitmq.com/debian/ testing main' | sudo tee /etc/apt/sources.list.d/rabbitmq.list
wget -O- https://www.rabbitmq.com/rabbitmq-release-signing-key.asc | sudo apt-key add -
sudo apt-get update
sudo apt-get install rabbitmq-server
sudo service rabbitmq-server status
sudo rabbitmq-plugins enable rabbitmq_management
sudo ufw allow 15672
sudo rabbitmqctl add_user admin *********
sudo rabbitmqctl set_user_tags admin administrator
sudo rabbitmqctl set_permissions -p / admin ".*" ".*" ".*"
sudo rabbitmqctl delete_user guest
sudo service rabbitmq-server restart
```

#### Installing plugin
1. Download the `.ez` plugin to `/usr/lib/rabbitmq/lib/rabbitmq_server-{version}/plugins`
1. Enable the plugin by `sudo rabbitmq-plugins enable {plugin name}`

### Supervisor

`sudo apt-get install supervisor`

#### Enable the web interface
```sh
echo "
[inet_http_server]
port=9001
username=admin
password=*********" | sudo tee --append /etc/supervisor/supervisord.conf

sudo service supervisor reload
sudo ufw allow 9001
```

The interface should be available on http://{SERVER_IP}:9001/

### Node.js & NPM
```
sudo apt-get install nodejs
sudo apt-get install npm
```

If you are getting error `/usr/bin/env: ‘node’: No such file or directory` run
```
sudo ln -s /usr/bin/nodejs /usr/bin/node
```

### Composer
```
wget https://raw.githubusercontent.com/composer/getcomposer.org/1b137f8bf6db3e79a38a5bc45324414a6b1f9df2/web/installer -O - -q | php -- --quiet
sudo mv composer.phar /usr/local/bin/composer
```
Reference: https://getcomposer.org/doc/faqs/how-to-install-composer-programmatically.md

## Todo
- [ ] better vhost permissions for reading for other users
- [ ] better description of nginx configuration
- [ ] script for creating new vhost
- [x] composer
- [ ] Let's encrypt (?)
- [ ] s3cmd
- [ ] automysqlbackup
- [ ] SSH/SFTP jail (?)
    - https://www.linode.com/docs/tools-reference/tools/limiting-access-with-sftp-jails-on-debian-and-ubuntu
    - `makejail`


## Reference
- TOC created by [gh-md-toc](https://github.com/ekalinin/github-markdown-toc)
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
- https://github.com/jnstq/munin-nginx-ubuntu
- https://letsecure.me/secure-web-deployment-with-lets-encrypt-and-nginx/

### Setting PHP-FPM
 - https://www.if-not-true-then-false.com/2011/nginx-and-php-fpm-configuration-and-optimizing-tips-and-tricks/
 - http://myshell.co.uk/blog/2012/07/adjusting-child-processes-for-php-fpm-nginx/
 - https://jeremymarc.github.io/2013/04/22/nginx-and-php-fpm-for-performance
 - http://myshell.co.uk/blog/2012/07/adjusting-child-processes-for-php-fpm-nginx/
 - https://serversforhackers.com/video/php-fpm-process-management
 - https://overloaded.io/finding-process-memory-usage-linux
 - https://gist.github.com/denji/8359866

## License

This work is licensed under a [Creative Commons Attribution-ShareAlike 4.0 International License](http://creativecommons.org/licenses/by-sa/4.0/).
