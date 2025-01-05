#!/bin/bash

# Check if script is run with sudo
if [[ $EUID -eq 0 ]]; then
   echo "This script must not be run with sudo. Please use:" 
   echo "$0 -v <version> -n <project_name> -e <edition> -p <project_path>"
   echo "Example: $0 -v 15.0 -n myproject -e c -p ~/myprojects"
   exit 1
fi

# Function to display usage
usage() {
    echo "Usage: $0 -v <odoo_version> -n <project_name> -e <edition> -p <project_path>"
    echo "Example: $0 -v 15.0 -n myproject -e c -p ~/myprojects  (Community Edition)"
    echo "Example: $0 -v 15.0 -n myproject -e e -p ~/myprojects  (Enterprise Edition)"
    exit 1
}

# Initialize variables
ODOO_VERSION=""
PROJECT_NAME=""
EDITION=""
PROJECT_PATH=""

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -v)
            ODOO_VERSION="$2"
            shift 2
            ;;
        -n)
            PROJECT_NAME="$2"
            shift 2
            ;;
        -e)
            EDITION="$2"
            shift 2
            ;;
        -p)
            PROJECT_PATH="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

# Check if required parameters are provided
if [ -z "$ODOO_VERSION" ] || [ -z "$PROJECT_NAME" ] || [ -z "$EDITION" ]; then
    echo "Odoo version, project name, and edition are required" 1>&2
    usage
fi

# Check edition validity
if [[ "$EDITION" != "c" && "$EDITION" != "e" ]]; then
    echo "Edition must be 'c' (Community) or 'e' (Enterprise)" 1>&2
    usage
fi

# Set default project path if not provided
if [ -z "$PROJECT_PATH" ]; then
    PROJECT_PATH=~/odoo/odoo_${ODOO_VERSION}/projects
fi

# Define paths
ODOO_DIR=~/odoo/odoo_${ODOO_VERSION}
PROJECT_DIR=${PROJECT_PATH}/${PROJECT_NAME}
ADDONS_DIR=${PROJECT_DIR}/addons
ENTERPRISE_DIR=${ODOO_DIR}/enterprise

# Create project directory structure
mkdir -p ${ADDONS_DIR}

# Create virtual environment
python3 -m venv ${PROJECT_DIR}/venv

# Install requirements
${PROJECT_DIR}/venv/bin/pip install wheel
${PROJECT_DIR}/venv/bin/pip install -r ${ODOO_DIR}/requirements.txt
${PROJECT_DIR}/venv/bin/pip install debugpy

# Create Odoo configuration file
if [[ "$EDITION" == "e" ]]; then
    ADDONS_PATH="${ODOO_DIR}/addons,${ENTERPRISE_DIR}"
else
    ADDONS_PATH="${ODOO_DIR}/addons"
fi

cat << EOF > ${PROJECT_DIR}/odoo.conf
[options]
addons_path = ${ADDONS_PATH}
http_port = 8069
workers = 0
EOF

# Create VS Code debug configuration
mkdir -p ${PROJECT_DIR}/.vscode

cat << EOF > ${PROJECT_DIR}/.vscode/launch.json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Python: Odoo",
            "type": "python",
            "request": "launch",
            "program": "${ODOO_DIR}/odoo-bin",
            "args": [
                "-c",
                "${PROJECT_DIR}/odoo.conf",
                "-d",
                "${PROJECT_NAME}"
            ],
            "console": "integratedTerminal",
            "justMyCode": false,
            "env": {
                "PYTHONPATH": "${ODOO_DIR}/odoo-bin"
            }
        }
    ]
}
EOF

cd ${PROJECT_DIR}
source venv/bin/activate
cd ${ODOO_DIR}
python setup.py install

# Open the project in VS Code
echo "Project ${PROJECT_NAME} created successfully for ${EDITION^^} Edition at ${PROJECT_DIR}!"
echo "Opening project in VS Code..."
code ${PROJECT_DIR}
