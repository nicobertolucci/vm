#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

sudo apt-get update
sudo apt-get upgrade -y

sudo locale-gen "en_US.UTF-8"
sudo locale-gen "es_US.UTF-8"

sudo apt-get install -y curl debconf-utils unzip zip

sudo apt-get install -y apache2

echo "ServerName localhost" >> /etc/apache2/apache2.

sudo a2enmod rewrite
sudo a2dissite 000-default.conf

sudo cat << EOF > /etc/apache2/sites-available/000-default.conf
    <VirtualHost *:80>
        DocumentRoot /var/www/html
        ServerName localhost
        <Directory /var/www/html>
            AllowOverride All
            Require all granted
            <IfModule mod_rewrite.c>
                Options -MultiViews
                RewriteEngine On
                RewriteCond %{REQUEST_FILENAME} !-f
                RewriteRule ^(.*)$ index.php [QSA,L]
            </IfModule>
        </Directory>
    </VirtualHost>
EOF

sudo a2ensite 000-default.conf
sudo ufw allow in "Apache Full"

if [ -d /var/www/html ]; then
    sudo rm /var/www/html/*
fi

sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $2"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $2"

sudo apt-get install -y mysql-server

sudo mysql -uroot -p$2 << EOF
    CREATE DATABASE $1;
EOF

sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/app-password-confirm password $2"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password $2"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password $2"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect none"

sudo apt-get install -y php libapache2-mod-php phpmyadmin

curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -

sudo apt-get install -y nodejs

sudo apt-get autoremove -y --purge
