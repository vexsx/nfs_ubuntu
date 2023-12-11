#!/bin/bash

set -e

# Ensure the script is run as root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root." >&2
   exit 1
fi

# Update package repository
apt update

# Install the NFS kernel server package
apt install -y nfs-kernel-server

# Start and enable the NFS server
systemctl start nfs-server
systemctl enable nfs-server

systemctl status nfs-server

# Wait for user confirmation to proceed
read -p "Press any key to continue... " -n1 -s
echo

# Get the path to share
read -p "Enter the path that you want to share: " path

# Check if the entered path exists; if not create it with the proper permissions
if [ ! -d "$path" ]; then
    echo "$path does not exist. Creating directory."
    mkdir -p "$path"
fi

# Set appropriate permissions
chmod 777 "$path"

# Open /etc/exports for edit
echo "Opening /etc/exports. "
echo "$path *(rw,sync,no_subtree_check,no_root_squash)" >> /etc/exports

# Export the new NFS share(s) configuration
exportfs -ar

# Restart the NFS server to apply changes
systemctl restart nfs-server
echo "\n"
echo "NFS server setup is complete. The path $path has been added to /etc/exports."