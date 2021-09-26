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

export MOUNT_POINT="/export"
export WP_MOUNT_POINT="${MOUNT_POINT}/wordpress/"
export APP_HOME_DIR="/home/ubuntu/wp"
export SECRET_ID="credentials6"
export AWS_REGION="eu-central-1"
export EFS_DNS_NAME=$(aws secretsmanager get-secret-value --secret-id ${SECRET_ID} --region=${AWS_REGION} | jq -rs ".[].SecretString" | jq  -r ".efsdnsname")

sudo mkdir -p ${APP_HOME_DIR}

sudo mkdir -p ${MOUNT_POINT}
echo ${EFS_DNS_NAME}:/ ${MOUNT_POINT} nfs4 defaults,_netdev 0 0  | sudo tee --append /etc/fstab
sudo mount ${MOUNT_POINT}

sudo mkdir -p ${WP_MOUNT_POINT}


cat <<EOF > ${APP_HOME_DIR}/run.sh
echo WORDPRESS_DB_USER=\$(aws secretsmanager get-secret-value --secret-id ${SECRET_ID} --region=${AWS_REGION} | jq -rs ".[].SecretString" | jq  -r ".username") > ${APP_HOME_DIR}/.env
echo WORDPRESS_DB_PASSWORD=\$(aws secretsmanager get-secret-value --secret-id ${SECRET_ID} --region=${AWS_REGION} | jq -rs ".[].SecretString" | jq  -r ".password") >> ${APP_HOME_DIR}/.env
echo WORDPRESS_DB_HOST=\$(aws secretsmanager get-secret-value --secret-id ${SECRET_ID} --region=${AWS_REGION} | jq -rs ".[].SecretString" | jq  -r ".host") >> ${APP_HOME_DIR}/.env
echo WORDPRESS_DB_NAME=\$(aws secretsmanager get-secret-value --secret-id ${SECRET_ID} --region=${AWS_REGION} | jq -rs ".[].SecretString" | jq  -r ".dbname") >> ${APP_HOME_DIR}/.env

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
       - ${WP_MOUNT_POINT}:/var/www/html
EOF

sudo chmod +x ${APP_HOME_DIR}/run.sh

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
