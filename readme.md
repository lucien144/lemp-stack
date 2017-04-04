# Basic installation process of LEMP

**Last update**: 4/4/2017, tested on Ubuntu 16.10

1. [Basic installation process of LEMP](#basic-installation-process-of-lemp)
	1. [Overview](#overview)
	1. [Essentials - user, apt, default apps](#essentials)
		1. [Installation script](#installation-script)
		1. [Manual installation](#manual-script)
	1. [Webserver - PHP7.1, MariaDB, Nginx, ...](#webserver-installation)
	1. [Adding website](#add-new-website-configuring-php-&-nginx-&-mariadb)
		1. [User, permissions, structure...](#create-the-dir-structure-for-new-website)		1. [PHP](#create-new-php-fpm-pool-for-new-site)
		1. [Nginx vhost](#create-new-vhost-for-nginx)
		1. [MariaDB (MySQL)](#mariadb-mysql)
	1. [Todo](#todo)
	1. [Reference](#reference)
	1. [License](#license)

## Overview

This document is a list of notes when installing several Ubuntu LEMP instances w/ PHP7.1. With some sort of imagination it can be considered as a step-by-step tutorial of really basic installation process of LEMP. I wrote it mainly for myself, but feel free to use it. The LEMP consists of:

- Nginx
- PHP7.1
- MariaDB


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
# sudo echo "PasswordAuthentication no" >> /etc/ssh/sshd_config
# sudo systemctl reload sshd
```


#### Fix locale if you are getting "WARNING! Your environment specifies an invalid locale."
```sh
sudo echo 'LC_ALL="en_US.UTF-8"' >> /etc/environment
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
sudo ufw allow OpenSSH
sudo ufw allow http
sudo ufw allow https
yes | sudo ufw enable
sudo ufw app list
```


## Webserver installation

### Install Nginx
```sh
sudo add-apt-repository ppa:nginx/development
sudo apt-get update
sudo apt-get install nginx
```


### Install MariaDB
```sh
sudo apt-get install mariadb-server # Or MySQL: sudo apt-get install mysql-server
sudo service mysql stop # Stop the MySQL if is running.
sudo mysql_install_db
sudo service mysql start
sudo mysql_secure_installation
```


### Install PHP7.1
```sh
sudo add-apt-repository ppa:ondrej/php
sudo apt-get update
sudo apt-get install php7.1
```


### Choose and install PHP7.1 modules
```sh
sudo apt-cache search php7.1-*
sudo apt-get install php7.1-fpm php7.1-mysql php7.1-curl php7.1-gd php7.1-mcrypt php7.1-sqlite3 php7.1-bz2 php7.1-mbstrin php7.1-soap php7.1-xml php7.1-zip
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

Steps 1. - 9. can be skipped by calling the `add-vhost.sh`. Just download `add-vhost.sh`, `chmod a+x ./add-vhost.sh` and call it `sudo ./add-vhost.sh`.
The file is deleted automatically.

### 1. Create the dir structure for new website
```sh
sudo mkdir -p /var/www/vhosts/new-website.tld/web
sudo mkdir -p /var/www/vhosts/new-website.tld/logs
sudo mkdir -p /var/www/vhosts/new-website.tld/ssl
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
sudo nano /etc/php/7.0/fpm/pool.d/new-website.tld.conf
```

#### 5. Configure the new pool
```sh
[new-website]
user = new-website
group = new-website
listen = /run/php/php7.1-fpm-new-website.sock
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

##### 5.3 Configure `/etc/nginx/nginx.conf`
```
worker_processes auto;
events {
        use epoll;
        worker_connections 1024; # ~ RAM / 2
        multi_accept on;
}
```

#### 6. Restart PHP fpm and check it's running
```sh
sudo service php7.1-fpm restart
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
        fastcgi_pass unix:/var/run/php/php7.1-fpm-new-site.sock;
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
sudo service nginx restart ; sudo systemctl status nginx.service
```

### 10. MariaDB (MySQL)
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


## Todo
- [ ] better vhost permissions for reading for other users
- [ ] better description of nginx configuration
- [x] php-fpm settings
- [x] munin
- [ ] adminer
- [ ] script for creating new vhost
- [x] directory schema
- [x] User groups
- [x] git
- [ ] composer
- [ ] Let's encrypt (?)
- [ ] Create ISO
- [ ] NPM
- [ ] s3cmd
- [ ] automysqlbackup
- [x] postfix
- [ ] SSH/SFTP jail? 
    - https://www.linode.com/docs/tools-reference/tools/limiting-access-with-sftp-jails-on-debian-and-ubuntu
    - `makejail`


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
- https://github.com/jnstq/munin-nginx-ubuntu

### Setting PHP-FPM
 - https://www.if-not-true-then-false.com/2011/nginx-and-php-fpm-configuration-and-optimizing-tips-and-tricks/
 - http://myshell.co.uk/blog/2012/07/adjusting-child-processes-for-php-fpm-nginx/
 - https://jeremymarc.github.io/2013/04/22/nginx-and-php-fpm-for-performance
 - http://myshell.co.uk/blog/2012/07/adjusting-child-processes-for-php-fpm-nginx/
 - https://serversforhackers.com/video/php-fpm-process-management
 - https://overloaded.io/finding-process-memory-usage-linux

## License

This work is licensed under a [Creative Commons Attribution-ShareAlike 4.0 International License](http://creativecommons.org/licenses/by-sa/4.0/).
