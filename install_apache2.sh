#!/bin/bash -e
sudo apt update -y
sudo apt install apache2 -y
sudo systemctl start apache2
sudo bash -c 'echo "Test web server<br>ip: $(hostname)" > /var/www/html/index.html'
