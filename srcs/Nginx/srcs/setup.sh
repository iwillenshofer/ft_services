#! /bin/sh
sed -i "s|__FTP_USER__|${FTP_USER}|g" /var/www/html/index.html
sed -i "s|__FTP_PASSWORD__|${FTP_PASSWORD}|g" /var/www/html/index.html
sed -i "s|__MYSQL_ROOT_PASSWORD__|${MYSQL_ROOT_PASSWORD}|g" /var/www/html/index.html
sed -i "s|__SSH_USER__|${SSH_USER}|g" /var/www/html/index.html
sed -i "s|__SSH_PASS__|${SSH_PASS}|g" /var/www/html/index.html
sed -i "s|__WORDPRESS_USER_NAME__|${WORDPRESS_USER_NAME}|g" /var/www/html/index.html
sed -i "s|__WORDPRESS_PASSWORD__|${WORDPRESS_PASSWORD}|g" /var/www/html/index.html

ssh-keygen -A
adduser --disabled-password ${SSH_USER}
echo "${SSH_USER}:${SSH_PASS}" | chpasswd
export TELEGRAF_CONFIG_PATH=/etc/telegraf.conf
/usr/sbin/sshd -e & telegraf & nginx -g "pid /tmp/nginx.pid; daemon off;"
