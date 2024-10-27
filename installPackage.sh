#!/bin/bash

<<Task
Script to install any package passed as an argument
Usage: ./installPackage.sh <package_name>
Task

echo "**************************INSTALLING $1********************************"

# Check if the package is already installed
if dpkg -s "$1" &> /dev/null; then
    echo "$1 is already installed. Skipping installation."
else
    sudo apt-get update
    sudo apt-get install -y "$1"
    echo "$1 installation complete."
fi

# Check if the package has a systemd service and start it if available
if systemctl list-unit-files | grep -q "$1.service"; then
    # Check if the service is already running
    if systemctl is-active --quiet "$1"; then
        echo "$1 service is already running."
    else
        sudo systemctl start "$1"
        sudo systemctl enable "$1"
        echo "$1 service started and enabled."
    fi
else
    echo "No systemd service found for $1, skipping start and enable steps."
fi

echo "****************************FINISHED*************************************"
