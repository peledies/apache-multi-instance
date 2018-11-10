# Prepare system for instal

```
sudo apt update

sudo apt install curl -y
```


# Prepare for multiple versions of php

```
sudo apt install software-properties-common -y
sudo add-apt-repository ppa:ondrej/php -y
sudo apt update
```


# Install PHP's

### PHP 5.6
```
sudo apt install php5.6 php5.6-curl php5.6-mysql php5.6-mcrypt php5.6-gd php5.6-mbstring php5.6-zip php5.6-opcache php5.6-readline php5.6-xml -y
```
### PHP 7.0
```
sudo apt install php7.0 php7.0-curl php7.0-mysql php7.0-mcrypt php7.0-gd php7.0-mbstring php7.0-zip php7.0-opcache php7.0-readline php7.0-xml -y
```

### PHP 7.1
```
sudo apt install php7.1 php7.1-curl php7.1-mysql php7.1-mcrypt php7.1-gd php7.1-mbstring php7.1-zip php7.1-opcache php7.1-readline php7.1-xml -y
```

### PHP 7.2
> mcrypt deprecated after 7.1
```
sudo apt install php7.2 php7.2-curl php7.2-mysql php7.2-gd php7.2-mbstring php7.2-zip php7.2-opcache php7.2-readline php7.2-xml -y
```

### PHP 7.3
```
sudo apt install php7.3 php7.3-curl php7.3-mysql php7.3-gd php7.3-mbstring php7.3-zip php7.3-opcache php7.3-readline php7.3-xml -y
```

# ONE LINER
```
sudo apt install php5.6 php5.6-curl php5.6-mysql php5.6-mcrypt php5.6-gd php5.6-mbstring php5.6-zip php5.6-opcache php5.6-readline php5.6-xml php7.0 php7.0-curl php7.0-mysql php7.0-mcrypt php7.0-gd php7.0-mbstring php7.0-zip php7.0-opcache php7.0-readline php7.0-xml php7.1 php7.1-curl php7.1-mysql php7.1-mcrypt php7.1-gd php7.1-mbstring php7.1-zip php7.1-opcache php7.1-readline php7.1-xml php7.2 php7.2-curl php7.2-mysql php7.2-gd php7.2-mbstring php7.2-zip php7.2-opcache php7.2-readline php7.2-xml php7.3 php7.3-curl php7.3-mysql php7.3-gd php7.3-mbstring php7.3-zip php7.3-opcache php7.3-readline php7.3-xml -y
```

# switch primary php for cli (optional)
```
sudo update-alternatives --set php /usr/bin/php7.3
```

# Install Apache
> We install Apache 2nd so that we can clone the php modules when we create new apache instances.
```
sudo apt install apache2 libapache2-mod-php -y
```

# Use Apache Proper as the proxy
```
sudo a2enmod proxy
sudo a2enmod proxy_http
sudo a2enmod proxy_balancer
sudo a2enmod lbmethod_byrequests

sudo a2dissite 000-default.conf
sudo rm /etc/apache2/sites-available/000-default.conf
sudo rm /etc/apache2/sites-available/default-ssl.conf

sudo vi /etc/apache2/sites-available/proxy.conf

sudo a2ensite proxy.conf

sudo service apache2 start
```

# Apache 5.6

```
sudo sh /usr/share/doc/apache2/examples/setup-instance php56

sudo a2dismod-php56 php7.3 php7.2 php7.1 php7.0
sudo a2enmod-php56 php5.6
sudo update-rc.d apache2-php56 defaults
sudo a2enmod-php56 vhost_alias
sudo mkdir -p /var/www/php56/test
sudo bash -c 'echo "<?php echo phpinfo(); ?>" > /var/www/php56/test/index.php'
sudo sed -i "s/.*Listen 80.*/Listen 8056/" /etc/apache2-php56/ports.conf
sudo sed -i "s/.*Listen 443.*/Listen 4056/" /etc/apache2-php56/ports.conf

sudo vi /etc/apache2-php56/sites-available/wildcard.56.test.com.conf

<VirtualHost *:8056>
        ServerAlias *.56.test.com

        ServerAdmin deac@sfp.net
        VirtualDocumentRoot /var/www/php56/%1/

        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>

sudo a2ensite-php56 wildcard.56.test.com.conf
sudo a2dissite-php56 000-default.conf
sudo rm /etc/apache2-php56/sites-available/000-default.conf
sudo rm /etc/apache2-php56/sites-available/default-ssl.conf

sudo service apache2-php56 restart
```


# Apache 7.3 #
```
sudo sh /usr/share/doc/apache2/examples/setup-instance php73

sudo a2dismod-php73 php5.6 php7.2 php7.1 php7.0
sudo a2enmod-php73 php7.3
sudo update-rc.d apache2-php73 defaults
sudo a2enmod-php73 vhost_alias
sudo mkdir -p /var/www/php73/test
sudo bash -c 'echo "<?php echo phpinfo(); ?>" > /var/www/php73/test/index.php'
sudo sed -i "s/.*Listen 80.*/Listen 8073/" /etc/apache2-php73/ports.conf
sudo sed -i "s/.*Listen 443.*/Listen 4073/" /etc/apache2-php73/ports.conf

sudo vi /etc/apache2-php73/sites-available/wildcard.73.test.com.conf

<VirtualHost *:8073>
        ServerAlias *.73.test.com

        ServerAdmin deac@sfp.net
        VirtualDocumentRoot /var/www/php73/%1/

        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>

sudo a2ensite-php73 wildcard.73.test.com.conf
sudo a2dissite-php73 000-default.conf
sudo rm /etc/apache2-php73/sites-available/000-default.conf
sudo rm /etc/apache2-php73/sites-available/default-ssl.conf

sudo service apache2-php73 start
```

###########
# Testing #
###########
Run the script in a vagrant box to experiment with.
```
# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.configure("2") do |config|

  config.vm.box = "ubuntu/xenial64"

  config.vm.network "public_network"

  config.vm.network :forwarded_port, host: 8080, guest: 80
  config.vm.network :forwarded_port, host: 8056, guest: 8056
  config.vm.network :forwarded_port, host: 8070, guest: 8070
  config.vm.network :forwarded_port, host: 8071, guest: 8071
  config.vm.network :forwarded_port, host: 8072, guest: 8072
  config.vm.network :forwarded_port, host: 8073, guest: 8073
  
end
```