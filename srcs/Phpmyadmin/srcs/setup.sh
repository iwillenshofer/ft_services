#!/bin/sh

mkdir -p /run/lighttpd
touch /run/lighttpd/php-fastcgi.socket
chown -R lighttpd:lighttpd /run/lighttpd
mv /tmp/lighttpd.conf /etc/lighttpd/lighttpd.conf
mv /tmp/mod_fastcgi.conf /etc/lighttpd/mod_fastcgi.conf
mv /tmp/telegraf.conf /etc/telegraf.conf
export TELEGRAF_CONFIG_PATH=/etc/telegraf.conf

mkdir -p /var/www/phpmyadmin
tar -zxvf /tmp/phpmyadmin.tar.gz -C /var/www/phpmyadmin --strip 1
mv /tmp/config.inc.php /var/www/phpmyadmin/config.inc.php
chmod -R 755 /var/www/
chown lighttpd -R /var/www/


telegraf & /usr/sbin/lighttpd -D -f /etc/lighttpd/lighttpd.conf

