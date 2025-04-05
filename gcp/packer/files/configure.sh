#! /bin/bash
sudo apt update
sudo apt upgrade -y
sudo apt install apache2 net-tools -y
#vm_hostname=\"$(curl -H "Metadata-Flavor:Google" http://169.254.169.254/computeMetadata/v1/instance/name)\"
#echo "Page served from: $vm_hostname" | sudo tee /var/www/html/index.html
sudo systemctl enable apache2
sudo systemctl restart apache2