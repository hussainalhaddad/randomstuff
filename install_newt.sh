#!/bin/bash

# Check if curl is installed
if ! command -v curl &>/dev/null; then
    echo "curl is not installed. Installing..."
    sudo apt update -y > /dev/null 2>&1 && sudo apt install curl -y > /dev/null 2>&1
fi

# Get the latest release version from GitHub
version=$(basename "$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/fosrl/newt/releases/latest)")

# Prompt for user input
read -p 'ID: ' id
read -p 'Secret: ' secret
read -p 'Endpoint: ' endpoint

# Download and install Newt
echo "Installing Newt version $version..."
wget -q -O /usr/local/bin/newt "https://github.com/fosrl/newt/releases/download/$version/newt_linux_amd64"
chmod +x /usr/local/bin/newt

# Create systemd service for Newt
cat > /etc/systemd/system/newt.service <<EOL
[Unit]
Description=Newt VPN Client - Version $version
After=network.target

[Service]
ExecStart=/usr/local/bin/newt --id $id --secret $secret --endpoint $endpoint
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOL

# Enable and start the service
systemctl enable --quiet newt.service
systemctl start --quiet newt.service

# Final message
echo "Newt has been installed and configured to run automatically."
echo "Run 'systemctl status newt.service' to check the status."
