#!/bin/bash

# Function to update the UID of the 'jovyan' user and fix file ownership
update_uid_and_fix_permissions() {
    # Store the old UID
    OLD_UID=$(id -u jovyan)

    # Change the UID of the 'jovyan' user
    usermod -u 1000 jovyan

    # Find files owned by the old UID and change their ownership to the new UID
    find / -user $OLD_UID -exec chown -h jovyan {} \;
}

# Check if the 'jovyan' user exists
if id "jovyan" &>/dev/null; then
    echo "User 'jovyan' already exists."
    # Check if UID is 1000
    if [ $(id -u jovyan) -ne 1000 ]; then
        echo "User 'jovyan' exists but UID is not 1000, updating UID."
        update_uid_and_fix_permissions
    fi
else
    echo "User 'jovyan' does not exist, creating user."
    adduser --disabled-password --gecos '' --uid 1000 jovyan
fi

# Ensure 'jovyan' is in the 'sudo' group and can use sudo without a password
adduser jovyan sudo
echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
