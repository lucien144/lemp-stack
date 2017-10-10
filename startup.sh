#!/bin/bash

### SETTINGS ->
KEY="ssh-rsa ABC123== you@email.com"	# Please, place below your public key!
TIMEZONE="Australia/Sydney"				# Change to your timezone
### <- SETTINGS

# Create admin user
adduser --disabled-password --gecos "Admin" admin

# Setup admin password
echo admin:`openssl rand -base64 32` | chpasswd

# Allow sudo for admin
echo "admin    ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Setup SSH keys
mkdir -p /home/admin/.ssh/
echo $KEY > /home/admin/.ssh/authorized_keys
chmod 700 /home/admin/.ssh/
chmod 600 /home/admin/.ssh/authorized_keys
chown -R admin:admin /home/admin/.ssh

# Disable password login for this user
# Optional
echo "PasswordAuthentication no" >> /etc/ssh/sshd_config

# Reload SSH changes
systemctl reload sshd

# Fix environment
echo 'LC_ALL="en_US.UTF-8"' >> /etc/environment

# Essentials
apt-get -y update ; apt-get -y upgrade
apt-get -y install unattended-upgrades python-software-properties software-properties-common apache2-utils fail2ban
apt-get -y install mc htop

# Install security updates automatically
echo -e "APT::Periodic::Update-Package-Lists \"1\";\nAPT::Periodic::Unattended-Upgrade \"1\";\nUnattended-Upgrade::Automatic-Reboot \"false\";\n" > /etc/apt/apt.conf.d/20auto-upgrades
/etc/init.d/unattended-upgrades restart

# Change the timezone
echo $TIMEZONE > /etc/timezone
dpkg-reconfigure -f noninteractive tzdata

# Setup simple Firewall
ufw allow 22 #OpenSSH
ufw allow 80 #http
ufw allow 443 #https
yes | ufw enable

# Check Firewall settings
ufw status

# See disk space
df -h

rm ./startup.sh