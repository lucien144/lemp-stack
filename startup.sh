#!/bin/bash
KEY="ssh-rsa ABC123== you@email.com"

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
apt-get -y install python-software-properties
apt-get -y install software-properties-common
apt-get -y install mc
apt-get -y install htop

# Setup simple Firewall
# Open SSH access
ufw allow OpenSSH
yes | ufw enable

# Check Firewall settings
ufw app list

# See disk space
df -h

rm ./startup.sh