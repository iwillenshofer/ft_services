#!/bin/sh

export TELEGRAF_CONFIG_PATH=/etc/telegraf.conf

#-- mysql
sed -i "s|__MYSQL_DATA_DIR__|${MYSQL_DATA_DIR}|g" /etc/my.cnf.d/mariadb-server.cnf

if [ ! -d $MYSQL_DATA_DIR/mysql ]
then
	
	/usr/bin/mysql_install_db --user=mysql --datadir=$MYSQL_DATA_DIR
	chown mysql:mysql $MYSQL_DATA_DIR
	sed -i "s|__MYSQL_ROOT_PASSWORD__|${MYSQL_ROOT_PASSWORD}|g" /tmp/mysql.sql
	/usr/bin/mysqld --user=root --bootstrap --verbose=0 < /tmp/mysql.sql
fi

telegraf & exec /usr/bin/mysqld --user=root --console
