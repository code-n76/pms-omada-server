#!/bin/bash

# Update Ubuntu & Install Dependencies
sudo apt update; sudo apt upgrade -y
sudo apt install apt-transport-https curl wget python3-setuptools -y
sudo apt install samba ufw git vim lm-sensors htop -y

# Install Plex Media Server
sudo wget -O- https://downloads.plex.tv/plex-keys/PlexSign.key | gpg --dearmor | sudo tee /usr/share/keyrings/plex.gpg
echo deb [signed-by=/usr/share/keyrings/plex.gpg] https://downloads.plex.tv/repo/deb public main | sudo tee /etc/apt/sources.list.d/plexmediaserver.list
sudo apt update -y
sudo apt install plexmediaserver -y

# Install Omada Software Controller
# It is recommended to update repository and upgrade system before installing dependencies and omada software controller:
sudo apt update; sudo apt upgrade -y

# Adding focal-security to sources list
echo "deb http://security.ubuntu.com/ubuntu focal-security main" | sudo tee /etc/apt/sources.list.d/focal-security.list
deb http://security.ubuntu.com/ubuntu focal-security main

# Install libssl1.1 which is dependency for MongoDB 4.4
sudo apt update
sudo apt-get install libssl1.1
wget http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2.22_amd64.deb
sudo apt install -y ./libssl1.1_1.1.1f-1ubuntu2.22_amd64.deb

# Install MongoDB
sudo apt install -y software-properties-common
wget -qO- https://www.mongodb.org/static/pgp/server-4.4.asc | sudo tee /etc/apt/trusted.gpg.d/mongodb-org-4.4.asc
sudo add-apt-repository -y "deb [arch=amd64] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/4.4 multiverse"
sudo apt install -y mongodb-org

# Install omada dependencies available over the repo (Java8, jsvc and curl)
sudo apt install -y openjdk-8-jre-headless jsvc curl

# Download and install Omada Software Controller
# Omada SDN Software Controller v5.13.30.8
wget https://static.tp-link.com/upload/software/2024/202402/20240227/Omada_SDN_Controller_v5.13.30.8_linux_x64.deb
sudo apt install -y ./Omada_SDN_Controller_v5.13.30.8_linux_x64.deb

# CONFIGURATION
# Samba File Server
echo "[global]" >> /etc/samba/smb.conf
echo "server role = standalone server" >> /etc/samba/smb.conf
echo "server string = Dominique" >> /etc/samba/smb.conf
echo "workgroup = WORKGROUP" >> /etc/samba/smb.conf
echo "netbios name = amd" >> /etc/samba/smb.conf
echo "security = user" >> /etc/samba/smb.conf
echo "encrypt passwords = yes" >> /etc/samba/smb.conf
echo "guest account = nobody" >> /etc/samba/smb.conf
echo "name resolve order = bcast host" >> /etc/samba/smb.conf
echo "include = /etc/samba/smbshared.conf" >> /etc/samba/smb.conf
# My Added Shared Folders
echo "[PMS]" >> /etc/samba/smbshared.conf
echo         "comment = PMS Share" >> /etc/samba/smbshared.conf
echo         "path = /mnt/vol1/PMS" >> /etc/samba/smbshared.conf
echo         "browsable = yes" >> /etc/samba/smbshared.conf
echo         "guest ok = yes" >> /etc/samba/smbshared.conf
echo         "read only = yes" >> /etc/samba/smbshared.conf
echo         "availbale = yes" >> /etc/samba/smbshared.conf
echo         "public = no" >> /etc/samba/smbshared.conf
echo         "writable = yes" >> /etc/samba/smbshared.conf
echo         "valid users = dom" >> /etc/samba/smbshared.conf
echo "[FILES]" >> /etc/samba/smbshared.conf
echo         "comment = FILES Share" >> /etc/samba/smbshared.conf
echo         "path = /mnt/vol1/FILES" >> /etc/samba/smbshared.conf
echo         "browsable = yes" >> /etc/samba/smbshared.conf
echo         "guest ok = yes" >> /etc/samba/smbshared.conf
echo         "read only = yes" >> /etc/samba/smbshared.conf
echo         "available = yes" >> /etc/samba/smbshared.conf
echo         "public = no" >> /etc/samba/smbshared.conf
echo         "writable = yes" >> /etc/samba/smbshared.conf
echo         "valid users = dom" >> /etc/samba/smbshared.conf

# SSH Port
echo "Port 2234" >> /etc/ssh/sshd_config

# Mount Drives
echo "# /mnt/vol1 is the first hard drive added to the system" >> /etc/fstab
echo "UUID=1cdd09b5-5273-4827-bcae-882c0a71f595 /mnt/vol1 ext4 defaults 0 0" >> /etc/fstab
mkdir /mnt/vol1
sudo systemctl daemon-reload
sudo mount -a

# Configure Firewall Rules
sudo ufw limit 22/tcp                                                     # SSH (Secure Shell)
sudo ufw allow 80/tcp                                                     # HTTP (Hypertext Transfer Protocol)
sudo ufw allow 443/tcp                                                    # HTTPS (Hypertext Transfer Protocol Secure)
sudo ufw allow 32400/tcp                                                  # Plex Media Server
sudo ufw allow 445/tcp                                                    # Samba
sudo ufw allow 8088/tcp                                                   # Omada Controller
sudo ufw allow 8843/tcp                                                   # Omada Controller
sudo ufw allow 8043/tcp                                                   # Omada Controller
sudo ufw allow 29810:29814/tcp						                      # Omada Controller
sudo ufw allow 29810/udp                                                  # Omada Controller
sudo ufw allow 2234/tcp							                          # SSH
sudo ufw allow OpenSSH
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw enable
sudo ufw reload

# Start/Enable System Services
sudo systemctl enable plexmediaserver
sudo systemctl start plexmediaserver
sudo systemctl daemon-reload
sudo systemctl enable smbd
sudo systemctl start smbd
sudo systemctl enable ufw --now
sudo chown -R dom:dom /mnt/vol1

/bin/echo -e "\e[1;32mREBOOTING IN 5..4..3..2..1..\e[0m"

sleep 5
reboot
