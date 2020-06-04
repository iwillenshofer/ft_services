#!/bin/sh

mkdir -p /run/lighttpd
touch /run/lighttpd/php-fastcgi.socket
chown -R lighttpd:lighttpd /run/lighttpd
mv /tmp/lighttpd.conf /etc/lighttpd/lighttpd.conf
mv /tmp/mod_fastcgi.conf /etc/lighttpd/mod_fastcgi.conf
mv /tmp/telegraf.conf /etc/telegraf.conf
if [ ! -d /var/www/wp-admin ]
then
    tar -zxvf /tmp/wordpress.tar.gz -C /tmp
    cp -r /tmp/wordpress/* /var/www/

    sed -i "s|__WORDPRESS_DB_NAME__|${WORDPRESS_DB_NAME}|g" /tmp/wp-config.php
    sed -i "s|__WORDPRESS_USER_NAME__|${WORDPRESS_USER_NAME}|g" /tmp/wp-config.php
    sed -i "s|__WORDPRESS_PASSWORD__|${WORDPRESS_PASSWORD}|g" /tmp/wp-config.php
    sed -i "s|__WORDPRESS_DB_HOST__|${WORDPRESS_DB_HOST}|g" /tmp/wp-config.php
    sed -i "s|__WORDPRESS_USER_NAME__|${WORDPRESS_USER_NAME}|g" /tmp/mysql.sql
    sed -i "s|__WORDPRESS_PASSWORD__|${WORDPRESS_PASSWORD}|g" /tmp/mysql.sql
    sed -i "s|__WORDPRESS_DB_NAME__|${WORDPRESS_DB_NAME}|g" /tmp/backup.sql

    mv /tmp/wp-config.php /var/www/
    #wait for mysql host to have started
    while ! mysqladmin ping -hmysql --silent; do
        sleep 1
    done
    mysql -h mysql -uroot -p${MYSQL_ROOT_PASSWORD} < /tmp/mysql.sql
    mysql -h mysql -uroot -p${MYSQL_ROOT_PASSWORD} < /tmp/backup.sql
fi

chmod -R 755 /var/www/
chown lighttpd -R /var/www/

export TELEGRAF_CONFIG_PATH=/etc/telegraf.conf
telegraf & /usr/sbin/lighttpd -D -f /etc/lighttpd/lighttpd.conf
