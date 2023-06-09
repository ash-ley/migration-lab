#!/bin/bash

# Bash script to install mysql server
apt-get update
apt-get install -y debconf-utils

config_file="/etc/mysql/mysql.conf.d/mysqld.cnf"
DB_ROOT_PASS="${mysql_root_password}"
phpmyadmin_server_ip="${app_private_ip}"
bind_address_line="bind-address"
# Bash script to create database and user
DB_NAME="customer_db"
DB_USER="customer_user"
DB_USER_PASS="customer_pass"

debconf-set-selections <<< "mysql-server mysql-server/root_password password $DB_ROOT_PASS"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $DB_ROOT_PASS"
apt-get install -y mysql-server

mysql -uroot -p$DB_ROOT_PASS -e "CREATE DATABASE IF NOT EXISTS $DB_NAME"
mysql -uroot -p$DB_ROOT_PASS -e "CREATE USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_USER_PASS'"

# Modify bind-address
sed -i 's/^#*\s*'"$bind_address_line"'\s*=.*/'"$bind_address_line = 0.0.0.0"'/g' "$config_file"

service mysql restart

mysql -u root -p$DB_ROOT_PASS -e "CREATE USER 'phpmyadmin'@'$phpmyadmin_server_ip' IDENTIFIED BY '$DB_ROOT_PASS';"
mysql -u root -p$DB_ROOT_PASS -e "GRANT CREATE, ALTER, DROP, INSERT, UPDATE, DELETE, SELECT, REFERENCES, RELOAD on *.* TO 'phpmyadmin'@'$phpmyadmin_server_ip' WITH GRANT OPTION; FLUSH PRIVILEGES;"
