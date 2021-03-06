#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

sudo wget http://wordpress.org/latest.tar.gz -P /tmp
sudo tar -zxvf /tmp/latest.tar.gz -C /tmp

sudo cp -rf /tmp/wordpress/* /var/www/html

sudo rm /tmp/latest.tar.gz
sudo rm -rf /tmp/wordpress

sudo rm -rf /var/www/html/wp-content/plugins/akismet
sudo rm -rf /var/www/html/wp-content/plugins/hello.php
sudo rm -rf /var/www/html/wp-content/themes/twentyfifteen
sudo rm -rf /var/www/html/wp-content/themes/twentysixteen

sudo rm /var/www/html/license.txt
sudo rm /var/www/html/readme.html

sudo mv /var/www/html/wp-config-sample.php /var/www/html/wp-config.php

sudo sed -i "s|database_name_here|$1|" /var/www/html/wp-config.php
sudo sed -i "s|username_here|root|" /var/www/html/wp-config.php
sudo sed -i "s|password_here|$2|" /var/www/html/wp-config.php
sudo sed -i "s|'wp_'|'cms_'|" /var/www/html/wp-config.php

perl -i -pe'
    BEGIN {
        @chars = ("a" .. "z", "A" .. "Z", 0 .. 9);
        push @chars, split //, "!@#$%^&*()-_ []{}<>~\`+=,.;:/?|";
        sub salt { join "", map $chars[ rand @chars ], 1 .. 64 }
    }
    s/put your unique phrase here/salt()/ge
' /var/www/html/wp-config.php

sudo sed -i "s|path_source_here|source\\/|" /var/www/package.json
sudo sed -i "s|path_target_here|html\\/wp-content\\/themes\\/custom\\/assets\\/|" /var/www/package.json

sudo mkdir /var/www/html/wp-content/themes/custom
sudo mkdir /var/www/html/wp-content/themes/custom/assets
sudo mkdir /var/www/html/wp-content/themes/custom/assets/css
sudo mkdir /var/www/html/wp-content/themes/custom/assets/fonts
sudo mkdir /var/www/html/wp-content/themes/custom/assets/images
sudo mkdir /var/www/html/wp-content/themes/custom/assets/js
sudo mkdir /var/www/html/wp-content/themes/custom/languages
sudo mkdir /var/www/html/wp-content/uploads

sudo cat << EOF > /var/www/html/wp-content/themes/custom/functions.php
<?php
EOF

sudo cat << EOF > /var/www/html/wp-content/themes/custom/index.php
<?php get_header(); ?>
<main class="main" id="page-main">
    <p>Main</p>
</main>
<?php get_sidebar(); ?>
<?php get_footer(); ?>
EOF

sudo cat << EOF > /var/www/html/wp-content/themes/custom/robots.txt
EOF

sudo cat << EOF > /var/www/html/wp-content/themes/custom/style.css
/**
 * Theme Name: Custom
 * Theme URI: 
 * Description: 
 * Author: 
 * Author URI: 
 * Version: 1.0
 */
EOF
