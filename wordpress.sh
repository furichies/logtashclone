#!/bin/bash
# Instalar Apache, PHP y WordPress
sudo apt-get update
sudo apt-get install -y apache2 php libapache2-mod-php php-mysql
sudo apt-get install wget unzip -y
sudo wget https://wordpress.org/latest.zip
sudo unzip latest.zip
sudo mv wordpress/ /var/www/html/
# Configurar WordPress
sudo cp /var/www/html/wordpress/wp-config-sample.php /var/www/html/wordpress/wp-config.php
sudo sed -i 's/database_name_here/wordpress/' /var/www/html/wordpress/wp-config.php
sudo sed -i 's/username_here/wordpress/' /var/www/html/wordpress/wp-config.php
sudo sed -i 's/password_here/wordpress/' /var/www/html/wordpress/wp-config.php
sudo chown -R www-data:www-data /var/www/html/wordpress
# Crear el sitio virtual de Apache para WordPress
sudo tee /etc/apache2/sites-available/wordpress.conf << EOF
      <VirtualHost *:80>
       ServerAdmin webmaster@localhost
       DocumentRoot /var/www/html/wordpress

       <Directory /var/www/html/wordpress/>
        Options FollowSymLinks
        AllowOverride All
        Require all granted
       </Directory>

        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined
      </VirtualHost>
EOF

sudo a2ensite wordpress.conf
sudo a2dissite 000-default.conf

sudo systemctl reload apache2.service
# Instalar MariaDB
sudo apt-get update
sudo apt-get install -y mariadb-server mariadb-client

# Configurar MariaDB
sudo mysql -u root -e "CREATE DATABASE wordpress;"
sudo mysql -u root -e "CREATE USER 'wordpress'@'localhost' IDENTIFIED BY 'wordpress';"
sudo mysql -u root -e "GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpress'@'localhost';"
      
# Instalar Filebeat
sudo wget https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.15.1-amd64.deb
sudo dpkg -i ./filebeat-7.15.1-amd64.deb

# Configurar Filebeat
sudo tee /etc/filebeat/filebeat.yml << EOF
filebeat.inputs:
- type: log
  paths:
    - /var/log/apache2/*.log
  name: apache-logs
- type: log
  paths:
    - /var/log/syslog
  name: syslog-input

output.logstash:
  hosts: ["192.168.33.20:5044"]
  index: "filebeat-%{+yyyy.MM.dd}"
EOF

sudo systemctl enable filebeat.service
sudo systemctl start filebeat.service

# Enviar algunos logs de prueba a Logstash
echo "Testing log message from WordPress" | sudo tee -a /var/log/apache2/error.log
