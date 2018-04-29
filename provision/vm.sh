#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

if [ ! -d /var/cache/swap ]; then
    sudo mkdir -v /var/cache/swap
    cd /var/cache/swap
    sudo dd if=/dev/zero of=swapfile bs=1K count=$1M
    sudo chmod 600 swapfile
    sudo mkswap swapfile
    sudo swapon swapfile
    echo "/var/cache/swap/swapfile none swap sw 0 0" | sudo tee -a /etc/fstab
    sudo swapoff swapfile
    sudo swapon -va
fi

sudo apt-get update
sudo apt-get upgrade -y

sudo apt-get install -y curl debconf-utils unzip zip

if [ ! -d /var/www/var ]; then
    sudo mkdir /var/www/var
fi

if [ ! -d /var/www/var/cache ]; then
    sudo mkdir /var/www/var/cache
fi

if [ ! -d /var/www/var/log ]; then
    sudo mkdir /var/www/var/log
fi

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
        CustomLog /var/www/var/log/access.log combined
        ErrorLog /var/www/var/log/error.log
    </VirtualHost>
EOF

if [ ! -d /var/www/var/cache ]; then
    sudo mkdir /var/www/var/cache
fi

if [ ! -d /var/www/var/log ]; then
    sudo mkdir /var/www/var/log
fi

sudo a2ensite 000-default.conf
sudo ufw allow in "Apache Full"

if [ -d /var/www/html ]; then
    sudo rm /var/www/html/*
fi

sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $3"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $3"

sudo apt-get install -y mysql-server

sudo mysql -uroot -p$3 << EOF
    CREATE DATABASE $2;
EOF

sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/app-password-confirm password $3"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password $3"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password $3"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect none"

sudo apt-get install -y php libapache2-mod-php phpmyadmin

curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -

sudo apt-get install -y nodejs

sudo apt-get autoremove -y --purge
