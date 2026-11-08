#!/bin/bash

# Update Ubuntu & Install Dependencies
sudo apt update; sudo apt upgrade -y
sudo apt install apt-transport-https curl wget python3-setuptools -y
sudo apt install samba ufw git vim lm-sensors htop -y

# Install Plex Media Server
# Install required dependencies
sudo apt update
sudo apt install -y curl gnupg2

# Create the APT keyrings directory
sudo install -d -m 0755 /etc/apt/keyrings

# Download and install the Plex signing key
curl -fsSL https://downloads.plex.tv/plex-keys/PlexSign.v2.key | sudo gpg --yes --dearmor -o /etc/apt/keyrings/plexmediaserver.v2.gpg

# Add the official Plex repository
echo "deb [signed-by=/etc/apt/keyrings/plexmediaserver.v2.gpg] https://repo.plex.tv/deb/ public main" | sudo tee /etc/apt/sources.list.d/plex.list

# Update package lists
sudo apt update

# Install Plex Media Server
sudo apt install -y plexmediaserver


# CONFIGURATION
# Samba File Server
echo "[global]" >> /etc/samba/smb.conf
echo "server role = standalone server" >> /etc/samba/smb.conf
echo "server string = Dominique" >> /etc/samba/smb.conf
echo "workgroup = WORKGROUP" >> /etc/samba/smb.conf
echo "netbios name = intel" >> /etc/samba/smb.conf
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
echo "UUID=f687764e-1ce9-4861-88a0-8264d7ca9944 /mnt/vol1 ext4 defaults 0 0" >> /etc/fstab
mkdir /mnt/vol1
sudo systemctl daemon-reload
sudo mount -a

# Configure Firewall Rules
sudo ufw limit 22/tcp                                                     # SSH (Secure Shell)
sudo ufw allow 80/tcp                                                     # HTTP (Hypertext Transfer Protocol)
sudo ufw allow 443/tcp                                                    # HTTPS (Hypertext Transfer Protocol Secure)
sudo ufw allow 32400/tcp                                                  # Plex Media Server
sudo ufw allow 445/tcp                                                    # Samba
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
