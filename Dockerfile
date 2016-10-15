FROM php:7.0-apache
MAINTAINER Alan Kent <alan.james.kent@gmail.com>


########### Apache and PHP Setup ########### 

# Get a good version of PHP with extensions installed,
# Add some more useful utlities,
# Enable Apache rewrite module.

RUN apt-get update \
 && apt-get install -y libfreetype6-dev libicu-dev libjpeg62-turbo-dev libmcrypt-dev libpng12-dev libxslt1-dev \
 && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
 && docker-php-ext-install gd intl mbstring mcrypt pdo_mysql xsl zip \
 && apt-get update \
 && apt-get install -y vim git curl net-tools telnet sudo cron \
 && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
 && a2enmod rewrite \
 && echo "memory_limit = 2048M" > /usr/local/etc/php/php.ini

# Environment variables from /etc/apache2/apache2.conf
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_RUN_DIR /var/run/apache2
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2/apache2.pid


########### SSHD ########### 

# Enable sftp
RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get -y install openssh-server \
 && rm -rf /var/lib/apt/lists/* \
 && mkdir -p /var/run/sshd
EXPOSE 22


########### NodeJS ########### 

# Install NodeJS (after curl is installed above).
RUN curl -sL https://deb.nodesource.com/setup_4.x | bash - \
 && apt-get update \
 && apt-get install -y nodejs


########### Java ########### 

RUN apt-get update \
 && apt-get install -y default-jre


########### MySQL Setup ########### 

env MYSQL_ROOT_PASSWORD=magento2
env MYSQL_DATABASE=magento2
env MYSQL_USER=magento2
env MYSQL_PASSWORD=magento2
env MYSQL_ALLOW_EMPTY_PASSWORD=yes

ADD mysql-install.sh /usr/local/bin
RUN chmod +x /usr/local/bin/mysql-install.sh
RUN /usr/local/bin/mysql-install.sh

# Create the 'magento2' database
ADD mysql-init.sh /usr/local/bin
RUN chmod +x /usr/local/bin/mysql-init.sh
RUN /usr/local/bin/mysql-init.sh mysqld

#EXPOSE 3306

