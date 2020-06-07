#!/bin/sh

mv /tmp/telegraf.conf /etc/telegraf.conf
export TELEGRAF_CONFIG_PATH=/etc/telegraf.conf

mkdir -p /ftps/$FTP_USER

openssl req -x509 -nodes -days 7300 -newkey rsa:2048 -subj "/C=BR/ST=br/L=Brasil/O=42 SP/CN=phippy" -keyout /etc/ssl/private/pure-ftpd.pem -out /etc/ssl/private/pure-ftpd.pem
chmod 600 /etc/ssl/private/pure-ftpd.pem

adduser -h /ftps/$FTP_USER -D $FTP_USER
echo "$FTP_USER:$FTP_PASSWORD" | chpasswd

adduser -h /wordpress/ -D $WORDPRESS_USER_NAME
echo "$WORDPRESS_USER_NAME:$WORDPRESS_PASSWORD" | chpasswd

telegraf & /usr/sbin/pure-ftpd -j -Y 1 -p 21000:21000 -P "__MINIKUBE_IP__"
