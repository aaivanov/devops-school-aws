#!/bin/bash -e
sudo apt update -y
#sudo apt install apache2 -y
#sudo systemctl start apache2
#sudo systemctl stop apache2
#sudo bash -c 'echo "Test web server<br>ip: $(hostname)" > /var/www/html/index.html'

sudo apt  install docker.io awscli jq nfs-common -y
sudo usermod -aG docker ubuntu
sudo systemctl enable docker
sudo systemctl start docker

sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/bin/docker-compose
sudo chmod +x /usr/bin/docker-compose

sudo mkdir /wordpress
export APP_HOME_DIR="/home/ubuntu/wp"
mkdir -p ${APP_HOME_DIR}

cat <<EOF > ${APP_HOME_DIR}/run.sh
echo WORDPRESS_DB_USER=\$(aws secretsmanager get-secret-value --secret-id credentials0 --region=eu-central-1 | jq -rs ".[].SecretString" | jq  -r ".username") > ${APP_HOME_DIR}/.env
echo WORDPRESS_DB_PASSWORD=\$(aws secretsmanager get-secret-value --secret-id credentials0 --region=eu-central-1 | jq -rs ".[].SecretString" | jq  -r ".password") >> ${APP_HOME_DIR}/.env
echo WORDPRESS_DB_HOST=\$(aws secretsmanager get-secret-value --secret-id credentials0 --region=eu-central-1 | jq -rs ".[].SecretString" | jq  -r ".host") >> ${APP_HOME_DIR}/.env
echo WORDPRESS_DB_NAME=\$(aws secretsmanager get-secret-value --secret-id credentials0 --region=eu-central-1 | jq -rs ".[].SecretString" | jq  -r ".dbname") >> ${APP_HOME_DIR}/.env

/usr/bin/docker-compose -f ${APP_HOME_DIR}/docker-compose.yml up -d --remove-orphan
EOF

cat <<EOF > ${APP_HOME_DIR}/docker-compose.yml
version: '3.3'
services:
   wordpress:
     image: wordpress:latest
     ports:
       - "80:80"
     restart: always
     env_file:
       - ${APP_HOME_DIR}/.env
     volumes:
       - /wordpress:/var/www/html
EOF

chmod +x ${APP_HOME_DIR}/run.sh

cat <<EOF > ${APP_HOME_DIR}/docker_boot.service
[Unit]
Description=docker boot
After=docker.service


[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=${APP_HOME_DIR}
ExecStart=/bin/bash -c ${APP_HOME_DIR}/run.sh


[Install]
WantedBy=multi-user.target
EOF

sudo cp -v ${APP_HOME_DIR}/docker_boot.service /etc/systemd/system
sudo systemctl enable docker_boot.service
sudo systemctl start docker_boot.service
