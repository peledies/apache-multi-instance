#!/bin/bash
green=$(tput setaf 2)
gold=$(tput setaf 3)
magenta=$(tput setaf 5)
cyan=$(tput setaf 6)
red=$(tput setaf 1)
default=$(tput sgr0)

BOOTUP=color
RES_COL=0
RES_COL_B=20
MOVE_TO_COL_B="echo -en \\033[${RES_COL_B}G"
MOVE_TO_COL="echo -en \\033[${RES_COL}G"
SETCOLOR_SUCCESS="echo -en \\033[1;32m"
SETCOLOR_FAILURE="echo -en \\033[1;31m"
SETCOLOR_WARNING="echo -en \\033[1;33m"
SETCOLOR_NORMAL="echo -en \\033[0;39m"

echo_start() {
  [ "$BOOTUP" = "color" ] && $MOVE_TO_COL
  echo -n "["
  [ "$BOOTUP" = "color" ] && $SETCOLOR_SUCCESS
  echo -n $"..."
  [ "$BOOTUP" = "color" ] && $SETCOLOR_NORMAL
  echo -n "]"
  $MOVE_TO_COL_B
  return 0
}

echo_success() {
  [ "$BOOTUP" = "color" ] && $MOVE_TO_COL
  echo -n "["
  [ "$BOOTUP" = "color" ] && $SETCOLOR_SUCCESS
  echo -n $" OK "
  [ "$BOOTUP" = "color" ] && $SETCOLOR_NORMAL
  echo -n "]"
  echo -ne "\n"
  return 0
}

echo_done() {
  [ "$BOOTUP" = "color" ] && $MOVE_TO_COL
  echo -n "["
  [ "$BOOTUP" = "color" ] && $SETCOLOR_SUCCESS
  echo -n $" DONE "
  [ "$BOOTUP" = "color" ] && $SETCOLOR_NORMAL
  echo -n "]"
  echo -ne "\n"
  return 0
}

echo_failure() {
  [ "$BOOTUP" = "color" ] && $MOVE_TO_COL
  echo -n "["
  [ "$BOOTUP" = "color" ] && $SETCOLOR_FAILURE
  echo -n $"FAILED"
  [ "$BOOTUP" = "color" ] && $SETCOLOR_NORMAL
  echo -n "]"
  echo -ne "\n"
  return 1
}

test_for_success() {
   rc=$1
  if [[ $rc -eq 0 ]]; then
    echo_success
  elif [ "$2" = "allow" ]; then
    echo_failure
  else
    echo_failure
    exit $rc
  fi
}

info_box() {
  NUM=$((${#1} + 4))
  echo "${cyan}"

  # print the top of the info box
  eval printf %.0s# '{1..'"${NUM}"\}; echo

  # print the middle of the info box
  echo "# $1 #"

  # print the bottom of the info box
  eval printf %.0s# '{1..'"${NUM}"\}; echo

  echo "${default}"
}

##########################
# Ensure Root privileges #
##########################
if [ "$(whoami)" != "root" ]; then
  echo "${gold}!- ${red}You will need to run this with root, or sudo.${gold} -!"
  exit 1
fi

#############################
# Check for domain argument #
#############################
if [ -z "$1" ]
then
  DOMAIN="test.com"
  echo -e "${red}No Domain provided, using $DOMAIN\n${default}"
else
  DOMAIN=$1
  echo -e "${magenta}Domain provided, using $DOMAIN\n${default}"
fi

info_box "Prepare system for install"

echo_start
    echo -n "Updating Aptitude"
    sudo apt update > /dev/null 2>&1
test_for_success $? allow

echo_start
    echo -n "Installing curl"
    sudo apt install curl -y > /dev/null 2>&1
test_for_success $? allow


########################################
# Prepare for multiple versions of php #
########################################
info_box "Prepare for multiple versions of php"

echo_start
    echo -n "Adding software-properties-common"
    sudo apt install software-properties-common -y > /dev/null 2>&1
test_for_success $? allow

echo_start
    echo -n "Adding ppa:ondrej/php repository"
    sudo add-apt-repository ppa:ondrej/php -y > /dev/null 2>&1
test_for_success $? allow

echo_start
    echo -n "Updating Aptitude"
    sudo apt update > /dev/null 2>&1
test_for_success $? allow


#################
# Install PHP's #
#################
info_box "Installing PHP versions [5.6, 7.0, 7.1, 7.2, 7.3]"

echo_start
    echo -n "Installing PHP 5.6"
    sudo apt install php5.6 php5.6-curl php5.6-mysql php5.6-mcrypt php5.6-gd php5.6-mbstring php5.6-zip php5.6-opcache php5.6-readline php5.6-xml -y > /dev/null 2>&1
test_for_success $? allow

echo_start
    echo -n "Installing PHP 7.0"
    sudo apt install php7.0 php7.0-curl php7.0-mysql php7.0-mcrypt php7.0-gd php7.0-mbstring php7.0-zip php7.0-opcache php7.0-readline php7.0-xml -y > /dev/null 2>&1
test_for_success $? allow

echo_start
    echo -n "Installing PHP 7.1"
    sudo apt install php7.1 php7.1-curl php7.1-mysql php7.1-mcrypt php7.1-gd php7.1-mbstring php7.1-zip php7.1-opcache php7.1-readline php7.1-xml -y > /dev/null 2>&1
test_for_success $? allow

echo_start
    echo -n "Installing PHP 7.2"
    sudo apt install php7.2 php7.2-curl php7.2-mysql php7.2-gd php7.2-mbstring php7.2-zip php7.2-opcache php7.2-readline php7.2-xml -y > /dev/null 2>&1
test_for_success $? allow

echo_start
    echo -n "Installing PHP 7.3"
    sudo apt install php7.3 php7.3-curl php7.3-mysql php7.3-gd php7.3-mbstring php7.3-zip php7.3-opcache php7.3-readline php7.3-xml -y > /dev/null 2>&1
test_for_success $? allow


##################
# Install Apache #
##################
info_box "Installing Apache2"
echo_start
    echo -n "Installing Apache2"
    sudo apt install apache2 libapache2-mod-php -y > /dev/null 2>&1
test_for_success $? allow

##################################
# Use Apache Proper as the proxy #
##################################
info_box "Configure Apache2 Proper as the proxy"
echo_start
    echo -n "Enabling Apache Proxy Modules"
    sudo a2enmod proxy proxy_http proxy_balancer lbmethod_byrequests > /dev/null 2>&1
test_for_success $? allow

echo_start
    echo -n "Disable the default site"
    sudo a2dissite 000-default.conf > /dev/null 2>&1
test_for_success $? allow

echo_start
    echo -n "Remove default config files"
    sudo rm /etc/apache2/sites-available/000-default.conf > /dev/null 2>&1
    sudo rm /etc/apache2/sites-available/default-ssl.conf > /dev/null 2>&1
test_for_success $? allow

echo_start
    echo -n "Writing Proxy Config"
    sudo touch /etc/apache2/sites-available/proxy.conf > /dev/null 2>&1
cat <<EOF > /etc/apache2/sites-available/proxy.conf
<VirtualHost *:80>
  ProxyPreserveHost On
  ProxyRequests Off
  ServerAlias *.56.$DOMAIN
  ProxyPass / http://127.0.0.1:8056/
  ProxyPassReverse / http://127.0.0.1:8056/
</VirtualHost>
<VirtualHost *:80>
  ProxyPreserveHost On
  ProxyRequests Off
  ServerAlias *.70.$DOMAIN
  ProxyPass / http://127.0.0.1:8070/
  ProxyPassReverse / http://127.0.0.1:8070/
</VirtualHost>
<VirtualHost *:80>
  ProxyPreserveHost On
  ProxyRequests Off
  ServerAlias *.71.$DOMAIN
  ProxyPass / http://127.0.0.1:8071/
  ProxyPassReverse / http://127.0.0.1:8071/
</VirtualHost>
<VirtualHost *:80>
  ProxyPreserveHost On
  ProxyRequests Off
  ServerAlias *.72.$DOMAIN
  ProxyPass / http://127.0.0.1:8072/
  ProxyPassReverse / http://127.0.0.1:8072/
</VirtualHost>
<VirtualHost *:80>
  ProxyPreserveHost On
  ProxyRequests Off
  ServerAlias *.73.$DOMAIN
  ProxyPass / http://127.0.0.1:8073/
  ProxyPassReverse / http://127.0.0.1:8073/
</VirtualHost>
EOF
test_for_success $? allow

function ApacheInit() {
  info_box "Configure apache2-php$2 service"


  echo_start
      echo -n "Creating new apache service instance"
      sudo sh /usr/share/doc/apache2/examples/setup-instance php$2 > /dev/null 2>&1
  test_for_success $? allow

  echo_start
      echo -n "Ensure php versions not enabled for new instance"
      sudo a2dismod-php$2 php7.3 php7.2 php7.1 php7.0 > /dev/null 2>&1
  test_for_success $? allow

  echo_start
      echo -n "Enable PHP $1 for new instance"
      sudo a2enmod-php$2 php$1 > /dev/null 2>&1
  test_for_success $? allow

  echo_start
      echo -n "Create System V config"
      sudo update-rc.d apache2-php$2 defaults > /dev/null 2>&1
  test_for_success $? allow

  echo_start
      echo -n "Enable vhost_alias for wildcard handling"
      sudo a2enmod-php$2 vhost_alias > /dev/null 2>&1
  test_for_success $? allow

  echo_start
      echo -n "Build directory stucture"
      sudo mkdir -p /var/www/php$2/test > /dev/null 2>&1
  test_for_success $? allow

  echo_start
      echo -n "Create phpinfo test page"
      sudo bash -c "echo '<?php echo phpinfo(); ?>' > /var/www/php$2/test/index.php" > /dev/null 2>&1
  test_for_success $? allow

  echo_start
      echo -n "Update new instance ports"
      sudo sed -i "s/.*Listen 80.*/Listen 80$2/" /etc/apache2-php$2/ports.conf > /dev/null 2>&1
      sudo sed -i "s/.*Listen 443.*/Listen 40$2/" /etc/apache2-php$2/ports.conf > /dev/null 2>&1
  test_for_success $? allow

  echo_start
      echo -n "Writing wildcard.$2.$DOMAIN.conf Config"
      sudo touch /etc/apache2-php$2/sites-available/wildcard.$2.$DOMAIN.conf > /dev/null 2>&1
cat <<EOF > /etc/apache2-php$2/sites-available/wildcard.$2.$DOMAIN.conf
<VirtualHost *:80$2>
        ServerAlias *.$2.$DOMAIN

        ServerAdmin deac@sfp.net
        VirtualDocumentRoot /var/www/php$2/%1/

        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF
  test_for_success $? allow

  echo_start
      echo -n "Remove transposed proxy config file"
      sudo rm /etc/apache2-php$2/sites-available/proxy.conf > /dev/null 2>&1
  test_for_success $? allow
}

function StartApache(){
  echo_start
    echo -n "Enable $1 configuration"
    sudo a2ensite$2 $1 > /dev/null 2>&1
  test_for_success $? allow

  echo_start
      echo -n "Starting apache2$2 Instance"
      sudo service apache2$2 start > /dev/null 2>&1
  test_for_success $? allow
}

ApacheInit 5.6 56
ApacheInit 7.0 70
ApacheInit 7.1 71
ApacheInit 7.2 72
ApacheInit 7.3 73

info_box "Starting Apache Instances"
StartApache proxy.conf
StartApache wildcard.56.$DOMAIN.conf -php56
StartApache wildcard.70.$DOMAIN.conf -php70
StartApache wildcard.71.$DOMAIN.conf -php71
StartApache wildcard.72.$DOMAIN.conf -php72
StartApache wildcard.73.$DOMAIN.conf -php73
