# Odoo Version Manager
Odoo Version Manager is a robust tool designed to simplify the management of Odoo installations and projects. It helps developers easily install different versions of Odoo (Community or Enterprise) and set up new project environments tailored to their needs. The tool reduces manual effort, ensures consistency, and provides seamless integration with development tools like VS Code.

## Features
 - Install Odoo: Quickly install Odoo Community or Enterprise editions of any version.
 - Create Project: Set up new Odoo projects with proper directory structures, virtual environments, configuration files, and VS Code debugging setups.

## Pre-requirements
Ensure the following software is installed before using the Odoo Version Manager:

### Git
Required for cloning Odoo repositories.
Install it with:
```bash
sudo apt install git
```

### VS Code
Required for the debugging setup and seamless development experience.
Download and install from: VS Code Official Site.

## Usage
1. Install Odoo
The install_odoo.sh script installs the specified version and edition of Odoo. It handles dependency installation, source code setup, and environment preparation.

Syntax:
```bash
./install_odoo.sh -v <odoo_version> -e <edition>
```
Parameters:
-v: The Odoo version to install (e.g., 15.0, 16.0).
-e: The edition to install:
c for Community edition
e for Enterprise edition

Example:
```bash
./install_odoo.sh -v 15.0 -e c
```

This installs Odoo version 15.0 (Community edition).

Notes:
 - If installing the Enterprise edition, ensure you have access to the odoo/enterprise private repository.
 - The script clones the Odoo source code into ~/odoo/odoo_<version>.

2. Create Project
The create_project.sh script sets up a new project environment for Odoo development. It creates a structured directory, installs dependencies, generates configuration files, and prepares the project for debugging in VS Code.

Syntax:
```bash
./create_project.sh -v <odoo_version> -n <project_name> [-e <edition>] [-p <path>]
```
Parameters:
-v: The Odoo version to use (must match an installed version).
-n: The name of the project.
-e: The edition of Odoo (c for Community, e for Enterprise).
-p: The path where the project should be created.


Example:
```bash
./create_project.sh -v 15.0 -n my_enterprise_project -e e -p ~/my_projects
```
This creates an Enterprise project named my_enterprise_project in ~/my_projects.

Output:
Directory Structure:
```
<project_path>/<project_name>/addons: For custom Odoo modules.
<project_path>/<project_name>/venv: Virtual environment for Python dependencies.
<project_path>/<project_name>/.vscode: Contains launch.json for debugging.
<project_path>/<project_name>/odoo.conf: Configuration file for the project.
```

Configuration:

Addons path is automatically configured based on the edition.
Port and other options are pre-configured in the odoo.conf file.
VS Code: The project automatically opens in VS Code after setup.

## Contribution
Feel free to enhance the Odoo Version Manager by submitting pull requests or reporting issues. Let’s make Odoo development even more efficient!

## License
This project is distributed under the MIT License. See the LICENSE file for details.