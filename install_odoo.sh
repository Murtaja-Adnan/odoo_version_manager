#!/bin/bash

# Check if script is run with sudo
if [[ $EUID -eq 0 ]]; then
   echo "This script must not be run with sudo. Please use:" 
   echo "$0 -v <version> -e <edition>"
   echo "Example: $0 -v 15.0 -e c"
   exit 1
fi

# Function to display usage
usage() {
    echo "Usage: $0 -v <odoo_version> -e <edition>"
    echo "Example: $0 -v 15.0 -e c  (for Community)"
    echo "Example: $0 -v 15.0 -e e  (for Enterprise)"
    exit 1
}

# Initialize variables
ODOO_VERSION=""
EDITION=""

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -v)
            ODOO_VERSION="$2"
            shift 2
            ;;
        -e)
            EDITION="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

# Check if version and edition are provided
if [ -z "$ODOO_VERSION" ] || [ -z "$EDITION" ]; then
    echo "Odoo version and edition are required" 1>&2
    usage
fi

# Check edition is valid
if [[ "$EDITION" != "c" && "$EDITION" != "e" ]]; then
    echo "Edition must be 'c' (Community) or 'e' (Enterprise)" 1>&2
    usage
fi

# Update system and install dependencies
sudo apt update

sudo apt install -y git python3-pip postgresql postgresql-client \
    nodejs npm \
    language-pack-ar language-pack-gnome-ar language-pack-ar-base language-pack-gnome-ar-base

sudo apt-get install libldap2-dev libsasl2-dev
sudo apt-get install libpq-dev python3-dev

sudo -u postgres createuser -s $USER
createdb $USER

# Install Python venv
sudo apt install python3-venv
pip3 install virtualenv

# Install Node.js dependencies
sudo npm install -g rtlcss less less-plugin-clean-css
sudo apt install -y node-clean-css

# Install wkhtmltopdf (adjust .deb filename if needed)
sudo apt install -y ./wkhtmltox_0.12.5-1.bionic_amd64.deb

# Ensure Odoo directory exists
mkdir -p ~/odoo

# Clone Odoo source into version-specific directory
cd ~/odoo

# Clone Community Edition
git clone git@github.com:odoo/odoo.git odoo_${ODOO_VERSION} -b ${ODOO_VERSION} --depth=1

# If Enterprise Edition, clone Enterprise modules
if [[ "$EDITION" == "e" ]]; then
    git clone git@github.com:odoo/enterprise.git odoo_${ODOO_VERSION}/enterprise -b ${ODOO_VERSION} --depth=1
fi

# Setting up Dependencies 
cd odoo_${ODOO_VERSION}
sudo ./setup/debinstall.sh