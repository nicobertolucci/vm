#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

if [ -d /var/www/var/cache ]; then
    sudo rm -rf /var/www/var/cache/*
fi

if [ -d /var/www/var/log ]; then
    sudo rm -rf /var/www/var/log/*
fi

sudo service mysql restart

sudo service apache2 restart
