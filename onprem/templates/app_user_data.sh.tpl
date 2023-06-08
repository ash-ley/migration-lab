#!/bin/bash

# Set MySQL root password
mysql_root_password="${mysql_root_password}"

# Set remote MySQL server details
remote_mysql_host="${db_private_ip}"
remote_mysql_port="3306"

# Install phpMyAdmin and its dependencies
export DEBIAN_FRONTEND=noninteractive

# Configure phpMyAdmin
debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2"
debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true"
debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password $mysql_root_password"
debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password $mysql_root_password"

apt update
apt install -yq phpmyadmin php-mbstring

# Configure phpMyAdmin to connect to remote MySQL server
sudo sed -i "s/\$dbserver='.*';/\$dbserver='$remote_mysql_host';/g" /etc/phpmyadmin/config-db.php

# Enable mysqli extension
phpenmod mysqli

# Restart Apache server
systemctl restart apache2

echo "phpMyAdmin installation completed."