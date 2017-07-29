#!/bin/bash
yum update -y

yum install php71 httpd24 php71-mysqlnd git -y

chmod +x /usr/bin/wp-cli
wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -O /usr/bin/wp
chmod +x /usr/bin/wp
wget https://wordpress.org/wordpress-4.8.tar.gz -O /tmp/wordpress.tar.gz
tar -zxvf /tmp/wordpress.tar.gz  --strip 1 --directory /var/www/html/
cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php

sed -i "s/database_name_here/${db_name}/" /var/www/html/wp-config.php
sed -i "s/username_here/${db_username}/" /var/www/html/wp-config.php
sed -i "s/password_here/${db_password}/" /var/www/html/wp-config.php
sed -i "s/localhost/${db_host}/" /var/www/html/wp-config.php
chown -R apache:apache /var/www/html/

sudo -H -u apache bash -c 'cd /var/www/html; if ! $(wp core is-installed); then
wp core install --url="${site_url}" --title="${site_title}" --admin_name="${site_admin_name}" --admin_password=${site_admin_password} --admin_email=${site_admin_email};
fi'

cd /var/www/html/wp-content/plugins; git clone https://github.com/humanmade/S3-Uploads
chown -R apache:apache /var/www/html/
sudo -H -u apache bash -c 'cd /var/www/html; wp plugin activate S3-Uploads'
service httpd restart
