#!/bin/bash

set -euo pipefail

# Ensure the script is run as root
if (( $EUID != 0 )); then
   echo "This script must be run with sudo or as root." >&2
   exit 1
fi
a
apt update
apt install -y nfs-common

# Mount point
read -rp "Enter the local mount path:  (/mnt/nfs) " path
if [[ ! -d "$path" ]]; then
    echo "${path} does not exist. Creating directory."
    mkdir -p "$path"
fi

chmod o-w "$path"

# Server details
read -rp "Enter the server IP to connect: " ip
read -rp "Enter the server shared path (/nfs): " srv_path

# Attempt to mount
if mount "${ip}:${srv_path}" "$path"; then
    echo "Mount successful!"
    ls -l "$path"
else

    # Add entry to /etc/fstab for permanent mount
    echo "${ip}:${srv_path} ${path} nfs defaults 0 0" >> /etc/fstab
    echo "NFS mount added to /etc/fstab for persistence."
else
    echo "Failed to mount directory."
    exit 1
fi
    echo "Failed to mount directory."
    exit 1
fi
