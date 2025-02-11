#$/bin/bash

if [[ ! $(which curl) ]]; then
echo "curl is not installed."
echo "Installing it now..."
sudo apt update > /dev/null 2>& 1 && sudo apt install curl -y > /dev/null 2>& 1
fi

version=$(basename $($(which curl) -Ls -o /dev/null -w %{url_effective} https://github.com/fosrl/newt/releases/latest))
read -p 'ID: ' id
read -p 'Secret: ' secret
read -p 'Endpoint: ' endpoint
echo "Installing Newt version $version"
wget -O /usr/local/bin/newt "https://github.com/fosrl/newt/releases/download/$version/newt_linux_amd64" > /dev/null 2>& 1
chmod +x /usr/local/bin/newt > /dev/null 2>& 1
cat >/etc/systemd/system/newt.service <<EOL
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

systemctl enable newt.service > /dev/null 2>& 1
systemctl start newt.service

echo "Newt has been installed and configured to run automatically."
echo "Run systemctl status newt.service to check the status.
