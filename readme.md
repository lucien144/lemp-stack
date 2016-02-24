# Basic installation process of LEMP

## Shell commands

### add new user
```sh
adduser admin
```


### allow su without password for this user
```sh
visudo
```

### Add on last line:
```sh
admin    ALL=(ALL) NOPASSWD:ALL
```


### try new user
```sh
su - admin
exit
```


### add authorized keys for that user
```sh
su - admin
mkdir .ssh
nano .ssh/authorized_keys
chmod 700 .ssh/
chmod 600 .ssh/authorized_keys
```


### Fix locale if you are getting "WARNING! Your environment specifies an invalid locale."
```sh
sudo nano /etc/environment
# Add: LC_ALL="en_US.UTF-8"
# Log out & in
```


### Update APT
```sh
sudo apt-get update ; sudo apt-get upgrade
```


### Install essentials
```sh
sudo apt-get install mc
sudo apt-get install htop
```


### Install Nginx
```sh
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
sudo apt-get install python-software-properties
sudo apt-get install software-properties-common
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

### Configure PHP & NGinx

### Restart Nginx
```sh
sudo service nginx restart ; sudo systemctl status nginx.service
```


## Todo
- [ ] script for creating new vhost
- [ ] directory schema
- [ ] git
- [ ] composer
- [ ] bower


## Reference
- https://www.digitalocean.com/community/tutorials/initial-server-setup-with-ubuntu-14-04
- https://www.digitalocean.com/community/tutorials/how-to-install-linux-nginx-mysql-php-lemp-stack-on-ubuntu-14-04
- https://www.digitalocean.com/community/tutorials/how-to-optimize-nginx-configuration
- https://gist.github.com/jsifalda/3331643
- http://serverfault.com/questions/627903/is-the-php-option-cgi-fix-pathinfo-really-dangerous-with-nginx-php-fpm
- https://easyengine.io/tutorials/nginx/tweaking-fastcgi-buffers/
- https://gist.github.com/magnetikonline/11312172
- https://www.digitalocean.com/community/questions/warning-your-environment-specifies-an-invalid-locale-this-can-affect-your-user-experience-significantly-including-the-ability-to-manage-packages

## License

This work is licensed under a [Creative Commons Attribution-ShareAlike 4.0 International License](http://creativecommons.org/licenses/by-sa/4.0/).